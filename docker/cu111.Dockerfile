#FROM nvidia/cuda:11.6.2-devel-ubuntu20.04
FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04

# Set environment variables
ENV NVENCODE_CFLAGS "-I/usr/local/cuda/include"
ENV CV_VERSION=4.2.0
ENV DEBIAN_FRONTEND=noninteractive

# Get all dependencies
RUN apt-get update && apt-get install -y \
    git zip unzip libssl-dev libcairo2-dev lsb-release libgoogle-glog-dev libgflags-dev libatlas-base-dev libeigen3-dev software-properties-common \
    build-essential cmake pkg-config libapr1-dev autoconf automake libtool curl libc6 libboost-all-dev debconf libomp5 libstdc++6 \
    libqt5core5a libqt5xml5 libqt5gui5 libqt5widgets5 libqt5concurrent5 libqt5opengl5 libcap2 libusb-1.0-0 libatk-adaptor neovim \
    python3-pip python3-tornado python3-dev python3-numpy python3-virtualenv libpcl-dev libgoogle-glog-dev libgflags-dev libatlas-base-dev \
    libsuitesparse-dev python3-pcl pcl-tools libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev libtbb2 libtbb-dev libjpeg-dev \
    libpng-dev libtiff-dev libdc1394-22-dev xfce4-terminal &&\
    rm -rf /var/lib/apt/lists/*

# PyTorch for CUDA 11.6
# RUN pip3 install torch==1.13.1+cu116 torchvision==0.14.1+cu116 torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cu116
RUN pip3 install torch==1.9.1+cu111 torchvision==0.10.1+cu111 torchaudio==0.9.1 -f https://download.pytorch.org/whl/torch_stable.html
ENV TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX"
    
# OpenPCDet
RUN pip3 install --upgrade pip
RUN pip3 install numpy==1.23.0 llvmlite numba tensorboardX easydict pyyaml scikit-image tqdm SharedArray 
RUN pip3 install --ignore-installed  blinker==1.6.3
RUN pip3 install open3d mayavi av2 kornia==0.6.12 pyquaternion opencv-python
RUN pip3 install spconv-cu111

RUN git clone https://github.com/open-mmlab/OpenPCDet.git

WORKDIR OpenPCDet

RUN python3 setup.py develop
    
WORKDIR /

ENV NVIDIA_VISIBLE_DEVICES="all" \
    OpenCV_DIR=/usr/share/OpenCV \
    NVIDIA_DRIVER_CAPABILITIES="video,compute,utility,graphics" \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib:/usr/lib:/usr/local/lib \
    QT_GRAPHICSSYSTEM="native"

# Build instructions: docker build -f minimal.Dockerfile -t openpcdet:cuda11 .
# Start instructions: xhost local:root && docker run -it --rm -e SDL_VIDEODRIVER=x11 -e DISPLAY=$DISPLAY --env='DISPLAY' --gpus all --ipc host --privileged --network host -p 8080:8081 -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v file_locations:/storage -v /weights:/weights openpcdet:cuda11 xfce4-terminal --title=openPCDet
