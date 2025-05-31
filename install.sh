#!/bin/bash

set -e

INSTALL_DIR="$HOME/bin"

mkdir -p "$INSTALL_DIR"

# Копируем скрипты
cp bin/rh-log.sh bin/mcedit bin/rh-log.sh "$INSTALL_DIR"

# Устанавливаем права на исполнение
chmod +x "$INSTALL_DIR/rh-log.sh" "$INSTALL_DIR/mcedit"

# Добавляем в .bashrc если ещё не добавлено
RC_FILE="$HOME/.bashrc"

grep -qxF 'export PATH="$HOME/bin:$PATH"' "$RC_FILE" || echo 'export PATH="$HOME/bin:$PATH"' >> "$RC_FILE"
grep -qxF 'export EDITOR=mcedit' "$RC_FILE" || echo 'export EDITOR=mcedit' >> "$RC_FILE"
grep -qxF 'export PROMPT_COMMAND='"'"'history -a; rh-log.sh "$(fc -ln -1)"'"'" "$RC_FILE" || echo 'export PROMPT_COMMAND='"'"'history -a; rh-log.sh "$(fc -ln -1)"'"'" >> "$RC_FILE"

echo "Установка завершена. Перезапустите терминал или выполните: source ~/.bashrc"
