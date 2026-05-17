<!-- 2026-05-12 15:27:49 [019e198e] -->
## Palier C — Dossier Tracker Extraction Mail LLM (2026-05-12)

### Backend
- `POST /dossiers/:opportunityId/extract-from-mail` — analyse mail via LLM, retourne suggestions sans écrire en base
- Slot `mail_extraction` résolu dynamiquement via `AiProfilesService.resolveProfileForSlot()` avec fallback `qwen2.5-coder-7b` (Ollama)
- Prompt structuré dans `backend/src/dossier/prompts/mail-extraction.prompt.ts` (template + parser JSON + fallback regex)
- `DossierModule` injecte maintenant `AiModule` pour accès à `AiService` + `AiProfilesService`

### Frontend
- Modal d'extraction mail intégrée dans `dossier_tracker.js` (bouton ⚙️ → textarea → API → rendu suggestions avec confiance)
- Validation humaine obligatoire avant écriture en base
- Pattern objet littéral conforme (`window.DossierTrackerModule`)

### Versioning
- v1.81.0 → v1.81.1 (patch)
- Cache-busting mis à jour sur `dossier_tracker.js` et `version.js`

### Validation
- TypeScript: 0 erreurs
- NestJS build: OK
- Backend non testé en live (Docker inactif au moment du commit)

### Risques
- Endpoint protégé JWT + Editor/Admin uniquement
- Fallback silencieux sur Ollama si slot non configuré
- Parser JSON a fallback regex pour réponses partielles LLM

### PR
- https://github.com/rajimounit/Pres-Assist-Pro-/pull/60