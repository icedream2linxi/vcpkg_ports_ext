@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass "& {& '%~dp0vcpkg_env.ps1'}"