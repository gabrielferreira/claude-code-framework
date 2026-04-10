<!-- framework-tag: v2.38.0 framework-file: skills/dependency-audit/README.md -->
# Skill: Dependency Audit

> Use esta skill ao adicionar, atualizar ou revisar dependencias do projeto.
> Rode este checklist ANTES de instalar pacote novo ou fazer upgrade de versao.
>
> **Foco:** vulnerabilidades, versoes desatualizadas, licencas, bundle size.

## Quando usar

- Ao adicionar nova dependencia (`npm install`, `pip install`, `go get`, `cargo add`, `dart pub add`, `dotnet add package`)
- Ao fazer upgrade de versao (minor ou major)
- Ao revisar PR que altera lock file
- Em auditoria periodica (mensal recomendado)
- Ao preparar release para producao

## Quando NAO usar

- Para analise de codigo proprio — usar skill code-quality
- Para performance de runtime — usar agent `performance-audit`
- Para vulnerabilidades no codigo (nao em deps) — usar skill security-review

## Checklist

### Vulnerabilidades conhecidas

- [ ] `npm audit` / `pip audit` / `govulncheck` executado sem findings criticos
- [ ] CVEs com severidade alta/critica resolvidos ou com workaround documentado
- [ ] Dependencias diretas sem vulnerabilidades conhecidas
- [ ] Dependencias transitivas auditadas (cadeia completa)

### Versoes desatualizadas

- [ ] Patch updates aplicados (seguranca e bug fixes)
- [ ] Minor updates avaliados (features novas, breaking em edge cases)
- [ ] Major updates com plano de migracao (changelog lido, testes adaptados)
- [ ] Nenhuma dependencia presa em versao end-of-life

### Licencas

- [ ] Licenca de cada dep compativel com o projeto
- [ ] GPL/AGPL NAO presente em projeto MIT/Apache (contaminacao)
- [ ] Licencas de dependencias transitivas verificadas
- [ ] `license-checker` ou equivalente rodando em CI

### Dependencias abandonadas

- [ ] Sem dependencia com ultimo commit > 1 ano (risco de seguranca)
- [ ] Sem dependencia com issues abertas criticas sem resposta
- [ ] Alternativa identificada para deps em risco de abandono
- [ ] Forks avaliados quando mantainer original parou

### Bundle size impact

- [ ] Nova dep avaliada por tamanho (`bundlephobia.com` ou equivalente)
- [ ] Tree shaking funcionando (import especifico, nao import total)
- [ ] Alternativa menor considerada (ex: `date-fns` vs `moment`)
- [ ] Impacto medido antes e depois da adicao

### Lock file

- [ ] Lock file presente e commitado (`package-lock.json`, `poetry.lock`, `go.sum`, `Cargo.lock`, `pubspec.lock`, `packages.lock.json`)
- [ ] Lock file atualizado apos qualquer mudanca de deps
- [ ] Nenhuma divergencia entre manifest e lock file
- [ ] CI instala com flag frozen (`npm ci`, `pip install --require-hashes`)

### Dependencias transitivas

- [ ] Arvore de deps revisada para pacotes desconhecidos
- [ ] Sem duplicacao de versao da mesma lib (ex: dois lodash diferentes)
- [ ] Pacotes com muitas deps transitivas avaliados criticamente
- [ ] `npm ls --all` / `pipdeptree` sem warnings

## Exemplos concretos

```bash
# Node.js — auditoria completa
npm audit --audit-level=high
npx license-checker --failOn "GPL-2.0;GPL-3.0;AGPL-3.0"
npx depcheck                    # deps nao utilizadas
npx bundlephobia-cli lodash     # tamanho antes de instalar

# Python — auditoria completa
pip audit
pip-licenses --fail-on="GPL-2.0;GPL-3.0"
pipdeptree --warn silence       # arvore de deps

# Go — auditoria completa
govulncheck ./...
go mod tidy                     # remover deps nao usadas
go mod verify                   # integridade do go.sum

# Rust — auditoria completa
cargo audit                     # CVEs no RustSec advisory database
cargo outdated                  # versoes desatualizadas
cargo deny check licenses       # licencas proibidas (requer cargo-deny)
cargo tree                      # arvore de deps transitivas

# Dart — auditoria completa
dart pub outdated               # versoes desatualizadas
dart pub audit                  # vulnerabilidades conhecidas (Dart 3.3+)
flutter pub deps --style=tree   # arvore de deps (projetos Flutter)

# C# (.NET) — auditoria completa
dotnet list package --vulnerable --include-transitive  # CVEs conhecidos
dotnet list package --outdated                         # versoes desatualizadas
dotnet restore                  # valida integridade do packages.lock.json
```

## Regras

1. **Zero vulnerabilidades criticas em producao.** Alta severidade = bloqueia deploy.
2. **Lock file sempre commitado.** Sem lock file = builds nao reproduziveis.
3. **Licenca verificada antes de instalar.** GPL em projeto proprietario = risco legal.
4. **Bundle size medido em CI.** Regressao de tamanho > 10% = investigar.
5. **Dep abandonada = risco.** Sem atividade > 1 ano = planejar substituicao.
