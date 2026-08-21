docker stop m3_tp4
docker rm m3_tp4
for i in spark2 spark3 spark4 ;do ssh $i "docker stop m3_tp4" ; ssh $i "docker rm m3_tp4" ; ssh $i "rm -rf minimax-m3-vllm-new" ; scp -r ~/minimax-m3-vllm-new ${i}: ;done
