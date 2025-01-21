ARG BASE_IMAGE=nvcr.io/nvidia/l4t-base:r36.2.0
FROM ${BASE_IMAGE}

ARG OPENCV_VERSION=4.5.4
ENV OPENCV_VERSION=${OPENCV_VERSION}

ENV AUTOWARE_VESION=2310

ENV AUTOWARE_REPOS=autoware_${AUTOWARE_VESION}
ENV ROS_DOMAIN_ID=55
ENV ROS_DISTRO=humble
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}
ENV AUTOWARE_ROOT=/autoware
ENV ROS_PYTHON_VERSION=3

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL /bin/bash
SHELL ["/bin/bash", "-c"] 

WORKDIR /tmp

#========================================================================================
## Pre Setting
#========================================================================================

# change POSIX to UTF (for ros2 install)
RUN locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# set default python version 3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# install dependences tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    vim \
    curl \
    git \
    wget \
    gnupg2 \
    lsb-release \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

#========================================================================================
## NVIDIA CUDA lib
#========================================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    nvidia-cuda-dev \
    nvidia-cudnn8-dev \
    nvidia-tensorrt-dev \
    cuda-toolkit-* \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
   
# add cuda PATH in bashrc  
RUN echo '' >> ~/.bashrc && echo "## >> CUDA SETTING >> " >> ~/.bashrc
RUN echo 'export PATH=/usr/local/cuda-12.2/bin${PATH:+:${PATH}}' >> ~/.bashrc
RUN echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.2/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc


#========================================================================================
## Opencv
#========================================================================================

COPY docker/opencv_sh/install_opencv${OPENCV_VERSION}_Jetson.sh /tmp/install_opencv_Jetson.sh

RUN chmod +x /tmp/install_opencv_Jetson.sh
RUN /tmp/install_opencv_Jetson.sh

#========================================================================================
## ROS2 Humble
#========================================================================================
# install ros humble as source (reference : https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html)
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN add-apt-repository universe

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# install ros
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-desktop \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# install ros dev packages1
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-flake8-docstrings \
    python3-pip \
    python3-pytest-cov \
    ros-dev-tools \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
    
# install ros dev packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-flake8-blind-except \
    python3-flake8-builtins \
    python3-flake8-class-newline \
    python3-flake8-comprehensions \
    python3-flake8-deprecated \
    python3-flake8-import-order \
    python3-flake8-quotes \
    python3-pytest-repeat \
    python3-pytest-rerunfailures \
    && apt-get clean
    

# install ros RMW Implemnetation
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-rmw-cyclonedds-cpp \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# add ros PATH, DOMAIN_ID, RMW in bashrc
RUN echo '' >> ~/.bashrc && echo "## >> ROS SETTING >> " >> ~/.bashrc
RUN echo "source ${ROS_ROOT}/setup.bash" >> ~/.bashrc
RUN echo "export ROS_DOMAIN_ID=${ROS_DOMAIN_ID}" >> ~/.bashrc
RUN echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc
RUN echo "export CYCLONEDDS_URI=${AUTOWARE_ROOT}/.cyclonedds.xml" >> ~/.bashrc


#========================================================================================
## Autoware dependent libraries
#========================================================================================
RUN sh -c 'echo "deb [trusted=yes] https://s3.amazonaws.com/autonomoustuff-repo/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/autonomoustuff-public.list'

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    geographiclib-tools \
    golang \
    ros-${ROS_DISTRO}-pacmod3 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN pip3 install pre-commit clang-format==17.0.5 gdown

RUN geographiclib-get-geoids egm2008-1


#========================================================================================
## Autoware src build
#========================================================================================

#mkdir WS
# copy repos file from host
COPY autoware/src ${AUTOWARE_ROOT}/src

# Install Autoware requires some ROS 2 packages
RUN apt-get update && \
    cd ${AUTOWARE_ROOT} && \
    source /opt/ros/humble/setup.bash && \
    rosdep init && \ 
    rosdep update && \ 
    rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# build code
#RUN cd ${AUTOWARE_ROOT} && \
#    source ${ROS_ROOT}/setup.bash && \
#    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

CMD ["bash"]
WORKDIR ${AUTOWARE_ROOT}

