
# 🛡️ NOC-PS-Monitor (v3.0 - Self-Healing Edition)

O **NOC-PS-Monitor** é uma solução de **Engenharia de Confiabilidade (SRE)** e monitoramento de ativos desenvolvida em PowerShell. O projeto evoluiu de um simples verificador de status para uma ferramenta de automação inteligente capaz de diagnosticar e recuperar serviços críticos sem intervenção humana.

> **Status Atual:** 🚀 **Fase 3 Concluída** - Implementação de Auto-Healing e Refatoração de Código.

----------

### 🛠️ Evolução do Projeto (Changelog)

#### **Fase 1: A Fundação (Monitoramento Core)**

-   **Monitoramento Híbrido:** Validação de conectividade (ICMP/Ping) e status de serviços Windows.
    
-   **Arquitetura Modular:** Separação total entre lógica de execução e dados de configuração (JSON).
    
-   **Logs de Auditoria:** Geração de arquivos `.csv` para análise histórica e conformidade.
    

#### **Fase 2: Conectividade e Alertas (Telegram API)**

-   **Notificações em Tempo Real:** Integração com a **API do Telegram** para alertas instantâneos no celular.
    
-   **Alertas Multinível:** Diferenciação visual entre **Saudável** (OK), **Serviço Parado** (Warning) e **Host Offline** (Critical).
    
-   **Segurança de Dados:** Implementação de boas práticas de _Secrets Management_ com `.gitignore` e modelos de configuração (`.example`).
    

#### **Fase 3: Automação Inteligente (Auto-Healing)**

-   **Recuperação Automática:** O script tenta reiniciar serviços parados automaticamente antes de escalar o incidente.
    
-   **Lógica de Confirmação:** Validação de status pós-reparo para garantir que a aplicação subiu corretamente.
    
-   **Código Refatorado:** Implementação de tratamento de erros (`Try/Catch`) e otimização do fluxo de mensagens.
    

----------

### 📂 Estrutura do Repositório

**Pasta**

**Conteúdo**

`src/`

`Monitor-NOC.ps1` (Script principal refatorado).

`config/`

Configurações de alvos e credenciais da API.

`logs/`

Histórico de eventos e ações de recuperação.

----------

### 🚀 Como Rodar o Sistema

1.  **Configuração Inicial:**
    
    -   Renomeie `config/targets.json.example` para `config/targets.json`.
        
    -   Configure seu **Token do Telegram**, **ChatID** e ative o `AutoHealing` como `"Sim"`.
        
2.  **Execução:**
    
    -   Abra o PowerShell como Administrador.
        
    -   Execute: `.\src\Monitor-NOC.ps1`