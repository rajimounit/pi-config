# Agent Instructions — Pi Agent Local

## Backend et contraintes d'inference
- Provider principal : Ollama sur http://localhost:11434/v1
- Provider alternatif : llama-cpp sur http://127.0.0.1:8081/v1 (si demarre)
- Modele par defaut : qwen3.6:35b-a3b
- Limite contexte effective : traiter 24k tokens comme limite sure
- Quand le contexte depasse 70%, ecrire un TODO.md resumant le travail restant avant compaction

## Style de travail
- Toujours lire un fichier avant de le modifier — ne jamais supposer sa structure
- Verifier les changements : lancer le test, linter ou build concerne apres chaque edition
- Pour les taches > 6 tours, ecrire un plan TASK.md et le suivre
- Preferer les editions chirurgicales aux reecritures completes
- Les operations destructives (delete, drop, rm -rf) necessitent un commentaire de confirmation explicite avant execution

## Qualite de code par defaut
- Python : type hints, pas de except nu, f-strings
- TypeScript/JavaScript : strict mode, types de retour explicites sur les exports
- Docker : toujours HEALTHCHECK, tags d'image epingles
- Shell : set -euo pipefail en tete de chaque script

## Git
- Toujours verifier git status avant de commencer
- Creer une branche dediee pour toute fonctionnalite ou fix non trivial
- Format de commit : type(scope): description courte

## Quand s'arreter et demander
S'arreter uniquement si :
1. Un secret ou credential absent du repo est necessaire
2. Une action destructive n'a pas de rollback clair
3. La spec est genuinement ambigue (pas juste complexe)

## Model Routing

Default: ollama/pi-qwen3-35b (fast start, most tasks)

Switch to llama-cpp when:
- Session will exceed 30k tokens (large repo reads, full module analysis)
- Task requires guaranteed 64k context (AVV Assist Pro full backend read)
- Ollama silently truncates responses

Switch command: Ctrl+P then select llama-cpp/qwen3-coder:latest
Start llama server first: ~/.pi/start-llama.sh

Switch to pi-qwen25-coder-7b when:
- Quick lookup, grep, single file read
- VRAM is constrained (other processes running)

Switch to deepseek-r1:32b when:
- Architecture decision needed
- Non-trivial debugging requiring structured reasoning
