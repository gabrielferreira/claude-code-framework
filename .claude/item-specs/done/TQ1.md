# TQ1 — Repo de teste automatizado (test-setup.sh)

**Contexto:** não havia forma automática de verificar se o setup-framework funcionaria corretamente — dependia de teste manual em repo real. Mudanças podiam quebrar o setup silenciosamente.

**Abordagem:** `scripts/test-setup.sh` simula o `/setup-framework` em um repo temporário e verifica 13 categorias de checks (40+ assertions):
- Estrutura de diretórios criada
- Contagem de agents copiados (igual ao source)
- Skills de gestão excluídas (setup-framework, update-framework não vão pro projeto)
- Contagem de docs e skills copiados
- Arquivos raiz presentes (CLAUDE.template.md, SPECS_INDEX.template.md, etc.)
- Templates de spec, PRD, bug presentes
- Scripts copiados
- Migrations copiados
- plugin.json válido (JSON válido + campo version presente)
- framework-tags consistentes em todos os arquivos
- CLAUDE.template.md raw não copiado (só o processado vai)

**Decisões chave:**
- Cria repo git temporário real — não mocka o filesystem
- Roda como job no CI (GitHub Actions) em todo push/PR
- Falha com mensagem clara apontando qual check quebrou

**Entregou:** `scripts/test-setup.sh` + job no `.github/workflows/ci.yml`
