<#
.SYNOPSIS
    Instalador de tarefa agendada para limpeza automática ao fechar iRacing.

.DESCRIPTION
    Este script cria uma tarefa no Agendador de Tarefas do Windows que monitora
    o processo do iRacing e executa a limpeza automaticamente quando o jogo é fechado.
    
    REQUER PRIVILÉGIOS DE ADMINISTRADOR.

.EXAMPLE
    .\Install-TaskScheduler.ps1
    Instala a tarefa agendada (requer execução como Administrador).

.NOTES
    Autor: Sistema de Automação iRacing
    Versão: 1.0
    Data: 2025-12-29
#>

#Requires -RunAsAdministrator

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

function Test-Administrator {
    <#
    .SYNOPSIS
        Verifica se o script está sendo executado como Administrador.
    #>
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
    return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Remove-ExistingTask {
    <#
    .SYNOPSIS
        Remove tarefa existente se houver.
    #>
    param([string]$TaskName)
    
    try {
        $ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        
        if ($ExistingTask) {
            Write-ColorMessage "Removendo tarefa existente..." -Color "Yellow"
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Write-ColorMessage "✓ Tarefa anterior removida." -Color "Green"
        }
    }
    catch {
        Write-ColorMessage "Aviso ao verificar tarefa existente: $_" -Color "Yellow"
    }
}

function New-CleanupTask {
    <#
    .SYNOPSIS
        Cria a tarefa agendada no Windows.
    #>
    param(
        [string]$TaskName,
        [string]$ScriptPath,
        [string]$WorkingDirectory
    )
    
    Write-ColorMessage "Criando nova tarefa agendada..." -Color "Cyan"
    
    # Configuração da Ação
    $ActionParams = @{
        Execute          = "powershell.exe"
        Argument         = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""
        WorkingDirectory = $WorkingDirectory
    }
    $Action = New-ScheduledTaskAction @ActionParams
    
    # Configuração do Gatilho (Trigger)
    # Nota: O Windows Task Scheduler não suporta gatilho direto para "processo fechado"
    # Alternativa: Executar a cada N minutos OU usar Event Viewer
    # Vamos usar uma abordagem híbrida com script wrapper
    
    Write-ColorMessage "`nEscolha o método de execução automática:" -Color "Yellow"
    Write-ColorMessage "  1 - Executar diariamente às 23:00 (recomendado)" -Color "White"
    Write-ColorMessage "  2 - Executar ao fazer logon no Windows" -Color "White"
    Write-ColorMessage "  3 - Criar script wrapper para monitorar processo (avançado)" -Color "White"
    Write-Host "`nEscolha (1-3): " -NoNewline -ForegroundColor "Cyan"
    $Choice = Read-Host
    
    $Trigger = switch ($Choice) {
        "1" {
            # Execução diária às 23:00
            New-ScheduledTaskTrigger -Daily -At "23:00"
        }
        "2" {
            # Execução ao fazer logon
            New-ScheduledTaskTrigger -AtLogOn
        }
        "3" {
            # Para monitoramento de processo, será necessário criar um script wrapper
            Write-ColorMessage "`nModo avançado selecionado." -Color "Yellow"
            Write-ColorMessage "Será criado um script wrapper para monitorar o processo do iRacing." -Color "Yellow"
            
            # Criar script wrapper
            $WrapperScript = Join-Path $WorkingDirectory "Monitor-iRacing.ps1"
            Create-ProcessMonitorScript -OutputPath $WrapperScript -CleanScript $ScriptPath
            
            # Executar o monitor a cada 5 minutos
            New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([TimeSpan]::MaxValue)
        }
        default {
            Write-ColorMessage "Opção inválida. Usando execução diária." -Color "Yellow"
            New-ScheduledTaskTrigger -Daily -At "23:00"
        }
    }
    
    # Configurações da Tarefa
    $Settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RunOnlyIfNetworkAvailable:$false `
        -Hidden
    
    # Principal (usuário que executará)
    $Principal = New-ScheduledTaskPrincipal `
        -UserId $env:USERNAME `
        -LogonType Interactive `
        -RunLevel Limited
    
    # Registra a tarefa
    try {
        Register-ScheduledTask `
            -TaskName $TaskName `
            -Action $Action `
            -Trigger $Trigger `
            -Settings $Settings `
            -Principal $Principal `
            -Description "Limpeza automática de arquivos Trading Paints do iRacing" `
            -ErrorAction Stop | Out-Null
        
        Write-ColorMessage "✓ Tarefa criada com sucesso!" -Color "Green"
        return $true
    }
    catch {
        Write-ColorMessage "✗ ERRO ao criar tarefa: $_" -Color "Red"
        return $false
    }
}

function Create-ProcessMonitorScript {
    <#
    .SYNOPSIS
        Cria script wrapper para monitorar o processo do iRacing.
    #>
    param(
        [string]$OutputPath,
        [string]$CleanScript
    )
    
    $MonitorScriptContent = @"
# Monitor-iRacing.ps1
# Este script monitora o processo do iRacing e executa limpeza quando fechado

`$ProcessName = "iRacingSim64DX11"
`$StateFile = "`$PSScriptRoot\iracing_state.txt"
`$CleanScript = "$CleanScript"

# Verifica se o processo está em execução
`$Process = Get-Process -Name `$ProcessName -ErrorAction SilentlyContinue

if (`$Process) {
    # iRacing está rodando - salva estado
    Set-Content -Path `$StateFile -Value "RUNNING"
}
else {
    # iRacing não está rodando
    if (Test-Path `$StateFile) {
        `$LastState = Get-Content -Path `$StateFile -ErrorAction SilentlyContinue
        
        if (`$LastState -eq "RUNNING") {
            # iRacing acabou de fechar - executa limpeza
            Start-Sleep -Seconds 10  # Aguarda 10 segundos
            
            # Executa script de limpeza
            & `$CleanScript
            
            # Atualiza estado
            Set-Content -Path `$StateFile -Value "STOPPED"
        }
    }
    else {
        # Primeiro execução - cria arquivo de estado
        Set-Content -Path `$StateFile -Value "STOPPED"
    }
}
"@
    
    Set-Content -Path $OutputPath -Value $MonitorScriptContent -Encoding UTF8
    Write-ColorMessage "✓ Script de monitoramento criado: $OutputPath" -Color "Green"
}

#endregion

#region Execução Principal

Clear-Host

Write-ColorMessage "========================================" -Color "Cyan"
Write-ColorMessage "  INSTALADOR - AGENDADOR DE TAREFAS" -Color "Cyan"
Write-ColorMessage "========================================" -Color "Cyan"

# Verifica privilégios de administrador
if (-not (Test-Administrator)) {
    Write-ColorMessage "`n✗ ERRO: Este script requer privilégios de Administrador!" -Color "Red"
    Write-ColorMessage "`nClique com botão direito no PowerShell e selecione 'Executar como Administrador'." -Color "Yellow"
    Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor "Gray"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-ColorMessage "✓ Executando como Administrador." -Color "Green"

# Configurações
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$MainScript = Join-Path $ScriptPath "LimparPinturas.ps1"
$TaskName = "iRacing - Limpeza Trading Paints"

# Validações
Write-ColorMessage "`nVerificando arquivos necessários..." -Color "Cyan"

if (-not (Test-Path $MainScript)) {
    Write-ColorMessage "✗ ERRO: Script principal não encontrado!" -Color "Red"
    Write-ColorMessage "Esperado em: $MainScript" -Color "Yellow"
    Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor "Gray"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-ColorMessage "✓ Script principal encontrado." -Color "Green"

# Remove tarefa existente
Remove-ExistingTask -TaskName $TaskName

# Cria nova tarefa
$Success = New-CleanupTask -TaskName $TaskName -ScriptPath $MainScript -WorkingDirectory $ScriptPath

# Resumo final
Write-ColorMessage "`n========================================" -Color "Cyan"
Write-ColorMessage "  RESUMO DA INSTALAÇÃO" -Color "Cyan"
Write-ColorMessage "========================================" -Color "Cyan"

if ($Success) {
    Write-ColorMessage "✓ Instalação concluída com sucesso!" -Color "Green"
    
    Write-ColorMessage "`nINFORMAÇÕES DA TAREFA:" -Color "Yellow"
    Write-ColorMessage "  Nome: $TaskName" -Color "White"
    Write-ColorMessage "  Script: $MainScript" -Color "White"
    
    Write-ColorMessage "`nGERENCIAMENTO:" -Color "Yellow"
    Write-ColorMessage "  Para visualizar: Abra 'Agendador de Tarefas' do Windows" -Color "White"
    Write-ColorMessage "  Para desinstalar: Execute este script novamente" -Color "White"
    Write-ColorMessage "                    ou remova manualmente no Agendador" -Color "White"
    
}
else {
    Write-ColorMessage "⚠ Instalação concluída com erros." -Color "Yellow"
    Write-ColorMessage "Revise as mensagens acima." -Color "Yellow"
}

Write-ColorMessage "========================================" -Color "Cyan"

# Pausa para leitura
Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor "Gray"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

#endregion
