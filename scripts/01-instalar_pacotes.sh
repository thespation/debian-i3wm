#!/usr/bin/env bash
# ==============================================================================
# 01-instalar_pacotes.sh — Instalação de pacotes via apt para Debian + i3wm
# ==============================================================================
# Variáveis de ambiente:
#   DRY_RUN=1     Simula sem instalar nada
#   AUTO_YES=1    Sem prompts interativos
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACOTES="$SCRIPT_DIR/01-pacotes.txt"

LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/debian-i3wm"
LOG_INSTALADOS="$LOG_DIR/instalados.txt"
LOG_PULADOS="$LOG_DIR/pulados.txt"
LOG_ERROS="$LOG_DIR/erros.txt"

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
# SPINNER — silencioso fora de TTY
# ==============================================================================
spinner() {
    local pid=$!
    [[ ! -t 1 ]] && { wait "$pid"; return; }
    local spin='|/-\'
    while ps -p "$pid" &>/dev/null; do
        printf "\r  [%c] " "$spin"
        spin=${spin#?}${spin%"${spin#?}"}
        sleep 0.1
    done
    printf "\r       \r"
}

# ==============================================================================
# GESTORES DE LOGIN — só um pode estar instalado
# ==============================================================================
GESTORES=(lightdm gdm3 sddm xdm lxdm ly)
GESTOR_INSTALADO=""

tem_gestor_instalado() {
    for g in "${GESTORES[@]}"; do
        if dpkg-query -W -f='${Status}' "$g" 2>/dev/null | grep -q "^install ok installed"; then
            GESTOR_INSTALADO="$g"
            return 0
        fi
    done
    return 1
}

# ==============================================================================
# BANNER
# ==============================================================================
apresentacao() {
    echo -e "${VERDE}
  ══════════════════════════════════════════════════════════════
  ┬┌┐┌┌─┐┌┬┐┌─┐┬  ┌─┐┬─┐  ┌─┐┌─┐┌─┐┌─┐┌┬┐┌─┐┌─┐  ┌┐ ┌─┐┌─┐┌─┐
  ││││└─┐ │ ├─┤│  ├─┤├┬┘  ├─┘├─┤│  │ │ │ ├┤ └─┐  ├┴┐├─┤└─┐├┤
  ┴┘└┘└─┘ ┴ ┴ ┴┴─┘┴ ┴┴└─  ┴  ┴ ┴└─┘└─┘ ┴ └─┘└─┘  └─┘┴ ┴└─┘└─┘
  ══════════════════════════════════════════════════════════════${RESET}"
    echo ""
    [[ "$DRY_RUN" == "1" ]] && log_skip "Modo DRY-RUN — nenhum pacote será instalado."
    echo ""
}

# ==============================================================================
# VERIFICAÇÕES INICIAIS
# ==============================================================================
verifica_arquivo() {
    if [[ ! -f "$PACOTES" ]]; then
        log_err "Arquivo não encontrado: $PACOTES"
        exit 1
    fi
    local total
    total=$(grep -cE '^[^#[:space:]]' "$PACOTES" || true)
    log_info "Arquivo: $(basename "$PACOTES") (${total} pacotes)"
}

# ==============================================================================
# INSTALAR PACOTE
# ==============================================================================
instala_pacote() {
    local pkg="$1"

    # Conflito de gestor de login
    if [[ " ${GESTORES[*]} " =~ " $pkg " ]]; then
        if tem_gestor_instalado && [[ "$GESTOR_INSTALADO" != "$pkg" ]]; then
            log_skip "${pkg} — pulado (já existe: ${GESTOR_INSTALADO})"
            echo "$pkg" >> "$LOG_PULADOS.tmp"
            return
        fi
    fi

    # Já instalado?
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "^install ok installed"; then
        log_skip "${pkg} — já instalado"
        echo "$pkg" >> "$LOG_PULADOS.tmp"
        return
    fi

    # DRY-RUN
    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "${pkg} — [DRY-RUN] instalação simulada"
        echo "$pkg" >> "$LOG_PULADOS.tmp"
        return
    fi

    echo ""
    log_run "Instalando: ${NEGRITO}${pkg}${RESET} ..."
    sudo apt-get install -y "$pkg" &>/dev/null &
    spinner

    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "^install ok installed"; then
        log_ok "${pkg} instalado"
        echo "$pkg" >> "$LOG_INSTALADOS.tmp"
    else
        log_err "${pkg} — falha na instalação"
        echo "$pkg" >> "$LOG_ERROS.tmp"
    fi
}

# ==============================================================================
# LOOP PRINCIPAL
# ==============================================================================
processa_pacotes() {
    separador
    echo -e "${NEGRITO}  Processando pacotes...${RESET}"
    separador
    echo ""

    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
        # Remove comentários e linhas vazias
        pkg="${pkg%%#*}"
        pkg="${pkg//[[:space:]]/}"
        [[ -z "$pkg" ]] && continue
        instala_pacote "$pkg"
    done < "$PACOTES"
}

# ==============================================================================
# RESUMO FINAL
# ==============================================================================
exibe_resumo() {
    mkdir -p "$LOG_DIR"
    echo ""
    separador
    echo -e "${NEGRITO}  Resumo:${RESET}"
    separador

    if [[ -f "$LOG_INSTALADOS.tmp" ]]; then
        sort -u "$LOG_INSTALADOS.tmp" > "$LOG_INSTALADOS"
        rm -f "$LOG_INSTALADOS.tmp"
        log_ok "Instalados : $(wc -l < "$LOG_INSTALADOS") pacotes"
    fi
    if [[ -f "$LOG_PULADOS.tmp" ]]; then
        sort -u "$LOG_PULADOS.tmp" > "$LOG_PULADOS"
        rm -f "$LOG_PULADOS.tmp"
        log_skip "Pulados    : $(wc -l < "$LOG_PULADOS") pacotes"
    fi
    if [[ -f "$LOG_ERROS.tmp" ]]; then
        sort -u "$LOG_ERROS.tmp" > "$LOG_ERROS"
        rm -f "$LOG_ERROS.tmp"
        log_err "Erros      : $(wc -l < "$LOG_ERROS") pacotes"
        echo ""
        log_warn "Pacotes com falha:"
        while IFS= read -r p; do log_err "  → $p"; done < "$LOG_ERROS"
    fi

    separador
    log_info "Logs em: $LOG_DIR"
    separador
}

# ==============================================================================
# MAIN
# ==============================================================================
apresentacao
verifica_arquivo
echo ""

if [[ "$DRY_RUN" != "1" ]]; then
    sudo apt-get update -qq || log_warn "apt-get update retornou erros (instalação continua)."
    echo ""
fi

mkdir -p "$LOG_DIR"
processa_pacotes
exibe_resumo