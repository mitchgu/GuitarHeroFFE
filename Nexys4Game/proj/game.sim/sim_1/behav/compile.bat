@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.3\\bin
echo "xvlog -m64 --relax -prj SC_note_matching_sub_tb_vlog.prj"
call %xv_path%/xvlog  -m64 --relax -prj SC_note_matching_sub_tb_vlog.prj -log compile.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
