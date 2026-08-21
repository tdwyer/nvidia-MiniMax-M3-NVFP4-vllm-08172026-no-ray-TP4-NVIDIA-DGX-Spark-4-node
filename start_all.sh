echo "start spark2"
ssh spark2 "~/minimax-m3-vllm-new/boot_scripts/rank1.sh"
echo "start spark3"
ssh spark3 "~/minimax-m3-vllm-new/boot_scripts/rank2.sh"
echo "start spark4"
ssh spark4 "~/minimax-m3-vllm-new/boot_scripts/rank3.sh"

echo "start spark1"
~/minimax-m3-vllm-new/boot_scripts/rank0.sh
