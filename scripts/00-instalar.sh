#!/usr/bin/env bash
# ==============================================================================
# 00-instalar.sh — Menu principal de instalação do ambiente Debian + i3wm
# ==============================================================================
# Variáveis de ambiente:
#   AUTO_YES=1      Executa "Executar todos" sem interação
#   DRY_RUN=1       Simula execução sem alterar o sistema
# ==============================================================================

# SEM set -euo pipefail — o menu precisa sobreviver a falhas dos filhos

if [[ -t 1 ]]; then
    RESET=$'\033[0m'
    VERDE=$'\033[0;32m'
    AMARELO=$'\033[0;33m'
    AZUL=$'\033[0;94m'
    CYAN=$'\033[0;36m'
    VERMELHO=$'\033[0;31m'
    CINZA=$'\033[0;90m'
    NEGRITO=$'\033[1m'
else
    RESET='' VERDE='' AMARELO='' AZUL='' CYAN='' VERMELHO='' CINZA='' NEGRITO=''
fi

ICO_MENU="📂"; ICO_RUN="⚙"; ICO_OK="✔"; ICO_WARN="⚠"
ICO_ERR="✖";  ICO_SKIP="↷"; ICO_INFO="ℹ"; ICO_SETA="➜"

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_ATUAL="$(basename "${BASH_SOURCE[0]}")"
declare -A CONCLUIDOS=()
declare -A FALHADOS=()
declare -a SCRIPTS=()
AUTO_YES="${AUTO_YES:-0}"
DRY_RUN="${DRY_RUN:-0}"

log_ok()   { echo -e "${VERDE}  [${ICO_OK}]${RESET} $*"; }
log_info() { echo -e "${AZUL}  [${ICO_INFO}]${RESET} $*"; }
log_warn() { echo -e "${AMARELO}  [${ICO_WARN}]${RESET} $*"; }
log_err()  { echo -e "${VERMELHO}  [${ICO_ERR}]${RESET} $*"; }
log_skip() { echo -e "${AMARELO}  [${ICO_SKIP}]${RESET} $*"; }
log_run()  { echo -e "${CYAN}  [${ICO_SETA}]${RESET} $*"; }
separador(){ echo -e "  ──────────────────────────────────────────────"; }

nome_limp() { local n; n="$(basename "$1")"; echo "${n%.sh}"; }

carregar_scripts() {
    mapfile -t SCRIPTS < <(
        find "$SCRIPTS_DIR" -maxdepth 1 -type f -name "[0-9][0-9]-*.sh" \
        | grep -v "$SCRIPT_ATUAL" \
        | sort
    )
    if (( ${#SCRIPTS[@]} == 0 )); then
        log_err "Nenhum script encontrado em: $SCRIPTS_DIR"
        exit 1
    fi
}

mostrar_menu() {
    clear
    echo -e "${VERDE}
  ══════════════════════════════════════════════════════════
  ┬┌┐┌┌─┐┌┬┐┌─┐┬  ┌─┐┌─┐  ┌─┐┬ ┬┌┬┐┌─┐┌┬┐┌─┐┌┬┐┬┌─┐┌─┐┌┬┐┌─┐
  ││││└─┐ │ ├─┤│  ├─┤│ │  ├─┤│ │ │ │ ││││├─┤ │ │┌─┘├─┤ ││├─┤
  ┴┘└┘└─┘ ┴ ┴ ┴┴─┘┴ ┴└─┘  ┴ ┴└─┘ ┴ └─┘┴ ┴┴ ┴ ┴ ┴└─┘┴ ┴─┴┘┴ ┴
  ══════════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "${AZUL}  ${ICO_MENU} Scripts disponíveis:${RESET}"
    echo ""

    local i=1
    for script in "${SCRIPTS[@]}"; do
        local nome badge=""
        nome="$(nome_limp "$script")"
        [[ -n "${CONCLUIDOS[$nome]:-}" ]] && badge="${VERDE}[${ICO_OK} OK]${RESET}"
        [[ -n "${FALHADOS[$nome]:-}"   ]] && badge="${VERMELHO}[${ICO_ERR} FALHOU]${RESET}"
        echo -e "  ${AMARELO}${NEGRITO}${i})${RESET} ${nome} ${badge}"
        (( i++ ))
    done

    echo ""
    separador
    echo -e "  ${AMARELO}${NEGRITO}T)${RESET} Executar todos os scripts"
    echo -e "  ${AMARELO}${NEGRITO}S)${RESET} Sair"
    separador
    echo ""
}

executar_script() {
    local script="$1"
    local nome resposta
    nome="$(nome_limp "$script")"

    if [[ "$AUTO_YES" == "1" ]]; then
        resposta="s"
    else
        read -r -p "$(echo -e "\n${CYAN}${ICO_RUN} Executar '${NEGRITO}${nome}${RESET}${CYAN}'? [S/n]: ${RESET}")" resposta
    fi

    [[ -n "$resposta" && ! "$resposta" =~ ^[sS]$ ]] && { log_skip "Cancelado: ${nome}"; return 0; }

    if [[ "$DRY_RUN" == "1" ]]; then
        separador; log_skip "[DRY-RUN] Simulando: ${NEGRITO}${nome}${RESET}"; separador
        CONCLUIDOS["$nome"]=1; return 0
    fi

    separador
    log_run "Executando: ${NEGRITO}${nome}${RESET}"
    separador
    echo ""

    local inicio fim duracao code=0
    inicio="$(date +%s)"
    export DRY_RUN AUTO_YES
    bash "$script" || code=$?
    fim="$(date +%s)"
    duracao=$(( fim - inicio ))
    echo ""

    if (( code == 0 )); then
        separador
        log_ok "Concluído: ${NEGRITO}${nome}${RESET} (${duracao}s)"
        separador
        CONCLUIDOS["$nome"]=1
        unset "FALHADOS[$nome]"
    else
        separador
        log_err "Falhou: ${NEGRITO}${nome}${RESET} (código ${code}, ${duracao}s)"
        separador
        FALHADOS["$nome"]=1
        unset "CONCLUIDOS[$nome]"
    fi
}

executar_todos() {
    local resposta total="${#SCRIPTS[@]}" falhas=0
    if [[ "$AUTO_YES" == "1" ]]; then
        resposta="s"
    else
        read -r -p "$(echo -e "\n${CYAN}${ICO_RUN} Executar todos os ${total} scripts? [S/n]: ${RESET}")" resposta
    fi
    [[ -n "$resposta" && ! "$resposta" =~ ^[sS]$ ]] && { log_warn "Cancelado."; return; }

    # Ao rodar todos, não pergunta em cada script individualmente
    local AUTO_YES=1

    echo ""; local i=1
    for script in "${SCRIPTS[@]}"; do
        local nome; nome="$(nome_limp "$script")"
        echo -e "  [${i}/${total}] ${nome}"
        executar_script "$script"
        [[ -n "${FALHADOS[$nome]:-}" ]] && (( falhas++ )) || true
        (( i++ )); echo ""
    done

    separador; echo -e "${NEGRITO}  Resumo:${RESET}"; separador
    log_ok "Concluídos : $(( total - falhas ))/${total}"
    (( falhas > 0 )) && log_err "Falhados   : ${falhas}/${total}"
    separador; echo ""

    local cmds=(i3 rofi polybar picom dunst brave-browser ksuperkey zsh alacritty)
    separador; echo -e "${NEGRITO}  Checklist:${RESET}"; separador
    for cmd in "${cmds[@]}"; do
        command -v "$cmd" >/dev/null 2>&1 && log_ok "$cmd" || log_warn "${cmd} (não encontrado)"
    done
    separador; echo ""

    echo -e "  ${AMARELO}${ICO_WARN} Recomenda-se reiniciar.${RESET}"; echo ""
    local r
    read -r -p "$(echo -e "${CYAN}${ICO_RUN} Reiniciar agora? [s/N]: ${RESET}")" r
    [[ "$DRY_RUN" == "1" ]] && { log_skip "[DRY-RUN] Reinício simulado."; return; }
    [[ "${r,,}" =~ ^s ]] && { log_run "Reiniciando..."; command -v systemctl >/dev/null 2>&1 && sudo systemctl reboot || sudo reboot; } \
                          || log_info "Reinicie manualmente quando quiser."
}

case "${1:-}" in
    -h|--help)
        echo "Uso: ./00-instalar.sh"
        echo "  AUTO_YES=1   Sem interação"
        echo "  DRY_RUN=1    Simula sem alterar"
        exit 0 ;;
    "") : ;;
    *) log_err "Opção inválida: $1"; exit 1 ;;
esac

carregar_scripts

while true; do
    mostrar_menu
    if [[ "$AUTO_YES" == "1" ]]; then
        executar_todos; exit 0
    fi

    echo -n "  Escolha uma opção: "
    read -r opcao
    echo ""

    case "$opcao" in
        [Tt]) executar_todos; exit 0 ;;
        [Ss]) log_info "Até logo!"; exit 0 ;;
        ''|*[!0-9]*) log_warn "Opção inválida." ;;
        *)
            if (( opcao >= 1 && opcao <= ${#SCRIPTS[@]} )); then
                executar_script "${SCRIPTS[$((opcao - 1))]}"
            else
                log_warn "Número fora da lista (1–${#SCRIPTS[@]})."
            fi
            ;;
    esac

    echo ""
    echo -e "  ${AZUL}Pressione ENTER para voltar ao menu...${RESET}"
    read -r
done