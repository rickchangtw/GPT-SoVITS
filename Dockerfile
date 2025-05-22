# Base CUDA image
FROM cnstark/pytorch:2.0.1-py3.9.17-cuda11.8.0-ubuntu20.04
# FROM nvidia/cuda:12.9.0-devel-ubuntu22.04 AS base
# FROM ${IMAGE_NAME}:12.9.0-devel-ubuntu20.04 AS base
# FROM nvidia/cuda:12.9.0-devel-ubuntu22.04 AS base

# FROM base AS base-amd64
# FROM base-${TARGETARCH}

# LABEL maintainer="breakstring@hotmail.com"
LABEL version="dev-20240209"
LABEL description="Docker image for GPT-SoVITS"
LABEL maintainer="NVIDIA CORPORATION <cudatools@nvidia.com>"
LABEL com.nvidia.cudnn.version="${NV_CUDNN_VERSION}"

# Install 3rd party apps
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei

ENV NV_CUDNN_VERSION=9.9.0.52-1
ENV NV_CUDNN_PACKAGE_NAME=libcudnn9-cuda-12
ENV NV_CUDNN_PACKAGE=libcudnn9-cuda-12=${NV_CUDNN_VERSION}
ENV NV_CUDNN_PACKAGE_DEV=libcudnn9-dev-cuda-12=${NV_CUDNN_VERSION}


# RUN apt-get update && apt-get install -y --no-install-recommends \
#     ${NV_CUDNN_PACKAGE} \
#     ${NV_CUDNN_PACKAGE_DEV} \
#     && apt-mark hold ${NV_CUDNN_PACKAGE_NAME}
#     # && rm -rf /var/lib/apt/lists/*


RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip tzdata ffmpeg libsox-dev parallel aria2 git git-lfs && \
    git lfs install && \
    rm -rf /var/lib/apt/lists/*

# Copy only requirements.txt initially to leverage Docker cache
WORKDIR /workspace
COPY requirements.txt /workspace/
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Define a build-time argument for image type
ARG IMAGE_TYPE=full
# ARG TARGETARCH

# Conditional logic based on the IMAGE_TYPE argument
# Always copy the Docker directory, but only use it if IMAGE_TYPE is not "elite"
COPY ./Docker /workspace/Docker 
# elite 类型的镜像里面不包含额外的模型
RUN if [ "$IMAGE_TYPE" != "elite" ]; then \
        chmod +x /workspace/Docker/download.sh && \
        /workspace/Docker/download.sh && \
        python /workspace/Docker/download.py && \
        python -m nltk.downloader averaged_perceptron_tagger cmudict; \
    fi


# Copy the rest of the application
COPY . /workspace

EXPOSE 9871 9872 9873 9874 9880

CMD ["python", "webui.py"]
