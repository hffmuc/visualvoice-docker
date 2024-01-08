# Use the image base-notebook to build our image on top of it
FROM python:3.7-slim-buster

# Change to root user
USER root

# Set Environment to ignore sudo warning for pip
ENV PIP_ROOT_USER_ACTION=ignore

# Copy data from current directory into the docker image
COPY . .

# Install basic dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    wget \
    software-properties-common \
    curl \
    libfreetype6-dev \
    libpng-dev \
    libzmq3-dev \
    pkg-config \
    rsync \
    unzip \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libopenblas-dev \
    liblapack-dev \
    git \
    nano \
    gnupg \
    gnupg2 \
    ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install NVIDIA CUDA, CUDNN, etc.

# Add NVIDIA package repositories
RUN curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/ /" > /etc/apt/sources.list.d/nvidia-ml.list

# Install CUDA Toolkit 10.0
ENV CUDA_VERSION 10.0.130-1
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-toolkit-10-0=$CUDA_VERSION && \
    apt-mark hold cuda-toolkit-10-0 && \
    rm -rf /var/lib/apt/lists/*

# Install CUDNN 7.4
ENV CUDNN_VERSION 7.4.2.24
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcudnn7=$CUDNN_VERSION-1+cuda10.0 && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*

# Install CUDNN 7.4 Dev
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcudnn7-dev=$CUDNN_VERSION-1+cuda10.0 && \
    apt-mark hold libcudnn7-dev && \
    rm -rf /var/lib/apt/lists/*

# Set CUDA Path
ENV PATH /usr/local/cuda-10.0/bin:${PATH}

# Install package requirements
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt

# Set the working directory in the container
WORKDIR /app

# Clone the VisualVoice repository
RUN git clone https://github.com/facebookresearch/VisualVoice.git /app/VisualVoice

# Download pre-trained models
WORKDIR /app/VisualVoice/models
RUN wget http://dl.fbaipublicfiles.com/VisualVoice/av-speech-separation-model/facial_best.pth && \
    wget http://dl.fbaipublicfiles.com/VisualVoice/av-speech-separation-model/lipreading_best.pth && \
    wget http://dl.fbaipublicfiles.com/VisualVoice/av-speech-separation-model/unet_best.pth && \
    wget http://dl.fbaipublicfiles.com/VisualVoice/av-speech-separation-model/vocal_best.pth && \
    wget http://dl.fbaipublicfiles.com/VisualVoice/cross-modal-pretraining/facial.pth && \
    wget http://dl.fbaipublicfiles.com/VisualVoice/cross-modal-pretraining/vocal.pth

# Change working directory to the root of the VisualVoice project
WORKDIR /app/VisualVoice

# Set the default command to run when the container starts
CMD ["bash"]
