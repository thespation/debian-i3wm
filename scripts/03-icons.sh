#!/usr/bin/env bash
# ==============================================================================
# 03-icons.sh — Instalação de ícones Archcraft para Debian + i3wm
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
ICONS_REPO="https://github.com/archcraft-os/archcraft-icons.git"
ICONS_DIR="/tmp/archcraft-icons"
DEST_DIR="/usr/share/icons"

# ==============================================================================
# BANNER
# ==============================================================================
echo -e "${VERDE}
  ══════════════════════════════════════════════════════════════
  ┌─┐┌─┐┬─┐┌─┐┌─┐┌─┐┌─┐┌┐┌┌┬┐┌─┐┌┐┌┌┬┐┌─┐  ┬┌─┐┌─┐┌┐┌┌─┐┌─┐
  ├─┤│  ├┬┘├┤ └─┐│  ├┤ │││ │ ├─┤│││ │││ │  ││  │ ││││├┤ └─┐
  ┴ ┴└─┘┴└─└─┘└─┘└─┘└─┘┘└┘ ┴ ┴ ┴┘└┘─┴┘└─┘  ┴└─┘└─┘┘└┘└─┘└─┘
  ══════════════════════════════════════════════════════════════${RESET}"
echo ""
[[ "$DRY_RUN" == "1" ]] && log_skip "Modo DRY-RUN — nenhuma alteração será feita."
echo ""

# ==============================================================================
# VERIFICAR GIT
# ==============================================================================
command -v git >/dev/null 2>&1 || { log_err "git não encontrado. Instale e tente novamente."; exit 1; }

# ==============================================================================
# CLONAR OU ATUALIZAR REPOSITÓRIO
# ==============================================================================
separador
if [[ -d "$ICONS_DIR/.git" ]]; then
    log_run "Repositório já existe — atualizando..."
    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] git pull simulado."
    else
        if git -C "$ICONS_DIR" pull --ff-only &>/dev/null; then
            log_ok "Repositório atualizado."
        else
            log_err "Erro ao atualizar repositório."
            exit 1
        fi
    fi
elif [[ -d "$ICONS_DIR" ]]; then
    log_warn "Diretório existe sem .git — recriando."
    [[ "$DRY_RUN" != "1" ]] && rm -rf "$ICONS_DIR"
    log_run "Clonando repositório de ícones..."
    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] git clone simulado."
    else
        if git clone --depth=1 "$ICONS_REPO" "$ICONS_DIR" &>/dev/null; then
            log_ok "Repositório clonado."
        else
            log_err "Erro ao clonar repositório."
            exit 1
        fi
    fi
else
    log_run "Clonando repositório de ícones..."
    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] git clone simulado."
    else
        if git clone --depth=1 "$ICONS_REPO" "$ICONS_DIR" &>/dev/null; then
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
        sudo mkdir -p "$DEST_DIR" || { log_err "Erro ao criar diretório: $DEST_DIR"; exit 1; }
        log_ok "Diretório criado: $DEST_DIR"
    fi
fi

# ==============================================================================
# COPIAR ÍCONES
# ==============================================================================
separador
log_info "Copiando ícones para $DEST_DIR ..."
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

        if sudo cp -rf "$subfolder/" "$dest/"; then
            log_ok "Copiado: $local_name"
            (( ct_ok++ )) || true
        else
            log_err "Erro ao copiar: $local_name"
            (( ct_err++ )) || true
        fi
    done < <(find "$files_dir" -mindepth 1 -maxdepth 1 -type d)
done < <(find "$ICONS_DIR" -type d -name "files")

# ==============================================================================
# AJUSTAR PERMISSÕES
# ==============================================================================
if [[ "$DRY_RUN" != "1" ]]; then
    log_run "Ajustando permissões em $DEST_DIR ..."
    if sudo chmod -R a+rX "$DEST_DIR"; then
        log_ok "Permissões ajustadas."
    else
        log_warn "Erro ao ajustar permissões (não crítico)."
    fi
fi

# ==============================================================================
# RESUMO
# ==============================================================================
echo ""
separador
echo -e "${NEGRITO}  Resumo:${RESET}"
separador
log_ok   "Ícones copiados : ${ct_ok}"
(( ct_err > 0 )) && log_err "Erros           : ${ct_err}"
separador