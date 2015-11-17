@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.3\\bin
call %xv_path%/xsim SC_note_matching_super_tb_behav -key {Behavioral:sim_1:Functional:SC_note_matching_super_tb} -tclbatch SC_note_matching_super_tb.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
