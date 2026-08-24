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
* Real world single stream ~60,000 token context about 35 tok/s and larger than 200,000 token context guessing 27 tok/s PP > 3,000 tok/s

NOTE: More Info and Docker Hub link within 24hrs

# Built Docker image with fastokens

`docker pull dockerstudio123/vllm-4ab5e501-fastokens`
`

## With DSpark

```
saib-llm --backend openai-compatible --base-url http://192.168.10.223:8000 --model minimax-m3 --concurrency 1 --repetitions 1

+------+-------------------+-------------------+------------+-------------+-----------+-------+---------+------+------+-----------+--------+                                                                
| #RUN |      Backend      |      Engine       |   Model    | Accelerator | Precision | Quant | Weights | Ctx  | Conc | Gen tok/s | TTFT s |                                                                
+------+-------------------+-------------------+------------+-------------+-----------+-------+---------+------+------+-----------+--------+                                                                
|  0   | openai-compatible | openai-compatible | minimax-m3 |   unknown   |           | none  |         | 2048 |  1   |   42.68   | 0.466  |                                                                
+------+-------------------+-------------------+------------+-------------+-----------+-------+---------+------+------+-----------+--------+ 
```
