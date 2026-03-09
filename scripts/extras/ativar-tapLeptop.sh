#!/usr/bin/env bash
# ==============================================================================
# ativar-tap-laptop.sh — Ativa Tap-to-Click no touchpad para Debian + i3wm
# ==============================================================================
# Variáveis de ambiente:
#   DRY_RUN=1   Simula sem alterar o sistema
# ==============================================================================

DRY_RUN="${DRY_RUN:-0}"

XORG_CONF_DIR="/etc/X11/xorg.conf.d"
XORG_CONF_FILE="$XORG_CONF_DIR/40-libinput.conf"

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
  ┌─┐┌┬┐┬┬  ┬┌─┐┬─┐  ┌┬┐┌─┐┌─┐  ┬  ┌─┐┌─┐┌┬┐┌─┐┌─┐
  ├─┤ │ │└┐┌┘├─┤├┬┘   │ ├─┤├─┘  │  ├─┤├─┘ │ │ │├─┘
  ┴ ┴ ┴ ┴ └┘ ┴ ┴┴└─   ┴ ┴ ┴┴    ┴─┘┴ ┴┴   ┴ └─┘┴  
  ══════════════════════════════════════════════════════════${RESET}"
echo ""
[[ "$DRY_RUN" == "1" ]] && log_skip "Modo DRY-RUN — nenhuma alteração será feita."
echo ""

# ==============================================================================
# VERIFICAR XINPUT
# ==============================================================================
separador
log_info "Verificando dependências..."
separador

if command -v xinput >/dev/null 2>&1; then
    log_skip "xinput — já instalado"
elif [[ "$DRY_RUN" == "1" ]]; then
    log_skip "[DRY-RUN] Instalaria: xinput"
else
    log_run "Instalando xinput..."
    sudo apt-get update -qq
    if sudo apt-get install -y xinput &>/dev/null && command -v xinput >/dev/null 2>&1; then
        log_ok "xinput instalado."
    else
        log_err "Falha ao instalar xinput."
        exit 1
    fi
fi

# ==============================================================================
# DETECTAR TOUCHPAD
# ==============================================================================
separador
log_info "Procurando touchpad..."
separador

detectar_touchpad_id() {
    xinput list | grep -i "touchpad" | grep -oP 'id=\K[0-9]+' | head -n1
}

TOUCHPAD_NOME=""
TOUCHPAD_ID=""

if [[ "$DRY_RUN" == "1" ]]; then
    log_skip "[DRY-RUN] Detecção de touchpad simulada."
else
    TOUCHPAD_ID="$(detectar_touchpad_id)"

    if [[ -z "$TOUCHPAD_ID" ]]; then
        log_err "Nenhum touchpad encontrado."
        log_warn "Este script é destinado a laptops com libinput."
        exit 1
    fi

    TOUCHPAD_NOME="$(xinput list --name-only "$TOUCHPAD_ID" 2>/dev/null || echo "id=$TOUCHPAD_ID")"
    log_ok "Touchpad detectado: ${NEGRITO}${TOUCHPAD_NOME}${RESET} (id=${TOUCHPAD_ID})"
fi

# ==============================================================================
# ATIVAR TAP-TO-CLICK (sessão atual)
# ==============================================================================
separador
log_info "Ativando Tap-to-Click na sessão atual..."
separador

if [[ "$DRY_RUN" == "1" ]]; then
    log_skip "[DRY-RUN] xinput set-prop simulado."
elif xinput set-prop "$TOUCHPAD_ID" "libinput Tapping Enabled" 1 2>/dev/null; then
    log_ok "Tap-to-Click ativado na sessão atual."
else
    log_warn "Não foi possível ativar via xinput (sessão gráfica pode não estar ativa)."
    log_info "A configuração permanente abaixo garantirá o tap no próximo boot."
fi

# ==============================================================================
# CONFIGURAÇÃO PERMANENTE
# ==============================================================================
separador
log_info "Criando configuração permanente..."
separador

if [[ "$DRY_RUN" == "1" ]]; then
    log_skip "[DRY-RUN] Criação de $XORG_CONF_FILE simulada."
else
    sudo mkdir -p "$XORG_CONF_DIR"

    sudo bash -c "cat > $XORG_CONF_FILE" << 'XORGEOF'
Section "InputClass"
    Identifier "touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lrm"
EndSection
XORGEOF

    if [[ -f "$XORG_CONF_FILE" ]]; then
        log_ok "Configuração gravada em: $XORG_CONF_FILE"
    else
        log_err "Falha ao criar arquivo de configuração."
        exit 1
    fi
fi

# ==============================================================================
# RESUMO
# ==============================================================================
echo ""
separador
log_ok "Tap-to-Click configurado com sucesso!"
log_info "A configuração é permanente e estará ativa em todos os boots."
separador