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
