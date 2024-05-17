# Use Ubuntu 18.04 as the base image
FROM ubuntu:18.04

# Set the maintainer label
LABEL maintainer="your_email@example.com"

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Update the package repository
RUN apt update && apt-get update

# Install GStreamer and related packages
RUN apt-get install -y \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio

# Install basic utilities
RUN apt-get install -y software-properties-common \
    && apt-get install -y sudo \
    && apt install -y vim

# Add PPA for nnstreamer and toolchain
RUN apt-add-repository ppa:nnstreamer \
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt update \
    && apt --fix-broken install

# Install nnstreamer
RUN apt install -y nnstreamer

# Set the working directory
WORKDIR /usr/src/app

# Copy local files to the container
COPY . .

# Set the default command
CMD ["bash"]
