#!/usr/bin/env bash
# ==============================================================================
# 05-files.sh — Restauração de configurações do ambiente Debian + i3wm
# ==============================================================================
# Variáveis de ambiente:
#   DRY_RUN=1   Simula sem alterar o sistema
# ==============================================================================

DRY_RUN="${DRY_RUN:-0}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$SCRIPT_DIR/../"

# ==============================================================================
# CORES
# ==============================================================================
if [[ -t 1 ]]; then
    RESET=$'\033[0m'
    VERDE=$'\033[0;32m'
    AMARELO=$'\033[1;33m'
    VERMELHO=$'\033[0;31m'
    AZUL=$'\033[1;34m'
    NEGRITO=$'\033[1m'
else
    RESET='' VERDE='' AMARELO='' VERMELHO='' AZUL='' NEGRITO=''
fi

ICO_OK="✔"; ICO_ERR="✖"; ICO_WARN="⚠"; ICO_SKIP="↷"; ICO_INFO="ℹ"; ICO_SETA="➜"

log_ok()   { echo -e "${VERDE}  [${ICO_OK}]${RESET} $*"; }
log_info() { echo -e "${AZUL}  [${ICO_INFO}]${RESET} $*"; }
log_warn() { echo -e "${AMARELO}  [${ICO_WARN}]${RESET} $*"; }
log_err()  { echo -e "${VERMELHO}  [${ICO_ERR}]${RESET} $*"; }
log_skip() { echo -e "${AMARELO}  [${ICO_SKIP}]${RESET} $*"; }
log_run()  { echo -e "${AZUL}  [${ICO_SETA}]${RESET} $*"; }
separador(){ echo -e "  ──────────────────────────────────────────────"; }

# ==============================================================================
# BANNER
# ==============================================================================
echo -e "${VERDE}
  ══════════════════════════════════════════════════════════
  ┬─┐┌─┐┌─┐┌┬┐┌─┐┬ ┬┬─┐┌─┐┬─┐  ┌─┐┌─┐┌┐┌┌─┐┬┌─┐┌─┐
  ├┬┘├┤ └─┐ │ ├─┤│ │├┬┘├─┤├┬┘  │  │ ││││├┤ ││ ┬└─┐
  ┴└─└─┘└─┘ ┴ ┴ ┴└─┘┴└─┴ ┴┴└─  └─┘└─┘┘└┘└  ┴└─┘└─┘
  ══════════════════════════════════════════════════════════${RESET}"
echo ""
[[ "$DRY_RUN" == "1" ]] && log_skip "Modo DRY-RUN — nenhuma alteração será feita."
echo ""

# ==============================================================================
# SELECIONAR BACKUP
# ==============================================================================
log_info "Procurando arquivos de backup..."

mapfile -t BACKUP_FILES < <(find "$PARENT_DIR" -maxdepth 1 -type f -name "backup-*.zip" | sort)

if (( ${#BACKUP_FILES[@]} == 0 )); then
    log_err "Nenhum backup encontrado em: $PARENT_DIR"
    exit 1
elif (( ${#BACKUP_FILES[@]} == 1 )); then
    BACKUP_SELECTED="${BACKUP_FILES[0]}"
    log_ok "Backup encontrado: $(basename "$BACKUP_SELECTED")"
else
    echo ""
    log_warn "Mais de um backup encontrado:"
    echo ""
    local i=1
    for file in "${BACKUP_FILES[@]}"; do
        echo -e "  ${AMARELO}${i})${RESET} $(basename "$file")"
        (( i++ ))
    done
    echo ""
    echo -en "  ${AZUL}Digite o número do backup desejado: ${RESET}"
    read -r CHOICE

    if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || (( CHOICE < 1 || CHOICE > ${#BACKUP_FILES[@]} )); then
        log_err "Opção inválida."
        exit 1
    fi

    BACKUP_SELECTED="${BACKUP_FILES[$((CHOICE-1))]}"
    log_ok "Backup selecionado: $(basename "$BACKUP_SELECTED")"
fi

# ==============================================================================
# DESCOMPACTAR
# ==============================================================================
TMP_RESTORE_DIR="$SCRIPT_DIR/restaurar_tmp"
rm -rf "$TMP_RESTORE_DIR"
mkdir -p "$TMP_RESTORE_DIR"

echo ""
separador
log_run "Descompactando backup..."

if [[ "$DRY_RUN" == "1" ]]; then
    log_skip "[DRY-RUN] unzip simulado."
    ROOT_DIR="$TMP_RESTORE_DIR/dry-run"
    FILES_DIR="$ROOT_DIR"
else
    if ! unzip -q "$BACKUP_SELECTED" -d "$TMP_RESTORE_DIR"; then
        log_err "Falha ao descompactar backup."
        exit 1
    fi
    ROOT_DIR=$(find "$TMP_RESTORE_DIR" -mindepth 1 -maxdepth 1 -type d | head -n1)
    if [[ -z "$ROOT_DIR" ]]; then
        log_err "Nenhuma pasta encontrada dentro do ZIP."
        exit 1
    fi
    FILES_DIR="$ROOT_DIR"
    log_ok "Backup carregado: $(basename "$FILES_DIR")"
fi

# ==============================================================================
# PASTA DE BACKUP DOS ARQUIVOS ATUAIS
# ==============================================================================
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
GLOBAL_BACKUP="$HOME/.config/Backup_$TIMESTAMP"

if [[ "$DRY_RUN" != "1" ]]; then
    mkdir -p "$GLOBAL_BACKUP"
fi
log_info "Backup dos arquivos atuais em: $GLOBAL_BACKUP"

backup_if_exists() {
    local target="$1"
    if [[ -e "$target" ]]; then
        if [[ "$DRY_RUN" == "1" ]]; then
            log_skip "[DRY-RUN] Moveria para backup: $target"
        else
            mv "$target" "$GLOBAL_BACKUP/" && log_info "Backup: $(basename "$target")"
        fi
    fi
}

# ==============================================================================
# RESTAURAR ~/.config
# ==============================================================================
restore_config_folders() {
    echo ""
    separador
    log_info "Restaurando pastas de ~/.config ..."
    separador

    local config_dir="$HOME/.config"
    local -a folders=(alacritty geany gtk-3.0 i3 Thunar)

    for folder in "${folders[@]}"; do
        if [[ -d "$FILES_DIR/$folder" ]]; then
            backup_if_exists "$config_dir/$folder"
            if [[ "$DRY_RUN" == "1" ]]; then
                log_skip "[DRY-RUN] Restauraria: ~/.config/$folder"
            else
                cp -r "$FILES_DIR/$folder" "$config_dir/"
                log_ok "Restaurado: ~/.config/$folder"
            fi
        else
            log_warn "Não encontrado no backup: $folder"
        fi
    done
}

# ==============================================================================
# RESTAURAR ARQUIVOS PESSOAIS
# ==============================================================================
restore_personal_files() {
    echo ""
    separador
    log_info "Restaurando arquivos pessoais..."
    separador

    # Arquivos soltos
    declare -A files=(
        [".zshrc"]="$HOME/.zshrc"
        ["colorscript"]="$HOME/.local/bin/colorscript"
    )

    for src in "${!files[@]}"; do
        local dest="${files[$src]}"
        if [[ -f "$FILES_DIR/$src" ]]; then
            backup_if_exists "$dest"
            if [[ "$DRY_RUN" == "1" ]]; then
                log_skip "[DRY-RUN] Restauraria: $dest"
            else
                mkdir -p "$(dirname "$dest")"
                cp "$FILES_DIR/$src" "$dest"
                log_ok "Restaurado: $dest"
            fi
        fi
    done

    # Fonts
    if [[ -d "$FILES_DIR/fonts" ]]; then
        backup_if_exists "$HOME/.local/share/fonts"
        if [[ "$DRY_RUN" == "1" ]]; then
            log_skip "[DRY-RUN] Restauraria: ~/.local/share/fonts"
        else
            mkdir -p "$HOME/.local/share"
            cp -r "$FILES_DIR/fonts" "$HOME/.local/share/fonts"
            log_ok "Restaurado: ~/.local/share/fonts"
        fi
    fi

    # Asciiart
    if [[ -d "$FILES_DIR/asciiart" ]]; then
        backup_if_exists "$HOME/.local/share/asciiart"
        if [[ "$DRY_RUN" == "1" ]]; then
            log_skip "[DRY-RUN] Restauraria: ~/.local/share/asciiart"
        else
            mkdir -p "$HOME/.local/share"
            cp -r "$FILES_DIR/asciiart" "$HOME/.local/share/asciiart"
            log_ok "Restaurado: ~/.local/share/asciiart"
        fi
    fi
}

# ==============================================================================
# PLUGIN DO THUNAR — path dinâmico (compatível com qualquer arquitetura)
# ==============================================================================
handle_thunar_plugin() {
    local plugin_path
    plugin_path=$(find /usr/lib -name "thunar-wallpaper-plugin.so" 2>/dev/null | head -n1)

    [[ -z "$plugin_path" ]] && return

    local backup_path="${plugin_path}.bak"
    [[ -f "$backup_path" ]] && { log_skip "Plugin Thunar já tratado anteriormente."; return; }

    echo ""
    separador
    log_info "Removendo entrada duplicada de wallpaper do Thunar..."
    separador

    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] sudo mv $plugin_path $backup_path simulado."
    else
        sudo mv "$plugin_path" "$backup_path"
        log_ok "Backup criado: $backup_path"
    fi
}

# ==============================================================================
# SELETOR DE TEMA
# ==============================================================================
choose_theme() {
    local theme_script="$HOME/.config/i3/rofi/themes2"
    local fallback_script="$HOME/.config/i3/themes/catppuccin/apply.sh"
    local log_file="$HOME/.config/theme_restore_errors.log"

    echo ""
    separador
    log_info "Aplicando tema..."
    separador

    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] Aplicação de tema simulada."
        return
    fi

    local usar_fallback=0
    [[ -z "${XDG_CURRENT_DESKTOP:-}" && -z "${DESKTOP_SESSION:-}" ]] && usar_fallback=1
    pgrep -x i3 >/dev/null 2>&1 && usar_fallback=1

    if (( usar_fallback )); then
        if [[ -x "$fallback_script" ]]; then
            "$fallback_script" 2>>"$log_file"
            log_ok "Tema Catppuccin aplicado."
        else
            log_err "Fallback não encontrado: $fallback_script"
        fi
    else
        if [[ -x "$theme_script" ]]; then
            "$theme_script" 2>>"$log_file"
            log_ok "Seletor de tema aberto."
        else
            log_err "Seletor não encontrado: $theme_script"
            log_warn "Verifique o caminho e permissões (chmod +x)."
        fi
    fi
}

# ==============================================================================
# LIMPEZA
# ==============================================================================
limpar_tmp() {
    [[ "$DRY_RUN" != "1" && -d "$TMP_RESTORE_DIR" ]] && rm -rf "$TMP_RESTORE_DIR"
}

# ==============================================================================
# MAIN
# ==============================================================================
restore_config_folders
restore_personal_files
handle_thunar_plugin
choose_theme
limpar_tmp

echo ""
separador
log_ok "Restauração concluída!"
log_info "Backups substituídos em: $GLOBAL_BACKUP"
log_info "Backup usado: $(basename "$BACKUP_SELECTED")"
separador