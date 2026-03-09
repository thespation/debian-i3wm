#!/usr/bin/env bash
# ==============================================================================
# 06-ksuperkey.sh — Compilação e instalação do ksuperkey para Debian + i3wm
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
URL_REPOSITORIO="https://github.com/hanschen/ksuperkey.git"
DIRETORIO_BUILD="/tmp/ksuperkey"

# ==============================================================================
# BANNER
# ==============================================================================
echo -e "${VERDE}
  ══════════════════════════════════════════════════════════
  ┬┌┐┌┌─┐┌┬┐┌─┐┬  ┌─┐┬─┐  ┬┌─┌─┐┬ ┬┌─┐┌─┐┬─┐┬┌─┌─┐┬ ┬
  ││││└─┐ │ ├─┤│  ├─┤├┬┘  ├┴┐└─┐│ │├─┘├┤ ├┬┘├┴┐├┤ └┬┘
  ┴┘└┘└─┘ ┴ ┴ ┴┴─┘┴ ┴┴└─  ┴ ┴└─┘└─┘┴  └─┘┴└─┴ ┴└─┘ ┴
  ══════════════════════════════════════════════════════════${RESET}"
echo ""
[[ "$DRY_RUN" == "1" ]] && log_skip "Modo DRY-RUN — nenhuma alteração será feita."
echo ""

# ==============================================================================
# VERIFICAR SE JÁ ESTÁ INSTALADO
# ==============================================================================
verificar_instalacao_existente() {
    if ! command -v ksuperkey >/dev/null 2>&1; then
        return 0
    fi

    log_info "ksuperkey já está instalado."
    echo ""

    local resposta
    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] Reinstalação simulada."
        return 0
    fi

    read -r -p "$(echo -e "  ${AMARELO}Deseja reinstalar? [s/N]: ${RESET}")" resposta
    echo ""

    case "${resposta,,}" in
        s|sim) log_run "Reinstalação confirmada. Continuando..." ;;
        *)     log_info "Instalação cancelada."; exit 0 ;;
    esac
}

# ==============================================================================
# ATUALIZAR LISTA DE PACOTES
# ==============================================================================
atualizar_sistema() {
    separador
    log_run "Atualizando lista de pacotes..."
    [[ "$DRY_RUN" == "1" ]] && { log_skip "[DRY-RUN] apt-get update simulado."; return; }
    sudo apt-get update -qq || log_warn "apt-get update retornou erros (instalação pode continuar)."
}

# ==============================================================================
# INSTALAR DEPENDÊNCIAS
# ==============================================================================
instalar_dependencias() {
    separador
    log_run "Instalando dependências de compilação..."
    [[ "$DRY_RUN" == "1" ]] && { log_skip "[DRY-RUN] Instalação de dependências simulada."; return; }

    local deps=(git build-essential libx11-dev libxtst-dev pkg-config)
    if sudo apt-get install -y "${deps[@]}" &>/dev/null; then
        log_ok "Dependências instaladas."
    else
        log_err "Falha ao instalar dependências."
        exit 1
    fi
}

# ==============================================================================
# CLONAR OU ATUALIZAR REPOSITÓRIO
# ==============================================================================
clonar_repositorio() {
    separador
    if [[ -d "$DIRETORIO_BUILD/.git" ]]; then
        log_run "Repositório já existe — atualizando..."
        [[ "$DRY_RUN" == "1" ]] && { log_skip "[DRY-RUN] git pull simulado."; return; }
        if git -C "$DIRETORIO_BUILD" pull --ff-only &>/dev/null; then
            log_ok "Repositório atualizado."
        else
            log_warn "git pull falhou — recriando com clone limpo."
            rm -rf "$DIRETORIO_BUILD"
            clonar_repositorio
        fi
    else
        [[ -d "$DIRETORIO_BUILD" ]] && rm -rf "$DIRETORIO_BUILD"
        log_run "Clonando repositório do ksuperkey..."
        [[ "$DRY_RUN" == "1" ]] && { log_skip "[DRY-RUN] git clone simulado."; return; }
        if git clone --depth=1 "$URL_REPOSITORIO" "$DIRETORIO_BUILD" &>/dev/null; then
            log_ok "Clone concluído."
        else
            log_err "Falha ao clonar repositório."
            exit 1
        fi
    fi
}

# ==============================================================================
# COMPILAR — subshell em vez de cd
# ==============================================================================
compilar_ksuperkey() {
    separador
    log_run "Compilando ksuperkey..."
    [[ "$DRY_RUN" == "1" ]] && { log_skip "[DRY-RUN] Compilação simulada."; return; }

    if ( cd "$DIRETORIO_BUILD" && make &>/dev/null ); then
        log_ok "Compilação concluída."
    else
        log_err "Falha na compilação."
        exit 1
    fi
}

# ==============================================================================
# INSTALAR
# ==============================================================================
instalar_ksuperkey() {
    separador
    log_run "Instalando ksuperkey no sistema..."
    [[ "$DRY_RUN" == "1" ]] && { log_skip "[DRY-RUN] make install simulado."; return; }

    if ( cd "$DIRETORIO_BUILD" && sudo make install &>/dev/null ); then
        log_ok "ksuperkey instalado com sucesso."
    else
        log_err "Falha ao instalar ksuperkey."
        exit 1
    fi
}

# ==============================================================================
# LIMPEZA
# ==============================================================================
limpar_build() {
    [[ -d "$DIRETORIO_BUILD" ]] && rm -rf "$DIRETORIO_BUILD"
}

# ==============================================================================
# MAIN
# ==============================================================================
verificar_instalacao_existente

if [[ "$DRY_RUN" != "1" ]]; then
    sudo -v || { log_err "Falha ao validar sudo."; exit 1; }
fi

atualizar_sistema
instalar_dependencias
clonar_repositorio
compilar_ksuperkey
instalar_ksuperkey
limpar_build

echo ""
separador
log_ok "ksuperkey instalado com sucesso!"
log_info "Adicione ao ~/.config/i3/config:"
echo -e "  exec --no-startup-id ksuperkey"
separador