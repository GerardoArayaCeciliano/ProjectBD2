@echo off
mode  110,45
title BorrarRespaldo

forfiles -p C:\respaldos\ -s -m *.dmp /D -15 /C "cmd /c del /q @path"
pause
