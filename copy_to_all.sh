docker stop m3_tp4
docker rm m3_tp4
for i in spark2 spark3 spark4 ;do ssh $i "docker stop m3_tp4" ; ssh $i "docker rm m3_tp4" ; ssh $i "rm -rf nvidia-MiniMax-M3-NVFP4-vllm-08172026-no-ray-TP4-NVIDIA-DGX-Spark-4-node" ; scp -r ~/nvidia-MiniMax-M3-NVFP4-vllm-08172026-no-ray-TP4-NVIDIA-DGX-Spark-4-node ${i}: ;done
