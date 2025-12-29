# Sistema de Limpeza Automática de Pinturas - Trading Paints para iRacing

Sistema completo e seguro para gerenciar automaticamente os arquivos de pintura do Trading Paints no iRacing, desenvolvido em PowerShell com foco em segurança e facilidade de uso.

---

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Características](#características)
- [Requisitos do Sistema](#requisitos-do-sistema)
- [Instalação](#instalação)
- [Como Usar](#como-usar)
- [Configuração Automática](#configuração-automática)
- [Troubleshooting](#troubleshooting)
- [Segurança](#segurança)
- [FAQ](#faq)

---

## 🎯 Visão Geral

Este sistema foi desenvolvido para resolver o problema de acúmulo de arquivos de pintura do Trading Paints na pasta do iRacing. Ele oferece:

- **Limpeza Manual**: Execute quando quiser com um clique
- **Limpeza Automática**: Configure para executar automaticamente
- **Segurança**: Validações rigorosas e sistema de logs
- **Simplicidade**: Interface clara e configuração fácil

### O que o sistema faz?

✅ Percorre recursivamente a pasta de pinturas do iRacing (ex: `Documents\iRacing\paint`)  
✅ Remove **apenas** arquivos `.tga` e `.mip`  
✅ **Preserva todas as pastas**  
✅ Gera logs detalhados de todas as operações  
✅ Mostra quanto espaço foi liberado  

---

## ✨ Características

### 🔧 LimparPinturas.ps1 (Script Principal)

- **Modo Interativo**: Solicita confirmação antes de excluir
- **Modo Automático**: Execução silenciosa para agendamento
- **Modo Simulação**: Visualize o que seria excluído sem fazer alterações
- **Sistema de Logs**: Registra todas as operações com timestamp
- **Relatórios**: Mostra arquivos removidos e espaço liberado
- **Validações**: Verifica caminhos e extensões antes de processar
- **Tratamento de Erros**: Continua funcionando mesmo se houver erros pontuais

### ⚙️ Setup-AutoClean.ps1 (Configurador)

- Configura automaticamente a Execution Policy
- Valida todos os componentes necessários
- Testa o script em modo simulação
- Interface colorida e amigável

### 📅 Install-TaskScheduler.ps1 (Agendador)

- Cria tarefa no Agendador de Tarefas do Windows
- Oferece múltiplas opções de agendamento:
  - Execução diária
  - Ao fazer logon
  - Monitoramento de processo (avançado)
- Remove tarefas antigas automaticamente

---

## 💻 Requisitos do Sistema

- **Sistema Operacional**: Windows 10 ou superior
- **PowerShell**: 5.1 ou superior (já incluído no Windows)
- **iRacing**: Instalado (pasta `Documentos\iRacing\paint` deve existir)
- **Permissões**:
  - Usuário normal para execução manual
  - Administrador apenas para configurar agendamento

---

## 📦 Instalação

### Passo 1: Baixar os Arquivos

Certifique-se de ter os seguintes arquivos na mesma pasta:

```
📁 Apagar os arquivos de pinturas\
├── LimparPinturas.ps1
├── Setup-AutoClean.ps1
├── Install-TaskScheduler.ps1
└── README.md
```

### Passo 2: Desbloquear os Scripts

Clique com o botão direito em cada arquivo `.ps1` → **Propriedades** → Marque **Desbloquear** (se disponível) → **OK**.

### Passo 3: Executar o Configurador

1. Abra o **PowerShell** (modo normal, não precisa ser administrador)
2. Navegue até a pasta onde salvou os scripts:
   ```powershell
   cd "C:\Caminho\Para\Seus\Scripts"
   ```
3. Execute o configurador:
   ```powershell
   .\Setup-AutoClean.ps1
   ```

O configurador irá:
- ✅ Configurar a Execution Policy
- ✅ Validar todos os arquivos
- ✅ Verificar a pasta do iRacing
- ✅ Testar o script em modo simulação

---

## 🚀 Como Usar

### Execução Manual

#### Modo Interativo (Recomendado para primeira vez)

```powershell
.\LimparPinturas.ps1 -Interactive
```

- Mostra quantos arquivos serão removidos
- Exibe o espaço que será liberado
- **Solicita confirmação antes de excluir**

#### Modo Automático (Silencioso)

```powershell
.\LimparPinturas.ps1
```

- Executa sem perguntar
- Ideal para agendamento
- Gera log completo

#### Modo Simulação (WhatIf)

```powershell
.\LimparPinturas.ps1 -WhatIf
```

- **Não exclui nada**
- Mostra o que seria feito
- Útil para testar antes de executar

### Visualizar Logs

Os logs ficam salvos na pasta `Logs\` e contêm:
- Data e hora de cada operação
- Arquivos removidos
- Erros encontrados
- Espaço liberado

Para visualizar o último log:

```powershell
Get-Content .\Logs\CleanLog_*.txt | Select-Object -Last 50
```

---

## ⏰ Configuração Automática

### Opção 1: Agendamento via Task Scheduler (Recomendado)

1. **Abra o PowerShell como Administrador**
   - Clique com botão direito no PowerShell
   - Selecione "Executar como Administrador"

2. **Navegue até a pasta dos scripts**
   ```powershell
   cd "C:\Caminho\Para\Seus\Scripts"
   ```

3. **Execute o instalador**
   ```powershell
   .\Install-TaskScheduler.ps1
   ```

4. **Escolha o método de execução**
   - **Opção 1**: Executar diariamente às 23:00 (recomendado)
   - **Opção 2**: Executar ao fazer logon no Windows
   - **Opção 3**: Monitorar processo do iRacing (avançado)

### Opção 2: Atalho Manual

Crie um atalho com o seguinte destino:

```
powershell.exe -ExecutionPolicy Bypass -File "C:\Caminho\Completo\Para\LimparPinturas.ps1"
```

Dica: Você pode copiar o caminho completo segurando Shift e clicando com o botão direito no arquivo `LimparPinturas.ps1`, selecionando "Copiar como caminho".

### Opção 3: Monitoramento de Processo (Avançado)

O script `Install-TaskScheduler.ps1` oferece a opção de criar um monitor que detecta quando o iRacing é fechado e executa a limpeza automaticamente.

**Como funciona:**
1. Um script auxiliar (`Monitor-iRacing.ps1`) é criado
2. Ele verifica a cada 5 minutos se o iRacing está rodando
3. Quando detecta que o iRacing foi fechado, aguarda 10 segundos
4. Executa a limpeza automaticamente

---

## 🔧 Troubleshooting

### Problema: "Não é possível executar scripts neste sistema"

**Causa**: Execution Policy está restrita.

**Solução**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Ou execute o configurador:
```powershell
.\Setup-AutoClean.ps1
```

---

### Problema: "Pasta não encontrada"

**Causa**: iRacing não está instalado ou pasta paint não existe.

**Solução**:
1. Verifique se o iRacing está instalado
2. Confirme que a pasta existe:
   ```powershell
   Test-Path "$env:USERPROFILE\Documents\iRacing\paint"
   ```
3. Se a pasta não existir, crie manualmente ou execute o iRacing uma vez

---

### Problema: "Acesso negado" ao excluir arquivo

**Causa**: Arquivo está em uso ou requer permissões especiais.

**Solução**:
- Feche o iRacing completamente
- Verifique se algum programa está usando os arquivos
- O script continuará e registrará o erro no log

---

### Problema: Tarefa agendada não executa

**Causa**: Várias possibilidades.

**Solução**:
1. Abra o **Agendador de Tarefas** do Windows
2. Localize a tarefa "iRacing - Limpeza Trading Paints"
3. Verifique:
   - A tarefa está habilitada?
   - O gatilho está correto?
   - As credenciais estão corretas?
4. Teste manualmente: Clique com botão direito → **Executar**

---

### Problema: Script não remove nenhum arquivo

**Causa**: Nenhum arquivo .tga ou .mip foi encontrado.

**Solução**:
- Isso é normal se você não tem arquivos do Trading Paints
- Verifique o log para confirmar
- Execute com `-WhatIf` para ver o que seria feito

---

## 🔐 Segurança

### Princípios de Segurança Implementados

#### 1. Princípio do Privilégio Mínimo
- Scripts principais **não requerem administrador**
- Apenas agendamento automático requer elevação
- Execution Policy configurada apenas para usuário atual

#### 2. Validações Rigorosas
- ✅ Verifica existência de diretórios antes de processar
- ✅ Valida extensões de arquivos (apenas .tga e .mip)
- ✅ Previne exclusão de pastas
- ✅ Verifica caminhos válidos

#### 3. Auditoria Completa
- 📝 Logs detalhados de todas as operações
- 📝 Timestamp em cada entrada
- 📝 Registro de sucessos e erros
- 📝 Rastreabilidade completa

#### 4. Tratamento Robusto de Erros
- Continua funcionando mesmo com erros pontuais
- Registra erros no log
- Não interrompe por falhas individuais
- Exit codes apropriados

#### 5. Modo Simulação
- Permite testar sem riscos
- Visualiza o que seria feito
- Valida antes de executar

### Permissões Necessárias

| Ação | Requer Admin? | Motivo |
|------|---------------|--------|
| Executar limpeza manual | ❌ Não | Opera em pasta de usuário |
| Configurar Execution Policy | ❌ Não | Escopo CurrentUser |
| Criar tarefa agendada | ✅ Sim | Acesso ao Task Scheduler |
| Visualizar logs | ❌ Não | Arquivos na pasta do script |

---

## ❓ FAQ

### P: O script exclui minhas pinturas personalizadas?
**R**: O script remove **apenas** arquivos .tga e .mip. Se suas pinturas personalizadas usam essas extensões e estão na pasta `paint`, sim, elas serão removidas. Recomendamos fazer backup de pinturas importantes em outra pasta.

### P: Posso reverter a exclusão?
**R**: Não diretamente, mas você pode restaurar da Lixeira do Windows (se não tiver sido esvaziada). Recomendamos usar o modo `-WhatIf` primeiro para verificar.

### P: Quanto espaço vou liberar?
**R**: Varia conforme o uso do Trading Paints. Usuários ativos podem liberar de 500MB a vários GB.

### P: Preciso executar toda vez que jogar?
**R**: Não é necessário. Você pode executar semanalmente ou configurar o agendamento automático.

### P: O script afeta o funcionamento do iRacing?
**R**: Não. O script apenas remove arquivos de pintura não essenciais na pasta de documentos.

### P: E se eu quiser manter algumas pinturas?
**R**: Mova as pinturas que deseja manter para outra pasta fora de `iRacing\paint` antes de executar o script.

### P: Como desinstalar?
**R**: 
1. Se criou tarefa agendada: Abra o Agendador de Tarefas e delete a tarefa "iRacing - Limpeza Trading Paints"
2. Delete a pasta com os scripts
3. (Opcional) Reverta a Execution Policy:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser
   ```

### P: Posso usar em múltiplos computadores?
**R**: Sim! Copie os scripts para cada computador e execute o configurador em cada um.

### P: O script funciona com outras pastas?
**R**: Não. Ele está programado especificamente para `Documentos\iRacing\paint`. Modificar isso requer editar o script.

---

## 📊 Estrutura de Logs

Exemplo de log gerado:

```
[2025-12-29 15:30:00] [INFO] ========================================
[2025-12-29 15:30:00] [INFO] Iniciando limpeza de arquivos Trading Paints
[2025-12-29 15:30:00] [INFO] ========================================
[2025-12-29 15:30:00] [INFO] Pasta alvo: C:\Users\USERNAME\Documents\iRacing\paint
[2025-12-29 15:30:00] [INFO] Extensões: *.tga, *.mip
[2025-12-29 15:30:01] [INFO] Procurando arquivos...
[2025-12-29 15:30:05] [INFO] Encontrados 1523 arquivos *.tga
[2025-12-29 15:30:06] [INFO] Encontrados 847 arquivos *.mip
[2025-12-29 15:30:06] [INFO] ----------------------------------------
[2025-12-29 15:30:06] [INFO] Total de arquivos encontrados: 2370
[2025-12-29 15:30:06] [INFO] Espaço a ser liberado: 1.45 GB
[2025-12-29 15:30:06] [INFO] ----------------------------------------
[2025-12-29 15:30:06] [SUCCESS] Removido: car_123.tga
[2025-12-29 15:30:06] [SUCCESS] Removido: car_123.mip
...
[2025-12-29 15:32:14] [INFO] ========================================
[2025-12-29 15:32:14] [INFO] RELATÓRIO FINAL
[2025-12-29 15:32:14] [INFO] ========================================
[2025-12-29 15:32:14] [SUCCESS] Arquivos removidos com sucesso: 2370
[2025-12-29 15:32:14] [SUCCESS] Espaço liberado: 1.45 GB
[2025-12-29 15:32:14] [INFO] ========================================
```

---

## 📞 Suporte

Para problemas ou dúvidas:

1. Consulte a seção [Troubleshooting](#troubleshooting)
2. Verifique os logs na pasta `Logs\`
3. Execute em modo `-WhatIf` para diagnóstico
4. Revise as validações do `Setup-AutoClean.ps1`

---

## 📝 Notas Importantes

⚠️ **Backup**: Considere fazer backup de pinturas importantes  
⚠️ **Teste**: Use `-WhatIf` antes da primeira execução real  
⚠️ **Logs**: Revise os logs periodicamente  
⚠️ **Permissões**: Não execute como Admin desnecessariamente  

---

## 🎯 Boas Práticas

1. **Primeira vez**: Execute com `-Interactive` e `-WhatIf`
2. **Rotina**: Configure agendamento diário ou semanal
3. **Monitoramento**: Revise logs mensalmente
4. **Backup**: Salve pinturas importantes em outra pasta
5. **Segurança**: Mantenha Execution Policy em RemoteSigned

---

<p align="center">
  <strong>Sistema desenvolvido com foco em segurança e facilidade de uso</strong><br>
  Versão 1.0 | 2025
</p>
