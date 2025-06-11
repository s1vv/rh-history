#!/bin/bash
set -e

cd "$(dirname "$0")"

FILES=("rh" "mcedit" "rh-log.sh")

USER_BIN="$HOME/bin"
mkdir -p "$USER_BIN"
echo "[+] Копирование исполняемых файлов в $USER_BIN"

for file in "${FILES[@]}"; do
    cp "bin/$file" "$USER_BIN"
    chmod +x "$USER_BIN/$file"
done

RC_FILE="$HOME/.zshrc"

echo "[+] Обновление $RC_FILE при необходимости"

grep -qxF 'export PATH="$HOME/bin:$PATH"' "$RC_FILE" || echo 'export PATH="$HOME/bin:$PATH"' >> "$RC_FILE"
grep -qxF 'export EDITOR=mcedit' "$RC_FILE" || echo 'export EDITOR=mcedit' >> "$RC_FILE"

# Добавляем функцию логирования команд с precmd в zshrc, если нет
if ! grep -q '_log_command' "$RC_FILE"; then
    cat >> "$RC_FILE" <<'EOF'

# rh history logging
function preexec() {
    rh-log.sh "$1" > /dev/null 2>&1
}
EOF
fi

if command -v sudo &>/dev/null; then
    echo "[?] Установить утилиты для root в /usr/local/bin? (y/n)"
    read -r install_root

    if [[ "$install_root" == "y" ]]; then
        for file in "${FILES[@]}"; do
            sudo cp "bin/$file" /usr/local/bin/
            sudo chmod +x "/usr/local/bin/$file"
        done

        echo "[+] Файлы установлены в /usr/local/bin"

        sudo bash <<'EOF'
RC_FILE="/root/.zshrc"

grep -qxF "export EDITOR=mcedit" "$RC_FILE" || echo "export EDITOR=mcedit" >> "$RC_FILE"

if ! grep -q '_log_command' "$RC_FILE"; then
    cat >> "$RC_FILE" <<'EOT'

# rh history logging
function preexec() {
    rh-log.sh "$1" > /dev/null 2>&1
}
EOT
fi
EOF

        echo "[+] Настройки добавлены в /root/.zshrc"
    fi
fi

echo "[✓] Установка завершена."
echo "→ Перезапусти терминал или выполните: source ~/.zshrc"
