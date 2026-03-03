# --- FUNÇÃO DE ALERTA (COM TRATAMENTO DE ERRO) ---
function Send-TelegramAlert {
    param([string]$Mensagem)
    try {
        $token  = $config.Configuracoes.TelegramToken
        $chatId = $config.Configuracoes.ChatID
        $url    = "https://api.telegram.org/bot$token/sendMessage"
        
        $body = @{
            chat_id    = $chatId
            text       = $Mensagem
            parse_mode = "HTML"
        }

        Invoke-RestMethod -Uri $url -Method Post -Body $body -ErrorAction Stop | Out-Null
    } catch {
        Write-Host "[ERRO CRÍTICO] Falha ao enviar alerta para o Telegram: $($_.Exception.Message)" -ForegroundColor Magenta
    }
}

# --- INICIALIZAÇÃO E CARREGAMENTO ---
$configPath = "$PSScriptRoot/../config/targets.json"
if (-not (Test-Path $configPath)) { 
    Write-Host "[ERRO] Arquivo de configuração não encontrado!" -ForegroundColor Red; exit 
}

$config = Get-Content $configPath | ConvertFrom-Json

# --- PROCESSAMENTO DE DADOS ---
$relatorio = foreach ($item in $config.Servidores) {
    $ping = Test-Connection -ComputerName $item.IP -Count 1 -Quiet
    $statusSvc = "Desconectado"
    
    if ($ping) {
        $svc = Get-Service -Name $item.Servico -ErrorAction SilentlyContinue
        $statusSvc = if ($svc) { $svc.Status.ToString() } else { "Nao_Encontrado" }
    }

    [PSCustomObject]@{
        Servidor  = $item.Nome
        IP        = $item.IP
        Service   = $item.Servico
        Conexao   = if ($ping) { "Online" } else { "Offline" }
        StatusSvc = $statusSvc
    }
}

# --- EXIBIÇÃO E LÓGICA DE NEGÓCIO (NOC) ---
$totalOK = 0; $totalAlerta = 0; $totalCritico = 0

foreach ($linha in $relatorio) {
    $msgTelegram = $null # Limpa a mensagem a cada loop

    # CENÁRIO 1: TUDO OPERACIONAL
    if ($linha.Conexao -eq "Online" -and $linha.StatusSvc -eq "Running") {
        Write-Host "[OK] $($linha.Servidor) ($($linha.IP)) - Operando normalmente." -ForegroundColor Green
        $totalOK++
    } 

    # CENÁRIO 2: SERVIÇO PARADO (COM AUTO-HEALING)
    elseif ($linha.Conexao -eq "Online" -and $linha.StatusSvc -ne "Running") {
        
        if ($config.Configuracoes.AutoHealing -eq "Sim" -and $linha.StatusSvc -eq "Stopped") {
            Write-Host "[AUTO-HEALING] Tentando reiniciar $($linha.Service) em $($linha.Servidor)..." -ForegroundColor Cyan
            
            Start-Service -Name $linha.Service -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 5
            
            if ((Get-Service $linha.Service).Status -eq "Running") {
                $linha.StatusSvc = "Recuperado"
                $msgTelegram = "✅ <b>AUTO-HEALING: SUCESSO</b> ✅`n`n<b>Servidor:</b> $($linha.Servidor)`n<b>Serviço:</b> $($linha.Service) foi reiniciado com sucesso."
                Write-Host "[RECUPERADO] $($linha.Servidor) voltou a operar via Auto-Healing." -ForegroundColor Green
                $totalOK++
            } else {
                $msgTelegram = "⚠️ <b>AUTO-HEALING: FALHA</b> ⚠️`n`n<b>Servidor:</b> $($linha.Servidor)`n<b>Serviço:</b> $($linha.Service) falhou ao reiniciar!"
                Write-Host "[FALHA] Auto-Healing falhou em $($linha.Servidor)." -ForegroundColor Yellow
                $totalAlerta++
            }
        } else {
            $msgTelegram = "⚠️ <b>ALERTA DE SERVIÇO</b> ⚠️`n`n<b>Servidor:</b> $($linha.Servidor)`n<b>Serviço:</b> $($linha.Service) está $($linha.StatusSvc)."
            Write-Host "[ALERTA] $($linha.Servidor) - Serviço parado/não encontrado." -ForegroundColor Yellow
            $totalAlerta++
        }
    }

    # CENÁRIO 3: HOST OFFLINE (PING FALHOU)
    else {
        $msgTelegram = "🚨 <b>FALHA CRÍTICA: OFFLINE</b> 🚨`n`n<b>Servidor:</b> $($linha.Servidor)`n<b>IP:</b> $($linha.IP) sem resposta de rede."
        Write-Host "[CRÍTICO] $($linha.Servidor) ($($linha.IP)) está OFFLINE!" -ForegroundColor Red
        $totalCritico++
    }

    # DISPARO DE MENSAGEM (Se houver uma mensagem gerada)
    if ($msgTelegram -and $config.Configuracoes.EnviarAlerta -eq "Sim") {
        Send-TelegramAlert -Mensagem $msgTelegram
    }
}

# --- RESUMO FINAL ---
Write-Host "`n" + ("-" * 50) -ForegroundColor Gray
Write-Host "RESUMO NOC - $(Get-Date -Format 'HH:mm:ss') | OK: $totalOK | Alerta: $totalAlerta | Crítico: $totalCritico" -ForegroundColor White
Write-Host ("-" * 50) -ForegroundColor Gray