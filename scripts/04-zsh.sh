#!/usr/bin/env bash
# ==============================================================================
# 04-zsh.sh — Instalação e configuração do Zsh + Oh My Zsh para Debian + i3wm
# ==============================================================================
# Variáveis de ambiente:
#   DRY_RUN=1   Simula sem alterar o sistema
# ==============================================================================

DRY_RUN="${DRY_RUN:-0}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

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
  ══════════════════════════════════════════════
  ┬ ┬┌─┐┌┐ ┬┬  ┬┌┬┐┌─┐┬─┐  ┌─┐┌─┐┬ ┬
  ├─┤├─┤├┴┐││  │ │ ├─┤├┬┘  ┌─┘└─┐├─┤
  ┴ ┴┴ ┴└─┘┴┴─┘┴ ┴ ┴ ┴┴└─  └─┘└─┘┴ ┴
  ══════════════════════════════════════════════${RESET}"
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

    for pkg in zsh git curl fonts-powerline; do
        if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "^install ok installed"; then
            log_skip "${pkg} — já instalado"
        elif [[ "$DRY_RUN" == "1" ]]; then
            log_skip "[DRY-RUN] Instalaria: $pkg"
        else
            log_run "Instalando: $pkg ..."
            if sudo apt-get install -y "$pkg" &>/dev/null; then
                log_ok "$pkg instalado"
            else
                log_err "Falha ao instalar: $pkg"
                exit 1
            fi
        fi
    done
}

# ==============================================================================
# OH MY ZSH
# ==============================================================================
instalar_ohmyzsh() {
    separador
    log_info "Verificando Oh My Zsh..."
    separador

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_skip "Oh My Zsh já está instalado."
        return
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] Instalação do Oh My Zsh simulada."
        return
    fi

    log_run "Instalando Oh My Zsh..."
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &>/dev/null; then
        log_ok "Oh My Zsh instalado."
    else
        log_err "Falha ao instalar Oh My Zsh."
        exit 1
    fi
}

# ==============================================================================
# POWERLEVEL10K
# ==============================================================================
instalar_powerlevel10k() {
    separador
    log_info "Verificando tema Powerlevel10k..."
    separador

    local dest="$ZSH_CUSTOM/themes/powerlevel10k"

    if [[ -d "$dest" ]]; then
        log_skip "Powerlevel10k já está instalado."
        return
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] git clone powerlevel10k simulado."
        return
    fi

    log_run "Instalando Powerlevel10k..."
    if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$dest" &>/dev/null; then
        log_ok "Powerlevel10k instalado."
    else
        log_err "Falha ao instalar Powerlevel10k."
        exit 1
    fi
}

# ==============================================================================
# PLUGINS
# ==============================================================================
instalar_plugin() {
    local nome="$1"
    local url="$2"
    local dest="$ZSH_CUSTOM/plugins/$nome"

    if [[ -d "$dest" ]]; then
        log_skip "${nome} — já instalado"
        return
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] git clone $nome simulado."
        return
    fi

    log_run "Instalando plugin: $nome ..."
    if git clone --depth=1 "$url" "$dest" &>/dev/null; then
        log_ok "$nome instalado."
    else
        log_err "Falha ao instalar: $nome"
    fi
}

instalar_plugins() {
    separador
    log_info "Verificando plugins..."
    separador

    instalar_plugin "zsh-autosuggestions" \
        "https://github.com/zsh-users/zsh-autosuggestions"
    instalar_plugin "zsh-syntax-highlighting" \
        "https://github.com/zsh-users/zsh-syntax-highlighting.git"
}

# ==============================================================================
# CONFIGURAR .zshrc
# ==============================================================================
configurar_zshrc() {
    separador
    log_info "Configurando .zshrc..."
    separador

    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] Configuração do .zshrc simulada."
        return
    fi

    if [[ ! -f "$HOME/.zshrc" ]]; then
        log_warn ".zshrc não encontrado — será criado pelo Oh My Zsh no primeiro uso."
        return
    fi

    # Tema
    sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
    log_ok "Tema definido: powerlevel10k"

    # Plugins — preserva plugins existentes, adiciona apenas os que faltam
    local linha_plugins
    linha_plugins=$(grep "^plugins=" "$HOME/.zshrc" | head -n1)

    local -a necessarios=(git debian zsh-autosuggestions zsh-syntax-highlighting)
    local -a atuais=()

    if [[ -n "$linha_plugins" ]]; then
        local lista
        lista=$(echo "$linha_plugins" | grep -oP '\(\K[^)]+')
        read -ra atuais <<< "$lista"
    fi

    local -a final=("${atuais[@]}")
    for p in "${necessarios[@]}"; do
        local encontrado=0
        for a in "${atuais[@]}"; do
            [[ "$a" == "$p" ]] && encontrado=1 && break
        done
        (( encontrado )) || final+=("$p")
    done

    local nova_linha="plugins=(${final[*]})"
    sed -i "s|^plugins=.*|${nova_linha}|" "$HOME/.zshrc"
    log_ok "Plugins configurados: ${final[*]}"
}

# ==============================================================================
# SHELL PADRÃO
# ==============================================================================
definir_shell_padrao() {
    separador
    log_info "Verificando shell padrão..."
    separador

    if [[ "$(basename "$SHELL")" == "zsh" ]]; then
        log_skip "Zsh já é o shell padrão."
        return
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        log_skip "[DRY-RUN] chsh simulado."
        return
    fi

    local zsh_path
    zsh_path="$(command -v zsh)"
    log_run "Alterando shell padrão para Zsh..."
    if chsh -s "$zsh_path"; then
        log_ok "Shell padrão alterado para Zsh."
    else
        log_warn "Não foi possível alterar o shell padrão (tente manualmente: chsh -s $zsh_path)."
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================
instalar_dependencias
echo ""
instalar_ohmyzsh
echo ""
instalar_powerlevel10k
echo ""
instalar_plugins
echo ""
configurar_zshrc
echo ""
definir_shell_padrao
echo ""
separador
log_ok "Zsh configurado com sucesso!"
log_info "Abra um novo terminal para ver as mudanças."
separador