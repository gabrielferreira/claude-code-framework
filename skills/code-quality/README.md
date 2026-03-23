# Skill: Code Quality — {NOME_DO_PROJETO}

> **PROATIVA:** Executar ao finalizar qualquer feature, refactor ou PR.
> Rodar ANTES do commit, junto com `definition-of-done`.

## Quando usar

- Ao criar novo arquivo ou módulo
- Ao modificar mais de 1 arquivo na mesma entrega
- Ao adicionar nova rota, service ou componente
- Quando pedido revisão de qualidade

## Checklist de duplicação

### Verificar antes de commitar

```bash
# 1. Funções duplicadas entre arquivos
# {ADAPTAR: padrão de busca}
grep -rn "function " {src}/*.js | sort -t: -k3 | uniq -d -f2

# 2. Constantes de negócio em mais de um lugar
# {ADAPTAR: valores do projeto}
grep -rn "{valor1}\|{valor2}" {backend}/ {frontend}/ --include="*.js" | grep -v node_modules | grep -v test

# 3. Padrões repetidos que deveriam ser helpers
# {ADAPTAR: patterns do projeto}
```

Se um valor de negócio aparece em mais de 2 arquivos -> extrair para constante compartilhada.

## Regras de qualidade

### Não duplicar

{Listar fontes únicas de verdade do projeto:}

1. **{Funções de segurança}** -> `{path/security.js}`
2. **{Validação de IDs}** -> `{path/validate.js}`
3. **{Preços/planos}** -> `{path/pricing.js}`
4. **{Constantes de negócio}** -> `{path/constants.js}`

### Não repetir padrões

1. **{Transaction}** -> usar helper quando disponível
2. **{Error handling}** -> usar pattern base
3. **{Rate limiter}** -> usar factory, não criar inline
4. **{Pagination}** -> usar helper compartilhado

### Métricas de code smell

| Smell | Threshold | Ação |
|---|---|---|
| Função > 50 linhas | > 50 | Extrair subfunções |
| Arquivo > 500 linhas | > 500 | Considerar split |
| Mesmo bloco > 10 linhas em 2+ arquivos | > 10 | Extrair para helper |
| Magic number em mais de 1 arquivo | > 1 | Extrair para constante |
| `SELECT *` em query | qualquer | Listar colunas |
| `console.log` em produção | qualquer | Usar logger estruturado |

## Componentização

### Quando extrair componente/módulo

- Bloco > 50 linhas usado em mais de 1 lugar -> extrair
- Lógica reutilizável (state + effects) -> extrair hook/helper
- Mesmo visual em múltiplas telas -> extrair componente com props
- Componente/módulo > 300 linhas -> considerar split

### Quando extrair para service/helper

- Função > 30 linhas usada em mais de 1 arquivo -> extrair
- Mesma query SQL em 2+ endpoints -> extrair para helper
- Lógica de negócio em handler/controller -> mover para service

## Quando escalar

Se detectar:
- Mesmo código em 3+ lugares -> **PARE e refatore antes de prosseguir**
- Divergência entre cópias -> **PARE — risco de inconsistência**
- Arquivo > 1000 linhas -> criar spec de refatoração
