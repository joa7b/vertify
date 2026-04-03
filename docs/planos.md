# Planejamento de Planos — Vertify

## Posicionamento

> "O assistente de IA que cuida dos seus alunos enquanto você cria conteúdo."

O Vertify não é concorrente de Hotmart, Kiwify ou área de membros.
É a **camada de comunicação inteligente** que roda por cima dessas plataformas — o CRM conversacional do produtor digital.

---

## As três dores que o produto resolve

| # | Dor | Como o Vertify resolve |
|---|---|---|
| 1 | **Evasão de até 60%** — alunos somem após a compra | Campanhas de reengajamento automáticas via WhatsApp |
| 2 | **Suporte manual via WhatsApp pessoal** — consome horas do produtor | Assistente de IA responde dúvidas 24/7 |
| 3 | **Leads quentes perdidos no lançamento** — centenas chegam ao mesmo tempo | Modo lançamento: atendimento instantâneo em escala |

---

## Âncora de precificação

O produto não compete com outros SaaS. Compete com:

- **Assistente humana:** R$1.500–2.500/mês
- **Receita perdida por evasão:** um produtor com R$20k/mês que reduz 10% da evasão recupera ~R$1.200/mês em LTV

Qualquer plano abaixo desses valores já é barato para o produtor.

---

## Planos

### Starter — R$97/mês | R$82/mês no anual

**Para quem:** Produtor iniciando, 1 curso, ainda responde suporte sozinho.

| Dimensão | Limite |
|---|---|
| Alunos gerenciados | até 500 |
| Cursos conectados | 1 |
| Integração | Hotmart **ou** Kiwify |
| Números de WhatsApp | 1 |
| Seats (equipe) | 1 |
| Campanhas de reengajamento | sim |
| Suporte | chat |

**Argumento de venda:** *"Menos que contratar uma assistente por 1 dia."*

---

### Pro — R$197/mês | R$161/mês no anual

**Para quem:** Produtor com lançamentos recorrentes, base de alunos crescendo, começa a ter equipe.

| Dimensão | Limite |
|---|---|
| Alunos gerenciados | até 3.000 |
| Cursos conectados | 5 |
| Integrações | Hotmart **+** Kiwify |
| Números de WhatsApp | 3 |
| Seats (equipe) | 3 |
| Modo lançamento (burst) | sim |
| Campanhas automatizadas | ilimitadas |
| Suporte | chat prioritário |

**Argumento de venda:** *"Paga sozinho se recuperar 2 alunos por mês que desistiriam."*

---

### Business — R$397/mês | R$327/mês no anual

**Para quem:** Produtor consolidado, múltiplos produtos, equipe de suporte, lançamentos de alto volume.

| Dimensão | Limite |
|---|---|
| Alunos gerenciados | até 15.000 |
| Cursos conectados | ilimitado |
| Integrações | ilimitadas |
| Números de WhatsApp | ilimitado |
| Seats (equipe) | 5 |
| Suporte | gerente de conta |
| Onboarding | assistido |
| IA personalizada por curso | sim |

**Argumento de venda:** *"Menos que o salário de 1 funcionário CLT de suporte."*

---

## Tabela de preços

| Plano | Mensal | Anual (por mês) | Economia anual |
|---|---|---|---|
| Starter | R$97 | R$82 | R$180 |
| Pro | R$197 | R$161 | R$432 |
| Business | R$397 | R$327 | R$840 |

O desconto anual representa aproximadamente 15–18% sobre o valor mensal.

---

## Escala de valor entre planos

```
R$97 ─────────────── R$197 ─────────────── R$397
  │                    │                     │
  │ +R$100             │ +R$200              │
  │                    │                     │
Automatiza        Escala para          Substitui
o suporte         lançamentos          uma equipe
do dia a dia      + multi-curso        de suporte
```

O salto Starter → Pro (+R$100) é justificado pelo **modo lançamento** — onde a maior dor acontece.
O salto Pro → Business (+R$200) é justificado pela **escala de contatos** e **suporte dedicado**.

---

## Trial

- **14 dias grátis no plano Pro** (não no Starter — força experimentar o plano com mais valor)
- Downgrade para Starter disponível após o trial
- Sem cartão de crédito para iniciar

---

## Dimensões técnicas a implementar no código

Os planos atuais usam `quotes.chatbots`, `quotes.kbs` e `quotes.namespace`.
Para este posicionamento, as dimensões relevantes são:

| Campo atual | Campo proposto | Descrição |
|---|---|---|
| `quotes.chatbots` | `quotes.products` | Cursos/produtos conectados |
| `quotes.kbs` | — | Absorvido por `products` |
| `quotes.namespace` | — | Absorvido por `products` |
| *(não existe)* | `quotes.contacts` | Alunos gerenciados |
| *(não existe)* | `quotes.whatsapp` | Números de WhatsApp ativos |
| *(não existe)* | `quotes.integrations` | Integrações ativas (Hotmart, Kiwify) |
| `profile.agents` | `profile.agents` | Seats da equipe (mantém) |

---

## Planos legados

Os planos anteriores (SANDBOX, BASIC, PREMIUM, TEAM, GROWTH, SCALE, PLUS) devem ser mantidos
no backend para usuários existentes, mas não exibidos em novas aquisições.
