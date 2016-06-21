# CaliceInstall
# CMake package to install all calice sub-packages
Copyright DESY

## INSTALL:

Can be built using [ilcsoft](http://ilcsoft.desy.de/portal).

The install procedure is managed by [CMake](http://cmake.org)

### Dependencies

All the needed packages are installed on-the-fly by CMake.
All calice packages are then built and installed in the same folder.

### First step 

First modify the file user-pro-test_x86_64_gcc48_sl6.cmake with the contents (only the upper part where package pathes are defined) of the file ILCSoft.cmake in your local or afs ilcsoft installation.

### Install

In the root directory :

```bash
mkdir build
cd build
cmake -C ../user-pro-test_x86_64_gcc48_sl6.cmake [-DOPTIONS=...] ..
make -jX
```

where OPTIONS can be :
* BUILD_CALICE_SIM [ON/OFF] to install calice_sim package
* BUILD_CALICE_CALIB [ON/OFF] to install calice_calib package

Example :

```bash
cmake -C ../user-pro-test_x86_64_gcc48_sl6.cmake -DBUILD_CALICE_SIM=ON ..
```

All options area by default set to OFF

### Bug report

You can send emails to <eldwan.brianne@desy.de>
or use the github issues interface
