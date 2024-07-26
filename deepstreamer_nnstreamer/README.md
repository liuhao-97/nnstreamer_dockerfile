# nnstreamer_dockerfile

nnstreamer docker build on Jetson AGX Orin

A prebuild docker image is here. https://drive.google.com/file/d/1t_Ce-Vw7Fy6ueqwmUx_sxw5wpPMlMa4q/view?usp=drive_link


If you want to build from scratch, use Docker_raw to build a simple image and then use the following command to install nnstreamer.

```
apt update
apt-get update
apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio
apt-get install software-properties-common
apt-get install sudo -y && apt install vim

sudo apt-add-repository ppa:nnstreamer

### fix nnstreamer-core 
### https://bitcoin.stackexchange.com/questions/98872/depends-libgcc-s1-3-0-but-it-is-not-installable-bitcoind-wallet-dependency
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt --fix-broken install

sudo apt install nnstreamer
```


# run docker with deepstream & NNstreamer
## First use docker built for deepstreamer
```
git clone https://github.com/NVIDIA-AI-IOT/deepstream_python_apps
git checkout nvaie-3.0
```

1. 
```
$ export DISPLAY=:1
$ xhost +

# 如果不是0
$ who 
#改成显示的display
```

2. 
```
sudo docker pull nvcr.io/nvidia/deepstream:6.3-triton-multiarch

sudo docker run -it --rm --net=host --gpus all -e DISPLAY=$DISPLAY --device /dev/snd -v /tmp/.X11-unix/:/tmp/.X11-unix -v /run/jtop.sock:/run/jtop.sock -v /home/ubuntu/lh:/opt/nvidia/deepstream/lh  -v /home/ubuntu/lh/deepstream_python_apps:/opt/nvidia/deepstream/deepstream-6.3/sources/deepstream_python_apps --runtime nvidia nvcr.io/nvidia/deepstream:6.3-triton-multiarch

```

3. 
```
apt update && apt install python3-gi python3-dev python3-gst-1.0 -y && apt-get install libgstrtspserver-1.0-0 gstreamer1.0-rtsp && apt-get install libgirepository1.0-dev && apt-get install gobject-introspection gir1.2-gst-rtsp-server-1.0

# to install ping in docker
apt-get install sudo -y && apt install vim && apt-get install iputils-ping

apt install python3-numpy python3-opencv -y

# pipeline dot
apt-get install graphviz
```

```
# no module for pyds
# https://github.com/NVIDIA-AI-IOT/deepstream_python_apps/releases
# install 
sudo wget https://github.com/NVIDIA-AI-IOT/deepstream_python_apps/releases/download/v1.1.8/pyds-1.1.8-py3-none-linux_aarch64.whl

# 编译pycairo报错
# https://stackoverflow.com/questions/70508775/error-could-not-build-wheels-for-pycairo-which-is-required-to-install-pyprojec
apt install libcairo2-dev pkg-config 

pip3 install ./pyds-1.1.8-py3-none*.whl
```

4. 

run demo deepstream-test1
```
cd /opt/nvidia/deepstream/deepstream-6.3/sources/deepstream_python_apps/apps/deepstream-test1
python3 deepstream_test_1.py /opt/nvidia/deepstream/deepstream-6.3/samples/streams/sample_720p.h264
```
run demo deepstream-test1-rtsp-out
```
python3 deepstream_test1_rtsp_out.py --input /opt/nvidia/deepstream/deepstream-6.3/samples/streams/sample_720p.h264
```

## Then install nnstreamer
```
apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

apt-get install software-properties-common
sudo apt-add-repository ppa:nnstreamer
sudo apt install nnstreamer
```
To test if NNstreamer is installed correctly
```
gst-inspect-1.0 nnstreamer
```


