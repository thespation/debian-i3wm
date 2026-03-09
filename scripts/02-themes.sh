#!/usr/bin/env bash
# ==============================================================================
# 02-themes.sh — Instalação de temas Archcraft para Debian + i3wm
# ==============================================================================
# Variáveis de ambiente:
#   DRY_RUN=1   Simula sem alterar o sistema
# ==============================================================================

DRY_RUN="${DRY_RUN:-0}"

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
# VARIÁVEIS
# ==============================================================================
THEMES_REPO="https://github.com/archcraft-os/archcraft-themes.git"
THEMES_DIR="/tmp/archcraft-themes"
DEST_DIR="/usr/share/themes"

# ==============================================================================
# BANNER
# ==============================================================================
echo -e "${VERDE}
  ══════════════════════════════════════════════════════════════
  ┌─┐┌─┐┬─┐┌─┐┌─┐┌─┐┌─┐┌┐┌┌┬┐┌─┐┌┐┌┌┬┐┌─┐  ┌┬┐┌─┐┌┬┐┌─┐┌─┐
  ├─┤│  ├┬┘├┤ └─┐│  ├┤ │││ │ ├─┤│││ │││ │   │ ├┤ │││├─┤└─┐
  ┴ ┴└─┘┴└─└─┘└─┘└─┘└─┘┘└┘ ┴ ┴ ┴┘└┘─┴┘└─┘   ┴ └─┘┴ ┴┴ ┴└─┘
  ══════════════════════════════════════════════════════════════${RESET}"
echo ""
[[ "$DRY_RUN" == "1" ]] && log_skip "Modo DRY-RUN — nenhuma alteração será feita."
echo ""

# ==============================================================================
# CLONAR OU ATUALIZAR REPOSITÓRIO
# ==============================================================================
separador
if [[ -d "$THEMES_DIR/.git" ]]; then
    log_run "Repositório já existe — atualizando..."

    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] git pull simulado."
    else
        if git -C "$THEMES_DIR" pull --ff-only &>/dev/null; then
            log_ok "Repositório atualizado."
        else
            log_err "Erro ao atualizar repositório."
            exit 1
        fi
    fi
elif [[ -d "$THEMES_DIR" ]]; then
    log_warn "Diretório existe sem .git — recriando."
    [[ "$DRY_RUN" != "1" ]] && rm -rf "$THEMES_DIR"
    log_run "Clonando repositório de temas..."
    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] git clone simulado."
    else
        if git clone --depth=1 "$THEMES_REPO" "$THEMES_DIR" &>/dev/null; then
            log_ok "Repositório clonado."
        else
            log_err "Erro ao clonar repositório."
            exit 1
        fi
    fi
else
    log_run "Clonando repositório de temas..."
    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] git clone simulado."
    else
        if git clone --depth=1 "$THEMES_REPO" "$THEMES_DIR" &>/dev/null; then
            log_ok "Repositório clonado."
        else
            log_err "Erro ao clonar repositório."
            exit 1
        fi
    fi
fi

# ==============================================================================
# CRIAR DIRETÓRIO DE DESTINO
# ==============================================================================
if [[ ! -d "$DEST_DIR" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] mkdir $DEST_DIR simulado."
    else
        sudo mkdir -p "$DEST_DIR"
        log_ok "Diretório criado: $DEST_DIR"
    fi
fi

# ==============================================================================
# COPIAR TEMAS
# ==============================================================================
separador
log_info "Copiando temas para $DEST_DIR ..."
separador
echo ""

ct_ok=0; ct_err=0

while IFS= read -r files_dir; do
    while IFS= read -r subfolder; do
        local_name="$(basename "$subfolder")"
        dest="$DEST_DIR/$local_name"

        if [[ "$DRY_RUN" == "1" ]]; then
            log_skip "[DRY-RUN] Copiaria: $local_name"
            (( ct_ok++ )) || true
            continue
        fi

        sudo mkdir -p "$dest"
        if sudo cp -rf "$subfolder/"* "$dest/"; then
            sudo chmod -R a+rX "$dest"
            log_ok "Copiado: $local_name"
            (( ct_ok++ )) || true
        else
            log_err "Erro ao copiar: $local_name"
            (( ct_err++ )) || true
        fi
    done < <(find "$files_dir" -mindepth 1 -maxdepth 1 -type d)
done < <(find "$THEMES_DIR" -type d -name "files")

# ==============================================================================
# RESUMO
# ==============================================================================
echo ""
separador
echo -e "${NEGRITO}  Resumo:${RESET}"
separador
log_ok   "Temas copiados : ${ct_ok}"
(( ct_err > 0 )) && log_err "Erros          : ${ct_err}"
separador