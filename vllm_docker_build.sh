git clone https://github.com/vllm-project/vllm.git

cd vllm

docker build \
  -f docker/Dockerfile \
  --build-arg BUILD_OS=manylinux \
  --build-arg BUILD_BASE_IMAGE=pytorch/manylinuxaarch64-builder:cuda13.0 \
  --build-arg torch_cuda_arch_list="12.1a" \
  --tag vllm-custom-sm121:latest \
  .
