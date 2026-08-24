echo "start spark2"
ssh spark2 "~/nvidia-MiniMax-M3-NVFP4-vllm-08172026-no-ray-TP4-NVIDIA-DGX-Spark-4-node/boot_scripts/rank1.sh"
echo "start spark3"
ssh spark3 "~/nvidia-MiniMax-M3-NVFP4-vllm-08172026-no-ray-TP4-NVIDIA-DGX-Spark-4-node/boot_scripts/rank2.sh"
echo "start spark4"
ssh spark4 "~/nvidia-MiniMax-M3-NVFP4-vllm-08172026-no-ray-TP4-NVIDIA-DGX-Spark-4-node/boot_scripts/rank3.sh"

echo "start spark1"
~/nvidia-MiniMax-M3-NVFP4-vllm-08172026-no-ray-TP4-NVIDIA-DGX-Spark-4-node/boot_scripts/rank0.sh
