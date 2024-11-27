# How to compile nnstreamer with pytorch on x86

## Before running experiment on x86, fix the cpu frequency 

https://stackoverflow.com/questions/64701751/can-i-fix-my-gpu-clock-rate-to-ensure-consistent-profiling-results   



```
# check GPU frequency  
nvidia-smi -q -d CLOCK  

# For GPU 0  
sudo nvidia-smi -i 0 -lgc 1400,1400  
```

## 1.  run docker and install the required package

```

sudo docker run -it --rm -v /home/liuh0f:/home/liuh0f  --cap-add=NET_RAW --cap-add=NET_ADMIN --gpus all --shm-size=50g --network host nvcr.io/nvidia/pytorch:22.02-py3

apt update && apt-get update
apt-get install sudo -y && apt install vim

sudo apt-get install ninja-build meson

sudo apt-get install libglib2.0
sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt install -y gstreamer1.0-tools

sudo apt-get install gstreamer1.0-plugins-base  gstreamer1.0-plugins-good

sudo apt-get install libglib2.0-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libjson-glib-dev
```

Then link the gi to conda/python

```
ln -s /usr/lib/python3/dist-packages/gi /opt/conda/lib/python3.8/site-packages/
```



## 2. edit the path and add pytorch.pc

```
export LD_LIBRARY_PATH=/opt/conda/lib/python3.8/site-packages/torch/lib:$LD_LIBRARY_PATH
```

```
vim /usr/lib/pkgconfig/pytorch.pc
ln -s /usr/lib/pkgconfig/pytorch.pc /usr/lib/x86_64-linux-gnu/pkgconfig/pytorch.pc
vim /usr/lib/x86_64-linux-gnu/pkgconfig/pytorch.pc
```

pytorch.pc

```
prefix=/opt/conda/lib/python3.8/site-packages/torch
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include
sharedlibdir=${prefix}/share

Name: PyTorch
Description: Tensors and Dynamic neural networks in Python with strong GPU acceleration
Version: 1.11.0
Libs: -L${libdir} -L${sharedlibdir} -ltorch -ltorch_cpu -lc10 -ltorch_cuda
Cflags: -I${includedir} -I${includedir}/torch/csrc/api/include
```


```
vim /usr/lib/pkgconfig/python3.pc

prefix=/opt/conda
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: Python
Description: Python language interpreter
Version: 3.8
Requires:
Libs: -L${libdir} -lpython3.8
Cflags: -I${includedir}/python3.8

```


## 3. modify meson.build

```
git clone https://github.com/liuhao-97/nnstreamer.git
cd nnstreamer
```

```
project('nnstreamer', 'c', 'cpp',
  version: '2.4.1',
  license: ['LGPL-2.1'],
  meson_version: '>=0.50.0',
  default_options: [
    'werror=false',
    'warning_level=2',
    'c_std=gnu89',
    'cpp_std=c++17',
  ]
)


# Retrieve PyTorch include and lib directories using Python
pytorch_include_dir = '/opt/conda/lib/python3.8/site-packages/torch/include'
pytorch_lib_dir = '/opt/conda/lib/python3.8/site-packages/torch/lib'

# Add PyTorch include directories
include_directories(pytorch_include_dir,'/opt/conda/lib/python3.8/site-packages/torch/include/torch/csrc/api/include')

# Add PyTorch library directory and libraries
add_project_link_arguments('-L' + pytorch_lib_dir, '-ltorch',  '-lc10', language: 'cpp')

# Adding new linker flags specifically for C++ linking
add_project_link_arguments(['-Wl,--no-as-needed', '-ltorch_cuda'], language: 'cpp')
```


<del>## 4.  modify nnstreamer_python3_helper.cc

<del>

```
vim nnstreamer/ext/nnstreamer/extra/nnstreamer_python3_helper.cc

# comment line 587
# https://github.com/nnstreamer/nnstreamer/issues/4523
// assert (Py_IsInitialized ());
```
</del>

## 5.  use meson to build and update plugin path

```
# how to build nnstreamer
# https://nnstreamer.github.io/getting-started-meson-build.html

cd nnstreamer

# meson build
meson build -Dpytorch-support=enabled -Denable-pytorch-use-gpu=true
ninja -C build
sudo ninja -C build install
build/tools/development/confchk/nnstreamer-check

export LD_LIBRARY_PATH=/opt/conda/lib/python3.8/site-packages/torch/lib:$LD_LIBRARY_PATH

export GST_PLUGIN_PATH=/usr/local/lib/x86_64-linux-gnu/gstreamer-1.0
export LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

gst-inspect-1.0 nnstreamer
rm ~/.cache/gstreamer-1.0/*
```

## 6. check if libnnstreamer_filter_pytorch.so link to libtorch_cuda.so

do some link

```
ldd /usr/local/lib/x86_64-linux-gnu/gstreamer-1.0/libnnstreamer.so
cp /usr/local/lib/x86_64-linux-gnu/libnnstreamer-single.so /lib/x86_64-linux-gnu/
ln -s /usr/lib/python3/dist-packages/gi /opt/conda/lib/python3.8/site-packages/
```



```
root@agxorin1:~/lh/nns/nnstreamer# ldd /usr/local/lib/aarch64-linux-gnu/nnstreamer/filters/libnnstreamer_filter_pytorch.so
        linux-vdso.so.1 (0x0000ffff82ffa000)
        libc10.so => /usr/local/lib/python3.8/dist-packages/torch/lib/libc10.so (0x0000ffff82edf000)
        libtorch_cuda.so => /usr/local/lib/python3.8/dist-packages/torch/lib/libtorch_cuda.so (0x0000ffff780a9000)
        libnnstreamer-single.so => /usr/local/lib/aarch64-linux-gnu/libnnstreamer-single.so (0x0000ffff7807a000)
        libtorch.so => /usr/local/lib/python3.8/dist-packages/torch/lib/libtorch.so (0x0000ffff78068000)
        libtorch_cpu.so => /usr/local/lib/python3.8/dist-packages/torch/lib/libtorch_cpu.so (0x0000ffff734be000)
        libglib-2.0.so.0 => /usr/lib/aarch64-linux-gnu/libglib-2.0.so.0 (0x0000ffff73367000)
        libgmodule-2.0.so.0 => /usr/lib/aarch64-linux-gnu/libgmodule-2.0.so.0 (0x0000ffff73353000)
        libgobject-2.0.so.0 => /usr/lib/aarch64-linux-gnu/libgobject-2.0.so.0 (0x0000ffff732e1000)
        libstdc++.so.6 => /usr/lib/aarch64-linux-gnu/libstdc++.so.6 (0x0000ffff730fc000)
        libm.so.6 => /usr/lib/aarch64-linux-gnu/libm.so.6 (0x0000ffff73051000)
        libgcc_s.so.1 => /usr/lib/aarch64-linux-gnu/libgcc_s.so.1 (0x0000ffff7302d000)
        libpthread.so.0 => /usr/lib/aarch64-linux-gnu/libpthread.so.0 (0x0000ffff72ffc000)
        libc.so.6 => /usr/lib/aarch64-linux-gnu/libc.so.6 (0x0000ffff72e89000)
        /lib/ld-linux-aarch64.so.1 (0x0000ffff82fca000)
        libnuma.so.1 => /usr/lib/aarch64-linux-gnu/libnuma.so.1 (0x0000ffff72e6a000)
        libgomp.so.1 => /usr/lib/aarch64-linux-gnu/libgomp.so.1 (0x0000ffff72e1c000)
        libc10_cuda.so => /usr/local/lib/python3.8/dist-packages/torch/lib/libc10_cuda.so (0x0000ffff72dbc000)
        libcudart.so.11.0 => /usr/local/cuda/lib64/libcudart.so.11.0 (0x0000ffff72d07000)
        libcusparse.so.11 => /usr/local/cuda/lib64/libcusparse.so.11 (0x0000ffff65102000)
        libcurand.so.10 => /usr/local/cuda/lib64/libcurand.so.10 (0x0000ffff6008c000)
        libcusolver.so.11 => /usr/local/cuda/lib64/libcusolver.so.11 (0x0000ffff53008000)
        libnvToolsExt.so.1 => /usr/local/cuda/lib64/libnvToolsExt.so.1 (0x0000ffff52fed000)
        libmpi_cxx.so.40 => /usr/lib/aarch64-linux-gnu/libmpi_cxx.so.40 (0x0000ffff52fc2000)
        libmpi.so.40 => /usr/lib/aarch64-linux-gnu/libmpi.so.40 (0x0000ffff52e96000)
        libdl.so.2 => /usr/lib/aarch64-linux-gnu/libdl.so.2 (0x0000ffff52e82000)
        librt.so.1 => /usr/lib/aarch64-linux-gnu/librt.so.1 (0x0000ffff52e6a000)
        libcufft.so.10 => /usr/local/cuda/lib64/libcufft.so.10 (0x0000ffff47f99000)
        libcublas.so.11 => /usr/local/cuda/lib64/libcublas.so.11 (0x0000ffff3df47000)
        libcudnn.so.8 => /usr/lib/aarch64-linux-gnu/libcudnn.so.8 (0x0000ffff3df11000)
        libopenblas.so.0 => /usr/lib/aarch64-linux-gnu/libopenblas.so.0 (0x0000ffff3d079000)
        libpcre.so.3 => /usr/lib/aarch64-linux-gnu/libpcre.so.3 (0x0000ffff3d007000)
        libffi.so.7 => /usr/lib/aarch64-linux-gnu/libffi.so.7 (0x0000ffff3cfee000)
        libcublasLt.so.11 => /usr/local/cuda/lib64/libcublasLt.so.11 (0x0000ffff25c90000)
        libopen-rte.so.40 => /usr/lib/aarch64-linux-gnu/libopen-rte.so.40 (0x0000ffff25bc5000)
        libopen-pal.so.40 => /usr/lib/aarch64-linux-gnu/libopen-pal.so.40 (0x0000ffff25b0c000)
        libhwloc.so.15 => /usr/lib/aarch64-linux-gnu/libhwloc.so.15 (0x0000ffff25ab3000)
        libgfortran.so.5 => /usr/lib/aarch64-linux-gnu/libgfortran.so.5 (0x0000ffff25938000)
        libz.so.1 => /usr/lib/aarch64-linux-gnu/libz.so.1 (0x0000ffff2590e000)
        libevent-2.1.so.7 => /usr/lib/aarch64-linux-gnu/libevent-2.1.so.7 (0x0000ffff258a8000)
        libutil.so.1 => /usr/lib/aarch64-linux-gnu/libutil.so.1 (0x0000ffff25894000)
        libevent_pthreads-2.1.so.7 => /usr/lib/aarch64-linux-gnu/libevent_pthreads-2.1.so.7 (0x0000ffff25881000)
        libudev.so.1 => /usr/lib/aarch64-linux-gnu/libudev.so.1 (0x0000ffff25847000)
        libltdl.so.7 => /usr/lib/aarch64-linux-gnu/libltdl.so.7 (0x0000ffff2582d000)
```



# After docker commit, how to resume

How to docker commit:
```
docker ps
docker commit c418a80ffb43 nns
```

To resume the docker
```

sudo docker run -it --rm -v /home/liuh0f:/home/liuh0f  --cap-add=NET_RAW --cap-add=NET_ADMIN --gpus all --shm-size=50g --network host nns


export LD_LIBRARY_PATH=/opt/conda/lib/python3.8/site-packages/torch/lib:$LD_LIBRARY_PATH
export GST_PLUGIN_PATH=/usr/local/lib/x86_64-linux-gnu/gstreamer-1.0
export LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
```


# Install custom plugin  

https://github.com/liuhao-97/deepstream_nnstreamer/tree/main/subplugin  

Install datareschedule on Jetson  
https://github.com/liuhao-97/deepstream_nnstreamer/tree/main/subplugin/subplugin_c/datareschedule  


Install splitaddhead.py fastrawdatagenerator.py on Jetson and host machine  
https://github.com/liuhao-97/deepstream_nnstreamer/tree/main/subplugin/subplugin_py  


## P.S.
```
# if gst-inspect-1.0 nnstreamer shows the error
# (gst-plugin-scanner:6257): GStreamer-WARNING **: 12:47:20.097: Failed to load plugin '/sr/lib/gstreamer-1.0/libnnstreamer.so':
# libnnstreamer-single.so: cannot open shared object file: No such file or directory

# check soft link 
ldd /usr/local/lib/aarch64-linux-gnu/gstreamer-1.0/libnnstreamer.so
```


## Reference
1. https://github.com/nnstreamer/nnstreamer/issues/4523
2. https://nnstreamer.github.io/getting-started-meson-build.html