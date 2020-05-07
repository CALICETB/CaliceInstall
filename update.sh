#!/bin/bash

for name in calice_analysis calice_calib calice_cddata calice_db_tools calice_dd_testbeams calice_pandora calice_reco calice_ROOTmacros calice_sim calice_standaloneg4 calice_steering calice_userlib flchcalsoftware labview_converter RootTreeWriter
do
  cd ${name}
  git pull
  cd ..
done
