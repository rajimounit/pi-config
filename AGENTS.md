# AGENTS - Prompt socle commun (AVV Assist Pro)

Ce fichier est le socle commun pour tous les agents IA du projet.
Chaque agent applique ce socle puis son prompt de rôle.

## 0) Mode Autopilot (par défaut)
Quand l'utilisateur décrit seulement une évolution métier/technique, l'agent doit:
- détecter automatiquement le type de tâche,
- choisir le rôle et la séquence d'orchestration adaptés,
- détecter les fichiers impactés probables,
- exécuter les checks pertinents,
- livrer le résultat sans demander de format supplémentaire.

Routage automatique attendu:
- Demande de review explicite -> mode REVIEW.
- Demande documentation explicite -> mode DOCS.
- Demande catalogue/ingestion/data explicite -> mode DATA (+ validation QA ciblée).
- Demande de fix/feature/refactor locale -> mode DEV -> REVIEW -> DEV fix -> QA.
- Si comportement utilisateur/API/workflow change -> ajouter DOCS en fin de séquence.

Politique de clarification:
- Poser une question uniquement si blocage réel (ambiguïté critique, choix métier irréversible, risque destructif).
- Sinon faire l'hypothèse la plus sûre, l'implémenter, puis l'expliquer dans la restitution.

## 1) Périmètre produit
- Produit: AVV Assist Pro (qualification avant-vente cloud/hybride).
- Front: `avv_assist` (SPA HTML/CSS/JS) - dev server sur `http://localhost:8082`.
- Backend: `backend` (NestJS) - API sur `http://localhost:3002`.
- DB: PostgreSQL (conteneur historique `avv-postgres` ou `avv_postgres`).

## 2) Base historique vérifiée (sources)
Règles dérivées des interactions et livrables déjà produits, vérifiées dans:
- `README.md`
- `docs/RUNBOOK.md`
- `docs/WORKFLOWS.md`
- `docs/ADMIN_IA.md`
- `docs/AI_LOCAL.md`
- `docs/INGESTION.md`
- `docs/SITE_MAP.md`
- `docs/SERVICE_DEFINITIONS.md`
- `docs/CLOUD_PROVIDER_REFERENCE.md`
- `avv_assist/CHANGELOG.md`
- `avv_assist/PHASE1_AUDIT_REPORT.md`
- `avv_assist/PHASE2_TARGET_SOLUTION.md`
- Historique git jusqu'au `2026-02-16` (`feat(ai)` + correctifs stack/dev/docs)

## 3) Décisions historiques à respecter

### 3.1 Architecture et flux
- Le front reste une SPA sans framework build (pas de React/Vite ajoutés sans demande explicite).
- Le backend est l'unique point d'accès IA (`/ai/chat`, `/ai/providers`, `/ai/health`).
- Le state front persiste en localStorage et se synchronise au backend (`opportunities`) via `Store.syncToBackend`.
- Toute évolution de schéma state doit garder la migration/rétrocompatibilité.

### 3.2 Navigation et parcours métier
- Le wizard est séquentiel: le verrouillage d'étape via validation ne doit pas être cassé.
- Les routes cachées (`deliverables`, `excel_import`, `price_list_admin`, `user_guide`) ne doivent être exposées que volontairement.
- La visibilité des modules dépend du scénario (cloud_only/hybrid/colocation/dedicated_cloud).

### 3.3 IA V1.1
- Profils IA backend-only (aucune clé API côté front).
- Routage par usage (`review`, `excel`) avec fallback.
- Validation humaine obligatoire du rendu IA avant injection (sauf demande explicite contraire).
- Les providers legacy peuvent être visibles mais non utilisés en production V1.

### 3.4 Livrables
- Cohérence attendue entre HTML, PDF, PPTX, email interne.
- Toute correction de calcul/format doit être propagée aux canaux concernés.
- Ne pas introduire d'écart de contenu entre "Restitution" et livrables exportés.

### 3.5 Données et catalogue
- Pipeline ingestion traçable: source -> parsing -> normalisation -> validation schéma.
- Déduplication par code service et conservation des références de provenance.
- Toute ambiguïté métier du catalogue doit être marquée pour revue humaine.

## 4) Règles d'implémentation
- Changement minimal et ciblé.
- Préserver conventions existantes (naming, structure, API).
- Éviter les refactors larges hors scope.
- Ajouter un commentaire uniquement si la logique est non évidente.
- Ne jamais inventer un résultat de test non exécuté.
- Pour les correctifs CSS purs (aucun JS ni backend modifié): pas de restart Docker nécessaire. Le hot-reload front suffit. Checks requis: `npm run lint` (dans `avv_assist`) + `bash scripts/smoke-front.sh` uniquement.

## 5) Validation minimale attendue
Exécuter uniquement les checks pertinents selon la zone modifiée.

Backend (`backend`):
- `npm run lint:check`
- `npm test`
- `npm run build`

Front (`avv_assist`):
- `npm run lint`
- `npm test`

Impacts stack/dev/IA:
- `bash scripts/dev.sh`
- `curl -sS http://localhost:3002/ai/providers`
- `curl -sS http://localhost:3002/ai/health`
- `bash scripts/smoke-back.sh`
- `bash scripts/smoke-front.sh`

## 6) Zones sensibles (revue renforcée)
Ces fichiers ont été souvent modifiés et demandent une vigilance accrue:
- `avv_assist/index.html`
- `avv_assist/js/core/version.js`
- `avv_assist/js/core/store.js`
- `avv_assist/js/core/router.js`
- `avv_assist/css/base.css`
- `avv_assist/css/layout.css`
- `avv_assist/js/modules/review.js`
- `avv_assist/js/modules/excel_importer.js`
- `avv_assist/js/modules/deliverables.js`
- `avv_assist/js/utils/pdf_generator.js`
- `avv_assist/js/utils/pptx_generator.js`
- `scripts/dev.sh`
- `docs/RUNBOOK.md`
- `docs/WORKFLOWS.md`

## 7) Definition of Done
Un travail est "Done" si:
- besoin fonctionnel couvert,
- diff lisible et limité,
- checks pertinents exécutés (ou limite clairement signalée),
- risques/régressions explicités,
- restitution finale avec fichiers touchés et impacts.

## 8) Interdits
- Exposer ou versionner des secrets.
- Contourner le flux IA backend-only.
- Casser la validation humaine avant injection IA sans demande explicite.
- Changer des données métier de façon destructive sans instruction explicite.

## 9) Format de restitution attendu
- Résultat: ce qui a changé et pourquoi.
- Vérifications: commandes exécutées + statut.
- Risques/limites: ce qui reste ouvert.
- Next steps: seulement si utile.

## 10) Entrée minimale utilisateur (zéro friction)
Entrée recommandée si tu veux ne rien piloter manuellement:
- `Demande: <ce que tu veux obtenir>`
- `Contrainte optionnelle: <deadline, techno imposée, scope interdit>`

L'agent doit déduire le reste automatiquement depuis ce socle.

## 11) Git workflow recommandé (petite feature/fix)
Séquence standard à appliquer:
1. `git switch develop` (s'assurer d'être sur la bonne base)
   `git switch -c feat/<nom-court>` (ou `fix/<nom-court>`)
2. Implémenter les changements.
3. `git status --short`
4. `git add <fichiers-liés>` (stager uniquement ce qui est lié à la demande)
5. `git commit -m "<type(scope): message>"`
6. `git push -u origin <branche>`
7. Ouvrir une PR vers `develop`
8. Après validation, merger dans `develop` puis supprimer la branche

Attention: ne jamais pousser directement sur `main`.
`main` est la branche de release stable et reçoit uniquement les merges validés depuis `develop`.

Règles:
- Une branche par sujet (pas de mélange de sujets dans un même commit).
- Commit atomique et message explicite.
- Pas de commit de fichiers temporaires/non liés.

## 12) Versioning + anti-cache (règles simples)
Quand un changement impacte le front livré (JS/CSS/HTML):
1. Appliquer SemVer simple:
- `patch`: correctif / amélioration interne sans rupture.
- `minor`: nouvelle feature compatible.
- `major`: rupture de compatibilité.
2. Mettre à jour `avv_assist/js/core/version.js`:
- `full`, `major`, `minor`, `patch` doivent rester cohérents.
3. Mettre à jour le cache-busting dans `avv_assist/index.html`:
- sur chaque asset JS/CSS **modifié** et référencé, mettre `?v=<Version.full>`.
- tout nouveau fichier CSS ajouté dans `index.html` doit porter un `?v=` dès sa première inclusion. Ne jamais référencer un asset CSS sans cache-buster.
4. Vérifier l'affichage version côté UI:
- placeholder `#app-version` dans `avv_assist/index.html` aligné avec la version courante (même si `app.js` l'écrase au runtime).

Objectif:
- éviter les faux incidents causés par cache navigateur,
- garder une version lisible et traçable dans les retours utilisateurs.

## 13) Branche de travail principale
La branche d'intégration du projet est `develop`.

- Toute branche `fix/<x>` ou `feat/<x>` est créée **depuis** `develop` et **mergée dans `develop` via PR** après validation.
- `main`: branche de release stable, reçoit uniquement les merges validés depuis `develop`.
- Ne jamais pousser directement sur `main`.

Commande de vérification avant toute nouvelle branche:
`git branch --show-current` -> doit afficher `develop`

## pi-autoresearch (AVV Assist Pro)

When asked to improve code autonomously:
- Use skill autoresearch-create to start a benchmark session
- checks.sh in the repo root defines success criteria
- Score 100 = TS compiles + no console.log + no secrets
- autoresearch-finalize commits if score improves, reverts if it drops
## Model Fleet — Recommendation Rules

Available models via llama-cpp (port 8081):

| Alias       | Model                       | Best for                         | Speed    |
|-------------|-----------------------------|----------------------------------|----------|
| llama       | Qwen3-Coder-30B-A3B         | Code generation, refactoring     | ~76 t/s  |
| llama35     | Qwen3.6-35B-A3B             | Architecture, reasoning, writing | ~60 t/s  |
| llama32     | Qwen2.5-Coder-32B           | Large code context, dense code   | ~40 t/s  |
| llama7      | Qwen2.5-Coder-7B            | Quick edits, fast answers        | ~180 t/s |
| llama9      | Qwen3.5-9B Reasoning        | Logic, math, chain-of-thought    | ~150 t/s |
| llamavision | Qwen2.5-VL-7B               | Images, screenshots, diagrams    | ~50 t/s  |

Available via Ollama:

| Model           | Best for                      |
|-----------------|-------------------------------|
| pi-qwen3-vl     | Vision fallback (Ollama)      |
| deepseek-r1:32b | Deep reasoning, research      |

When to suggest a model switch:
- User asks to analyze an image or screenshot -> suggest llamavision
- Task is a quick fix or single-line change -> suggest llama7 (2x faster)
- Task requires architecture review or long-form writing -> suggest llama35
- Task involves math, logic, or multi-step reasoning -> suggest llama9
- Currently on non-coder model and user opens a coding task -> suggest llama

How to recommend (exact format):
"Model suggestion: [alias] would handle this better because [one reason].
Run [alias] in a new terminal and restart Pi to switch. Continue with current model in the meantime?"

Never switch automatically. Never assume the user accepted. Wait for explicit confirmation.

## Model Fleet — Recommendation Rules

### llama-cpp (port 8081) — custom CUDA build, KV q8_0, large context

| Alias       | Model                    | Vision | CTX  | Best for                          |
|-------------|--------------------------|--------|------|-----------------------------------|
| llama       | Qwen3-Coder-30B Q4_K_M  | non    | 98k  | Code generation, refactoring      |
| llama35     | Qwen3.6-35B UD-Q3_K_S   | oui    | 65k  | Architecture, reasoning, images   |
| llama32     | Qwen2.5-Coder-32B Q4_K_M| non    | 32k  | Dense code, large files           |
| llamavision | Qwen2.5-VL-7B Q4_K_M    | oui    | 32k  | Screenshots, diagrams, fast vision|

### Ollama (port 11434) — acces direct via provider ollama/

| Model                  | Best for                            |
|------------------------|-------------------------------------|
| qwen3.6:35b-a3b        | Alternative 35b (Ollama managed)    |
| qwen3:30b              | Alternative 30b (Ollama managed)    |
| deepseek-r1:32b        | Deep reasoning, research            |
| gemma4:31b             | Long context, multilingual          |
| pi-qwen3-vl            | Vision fallback via Ollama          |
| bge-m3                 | Embeddings, semantic search         |
| qwen3-embedding        | Embeddings alternative              |

### Switch recommendations

- User asks to analyze image/screenshot → llamavision (fast) or llama35 (deeper analysis)
- Task is architecture review or long writing → llama35
- Task is coding, refactoring, PR review → llama (default)
- Task needs dense large file analysis → llama32
- Task needs deep reasoning or research → deepseek-r1:32b via Ollama
- Task needs embeddings → bge-m3 via Ollama (no switch needed, separate endpoint)

### How to recommend (exact format)

"Model suggestion: [alias] would handle this better because [one reason].
Run [alias] in a new terminal and restart Pi to switch. Continue with current model in the meantime?"

Never switch automatically. Never assume the user accepted. Wait for explicit confirmation.

## Workflow recommandé — Plan-First

Avant toute feature, bug fix ou refactor, suivre le workflow **plan-first** :

1. **Analyser** le projet (structure, package.json, README, TODO existants)
2. **Poser** au maximum 5 questions critiques en une seule fois
3. **Créer** un `TODO.md` avec des tâches petites, vérifiables, ordonnées par dépendance
4. **Demander** approbation utilisateur avant toute exécution
5. **Exécuter** une tâche à la fois, marquer `[x]` au fur et à mesure

Règles:
- NEVER write code, create files, or run commands before a TODO.md is approved.
- NEVER go off-plan. If new work is discovered, add it to TODO.md and ask for approval.
- Tasks must be small and independently verifiable.

See: `~/.pi/skills/plan-first/SKILL.md` for full workflow specification.

## Skills installés (practitioner-knowledge)

Les skills suivants ont été extraits du repo `practitioner-knowledge` et installés :

- `~/.pi/skills/humanizer/SKILL.md` — Dé-AI-fication du texte (prompt on-demand)
- `~/.pi/skills/security-threat-model/SKILL.md` — Threat modeling en 7 phases (on-demand)
- `~/.pi/prompts/threat-model-summary.md` — Template générique pour résumé de repo (prompt template)

<!-- SKILLS-INDEX-START -->
## 🛠 Installed Skills

**humanizer** — You are a writing editor that identifies and removes signs of AI-generated text
  → `humanize this: [ton texte]`

**security-threat-model** — You are a security engineer performing threat modeling on a software system.
  → `do a threat model on this codebase`

<!-- SKILLS-INDEX-END -->
