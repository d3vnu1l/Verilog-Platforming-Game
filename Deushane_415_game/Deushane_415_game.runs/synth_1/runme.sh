#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/fbuga/opt/xilinx/SDK/2017.3/bin:/home/fbuga/opt/xilinx/Vivado/2017.3/ids_lite/ISE/bin/lin64:/home/fbuga/opt/xilinx/Vivado/2017.3/bin
else
  PATH=/home/fbuga/opt/xilinx/SDK/2017.3/bin:/home/fbuga/opt/xilinx/Vivado/2017.3/ids_lite/ISE/bin/lin64:/home/fbuga/opt/xilinx/Vivado/2017.3/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/home/fbuga/opt/xilinx/Vivado/2017.3/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/home/fbuga/opt/xilinx/Vivado/2017.3/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/fbuga/Documents/415/Deushane_415_game/Deushane_415_game.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log pong_top_st.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source pong_top_st.tcl