
# 🛡️ NOC-PS-Monitor (Versão 2.0 - Alertas Inteligentes)

O **NOC-PS-Monitor** é uma solução de monitoramento de ativos e serviços desenvolvida em PowerShell, focada em alta disponibilidade e resposta rápida a incidentes.

> **Status Atual:** 🚀 Fase 2 - Integração com APIs de Mensageria (Telegram) concluída.

----------

### 🚀 Novas Funcionalidades (Fase 2)

-   **Notificações em Tempo Real:** Integração nativa com a **API do Telegram** para envio de alertas instantâneos.
    
-   **Inteligência de Alerta (Multinível):**
    
    -   🟢 **Saudável:** Registro silencioso em log para evitar ruído.
        
    -   🟡 **Alerta (Warning):** Disparo de notificação quando o servidor responde ao Ping, mas o serviço crítico está parado.
        
    -   🔴 **Crítico:** Disparo de prioridade máxima quando há perda total de conectividade com o host.
        
-   **Mensagens em HTML:** Formatação avançada de alertas para facilitar a leitura via dispositivos móveis (Mobile-First).
    
-   **Gestão de Segredos (Secrets Management):** Implementação de boas práticas de segurança, utilizando `.gitignore` e arquivos de exemplo (`.example`) para proteção de tokens e credenciais.
    

----------

### 📂 Estrutura do Projeto Atualizada

Plaintext

```
NOC-PS-Monitor/
├── config/
│   ├── targets.json           # Configurações locais (Ignorado pelo Git)
│   └── targets.json.example   # Modelo para novos deploys
├── src/
│   └── Monitor-NOC.ps1        # Core do sistema com integração API
├── logs/                      # Histórico de eventos (CSV)
└── README.md

```

----------

### 🛠️ Configuração dos Alertas (Telegram)

Para habilitar as notificações, siga os passos:

1.  Crie um bot no Telegram via **@BotFather** e obtenha seu Token.
    
2.  Obtenha seu Chat ID.
    
3.  Renomeie o arquivo `config/targets.json.example` para `config/targets.json`.
    
4.  Preencha as chaves `TelegramToken` e `ChatID` no arquivo.
    

JSON

```
"Configuracoes": {
    "TelegramToken": "SEU_TOKEN_AQUI",
    "ChatID": "SEU_ID_AQUI",
    "EnviarAlerta": "Sim"
}

```

----------

### 📈 Roadmap de Evolução

-   [x] **Fase 1:** Monitoramento base e logs locais.
    
-   [x] **Fase 2:** Integração com Telegram API e Alertas Multinível.
    
-   [ ] **Fase 3:** **Auto-Healing** (Recuperação automática de serviços).
    
-   [ ] **Fase 4:** Dashboard de Observabilidade em HTML.