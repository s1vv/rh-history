#!/bin/bash
set -e

# Перейти в директорию скрипта
cd "$(dirname "$0")"

# Файлы для установки
FILES=("rh" "mcedit" "rh-log.sh")

# Локальная установка для текущего пользователя
USER_BIN="$HOME/bin"
mkdir -p "$USER_BIN"
echo "[+] Копируем исполняемые файлы в $USER_BIN"

for file in "${FILES[@]}"; do
    cp "bin/$file" "$USER_BIN"
    chmod +x "$USER_BIN/$file"
done

# Обновление .bashrc пользователя
RC_FILE="$HOME/.bashrc"

echo "[+] Обновляем $RC_FILE при необходимости"
grep -qxF 'export PATH="$HOME/bin:$PATH"' "$RC_FILE" || echo 'export PATH="$HOME/bin:$PATH"' >> "$RC_FILE"
grep -qxF 'export EDITOR=mcedit' "$RC_FILE" || echo 'export EDITOR=mcedit' >> "$RC_FILE"
grep -qxF 'export PROMPT_COMMAND='"'"'history -a; rh-log.sh "$(fc -ln -1)"'"'" "$RC_FILE" || echo 'export PROMPT_COMMAND='"'"'history -a; rh-log.sh "$(fc -ln -1)"'"'" >> "$RC_FILE"

# Установка для root (если есть доступ)
if command -v sudo &>/dev/null; then
    echo "[?] Установить утилиты и для root в /usr/local/bin? (y/n)"
    read -r install_root

    if [[ "$install_root" == "y" ]]; then
        for file in "${FILES[@]}"; do
            sudo cp "bin/$file" /usr/local/bin/
            sudo chmod +x "/usr/local/bin/$file"
        done

        echo "[+] Файлы установлены в /usr/local/bin"

        # Добавление в /root/.bashrc через heredoc
        sudo bash <<'EOF'
RC_FILE="/root/.bashrc"

grep -qxF "export EDITOR=mcedit" "$RC_FILE" || echo "export EDITOR=mcedit" >> "$RC_FILE"

PROMPT_LINE='export PROMPT_COMMAND='\''history -a; rh-log.sh "$(fc -ln -1)"'\'''
grep -qxF "$PROMPT_LINE" "$RC_FILE" || echo "$PROMPT_LINE" >> "$RC_FILE"
EOF

        echo "[+] Настройки добавлены в /root/.bashrc"
    fi
fi

echo "[✓] Установка завершена."
echo "→ Перезапустите терминал или выполните: source ~/.bashrc"
