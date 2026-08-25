#
# Note: I actually added the fastokens in a Dockerfile which built on top of the
# orig but I'm assuming this would work to.
#
echo 'RUN pip install --no-cache-dir fastokens' >> docker/Dockerfile
echo 'ENV VLLM_USE_FASTOKENS=1' >> docker/Dockerfile

# Boot to sleep loop and use script to start vllm with the image
echo 'ENTRYPOINT ["sleep", "infinity"]' >> docker/Dockerfile

docker build \
  -f docker/Dockerfile \
  --build-arg BUILD_OS=manylinux \
  --build-arg BUILD_BASE_IMAGE=pytorch/manylinuxaarch64-builder:cuda13.0 \
  --build-arg torch_cuda_arch_list="12.1a" \
  --build-arg max_jobs=4 \
  --build-arg nvcc_threads=1 \
  --tag vllm-485e15dc-pr50594:latest \
  .
