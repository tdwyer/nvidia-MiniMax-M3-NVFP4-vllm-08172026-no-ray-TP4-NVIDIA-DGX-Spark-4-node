# Nvidia DGX Spark 4 node --tp 4 cluster

* nvidia/MiniMax-M3-NFVP4
  * Use: `f402882943835147f4e4738f8b1534fdf703f902` which has the thinking tag fix.
  * It's pinned in the boot_scripts so it should just download that one.
* nvidia/MiniMax-M3-DSpark
* NO patches NO mod's needed
* CUDA Graphs
* Locally built vLLM Docker 08-17-2026 `commit 4ab5e5012a27e2b751c679873f231bafa0f6b098`
* No Ray
* --kv-cache-dtype fp8
* 30GB of KV cache `1,073,627` tokens which still leaves room for the 1M context `1,048,576`
* I'm using 100GB switch MikroTik CRS504-4XQ-IN which likely makes it slower for small context but same at large due to memory speed.
    - Use a faster switch or [nccl-mesh-plugin]( https://github.com/autoscriptlabs/nccl-mesh-plugin)
* Without DSpark:  Real world single stream ~60,000 token context about 29 tok/s and >100,000 22 tok/s and >200,000 token context about 19 tok/s the PP is always fast > 2,000 tok/s
  * WITH DSpark: Get's really good bench. Real World is a question mark? I've found with any speculative decoder used it kind of makes the tok/s go all over the place. Sometimes I see 50 tok/s other times it's 15 tok/s So, I'm not really sure yet if it it actually better or worse yet.

# Built Docker image with fastokens

`docker pull dockerstudio123/vllm-4ab5e501-fastokens`

## With DSpark

However, this is a benchmark with a very small context. Real world seems worse with DSpark enabled

```
saib-llm --backend openai-compatible --base-url http://192.168.10.223:8000 --model minimax-m3 --concurrency 1 --repetitions 1

+------+-------------------+-------------------+------------+-------------+-----------+-------+---------+------+------+-----------+--------+                                                                
| #RUN |      Backend      |      Engine       |   Model    | Accelerator | Precision | Quant | Weights | Ctx  | Conc | Gen tok/s | TTFT s |                                                                
+------+-------------------+-------------------+------------+-------------+-----------+-------+---------+------+------+-----------+--------+                                                                
|  0   | openai-compatible | openai-compatible | minimax-m3 |   unknown   |           | none  |         | 2048 |  1   |   42.68   | 0.466  |                                                                
+------+-------------------+-------------------+------------+-------------+-----------+-------+---------+------+------+-----------+--------+ 

```

### Here is what MiniMax M3 thinks about it and it matches what I see...

For MiniMax-M3-NVFP4 on DGX Spark TP4, the rule of thumb:

```
┌────────────────┬────────────────────────────────────────────────────────────────────────────────────┐
│ Context length │ DSpark recommendation                                                              │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┤
│ < 16K tokens   │ Use DSpark — high acceptance rate, attention is cheap, speculation wins            │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┤
│ 16K–80K tokens │ Test — depends on workload type (creative writing high acceptance,                 │
│                │ retrieval/reasoning low)                                                           │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┤
│ > 100K tokens  │ Probably disable — attention cost dominates, draft rarely helps                    │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┤
│ > 200K tokens  │ Definitely disable — your measurement confirms this                                │
└────────────────┴────────────────────────────────────────────────────────────────────────────────────┘
```

The reasoning: at long context, the marginal cost of the main-model verification step is too high
relative to what you save from the cheap draft model.

Why your setup has this sharp threshold

Your setup compounds the long-context speculative penalty:

1. MikroTik 100GbE switch — at 200K context, KV cache shards are 32 MB each (FP8 KV, 200K × 128 dim × 2
   layers in a sparse attention layer × 4 nodes). The TP4 allreduce for the verification step takes
   longer than the verification compute itself. Speculation adds another allreduce for the draft model
   outputs — at 200K context this is a non-trivial fraction of your step time.
2. No symmetric memory (your boot log: Device capability 12.1 not supported) — every TP collective goes
   through the slow NCCL-over-IB path. Speculation multiplies the collective count.
3. Sparse attention with topk_blocks=16 (your boot log) — the main model's attention is not full
   attention at long context, it's a sparse attention. But DSpark's draft model still does full
   attention at 200K. The draft cost grows with context while the main model's attention stays roughly
   constant. So the draft model becomes proportionally more expensive at long context, not less — the
   opposite of what speculation wants.

The last point is particularly important and not obvious: MiniMax M3's sparse attention at long context
means the main model gets cheaper, but DSpark (a separate draft model) doesn't use sparse attention, so
its relative cost goes up.

Recommendation for your setup

Disable DSpark by default, enable it conditionally:

- Keep --speculative-config for low-context workloads (anything < 60K)
- Add a wrapper script that toggles DSpark based on incoming context length
- Or accept the throughput variance and leave it off for the 200K+ use cases

If you want a single setting, leave DSpark off — your measurement at 200K+ is the workload that drives
long-context DGX Spark deployments (that's the whole point of the 128GB unified memory and 1M context
window). Short-context workloads are well-served by any inference server; the differentiation is on
long-context.


## Firmware and CUDA versions

```
# nvidia-smi

NVIDIA-SMI 580.173.02             Driver Version: 580.173.02     CUDA Version: 13.0

# ethtool -i enP2p1s0f0np0

driver: mlx5_core
version: 6.17.0-1029-nvidia
firmware-version: 28.45.4028 (NVD0000000087)
```
