#!/bin/bash
set -e

# Go to the script directory
cd "$(dirname "$0")"

# Installation files
FILES=("rh" "mcedit" "rh-log.sh")

# Local installation for the current user
USER_BIN="$HOME/bin"
mkdir -p "$USER_BIN"
echo "[+] Copying the executable files to $USER_BIN"

for file in "${FILES[@]}"; do
    cp "bin/$file" "$USER_BIN"
    chmod +x "$USER_BIN/$file"
done

# Update the user's .bashrc
RC_FILE="$HOME/.bashrc"

echo "[+] Update $RC_FILE if necessary"
grep -qxF 'export PATH="$HOME/bin:$PATH"' "$RC_FILE" || echo 'export PATH="$HOME/bin:$PATH"' >> "$RC_FILE"
grep -qxF 'export EDITOR=mcedit' "$RC_FILE" || echo 'export EDITOR=mcedit' >> "$RC_FILE"
grep -qxF 'export PROMPT_COMMAND='"'"'history -a; rh-log.sh "$(fc -ln -1)"'"'" "$RC_FILE" || echo 'export PROMPT_COMMAND='"'"'history -a; rh-log.sh "$(fc -ln -1)"'"'" >> "$RC_FILE"

# Installation for root (if available)
if command -v sudo &>/dev/null; then
    echo "[?] Should install utilities for root in /usr/local/bin? (y/n)"
    read -r install_root

    if [[ "$install_root" == "y" ]]; then
        for file in "${FILES[@]}"; do
            sudo cp "bin/$file" /usr/local/bin/
            sudo chmod +x "/usr/local/bin/$file"
        done

        echo "[+] Файлы установлены в /usr/local/bin"

        # Adding to /root/.bashrc via heredoc
        sudo bash <<'EOF'
RC_FILE="/root/.bashrc"

grep -qxF "export EDITOR=mcedit" "$RC_FILE" || echo "export EDITOR=mcedit" >> "$RC_FILE"

PROMPT_LINE='export PROMPT_COMMAND='\''history -a; rh-log.sh "$(fc -ln -1)"'\'''
grep -qxF "$PROMPT_LINE" "$RC_FILE" || echo "$PROMPT_LINE" >> "$RC_FILE"
EOF

        echo "[+] Settings added to /root/.bashrc"
    fi
fi

echo "[✓] The installation is complete."
echo "→ Restart the terminal or run:source ~/.bashrc"
