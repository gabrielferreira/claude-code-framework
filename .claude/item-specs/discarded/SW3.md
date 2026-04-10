# SW3 — EARS format para requirements

**Contexto:** adotar formato Event-Action-Result-State para requirements nos RFs, tornando-os mecanicamente verificáveis pelo Claude.

**Abordagem:** não implementar sem teste em projeto real primeiro. Está em Wave 2 exatamente por isso — testar EARS em 2-3 specs antes de adotar como padrão no TEMPLATE.md.

**Critérios de aceitação:**
- [ ] EARS testado em ≥2 specs reais de projetos usando o framework
- [ ] Dev que testou confirma que legibilidade é igual ou melhor que formato livre
- [ ] TEMPLATE.md atualizado com seção de RFs em formato EARS
- [ ] spec-creator instrui o Claude a escrever RFs em EARS

**Restrições:** DF4 é o gate — não implementar até avaliar em uso real.

**Descartado em:** 2026-04-10
**Motivo:** Overhead acadêmico. Claude entende linguagem natural — formato EARS não agrega valor mensurável.
