#Based on the image of hyperkube, added nvidia lib path mapping into the image.
#Usage: docker build gcr.io/google_containers/hyperkube-amd64:v1.6.1-gpu .
FROM gcr.io/google_containers/hyperkube-amd64:v1.6.1-gpu 
MAINTAINER Jian Zhang <zjianbjz@cn.ibm.com>

ENV CUDA_VERSION 7.5
LABEL com.nvidia.cuda.version="7.5"

RUN echo "/usr/local/cuda/lib" >> /etc/ld.so.conf.d/cuda.conf && \
    echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
    echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf && \
    ldconfig

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

