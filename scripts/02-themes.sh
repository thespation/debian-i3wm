#!/bin/bash

# Cores para logs
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Arte ASCII inicial
echo -e "${GREEN}
========================================================
┌─┐┌─┐┬─┐┌─┐┌─┐┌─┐┌─┐┌┐┌┌┬┐┌─┐┌┐┌┌┬┐┌─┐  ┌┬┐┌─┐┌┬┐┌─┐┌─┐
├─┤│  ├┬┘├┤ └─┐│  ├┤ │││ │ ├─┤│││ │││ │   │ ├┤ │││├─┤└─┐
┴ ┴└─┘┴└─└─┘└─┘└─┘└─┘┘└┘ ┴ ┴ ┴┘└┘─┴┘└─┘   ┴ └─┘┴ ┴┴ ┴└─┘${NC}"

# Função para exibir mensagens coloridas
log_message() {
    local message=$1
    local color=$2
    local symbol=$3
    echo -e "${color}${symbol} ${message}${NC}"
}

# Função para verificar o status de um comando
check_status() {
    local status=$1
    local success_message=$2
    local error_message=$3

    if [ "$status" -eq 0 ]; then
        log_message "$success_message" "$GREEN" "[✔]"
    else
        log_message "$error_message" "$RED" "[✖]"
        exit 1
    fi
}

# Diretório onde o repositório será clonado
THEMES_REPO="https://github.com/archcraft-os/archcraft-themes.git"
THEMES_DIR="/tmp/archcraft-themes"

# Diretório de destino dos temas
DEST_DIR="/usr/share/themes"

# Clonar ou atualizar o repositório
if [ -d "$THEMES_DIR" ]; then
    log_message "Repositório já existe, atualizando" "$YELLOW" "[✔]"
    git -C "$THEMES_DIR" pull &>/dev/null
    check_status $? "Repositório atualizado com sucesso" "Erro ao atualizar repositório"
else
    log_message "Clonando repositório de temas..." "$YELLOW" "[✔]"
    git clone "$THEMES_REPO" "$THEMES_DIR"
    check_status $? "Repositório clonado com sucesso" "Erro ao clonar repositório"
fi

# Criar diretório de destino caso não exista
if [ ! -d "$DEST_DIR" ]; then
    sudo mkdir -p "$DEST_DIR"
    log_message "Criado diretório $DEST_DIR" "$GREEN" "[✔]"
fi

# Encontrar todas as pastas chamadas "files" dentro do repositório
find "$THEMES_DIR" -type d -name "files" | while read -r files_dir; do
    # O nome do tema é o nome da pasta pai da pasta "files"
    theme_name=$(basename "$(dirname "$files_dir")")

    # Copiar cada subpasta de "files/" diretamente para /usr/share/themes/
    find "$files_dir" -mindepth 1 -maxdepth 1 -type d | while read -r subfolder; do
        subfolder_name=$(basename "$subfolder")
        dest_theme_dir="$DEST_DIR/$subfolder_name"

        # Criar a pasta do tema no destino, se não existir
        if [ ! -d "$dest_theme_dir" ]; then
            sudo mkdir -p "$dest_theme_dir"
        fi

        # Copiar o conteúdo da pasta diretamente para o destino
        sudo cp -rf "$subfolder/"* "$dest_theme_dir/"
        check_status $? "Copiado: $subfolder_name" "Erro ao copiar: $subfolder_name"

        # Ajustar permissões para garantir que os temas sejam reconhecidos
        sudo chmod -R a+r "$dest_theme_dir"
    done
done

log_message "Processo de instalação concluído." "$GREEN" "[✔]"
