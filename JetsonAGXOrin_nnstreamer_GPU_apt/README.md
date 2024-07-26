# How to apt install nnstreamer and nnstreamer-pytorch

```
sudo docker run -it --rm --net=host --gpus all -e DISPLAY=$DISPLAY --device /dev/snd -v /tmp/.X11-unix/:/tmp/.X11-unix -v /run/jtop.sock:/run/jtop.sock    -v /home/agxorin1/lh:/home/lh --runtime nvidia nvcr.io/nvidia/l4t-pytorch:r35.2.1-pth2.0-py3

sudo docker run -it --rm --net=host --gpus all -e DISPLAY=$DISPLAY --device /dev/snd -v /tmp/.X11-unix/:/tmp/.X11-unix -v /run/jtop.sock:/run/jtop.sock    -v /home/agxorin1/lh:/root/lh --runtime nvidia  nvcr.io/nvidia/l4t-pytorch:r35.1.0-pth1.11-py3

# apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

apt update && apt-get update
apt-get install sudo -y && apt install vim

sudo apt-get install libglib2.0
sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev

apt-get install software-properties-common
sudo apt-add-repository ppa:nnstreamer


### fix nnstreamer-core 
### https://bitcoin.stackexchange.com/questions/98872/depends-libgcc-s1-3-0-but-it-is-not-installable-bitcoind-wallet-dependency
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt --fix-broken install

sudo apt install nnstreamer
sudo apt --fix-broken install nnstreamer-pytorch
```

## Reference
1. http://ppa.launchpad.net/nnstreamer/ppa/ubuntu/pool/main/n/nnstreamer/
