# Política de Segurança

## Versões suportadas

Apenas a versão **mais recente** do framework é suportada com atualizações de segurança. Consulte [Releases](https://github.com/gabrielferreira/claude-code-framework/releases) para a versão atual.

## Como reportar uma vulnerabilidade

**Não abra issues públicas para relatar vulnerabilidades de segurança.**

Para reportar uma vulnerabilidade, use [Private Vulnerability Reporting](https://github.com/gabrielferreira/claude-code-framework/security/advisories/new) do GitHub:

1. Acesse a aba **Security** do repositório
2. Clique em **Report a vulnerability**
3. Preencha os detalhes: descrição, passos pra reproduzir, impacto estimado

Se preferir e-mail, use o endereço do mantenedor principal disponível no perfil do GitHub.

## Escopo

Este framework é um conjunto de skills, agents e templates markdown distribuídos para projetos. As classes de vulnerabilidade relevantes aqui incluem:

- **Injection em scripts distribuídos** (`scripts/verify.sh`, `scripts/release.sh`) — comandos que processam input não confiável de forma insegura
- **Exfiltração via skills/agents** — instruções que poderiam levar o Claude a ler/vazar segredos do projeto que o usa
- **Supply chain** — dependências npm/pip utilizadas pelos scripts (poucas hoje) com vulnerabilidades conhecidas
- **Exposição em templates** — placeholders que por engano levem segredos pro projeto downstream

Não estão em escopo: vulnerabilidades em projetos específicos que usam o framework (relate no repositório daquele projeto), problemas no Claude Code em si (relate à Anthropic), vulnerabilidades em MCPs de terceiros.

## Processo de resposta

- **< 48h**: confirmação de recebimento
- **< 7 dias**: triagem inicial e classificação de severidade
- **< 30 dias**: fix + release para vulnerabilidades altas/críticas
- Para vulnerabilidades low/medium, prazo pactuado durante a triagem

Após fix publicado, aguardaremos pelo menos 7 dias antes da divulgação pública via GitHub Security Advisory, dando tempo pra projetos downstream atualizarem.

## Credenciais do reportador

Creditamos reportadores responsáveis no advisory público, a menos que prefiram anonimato.
