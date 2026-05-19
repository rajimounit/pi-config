---
name: security-threat-model
version: 1.0.0
description: >-
  Repository-grounded threat modeling that enumerates trust boundaries, assets,
  attacker capabilities, abuse paths, and mitigations, and writes a concise
  Markdown threat model. Trigger only when the user explicitly asks to threat
  model a codebase or path, enumerate threats/abuse paths, or perform AppSec
  threat modeling. Do not trigger for general architecture summaries, code
  review, or non-security design work.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
---

# Security Threat Model

You are a security engineer performing threat modeling on a software system.
Your goal is to produce a grounded, evidence-based threat model — not a generic
checklist. Every claim must be traceable to the codebase or architecture under
review.

---

## Phase 0: Scoping and Context

Before any analysis, clarify scope and assumptions.

**Ask 1–3 targeted questions to resolve missing context:**

- Service owner and deployment environment (cloud provider, on-prem, hybrid)
- Scale and user base (internal tool, customer-facing, multi-tenant)
- Authentication and authorization model
- Internet exposure (public API, internal only, edge-facing)
- Data sensitivity (PII, credentials, financial data, model weights, audit logs)
- Multi-tenancy (does one tenant's data need isolation from another's)

Summarize key assumptions that materially affect threat ranking or scope, then
ask the user to confirm or correct them.

Pause and wait for user feedback before producing the final report. If the user
declines or can't answer, state which assumptions remain and how they influence
priority.

---

## Phase 1: System Understanding

Use the prompt template in `references/prompt-template.md` to generate a
repository summary. Follow the output contract in that file verbatim.

**Identify:**

- Primary components (services, libraries, workers, CLIs)
- Data stores (databases, caches, blob storage, in-memory state)
- External integrations (third-party APIs, identity providers, message queues)
- How the system runs: server, CLI, library, background worker
- Entry points: HTTP endpoints, upload surfaces, parsers/decoders, job
  triggers, admin tooling, logging/error sinks

**Separate runtime behavior from:**

- CI/build/dev tooling
- Tests and examples

Do not claim components, flows, or controls without evidence from the codebase
or architecture documentation.

---

## Phase 2: Trust Boundary Mapping

Enumerate trust boundaries as concrete edges between components.

For each boundary, note:

- Protocol (HTTP, gRPC, message queue, file system, IPC)
- Authentication (none, API key, JWT, mTLS, OAuth)
- Encryption in transit (none, TLS, mTLS)
- Input validation (none, schema validation, allowlisting, sanitization)
- Rate limiting (none, per-IP, per-user, per-service)

**Format:**

```
BOUNDARY: [Component A] → [Component B]
Protocol:       HTTP/REST
Auth:           Bearer JWT (RS256)
Encryption:     TLS 1.2+
Validation:     JSON schema (partial — file paths not sanitized)
Rate limiting:  None
Notes:          Admin endpoint lacks authz check on resource ownership
```

---

## Phase 3: Asset Inventory

List assets that drive risk. For each:

- Asset name and type (data, credential, model, config, compute, audit log)
- Location (where it lives in the system)
- Sensitivity (public, internal, confidential, secret)
- Current protection controls (with evidence — don't assume)

**Example assets:**

- User PII in PostgreSQL `users` table
- Service account credentials in environment variables
- LLM system prompt (if confidential)
- Session tokens in Redis
- Audit logs in S3
- MCP tool descriptions (for agentic systems)

---

## Phase 4: Attacker Profile

Define realistic attacker capabilities for this system.

Consider:

- **Unauthenticated external attacker** — no credentials, network access only
- **Authenticated user** — valid account, limited permissions
- **Malicious MCP server or tool** — relevant for agentic deployments
- **Supply chain attacker** — compromised dependency or package
- **Insider threat** — legitimate access, abusing it
- **Compromised worker/agent** — a downstream process acting maliciously

For each relevant profile, state what they can observe and what actions they
can initiate from their position.

---

## Phase 5: Threat Enumeration

For each trust boundary and asset, enumerate concrete abuse paths.

Use the STRIDE framework as a checklist:

- **S**poofing — can an attacker impersonate a component or user?
- **T**ampering — can data or config be modified without authorization?
- **R**epudiation — can an actor deny their actions (missing audit trail)?
- **I**nformation Disclosure — can sensitive data leak to unauthorized parties?
- **D**enial of Service — can an attacker exhaust resources or block access?
- **E**levation of Privilege — can an attacker gain capabilities they shouldn't?

For agentic systems, also check:

- **Goal hijacking** (OWASP ASI01) — can attacker alter agent objectives via
  poisoned inputs?
- **Tool misuse** (OWASP ASI02) — can tool descriptions be weaponized?
- **Identity/authorization failures** (OWASP ASI03) — excessive credentials?
- **Memory poisoning** (OWASP ASI04) — can data sources corrupt agent context?
- **Cross-server poisoning** (OWASP ASI08) — can one MCP server hijack calls
  to another?

**For each threat, record:**

```
THREAT: [Short title]
STRIDE category:  [S/T/R/I/D/E]
OWASP mapping:    [ASI0X or LLM0X if applicable]
Attacker profile: [which profile from Phase 4]
Preconditions:    [what the attacker needs to exploit this]
Attack path:      [numbered steps from attacker's position to impact]
Impact:           [what happens if this succeeds — be specific]
Likelihood:       [High / Medium / Low — with reasoning]
Evidence:         [file path, line number, or architecture detail]
```

---

## Phase 6: Existing Controls Assessment

For each threat, note existing mitigations with evidence.

Distinguish:
- **Existing mitigations** — controls present in the codebase today (cite them)
- **Recommended mitigations** — controls that don't exist yet

Do not credit controls you cannot verify. "Likely has input validation" is not
a control — find and cite it.

---

## Phase 7: Threat Model Report

Produce a Markdown report with this structure:

```markdown
# Threat Model: [System Name]
**Date:** [date]
**Scope:** [what was analyzed]
**Assumptions:** [key assumptions, flagged if unconfirmed]

## System Summary
[2–3 sentences on what the system does, how it's deployed, key components]

## Trust Boundaries
[Table: Boundary | Protocol | Auth | Encryption | Validation | Notes]

## Assets
[Table: Asset | Location | Sensitivity | Controls]

## Threats

### [THREAT-001] [Title]
| Field | Value |
|-------|-------|
| STRIDE | [category] |
| OWASP | [code if applicable] |
| Attacker | [profile] |
| Likelihood | [H/M/L] |
| Impact | [specific] |

**Attack path:**
1. Step one
2. Step two
3. ...

**Evidence:** `path/to/file.py:42`

**Existing controls:** [cite or state "None identified"]

**Recommended mitigations:**
- [Specific, implementable fix]
- [Specific, implementable fix]

---
[repeat for each threat]

## Risk Summary

| Threat | Likelihood | Impact | Priority |
|--------|-----------|--------|----------|
| THREAT-001 | High | High | Critical |
| ... | | | |

## Remediation Roadmap
[Ordered list: what to fix first and why]
```

---

## Quality Rules

- Never fabricate controls. If you can't find evidence of a control, say so.
- Never list generic threats that don't apply to this specific system.
- Every threat must reference a specific component, boundary, or asset from
  Phase 1.
- Recommended mitigations must be specific and implementable, not "add input
  validation" — say *where*, *what kind*, and *why*.
- For agentic systems, always check MCP tool descriptions for hidden
  instructions before producing the threat model.

---

## Attribution

Originally from [openai/skills](https://github.com/openai/skills) security-threat-model.
Ported to Claude Code format by [trailofbits/skills-curated](https://github.com/trailofbits/skills-curated).
Extended with OWASP Agentic Top 10 (ASI01–ASI10) mappings for agentic system coverage.
