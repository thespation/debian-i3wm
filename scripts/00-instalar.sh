#!/bin/bash

# ============================
# CONFIGURAÇÃO DE CORES
# ============================
RESET="\e[0m"
VERDE="\e[32m"
AMARELO="\e[33m"
AZUL="\e[34m"
CYAN="\e[36m"
VERMELHO="\e[31m"

# ============================
# ÍCONES
# ============================
ICO_MENU="📂"
ICO_RUN="⚙"
ICO_OK="✔"
ICO_WARN="⚠"

# ============================
# VARIÁVEIS PRINCIPAIS
# ============================
SCRIPTS_DIR="$(dirname "$0")"
SCRIPT_ATUAL="$(basename "$0")"

# Array associativo para marcar scripts concluídos
declare -A CONCLUIDOS

# ============================
# FUNÇÃO: limpar nome (remover .sh)
# ============================
nome_limp() {
    local nome=$(basename "$1")
    echo "${nome%.sh}"
}

# ============================
# FUNÇÃO: carregar scripts
# ============================
carregar_scripts() {
    mapfile -t SCRIPTS < <(
        find "$SCRIPTS_DIR" -maxdepth 1 -type f -name "*.sh" \
        | grep -v "$SCRIPT_ATUAL" \
        | sort
    )
}

# ============================
# FUNÇÃO: mostrar menu
# ============================
mostrar_menu() {
    clear
    echo -e "${VERDE}
==========================================================
┬┌┐┌┌─┐┌┬┐┌─┐┬  ┌─┐┌─┐  ┌─┐┬ ┬┌┬┐┌─┐┌┬┐┌─┐┌┬┐┬┌─┐┌─┐┌┬┐┌─┐
││││└─┐ │ ├─┤│  ├─┤│ │  ├─┤│ │ │ │ ││││├─┤ │ │┌─┘├─┤ ││├─┤
┴┘└┘└─┘ ┴ ┴ ┴┴─┘┴ ┴└─┘  ┴ ┴└─┘ ┴ └─┘┴ ┴┴ ┴ ┴ ┴└─┘┴ ┴─┴┘┴ ┴${RESET}"

    echo -e "${AZUL}${ICO_MENU} Scripts disponíveis:${RESET}\n"

    local i=1
    for script in "${SCRIPTS[@]}"; do
        local nome=$(nome_limp "$script")
        local status=""

        [[ ${CONCLUIDOS["$nome"]} ]] && status="${VERDE}(OK)${RESET}"

        echo -e "${AMARELO}${i})${RESET} ${nome} ${status}"
        ((i++))
    done

    echo ""
    echo -e "${AMARELO}T)${RESET} Executar todos"
    echo -e "${AMARELO}S)${RESET} Sair"
    echo ""
}

# ============================
# FUNÇÃO: executar um script
# ============================
executar_script() {
    local script="$1"
    local nome=$(nome_limp "$script")

    # Pergunta e resposta na mesma linha com cores
    read -r -p "$(echo -e "\n${CYAN}${ICO_RUN} Executar '${nome}'? [S/n]: ${RESET}")" resp

    if [[ -z "$resp" || "$resp" =~ ^[sS]$ ]]; then
        echo -e "\n${AMARELO}${ICO_RUN} Executando: ${nome}...${RESET}"
        bash "$script"
        echo -e "${VERDE}${ICO_OK} Concluído: ${nome}${RESET}\n"
        CONCLUIDOS["$nome"]=1
    else
        echo -e "${VERMELHO}${ICO_WARN} Cancelado.${RESET}\n"
    fi
}

# ============================
# FUNÇÃO: executar todos
# ============================
executar_todos() {
    # Pergunta e resposta na mesma linha com cores
    read -r -p "$(echo -e "\n${CYAN}${ICO_RUN} Executar todos os scripts? [S/n]: ${RESET}")" resp

    if [[ -z "$resp" || "$resp" =~ ^[sS]$ ]]; then
        for script in "${SCRIPTS[@]}"; do
            executar_script "$script"
        done
    else
        echo -e "${VERMELHO}${ICO_WARN} Operação cancelada.${RESET}"
    fi
}

# ============================
# LOOP PRINCIPAL
# ============================
carregar_scripts

while true; do
    mostrar_menu
    echo -n "Escolha uma opção: "
    read -r opcao

    case "$opcao" in
        [Tt])
            executar_todos
            ;;
        [Ss])
            exit 0
            ;;
        ''|*[!0-9]*)
            echo -e "${VERMELHO}${ICO_WARN} Opção inválida.${RESET}"
            ;;
        *)
            if (( opcao >= 1 && opcao <= ${#SCRIPTS[@]} )); then
                executar_script "${SCRIPTS[$((opcao-1))]}"
            else
                echo -e "${VERMELHO}${ICO_WARN} Número fora da lista.${RESET}"
            fi
            ;;
    esac

    echo -e "\nPressione ENTER para voltar ao menu..."
    read -r
done
