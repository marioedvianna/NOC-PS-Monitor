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
        service   = $item.Servico
    }
}

$totalOK = 0
$totalAlerta = 0
$totalCritico = 0


foreach ($linha in $relatorio) {
   # 1. Se ambos estão OK 
    if ($linha.Conexao -eq "Online" -and $linha.StatusSvc -eq "Running") {
        Write-Host "[OK] O monitoramento de PING e do SERVIÇO ($($linha.service)) de $($linha.Servidor) está operando normalmente." -ForegroundColor Green
        $totalOK++
    }
    # 2. Se o Ping está OK, mas o Serviço deu erro
    elseif ($linha.Conexao -eq "Online" -and $linha.StatusSvc -ne "Running") {
        Write-Host "[ALERTA] Servidor $($linha.Servidor) responde ao PING, mas o SERVIÇO ($($linha.service)) está: $($linha.StatusSvc)." -ForegroundColor Yellow
        $totalAlerta++
    }
    # 3. Se não responde o Ping
    else {
        Write-Host "[CRÍTICO] O monitoramento de REDE (PING) de $($linha.Servidor) falhou! (Servidor Offline)" -ForegroundColor Red
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