#  -e VLLM_FLOAT32_MATMUL_PRECISION=high \
#  -e VLLM_FLASHINFER_ALLREDUCE_BACKEND=trtllm \
#
# --kv-cache-memory=35469134418 (33.03 GiB)
# --kv-cache-memory=48318382080 (45 GiB)
# --kv-cache-memory=46170898432 (43 GiB)
#     GPU KV cache size: 1,541,087 tokens,
#     Maximum concurrency for 512,288 tokens per request: 3.01x
#
#     44023414784
# --kv-cache-memory=42949672960 (40 GiB) 40 x 1024 x 1024 x 1024
#
# actually use --kv-cache-memory-bytes
# 
# This timeout line is tottaly unnessiary
#
# Yes—**if the 2 minutes is the total time to process the entire 500,000-token
# prefill across many engine steps**, it should not hit
# `VLLM_EXECUTE_MODEL_TIMEOUT_SECONDS`.
#
# With a token budget of roughly 8,192 tokens per iteration:
#
# \[
# \frac{500{,}000}{8{,}192} \approx 61
# \]
#
# So vLLM would typically process the prompt over roughly 61 scheduled prefill
# iterations, subject to chunked-prefill and scheduler settings. The timeout
# applies independently to each `execute_model` call, not to the aggregate
# 2-minute prefill.
#
# It would time out only if **one individual iteration**—for example, one
# 8,192-token chunk plus its associated model computation and
# communication—takes longer than the configured timeout.
#
# The block size of 128 mainly affects KV-cache memory allocation and paging. It
# does not mean the timeout is applied per 128-token block. Also, confirm that
# `8192` is your token budget, such as `max_num_batched_tokens`; vLLM’s “batch
# size” can sometimes refer to number of sequences rather than number of tokens.
#
# One caveat: if your configuration schedules the entire 500,000-token prefill
# in a single `execute_model` call rather than chunking it, then the whole call
# would need to finish within the timeout. With normal chunked-prefill
# scheduling, however, it is divided into multiple calls.
#-e VLLM_EXECUTE_MODEL_TIMEOUT_SECONDS=600 \
#
# Removed the ulimit because meh? I don't thik I need that.
# --ulimit stack=67108864 \

