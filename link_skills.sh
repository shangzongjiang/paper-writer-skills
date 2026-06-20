#!/usr/bin/env bash
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$HOME/.claude/commands"

mkdir -p "$COMMANDS_DIR"

count=0
skipped=0

while IFS= read -r skill_md; do
    folder=$(dirname "$skill_md")
    folder_name=$(basename "$folder")
    link="$COMMANDS_DIR/${folder_name}.md"

    if [[ -L "$link" ]] || [[ -e "$link" ]]; then
        echo "已存在: $folder_name"
        ((skipped++)) || true
        continue
    fi

    ln -s "$skill_md" "$link"
    echo "链接: $folder_name"
    ((count++)) || true
done < <(find "$SKILLS_DIR" -maxdepth 2 -name "SKILL.md" | sort)

echo ""
echo "完成：新建 $count 个，跳过 $skipped 个"
echo "命令目录: $COMMANDS_DIR"
