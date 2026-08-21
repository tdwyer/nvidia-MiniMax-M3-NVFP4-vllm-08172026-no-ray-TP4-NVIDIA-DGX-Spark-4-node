# Nvidia DGX Spark 4 node --tp 4 cluster

* nvidia/MiniMax-M3-NFVP4
* NO patches NO mod's needed
* CUDA Graphs
* Locally built vLLM Docker 08-17-2026 `commit 4ab5e5012a27e2b751c679873f231bafa0f6b098`
* No Ray
* --kv-cache-dtype fp8
* GPU KV cache size: 1,433,587 tokens, Maximum concurrency for 512,288 tokens per request: 2.80x
* MikroTik CRS504-4XQ-IN
    - Switch bottleneck -lt 65K context RAM speed bottleneck -gt 100k context
    - Use a faster switch or [nccl-mesh-plugin]( https://github.com/autoscriptlabs/nccl-mesh-plugin)
* Real world single stream ~60,000 token context = 28 tok/s > 120,000 token context 22 tok/s PP > 3,000 tok/s

NOTE: More Info and Docker Hub link within 24hrs
