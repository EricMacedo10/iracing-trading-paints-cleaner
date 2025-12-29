<#
.SYNOPSIS
    Configurador automático para o sistema de limpeza Trading Paints.

.DESCRIPTION
    Este script configura o ambiente necessário para executar o Clean-TradingPaints.ps1,
    incluindo a política de execução do PowerShell e validações de permissões.

.EXAMPLE
    .\Setup-AutoClean.ps1
    Executa a configuração automática.

.NOTES
    Autor: Sistema de Automação iRacing
    Versão: 1.0
    Data: 2025-12-29
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

#region Funções

function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-ExecutionPolicy {
    <#
    .SYNOPSIS
        Verifica e configura a política de execução.
    #>
    Write-ColorMessage "`n[1/4] Verificando Execution Policy..." -Color "Cyan"
    
    $CurrentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    Write-ColorMessage "Política atual (CurrentUser): $CurrentPolicy" -Color "White"
    
    if ($CurrentPolicy -eq "Restricted" -or $CurrentPolicy -eq "AllSigned") {
        Write-ColorMessage "`nA política de execução precisa ser ajustada para executar scripts." -Color "Yellow"
        Write-ColorMessage "Configurando para RemoteSigned (apenas para o usuário atual)..." -Color "Yellow"
        
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-ColorMessage "✓ Execution Policy configurada com sucesso!" -Color "Green"
            return $true
        }
        catch {
            Write-ColorMessage "✗ ERRO ao configurar Execution Policy: $_" -Color "Red"
            Write-ColorMessage "`nExecute o seguinte comando manualmente em PowerShell:" -Color "Yellow"
            Write-ColorMessage "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -Color "White"
            return $false
        }
    }
    else {
        Write-ColorMessage "✓ Execution Policy já está configurada adequadamente!" -Color "Green"
        return $true
    }
}

function Test-ScriptExists {
    <#
    .SYNOPSIS
        Verifica se o script principal existe.
    #>
    Write-ColorMessage "`n[2/4] Verificando script principal..." -Color "Cyan"
    
    $ScriptPath = Split-Path -Parent $MyInvocation.ScriptName
    $MainScript = Join-Path $ScriptPath "LimparPinturas.ps1"
    
    if (Test-Path $MainScript) {
        Write-ColorMessage "✓ Script encontrado: $MainScript" -Color "Green"
        return $MainScript
    }
    else {
        Write-ColorMessage "✗ ERRO: Script principal não encontrado!" -Color "Red"
        Write-ColorMessage "Esperado em: $MainScript" -Color "Yellow"
        return $null
    }
}

function Test-PaintFolder {
    <#
    .SYNOPSIS
        Verifica se a pasta de pinturas do iRacing existe.
    #>
    Write-ColorMessage "`n[3/4] Verificando pasta do iRacing..." -Color "Cyan"
    
    $PaintFolder = "C:\Users\ericm\OneDrive\Documentos\iRacing\paint"
    
    if (Test-Path $PaintFolder) {
        Write-ColorMessage "✓ Pasta encontrada: $PaintFolder" -Color "Green"
        
        # Conta arquivos .tga e .mip
        $TgaFiles = (Get-ChildItem -Path $PaintFolder -Filter "*.tga" -Recurse -File -ErrorAction SilentlyContinue).Count
        $MipFiles = (Get-ChildItem -Path $PaintFolder -Filter "*.mip" -Recurse -File -ErrorAction SilentlyContinue).Count
        $TotalFiles = $TgaFiles + $MipFiles
        
        Write-ColorMessage "  Arquivos encontrados: $TotalFiles (.tga: $TgaFiles, .mip: $MipFiles)" -Color "White"
        
        return $true
    }
    else {
        Write-ColorMessage "✗ AVISO: Pasta do iRacing não encontrada!" -Color "Yellow"
        Write-ColorMessage "Esperado em: $PaintFolder" -Color "Yellow"
        Write-ColorMessage "O script será configurado, mas não poderá executar até que o iRacing seja instalado." -Color "Yellow"
        return $false
    }
}

function Test-ScriptExecution {
    <#
    .SYNOPSIS
        Testa a execução do script principal em modo simulação.
    #>
    param([string]$ScriptPath)
    
    Write-ColorMessage "`n[4/4] Testando execução do script..." -Color "Cyan"
    
    try {
        Write-ColorMessage "Executando em modo simulação (-WhatIf)..." -Color "White"
        $Result = & $ScriptPath -WhatIf
        
        if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq $null) {
            Write-ColorMessage "✓ Script executado com sucesso!" -Color "Green"
            return $true
        }
        else {
            Write-ColorMessage "✗ Script retornou código de erro: $LASTEXITCODE" -Color "Yellow"
            return $false
        }
    }
    catch {
        Write-ColorMessage "✗ ERRO ao executar script: $_" -Color "Red"
        return $false
    }
}

#endregion

#region Execução Principal

Clear-Host

Write-ColorMessage "========================================" -Color "Cyan"
Write-ColorMessage "  CONFIGURADOR - LIMPEZA TRADING PAINTS" -Color "Cyan"
Write-ColorMessage "========================================" -Color "Cyan"

# Passo 1: Verifica Execution Policy
$Step1 = Test-ExecutionPolicy

# Passo 2: Verifica script principal
$MainScriptPath = Test-ScriptExists

# Passo 3: Verifica pasta do iRacing
$Step3 = Test-PaintFolder

# Passo 4: Testa execução
$Step4 = $false
if ($MainScriptPath) {
    $Step4 = Test-ScriptExecution -ScriptPath $MainScriptPath
}

# Resumo final
Write-ColorMessage "`n========================================" -Color "Cyan"
Write-ColorMessage "  RESUMO DA CONFIGURAÇÃO" -Color "Cyan"
Write-ColorMessage "========================================" -Color "Cyan"

$AllSuccess = $Step1 -and $MainScriptPath -and $Step4

if ($AllSuccess) {
    Write-ColorMessage "✓ Sistema configurado e pronto para uso!" -Color "Green"
    
    Write-ColorMessage "`nCOMO USAR:" -Color "Yellow"
    Write-ColorMessage "  Execução manual interativa:" -Color "White"
    Write-ColorMessage "    .\Clean-TradingPaints.ps1 -Interactive" -Color "Gray"
    
    Write-ColorMessage "`n  Execução automática (silenciosa):" -Color "White"
    Write-ColorMessage "    .\Clean-TradingPaints.ps1" -Color "Gray"
    
    Write-ColorMessage "`n  Simulação (não exclui arquivos):" -Color "White"
    Write-ColorMessage "    .\Clean-TradingPaints.ps1 -WhatIf" -Color "Gray"
    
    Write-ColorMessage "`nPara configurar execução automática ao fechar iRacing:" -Color "Yellow"
    Write-ColorMessage "  Execute (como Administrador):" -Color "White"
    Write-ColorMessage "    .\Install-TaskScheduler.ps1" -Color "Gray"
    
}
else {
    Write-ColorMessage "⚠ Configuração concluída com avisos." -Color "Yellow"
    Write-ColorMessage "Revise os erros acima antes de prosseguir." -Color "Yellow"
}

Write-ColorMessage "`nConsulte o README.md para mais informações." -Color "Cyan"
Write-ColorMessage "========================================" -Color "Cyan"

# Pausa para leitura
Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor "Gray"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

#endregion
