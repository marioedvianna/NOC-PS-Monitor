# 🛡️ NOC-PS-Monitor

O **NOC-PS-Monitor** é uma solução leve e modular desenvolvida em **PowerShell** para monitoramento em tempo real de ativos de rede e serviços críticos do Windows.

Diferente de scripts simples, este projeto foi estruturado para servir como o alicerce de um **Centro de Operações de Rede (NOC)**, separando a lógica de execução dos dados de configuração, permitindo escalabilidade e facilidade de manutenção.

----------

### 🚀 Funcionalidades Atuais (Fase 1)

-   **Monitoramento Híbrido:** Validação de conectividade (ICMP/Ping) e status de serviços do Windows no mesmo fluxo.
    
-   **Configuração via JSON:** Gerenciamento centralizado de alvos (IPs e Serviços) sem necessidade de alterar o código-fonte.
    
-   **Interface Visual:** Saída em console com cores intuitivas para identificação imediata de incidentes (Verde/Amarelo/Vermelho).
    
-   **Resumo Executivo:** Contador dinâmico de status ao final da execução para visão rápida da saúde do ambiente.
    
-   **Logs de Auditoria:** Geração automática de histórico em formato `.csv` para análise posterior e conformidade.
    

----------

### 📂 Estrutura do Projeto

**Pasta**

**Descrição**

`src/`

Contém o script principal de monitoramento (`Monitor-NOC.ps1`).

`config/`

Arquivos de configuração em JSON para definição de alvos.

`logs/`

Armazenamento dos logs históricos gerados pelo sistema.

----------

### 🛠️ Como Utilizar

1.  **Configuração:** Edite o arquivo `config/targets.json` adicionando os servidores e serviços que deseja monitorar:
    
    JSON
    
    ```
    {
        "Servidores": [
            { "Nome": "Servidor AD", "IP": "10.0.0.1", "Servico": "ntds" }
        ]
    }
    
    ```
    
2.  **Execução:** Abra o PowerShell como Administrador e execute:
    
    PowerShell
    
    ```
    .\src\Monitor-NOC.ps1
    
    ```
    

----------

### 📈 Roadmap de Evolução (Espaço para Crescimento)

Este projeto foi desenhado para evoluir. As próximas etapas de desenvolvimento incluem:

-   **Fase 2:** Implementação de alertas automáticos via **Telegram/Teams API**.
    
-   **Fase 3:** Sistema de **Auto-Healing** (tentativa automática de reinício de serviços parados).
    
-   **Fase 4:** Interface de visualização em **Dashboard HTML** responsivo.