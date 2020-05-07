#!/usr/bin/env bash

cd calice_dd_testbeams/2018_SPS_June_AHCAL
mkdir build
cd build
cmake ..
make install
cd ..
rm -rf build
cd ../../

cd calice_dd_testbeams/2018_SPS_May_AHCAL
mkdir build
cd build
cmake ..
make install
cd ..
rm -rf build
cd ../../

cd flchcalsoftware
mkdir build
cd build
cmake ..
make -j5
cd ..
rm -rf build
cd ..
