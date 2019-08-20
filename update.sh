#!/bin/bash

for name in calice_userlib labview_converter calice_reco calice_cddata calice_sim calice_analysis calice_calib RootTreeWriter calice_dd_testbeams calice_steering calice_calib calice_standaloneg4
do
  cd ${name}
  git pull
  cd ..
done
