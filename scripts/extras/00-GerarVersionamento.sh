#!/usr/bin/env bash
# ==============================================================================
# 00-GerarVersionamento.sh — Backup das configurações do ambiente Debian + i3wm
# ==============================================================================
# Variáveis de ambiente:
#   DRY_RUN=1    Simula sem alterar o sistema
#   AUTO_YES=1   Compacta sem perguntar (mantém pasta original por segurança)
# ==============================================================================

DRY_RUN="${DRY_RUN:-0}"
AUTO_YES="${AUTO_YES:-0}"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DEST="$HOME/Downloads/backup-$TIMESTAMP"
ARCHIVE="${DEST}.zip"

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
  ┌─┐┌─┐┬─┐┌─┐┬─┐  ┬  ┬┌─┐┬─┐┌─┐┬┌─┐┌┐┌┌─┐┌┬┐┌─┐┌┐┌┌┬┐┌─┐
  │ ┬├┤ ├┬┘├─┤├┬┘  └┐┌┘├┤ ├┬┘└─┐││ ││││├─┤│││├┤ │││ │ │ │
  └─┘└─┘┴└─┴ ┴┴└─   └┘ └─┘┴└─└─┘┴└─┘┘└┘┴ ┴┴ ┴└─┘┘└┘ ┴ └─┘
  ══════════════════════════════════════════════════════════${RESET}"
echo ""
[[ "$DRY_RUN" == "1" ]] && log_skip "Modo DRY-RUN — nenhuma alteração será feita."
echo ""

# ==============================================================================
# CRIAR PASTA DE DESTINO
# ==============================================================================
separador
log_info "Backup será salvo em: ${NEGRITO}$DEST${RESET}"
separador
echo ""

if [[ "$DRY_RUN" != "1" ]]; then
    mkdir -p "$DEST"
fi

# ==============================================================================
# COPIAR ITENS
# ==============================================================================
copiar_item() {
    local src="$1"
    local dest_nome="${2:-$(basename "$src")}"

    if [[ ! -e "$src" ]]; then
        log_warn "Não encontrado: $src"
        return
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] Copiaria: $src"
        return
    fi

    cp -r "$src" "$DEST/$dest_nome"
    log_ok "Copiado: $src"
}

# Pastas de ~/.config
for folder in alacritty geany gtk-3.0 i3 Thunar; do
    copiar_item "$HOME/.config/$folder"
done

echo ""

# Arquivos soltos
copiar_item "$HOME/.zshrc"
copiar_item "$HOME/.local/share/asciiart" "asciiart"
copiar_item "$HOME/.local/share/fonts"    "fonts"

# ==============================================================================
# RESUMO DO BACKUP
# ==============================================================================
echo ""
separador
log_ok "Backup concluído!"
separador
echo ""

# ==============================================================================
# COMPACTAR EM ZIP
# ==============================================================================
perguntar_compactar() {
    local resposta
    if [[ "$AUTO_YES" == "1" ]]; then
        resposta="s"
    else
        read -r -p "$(echo -e "  ${AZUL}Deseja compactar o backup em ZIP? [S/n]: ${RESET}")" resposta
    fi
    [[ -z "$resposta" || "${resposta,,}" =~ ^s ]]
}

instalar_zip() {
    if command -v zip >/dev/null 2>&1; then return 0; fi
    log_warn "'zip' não está instalado."
    log_run "Instalando zip..."
    sudo apt-get update -qq && sudo apt-get install -y zip &>/dev/null
    command -v zip >/dev/null 2>&1
}

spinner_zip() {
    local pid=$1
    local spin='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  [%c] Compactando..." "$spin"
        spin=${spin#?}${spin%"${spin#?}"}
        sleep 0.2
    done
    printf "\r                        \r"
}

compactar_backup() {
    if ! instalar_zip; then
        log_err "Não foi possível instalar 'zip'. Backup mantido em: $DEST"
        return
    fi

    ( cd "$(dirname "$DEST")" && zip -qr9 "$ARCHIVE" "$(basename "$DEST")" ) &
    spinner_zip $!
    wait $!

    if [[ ! -f "$ARCHIVE" ]]; then
        log_err "Arquivo ZIP não foi criado."
        return
    fi

    local tamanho rem_resp
    tamanho="$(du -sh "$ARCHIVE" 2>/dev/null | awk '{print $1}')"
    log_ok "ZIP criado: ${NEGRITO}$ARCHIVE${RESET} (${tamanho})"
    echo ""

    if [[ "$AUTO_YES" == "1" ]]; then
        rem_resp="n"
    else
        read -r -p "$(echo -e "  ${AZUL}Remover pasta original e manter só o ZIP? [s/N]: ${RESET}")" rem_resp
    fi

    if [[ "${rem_resp,,}" =~ ^s ]]; then
        rm -rf "$DEST"
        log_ok "Pasta original removida. Mantido apenas: $(basename "$ARCHIVE")"
    else
        log_info "Pasta original mantida junto com o ZIP."
    fi
}

if [[ "$DRY_RUN" == "1" ]]; then
    log_skip "[DRY-RUN] Compactação simulada."
elif perguntar_compactar; then
    compactar_backup
else
    log_info "Backup não compactado. Disponível em: $DEST"
fi

echo ""
separador
log_ok "Tudo pronto!"
separador