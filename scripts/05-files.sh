#!/bin/bash
set -e

# ================================
#   Script de Instalação/Restore
# ================================

# --- Cores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\e[94m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$SCRIPT_DIR/../"

echo -e "${BLUE}Procurando arquivos de backup no diretório superior...${NC}"

mapfile -t BACKUP_FILES < <(find "$PARENT_DIR" -maxdepth 1 -type f -name "backup-*.zip")

if [ ${#BACKUP_FILES[@]} -eq 0 ]; then
    echo -e "${RED}Nenhum backup encontrado.${NC}"
    exit 1
elif [ ${#BACKUP_FILES[@]} -eq 1 ]; then
    BACKUP_SELECTED="${BACKUP_FILES[0]}"
    echo -e "${GREEN}Backup encontrado:${NC} $BACKUP_SELECTED"
else
    echo -e "${YELLOW}Foi encontrado mais de um backups:${NC}"
    i=1
    for file in "${BACKUP_FILES[@]}"; do
        echo "  $i) $(basename "$file")"
        ((i++))
    done
    echo -en "\nDigite o número do backup desejado: "
    read -r CHOICE

    if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "${#BACKUP_FILES[@]}" ]; then
        echo -e "${RED}Opção inválida.${NC}"
        exit 1
    fi

    BACKUP_SELECTED="${BACKUP_FILES[$((CHOICE-1))]}"
    echo -e "${GREEN}Backup selecionado:${NC} $BACKUP_SELECTED"
fi

# =======================================
# Descompactação real do seu caso
# =======================================
TMP_RESTORE_DIR="$SCRIPT_DIR/restaurar_tmp"

rm -rf "$TMP_RESTORE_DIR"
mkdir -p "$TMP_RESTORE_DIR"

echo -e "\n${BLUE}Descompactando backup...${NC}"
unzip -q "$BACKUP_SELECTED" -d "$TMP_RESTORE_DIR"

# ---------------------------------------
# Procurar a pasta raiz real do backup
# ---------------------------------------
ROOT_DIR=$(find "$TMP_RESTORE_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [ -z "$ROOT_DIR" ]; then
    echo -e "${RED}Erro:${NC} não foi encontrada nenhuma pasta dentro do ZIP."
    exit 1
fi

FILES_DIR="$ROOT_DIR"

echo -e "${GREEN}Backup carregado da pasta:${NC} $FILES_DIR"

# =======================================
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
GLOBAL_BACKUP="$HOME/.config/Backup_$TIMESTAMP"
mkdir -p "$GLOBAL_BACKUP"
echo -e "Pasta de backup: ${BLUE}$GLOBAL_BACKUP${NC}"

backup_if_exists() {
    local TARGET="$1"
    local NAME=$(basename "$TARGET")

    if [ -e "$TARGET" ]; then
        echo -e "Movendo para backup: $TARGET → $GLOBAL_BACKUP/$NAME"
        mv "$TARGET" "$GLOBAL_BACKUP/"
    fi
}

restore_config_folders() {
    local CONFIG_DIR="$HOME/.config"
    local FOLDERS=(alacritty geany gtk-3.0 i3 Thunar)

    echo -e "\n==> ${BLUE}Restaurando pastas de ~/.config...${NC}"

    for folder in "${FOLDERS[@]}"; do
        if [ -d "$FILES_DIR/$folder" ]; then
            backup_if_exists "$CONFIG_DIR/$folder"
            cp -r "$FILES_DIR/$folder" "$CONFIG_DIR/"
            echo -e "${GREEN}Restaurado:${NC} ~/.config/$folder"
        else
            echo -e "${YELLOW}Pasta não está no backup:${NC} $folder"
        fi
    done
}

restore_personal_files() {
    echo -e "\n==> ${BLUE}Restaurando arquivos pessoais...${NC}"

    declare -A FILES=(
        [".zshrc"]="$HOME/.zshrc"
        ["colorscript"]="$HOME/.local/bin/colorscript"
    )

    for src in "${!FILES[@]}"; do
        if [ -f "$FILES_DIR/$src" ]; then
            backup_if_exists "${FILES[$src]}"
            mkdir -p "$(dirname "${FILES[$src]}")"
            cp "$FILES_DIR/$src" "${FILES[$src]}"
            echo -e "${GREEN}Restaurado:${NC} ${FILES[$src]}"
        fi
    done

    if [ -d "$FILES_DIR/fonts" ]; then
        backup_if_exists "$HOME/.local/share/fonts"
        mkdir -p "$HOME/.local/share"
        cp -r "$FILES_DIR/fonts" "$HOME/.local/share/fonts"
        echo -e "${GREEN}Restaurado:${NC} ~/.local/share/fonts"
    fi

    if [ -d "$FILES_DIR/asciiart" ]; then
        backup_if_exists "$HOME/.local/share/asciiart"
        mkdir -p "$HOME/.local/share"
        cp -r "$FILES_DIR/asciiart" "$HOME/.local/share/asciiart"
        echo -e "${GREEN}Restaurado:${NC} ~/.local/share/asciiart"
    fi
}

choose_theme() {
    local THEME_SCRIPT="$HOME/.config/i3/rofi/themes2"
    local FALLBACK_SCRIPT="$HOME/.config/i3/themes/catppuccin/apply.sh"
    local LOG_FILE="$HOME/.config/theme_restore_errors.log"

    echo -e "\n==> ${BLUE}Executando seletor de tema...${NC}"

    # Detectar se está rodando sem interface gráfica
    if [ -z "$XDG_CURRENT_DESKTOP" ] && [ -z "$DESKTOP_SESSION" ]; then
        echo -e "${YELLOW}Nenhuma interface gráfica detectada.${NC}"
        if [ -x "$FALLBACK_SCRIPT" ]; then
            "$FALLBACK_SCRIPT" 2>>"$LOG_FILE"
            echo -e "${GREEN}Tema Catppuccin aplicado (modo sem interface).${NC}"
        else
            echo -e "${RED}Erro:${NC} fallback $FALLBACK_SCRIPT não encontrado ou não executável."
        fi
        return
    fi

    # Detectar se está rodando i3wm
    if pgrep -x i3 >/dev/null 2>&1; then
        echo -e "${YELLOW}Detectado i3wm.${NC}"
        if [ -x "$FALLBACK_SCRIPT" ]; then
            "$FALLBACK_SCRIPT" 2>>"$LOG_FILE"
            echo -e "${GREEN}Tema Catppuccin aplicado (i3wm).${NC}"
        else
            echo -e "${RED}Erro:${NC} fallback $FALLBACK_SCRIPT não encontrado ou não executável."
        fi
        return
    fi

    # Caso esteja em outro ambiente gráfico (GNOME, XFCE, KDE etc.)
    if [ -x "$THEME_SCRIPT" ]; then
        "$THEME_SCRIPT" 2>>"$LOG_FILE"
        echo -e "${GREEN}Seletor de tema aberto com sucesso!${NC}"
    else
        echo -e "${RED}Erro:${NC} o arquivo $THEME_SCRIPT não existe ou não é executável."
        echo -e "Verifique se o caminho está correto e se tem permissão de execução (chmod +x)."
    fi
}

restore_config_folders
restore_personal_files
choose_theme

echo -e "\n${GREEN}Instalação/restauração concluída!${NC}"
echo -e "Backups substituídos estão em: ${BLUE}$GLOBAL_BACKUP${NC}"
echo -e "Backup usado: ${BLUE}$(basename "$BACKUP_SELECTED")${NC}"
