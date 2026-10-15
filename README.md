# Kernel Patches
This repository contains scripts and patches for [lemonade/lemonadep kernel](https://github.com/Gamesmes90/android_kernel_oneplus_sm8350)

### Features
The compiled kernel will have the following features
- [BORE Scheduler](./patches/0001-BORE-scheduler.patch)
- [Droidspaces](./patches/0001-Droidspaces-support.patch)
- [BakaSU](https://github.com/Baka-SU/BakaSU) with [SUSFS Inline Hook](https://bakasu.org/guide/build#susfs)
- [Custom Defconfig](./patches/0001-defconfig.patch)


### Usage
Use [patch_kernel.sh](./patch_kernel.sh) to apply these patches
```
./patch_kernel.sh [Kernel Repo Path]
```

Compile the kernel using the [build repository](https://github.com/Gamesmes90/build_android_kernel_oneplus_sm8350)