# Threat Model — Prompt Template

Use this template verbatim when generating the repository summary in Phase 1.

---

## Repository Summary Prompt

```
Analyze this repository and produce a structured summary for threat modeling.
Output the following sections exactly:

### Components
List every primary runtime component (service, worker, CLI, library).
For each: name, language, what it does, how it's invoked.

### Data Stores
List every data store (database, cache, file system, in-memory state, blob
storage). For each: technology, what data it holds, access pattern.

### External Integrations
List every external system this codebase calls or receives calls from.
For each: system name, protocol, direction (inbound/outbound/both), purpose.

### Entry Points
List every point where untrusted input enters the system.
For each: location (file:line), input type, current validation (cite it or
state "none identified").

### Secrets and Credentials
List every place credentials, tokens, or secrets are referenced.
For each: type, location, how it's loaded (env var, file, secrets manager).

### Authentication and Authorization
Describe the authn/authz model with evidence. Cite the relevant files.
Note any endpoints or operations that lack auth checks.

### Existing Security Controls
List observable security controls with file/line citations:
- Input validation
- Output encoding
- Rate limiting
- Audit logging
- Encryption at rest
- Encryption in transit

State "None identified" for each category where you find no evidence.
```

---

## Output Contract

The repository summary MUST:

1. Contain only claims verifiable from the codebase or provided architecture
   documentation.
2. Cite specific files and line numbers for every control listed.
3. Never assume a control exists because it "typically" would.
4. Separate runtime behavior from CI/build/test tooling.
5. Use the exact section headers above — the threat enumeration phase depends
   on this structure.

If the repository is too large to analyze fully, state which directories were
analyzed and which were excluded, with reasoning.
