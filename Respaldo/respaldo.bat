@echo off
mode  110,45
title Respaldo
echo %date%
EXPDP pgerardo/oracle DIRECTORY=backup_dir DUMPFILE=respaldo_%date:~-4,4%-%date:~-7,2%-%date:~-10,2%.dmp  nologfile=Y
pause
