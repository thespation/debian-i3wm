#!/usr/bin/env bash
# ==============================================================================
# 07-brave.sh — Instalação do Brave Browser para Debian + i3wm
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
GPG_URL="https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
GPG_FILE="/usr/share/keyrings/brave-browser-archive-keyring.gpg"
REPO_FILE="/etc/apt/sources.list.d/brave-browser-release.list"

# ==============================================================================
# BANNER
# ==============================================================================
echo -e "${VERDE}
  ══════════════════════════════════════════════════════════════════════
  ┬┌┐┌┌─┐┌┬┐┌─┐┬  ┌─┐┬─┐  ┌┐┌┌─┐┬  ┬┌─┐┌─┐┌─┐┌┬┐┌─┐┬─┐  ┌┐ ┬─┐┌─┐┬  ┬┌─┐
  ││││└─┐ │ ├─┤│  ├─┤├┬┘  │││├─┤└┐┌┘├┤ │ ┬├─┤ │││ │├┬┘  ├┴┐├┬┘├─┤└┐┌┘├┤
  ┴┘└┘└─┘ ┴ ┴ ┴┴─┘┴ ┴┴└─  ┘└┘┴ ┴ └┘ └─┘└─┘┴ ┴─┴┘└─┘┴└─  └─┘┴└─┴ ┴ └┘ └─┘
  ══════════════════════════════════════════════════════════════════════${RESET}"
echo ""
[[ "$DRY_RUN" == "1" ]] && log_skip "Modo DRY-RUN — nenhuma alteração será feita."
echo ""

# ==============================================================================
# DEPENDÊNCIAS
# ==============================================================================
instalar_dependencias() {
    separador
    log_info "Verificando dependências..."
    separador

    for pkg in apt-transport-https curl; do
        if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "^install ok installed"; then
            log_skip "${pkg} — já instalado"
        elif [[ "$DRY_RUN" == "1" ]]; then
            log_skip "[DRY-RUN] Instalaria: $pkg"
        else
            log_run "Instalando: $pkg ..."
            if sudo apt-get install -y "$pkg" &>/dev/null; then
                log_ok "$pkg instalado."
            else
                log_err "Falha ao instalar: $pkg"
                exit 1
            fi
        fi
    done
}

# ==============================================================================
# CHAVE GPG
# ==============================================================================
adicionar_chave() {
    separador
    log_info "Verificando chave GPG..."
    separador

    if [[ -f "$GPG_FILE" ]]; then
        log_skip "Chave GPG já adicionada."
        return
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] Download da chave GPG simulado."
        return
    fi

    log_run "Baixando chave GPG do Brave..."
    if sudo curl -fsSLo "$GPG_FILE" "$GPG_URL"; then
        log_ok "Chave GPG adicionada."
    else
        log_err "Falha ao baixar chave GPG."
        exit 1
    fi
}

# ==============================================================================
# REPOSITÓRIO
# ==============================================================================
adicionar_repositorio() {
    separador
    log_info "Verificando repositório..."
    separador

    if [[ -f "$REPO_FILE" ]]; then
        log_skip "Repositório já configurado."
        return
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] Adição de repositório simulada."
        return
    fi

    log_run "Adicionando repositório do Brave..."
    echo "deb [signed-by=${GPG_FILE}] https://brave-browser-apt-release.s3.brave.com/ stable main" \
        | sudo tee "$REPO_FILE" &>/dev/null

    log_ok "Repositório adicionado."
}

# ==============================================================================
# INSTALAR BRAVE
# ==============================================================================
instalar_brave() {
    separador
    log_info "Verificando Brave Browser..."
    separador

    if dpkg-query -W -f='${Status}' brave-browser 2>/dev/null | grep -q "^install ok installed"; then
        log_skip "Brave Browser já está instalado."
        return
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] Instalação do Brave simulada."
        return
    fi

    log_run "Atualizando lista de pacotes..."
    sudo apt-get update -qq || log_warn "apt-get update retornou erros (instalação continua)."

    log_run "Instalando Brave Browser..."
    if sudo apt-get install -y brave-browser &>/dev/null; then
        local versao
        versao="$(brave-browser --version 2>/dev/null | head -n1 || echo "")"
        log_ok "Brave Browser instalado. ${versao:+($versao)}"
    else
        log_err "Falha ao instalar Brave Browser."
        exit 1
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================
if [[ "$DRY_RUN" != "1" ]]; then
    sudo -v || { log_err "Falha ao validar sudo."; exit 1; }
fi

instalar_dependencias
adicionar_chave
adicionar_repositorio
instalar_brave

echo ""
separador
log_ok "Brave Browser pronto para uso!"
log_info "Para abrir: brave-browser"
separador