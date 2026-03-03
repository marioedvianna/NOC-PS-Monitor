# --- FUNÇÃO DE ALERTA ---
function Send-TelegramAlert {
    param([string]$Mensagem)
    
    $token = $config.Configuracoes.TelegramToken
    $chatId = $config.Configuracoes.ChatID
    $url = "https://api.telegram.org/bot$token/sendMessage"
    
    $body = @{
        chat_id = $chatId
        text = $Mensagem
        parse_mode = "HTML"
    }

    Invoke-RestMethod -Uri $url -Method Post -Body $body | Out-Null
}

# Carrega as configurações (garantindo o caminho correto)
$configPath = "$PSScriptRoot/../config/targets.json"
$config = Get-Content $configPath | ConvertFrom-Json

$relatorio = foreach ($item in $config.Servidores) {
    # 1. Teste de Ping
    $ping = Test-Connection -ComputerName $item.IP -Count 1 -Quiet
    
    # 2. Teste de Serviço (Só tenta se o ping responder)
    $statusSvc = "Desconectado"
    if ($ping) {
        $svc = Get-Service -Name $item.Servico -ErrorAction SilentlyContinue
        if ($svc) {
            $statusSvc = $svc.Status.ToString() # Garante que vire texto (Running/Stopped)
        } else {
            $statusSvc = "Nao_Encontrado"
        }
    }

    # 3. Criando o Objeto
    [PSCustomObject]@{
        Servidor  = $item.Nome
        Conexao   = if ($ping) { "Online" } else { "Offline" }
        StatusSvc = $statusSvc
        IP        = $item.IP
        service   = $item.Servico
    }
}

$totalOK = 0
$totalAlerta = 0
$totalCritico = 0


foreach ($linha in $relatorio) {
    # 1. TUDO OK: Não precisa mandar mensagem (silêncio é ouro no NOC)
    if ($linha.Conexao -eq "Online" -and $linha.StatusSvc -eq "Running") {
        Write-Host "[OK] ..." -ForegroundColor Green
        $totalOK++
    } 
    
    # 2. ALERTA: O servidor respira, mas a aplicação (serviço) morreu
    elseif ($linha.Conexao -eq "Online" -and $linha.StatusSvc -ne "Running") {
        $msg = "⚠️ <b>ALERTA DE SERVIÇO</b> ⚠️`n`n" +
            "<b>Servidor:</b> $($linha.Servidor)`n" +
            "<b>IP:</b> $($linha.IP)`n" +
            "<b>Serviço:</b> $($linha.service)`n" +
            "<b>Status:</b> $($linha.StatusSvc)" 

        if ($config.Configuracoes.EnviarAlerta -eq "Sim") { 
            Send-TelegramAlert -Mensagem $msg 
        }

        Write-Host "[ALERTA] ..." -ForegroundColor Yellow
        $totalAlerta++
    }
    
    # 3. CRÍTICO: O servidor parou de responder (Queda de Rede/Energia)
    else {
        $msg = "🚨 <b>FALHA CRÍTICA: OFFLINE</b> 🚨`n`n" +
            "<b>Servidor:</b> $($linha.Servidor)`n" +
            "<b>IP:</b> $($linha.IP)`n" +
            "<b>Status:</b> SEM RESPOSTA (PING)"  

        if ($config.Configuracoes.EnviarAlerta -eq "Sim") { 
            Send-TelegramAlert -Mensagem $msg 
        }

        Write-Host "[CRÍTICO] ..." -ForegroundColor Red
        $totalCritico++
    }
}

Write-Host "`n" 
Write-Host "--------------------------------------------------" -ForegroundColor Gray
Write-Host "RESUMO DO MONITORAMENTO NOC - $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White -NoNewline
Write-Host " | " -NoNewline
Write-Host "Saudáveis: $totalOK " -ForegroundColor Green -NoNewline
Write-Host "| Alertas: $totalAlerta " -ForegroundColor Yellow -NoNewline
Write-Host "| Críticos: $totalCritico" -ForegroundColor Red
Write-Host "--------------------------------------------------" -ForegroundColor Gray