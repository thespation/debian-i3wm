#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACOTES="$SCRIPT_DIR/01-pacotes.txt"

# Arquivos de log
LOG_INSTALADOS="$SCRIPT_DIR/instalados.txt"
LOG_PULADOS="$SCRIPT_DIR/pulados.txt"
LOG_ERROS="$SCRIPT_DIR/erros.txt"

# Cores ANSI
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Lista de gestores de login conhecidos (agora inclui Ly também)
GESTORES=("lightdm" "gdm3" "sddm" "xdm" "lxdm" "ly")

# Spinner (modelo Arch)
spinner() {
  local pid=$!
  local spinstr='|/-\\'
  while ps -p $pid &>/dev/null; do
    printf "\r [%c] " "$spinstr"
    spinstr=${spinstr#?}${spinstr%"${spinstr#?}"}
    sleep 0.1
  done
  printf "\r     \r"
}

# Banner
apresentacao() {
    echo -e "${GREEN}
===========================================================
┬┌┐┌┌─┐┌┬┐┌─┐┬  ┌─┐┬─┐  ┌─┐┌─┐┌─┐┌─┐┌┬┐┌─┐┌─┐  ┌┐ ┌─┐┌─┐┌─┐
││││└─┐ │ ├─┤│  ├─┤├┬┘  ├─┘├─┤│  │ │ │ ├┤ └─┐  ├┴┐├─┤└─┐├┤ 
┴┘└┘└─┘ ┴ ┴ ┴┴─┘┴ ┴┴└─  ┴  ┴ ┴└─┘└─┘ ┴ └─┘└─┘  └─┘┴ ┴└─┘└─┘${NC}"
    echo -e "${YELLOW}  Script de instalação de pacotes Debian    ${NC}"
    echo -e "${YELLOW}  Os pacotes listados em pacotes.txt serão  ${NC}"
    echo -e "${YELLOW}  verificados e instalados, se necessário. ${NC}\n"
}

# Verifica se o arquivo existe
verifica_arquivo() {
    if [ ! -f "$PACOTES" ]; then
        echo -e "${RED}Arquivo $PACOTES não encontrado em $SCRIPT_DIR!${NC}"
        exit 1
    fi
}

# Função para verificar se já existe algum gestor de login instalado
tem_gestor_instalado() {
    for g in "${GESTORES[@]}"; do
        if dpkg -s "$g" &>/dev/null; then
            GESTOR_INSTALADO="$g"
            return 0
        fi
    done
    return 1
}

instala_pacote() {
    local pkg=$1

    # Se o pacote for um gestor de login, verificar se já existe outro
    if [[ " ${GESTORES[@]} " =~ " $pkg " ]]; then
        if tem_gestor_instalado; then
            local gestor="$GESTOR_INSTALADO"
            if [[ "$gestor" != "$pkg" ]]; then
                echo -e "[${YELLOW}↷${NC}] $pkg pulado (já existe $gestor instalado)"
                echo "$pkg" >> "$LOG_PULADOS.tmp"
                return
            fi
        fi
    fi

    if dpkg -s "$pkg" &>/dev/null; then
        echo -e "[${GREEN}✔${NC}] $pkg já está instalado."
        echo "$pkg" >> "$LOG_PULADOS.tmp"
    else
        echo
        echo -e "Instalando $pkg..."
        sudo apt install -y "$pkg" &>/dev/null &
        spinner
        if dpkg -s "$pkg" &>/dev/null; then
            echo -e "[${GREEN}✔${NC}] ${GREEN}$pkg${NC} instalado"
            echo "$pkg" >> "$LOG_INSTALADOS.tmp"
        else
            echo -e "[${RED}✘${NC}] ${RED}$pkg${NC} Erro ao instalar"
            echo "$pkg" >> "$LOG_ERROS.tmp"
        fi
    fi
}

# Loop principal
processa_pacotes() {
    while read -r pkg; do
        [ -z "$pkg" ] && continue
        instala_pacote "$pkg"
    done < "$PACOTES"
}

# Execução
apresentacao
verifica_arquivo

# 🔑 Pede senha de sudo uma vez no início
sudo -v

processa_pacotes

# Criação dos arquivos finais apenas se houver registros
if [ -f "$LOG_INSTALADOS.tmp" ]; then
    mv "$LOG_INSTALADOS.tmp" "$LOG_INSTALADOS"
    echo -e "${GREEN}Instalados:${NC} $(wc -l < "$LOG_INSTALADOS") pacotes (salvos em $LOG_INSTALADOS)"
fi

if [ -f "$LOG_PULADOS.tmp" ]; then
    mv "$LOG_PULADOS.tmp" "$LOG_PULADOS"
    echo -e "${GREEN}Pulados:${NC} $(wc -l < "$LOG_PULADOS") pacotes (salvos em $LOG_PULADOS)"
fi

if [ -f "$LOG_ERROS.tmp" ]; then
    mv "$LOG_ERROS.tmp" "$LOG_ERROS"
    echo -e "${RED}Erros:${NC} $(wc -l < "$LOG_ERROS") pacotes (salvos em $LOG_ERROS)"
fi
