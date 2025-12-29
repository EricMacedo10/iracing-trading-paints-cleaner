@echo off
chcp 65001 >nul

set "SCRIPT_PATH=C:\Users\ericm\OneDrive\Área de Trabalho\PESSOAL\Apagar os arquivos de pinturas\LimparPinturas.ps1"

if exist "%SCRIPT_PATH%" (
    powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File "%SCRIPT_PATH%"
)
exit
