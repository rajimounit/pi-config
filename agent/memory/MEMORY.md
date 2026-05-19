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

<!-- 2026-05-17 17:01:26 [019e36d1] -->
# PDF Import Module Analysis - Summary

## Architecture and Workflow Orchestration

The PDF import module in Avv Assist Pro v3 follows a structured workflow that includes multiple phases:
1. File upload and validation (PDF format, size limits)
2. Document processing using OCR and text extraction
3. LLM-based content analysis and structuring
4. Result validation and application to opportunities

The key components are:
- Frontend: `avv_assist/js/modules/pdf_importer.js` - handles UI interactions and workflow orchestration
- Backend: `backend/src/documents/documents.service.ts` - core processing logic with detailed state management
- AI Integration: `backend/src/ai/ai-profiles.service.ts` and `backend/src/ai/providers/ollama.provider.ts` for LLM model management

## LLM Model Configuration

The system uses a slot-based configuration system for LLM models:
- AI profiles are managed through `AiProfilesService` with system and user profiles
- The `pdf_vision` slot is used for PDF import vision-based processing (with fallback to `qwen2.5-coder-7b`)
- The system supports both OpenAI-compatible and Ollama-compatible providers
- Default models configured via environment variables (`OLLAMA_MODEL_DEFAULT`, `OPENAI_MODEL_DEFAULT`)

## Document Type Handling and Model Selection Logic

The system implements a multi-tier approach to document type handling:
1. Document profiling using `flux2_extraction` slot for initial document analysis
2. Model selection based on document characteristics (document type, structure, language)
3. Adaptive model switching during processing when confidence drops
4. Support for both vision-based processing (`llm_vision`) and traditional OCR (`tesseract`, `native`)
5. Experimental parser mode with fallback strategies

## Performance and Optimization Strategies

Key performance considerations include:
- Asynchronous processing with progress tracking
- State persistence for long-running operations
- Adaptive OCR strategy selection based on previous attempts
- Caching of resolved model protocols to avoid repeated detection
- Configurable execution modes (manual/auto) and auto policies
- Performance metrics collection through learning dashboard

## Error Handling and User Feedback

The module has comprehensive error handling:
- Multiple warning codes for different failure scenarios
- Detailed error reporting with failure codes
- Progress tracking and ETA hints
- Graceful fallback strategies (model switching, error recovery)
- User feedback through UI modal with confidence indicators
- Ability to retry specific pages with different OCR profiles
- Support for cancellation of running operations

## Security and Traceability Features

The system implements security and traceability features:
- JWT-based authentication with role-based access control (Editor/Admin only)
- Detailed audit trail through opportunity analysis entities
- Document provenance tracking with source information
- Version control and state management
- Governance snapshot for policy compliance
- Comprehensive logging for debugging and monitoring

## Key Findings

1. **Modular Architecture**: Well-defined separation of concerns between frontend and backend components
2. **LLM Integration**: Strong integration with LLM providers through a flexible slot system
3. **Error Resilience**: Multiple fallback strategies and detailed error reporting
4. **Performance Optimization**: Async processing, caching, and adaptive algorithms
5. **Security**: Role-based access control and comprehensive audit trails
6. **Extensibility**: Support for custom AI profiles and experimental parser modes

## Recommendations

1. **Improve LLM Provider Health Checking**: Currently, health checks are basic and not comprehensive. Enhance the health check to validate model availability and performance characteristics.

2. **Add More Granular Performance Metrics**: While there are some metrics, more detailed profiling could help optimize performance and identify bottlenecks.

3. **Enhance Documentation**: Add more comprehensive documentation for the AI profile configuration system and PDF import workflow.

4. **Improve Local Development Experience**: The system should provide better error messages when AI providers are not properly configured locally.

5. **Add More Comprehensive Testing**: Expand test coverage for different document types and edge cases.

<!-- 2026-05-17 20:45:24 [019e36d1] -->
# PDF Import Module - LLM Processing Flow

Based on my analysis of the code, I can now explain how the LLM processing works in the PDF import module, specifically how the vision model (for OCR) feeds into the structuring model.

## Overview of the Two-Step Process

The PDF import module uses two distinct LLM models in a sequential process:

1. **Vision Model (OCR)**: Processes PDF pages as images to extract text using the `pdf_vision` slot
2. **Structuring Model**: Processes the extracted text to create structured data using the `pdf` slot

## Step-by-Step Flow

### 1. Initial Setup and Model Resolution
When a PDF import run starts:
- The system resolves the `pdf_vision` slot using `AiProfilesService.resolveProfileForSlot('pdf_vision')`
- This resolves to a vision model (like `qwen2.5-vl:7b`)
- If no specific vision model is provided, it defaults to the regular `model` parameter
- The system also resolves the `pdf` slot for structuring (usually with a different model like `qwen3-vl-8b-instruct`)

### 2. Vision-Based OCR Process
The vision model processes each page:
- PDF pages are converted to images (using `pdftoppm` or other tools)
- Images are sent to the vision model via `extractVisionTextForPage()` 
- The model extracts text from the image using a prompt designed for document analysis
- Extracted text is stored in `run.ocrState.extractedTextByPage[page]`

### 3. Text Aggregation
- All extracted text from all pages is aggregated into `run.rawText`
- The aggregated text is normalized and prepared for structuring

### 4. Structuring Process
- The system uses the `pdf` slot model for the structuring phase
- The structuring model receives all aggregated text
- It processes the text to extract requirements, clarifications, and other structured information
- The result is passed to `buildStructuredOutput()` which calls `requestStructuringJson()`

### 5. Model Configuration Details
- Vision model is resolved via `pdf_vision` slot (default: `qwen2.5-vl:7b`)
- Structuring model is resolved via `pdf` slot (default: `qwen3-vl-8b-instruct`)
- Both use the same provider (typically Ollama) but can be different models
- The structuring model works on the entire aggregated text, not individual pages

## Key Implementation Details

1. **Slot System**: The system uses a slot-based approach where `pdf_vision` and `pdf` are separate slots with their own configurations
2. **Text Flow**: The extracted text from vision processing flows seamlessly into the structuring phase
3. **Model Switching**: Different models are used for different tasks - one for OCR, one for structuring
4. **Aggregation**: Individual page extractions are aggregated before structuring

## Code Path
1. `processRun()` → `processOcrPages()` → `executeStrategyAttempt()` → `extractVisionTextForPage()`
2. All extracted text is stored in `run.ocrState.extractedTextByPage`
3. `buildRawTextFromPages()` aggregates all text
4. `buildStructuredOutput()` → `requestStructuringJson()` → uses the `pdf` slot model for final structuring

<!-- 2026-05-18 00:12:34 [019e386c] -->
# pi-autoresearch Setup - AVV Assist Pro

## Task Completed

I've successfully completed the setup of pi-autoresearch benchmark loop on AVV Assist Pro with the following steps:

1. **Read pi-autoresearch documentation** - Verified the extension documentation and capabilities

2. **Created checks.sh script** - Created a comprehensive checks script in the repo root that:
   - Verifies TypeScript compilation (40 points if successful)
   - Checks for console.log usage in new code (20 points if none found, 10 if found)
   - Scans for hardcoded API keys/secrets (40 points if none found, 0 if found)
   - Outputs a score (0-100) where 100 means all checks pass

3. **Updated AGENTS.md** - Added documentation on how to use autoresearch for AVV Assist Pro:
   - Explained when to use autoresearch-create skill
   - Described how checks.sh defines success criteria
   - Documented the scoring system (100 = TS compiles + no console.log + no secrets)
   - Mentioned that autoresearch-finalize commits improvements or reverts regressions

## Files Created/Modified

1. `/home/neowh/git/local-setup/avvAssistv3/avv-assist-pro-v3/checks.sh` - The checks script for autoresearch
2. `/home/neowh/.pi/AGENTS.md` - Documentation for using autoresearch on this project

## Implementation Details

The checks.sh script:
- Is located in the repository root 
- Is executable (chmod +x applied)
- Uses git diff to check for new console.log statements and hardcoded secrets
- Runs TypeScript compilation check in the backend directory
- Provides a scoring system to evaluate code quality for autoresearch

The documentation in AGENTS.md:
- Provides clear instructions for developers on when to use autoresearch
- Explains how the checks.sh script works
- Describes the expected scoring system for autoresearch
- Mentions the auto-commit/revert behavior of autoresearch-finalize