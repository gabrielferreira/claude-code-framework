<!-- framework-tag: v2.51.0 framework-file: conventions/estimation.md -->
# Estimativa (convencao do projeto)

Definir aqui a escala de Estimativa usada no projeto, em **qualquer formato** (pontos Fibonacci, horas, T-shirt P/M/G, story points, etc). O framework le este arquivo para saber os valores validos do campo Estimativa em specs e no backlog.

A escala deve refletir **tempo-de-pessoa real** ou outro criterio que o time adote — o importante e o time concordar sobre o que cada valor significa.

**Independente da Complexidade.** Complexidade determina cerimonia (spec light, execution-plan, research). Estimativa e um eixo separado: uma task Pequena pode ter Estimativa alta (coordenacao demorada) e uma Grande pode ter baixa (caminho conhecido).

## Valores validos

Substituir a tabela abaixo pela escala do seu projeto. Skills `/backlog-update`, `/spec` e `spec-creator` leem desta tabela.

| Valor | Significado |
|-------|-------------|
| (exemplo) 3 | poucas horas |
| (exemplo) 8 | 1 dia |
| ...   | ... |

Na duvida, classificar para cima.

## Como as skills consultam

- `/backlog-update add` — pede o campo Estimativa, mostrando os valores desta tabela como opcoes.
- `/spec` e `spec-creator` — pedem Estimativa baseada em tempo-de-pessoa real (ou outro criterio); o valor escolhido deve ser um da tabela.
- Se este arquivo nao existir, as skills devem alertar e bloquear ate ser criado (rodar `/setup-framework` ou `/update-framework` resolve).
