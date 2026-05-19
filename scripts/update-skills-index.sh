#!/usr/bin/env bash
SKILLS_DIR="$HOME/.pi/skills"
AGENTS_MD="$HOME/.pi/AGENTS.md"
START="<!-- SKILLS-INDEX-START -->"
END="<!-- SKILLS-INDEX-END -->"

block="$START\n## 🛠 Installed Skills\n\n"

for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
  [ -f "$skill_file" ] || continue
  skill_name=$(basename "$(dirname "$skill_file")")
  desc=$(awk '/^## |^# /{found=1; next} found && /^[^#]/ && NF{print; exit}' "$skill_file")
  usage=$(grep -im1 '^<!-- *usage:' "$skill_file" | sed 's/^<!-- *usage: *//; s/ *-->.*//')
  block+="**$skill_name** — ${desc:-no description}\n"
  [ -n "$usage" ] && block+="  → \`$usage\`\n"
  block+="\n"
done

block+="$END"

if grep -q "$START" "$AGENTS_MD" 2>/dev/null; then
  perl -i -0pe "s|\Q$START\E.*\Q$END\E|$block|ms" "$AGENTS_MD"
else
  printf "\n%b\n" "$block" >> "$AGENTS_MD"
fi
