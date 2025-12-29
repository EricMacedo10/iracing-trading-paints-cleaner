<#
.SYNOPSIS
    Script de limpeza automática de arquivos de pintura do Trading Paints para iRacing.
    Versão 2.0 (Novo Arquivo)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$Interactive,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# Configurações
$ErrorActionPreference = "Continue"
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFolder = Join-Path $ScriptPath "Logs"
$LogFile = Join-Path $LogFolder "CleanLog_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').txt"

# Caminho da pasta de pinturas do iRacing
$PaintFolder = "C:\Users\ericm\OneDrive\Documentos\iRacing\paint"
$TargetExtensions = @("*.tga", "*.mip")

# Função de Log Simples e Robusta
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogMessage -ErrorAction SilentlyContinue
    
    switch ($Level) {
        "SUCCESS" { Write-Host $LogMessage -ForegroundColor Green }
        "WARNING" { Write-Host $LogMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $LogMessage -ForegroundColor Red }
        default { Write-Host $LogMessage -ForegroundColor White }
    }
}

# Inicializa Log
if (-not (Test-Path $LogFolder)) { New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null }

Write-Log "Iniciando limpeza..." -Level "INFO"
Write-Log "Pasta alvo: $PaintFolder" -Level "INFO"

# Verificação Inicial
if (-not (Test-Path $PaintFolder)) {
    Write-Log "ERRO: Pasta nao encontrada: $PaintFolder" -Level "ERROR"
    exit 1
}

# Busca Arquivos
$FilesToRemove = @()
foreach ($Ext in $TargetExtensions) {
    try {
        $Files = Get-ChildItem -Path $PaintFolder -Filter $Ext -Recurse -File -ErrorAction Stop
        $FilesToRemove += $Files
        Write-Log "Encontrados $($Files.Count) arquivos $Ext" -Level "INFO"
    }
    catch {
        Write-Log "Erro ao buscar $Ext" -Level "ERROR"
    }
}

if ($FilesToRemove.Count -eq 0) {
    Write-Log "Nenhum arquivo encontrado. Limpeza concluida." -Level "SUCCESS"
    exit 0
}

# Confirmação
if ($Interactive) {
    Write-Host "`nATENCAO: Exclusao PERMANENTE de $($FilesToRemove.Count) arquivos." -ForegroundColor Yellow
    Write-Host "Deseja continuar? (S/N): " -ForegroundColor Yellow -NoNewline
    $Resp = Read-Host
    if ($Resp -ne "S" -and $Resp -ne "s") {
        Write-Log "Cancelado pelo usuario." -Level "WARNING"
        exit 0
    }
}

# Exclusão
$Count = 0
foreach ($File in $FilesToRemove) {
    try {
        Remove-Item -Path $File.FullName -Force -ErrorAction Stop
        Write-Log "Removido: $($File.Name)" -Level "SUCCESS"
        $Count++
    }
    catch {
        Write-Log "Falha ao remover: $($File.Name)" -Level "ERROR"
    }
}

Write-Log "Total removido: $Count arquivos." -Level "SUCCESS"
exit 0
