@echo off
chcp 65001 >nul
cls
echo ========================================
echo   LIMPEZA DE PINTURAS iRACING
echo   Modo Interativo
echo ========================================
echo.

set "SCRIPT_PATH=C:\Users\ericm\OneDrive\Área de Trabalho\PESSOAL\Apagar os arquivos de pinturas\LimparPinturas.ps1"

if exist "%SCRIPT_PATH%" (
    powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SCRIPT_PATH%" -Interactive
) else (
    echo [ERRO] Script nao encontrado em:
    echo "%SCRIPT_PATH%"
    pause
)

echo.
echo Pressione qualquer tecla para fechar...
pause >nul
