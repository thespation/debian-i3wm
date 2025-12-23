#!/bin/bash

# Cores para logs
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Arte ASCII inicial
echo -e "${GREEN}
=========================================================
┌─┐┌─┐┬─┐┌─┐┌─┐┌─┐┌─┐┌┐┌┌┬┐┌─┐┌┐┌┌┬┐┌─┐  ┬┌─┐┌─┐┌┐┌┌─┐┌─┐
├─┤│  ├┬┘├┤ └─┐│  ├┤ │││ │ ├─┤│││ │││ │  ││  │ ││││├┤ └─┐
┴ ┴└─┘┴└─└─┘└─┘└─┘└─┘┘└┘ ┴ ┴ ┴┘└┘─┴┘└─┘  ┴└─┘└─┘┘└┘└─┘└─┘${NC}"

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

# Verificar se o git está instalado
command -v git >/dev/null 2>&1 || { log_message "Erro: git não encontrado. Instale o git e tente novamente." "$RED" "[✖]"; exit 1; }

# Diretório onde o repositório será clonado
ICONS_REPO="https://github.com/archcraft-os/archcraft-icons.git"
ICONS_DIR="/tmp/archcraft-icons"

# Diretório de destino dos temas
DEST_DIR="/usr/share/icons"

# Clonar ou atualizar o repositório
if [ -d "$ICONS_DIR" ]; then
    log_message "Repositório já existe, atualizando..." "$YELLOW" "[✔]"
    git -C "$ICONS_DIR" pull &>/dev/null
    check_status $? "Repositório atualizado com sucesso" "Erro ao atualizar repositório"
else
    log_message "Clonando repositório de ícones..." "$YELLOW" "[✔]"
    git clone "$ICONS_REPO" "$ICONS_DIR"
    check_status $? "Repositório clonado com sucesso" "Erro ao clonar repositório"
fi

# Criar diretório de destino caso não exista
if [ ! -d "$DEST_DIR" ]; then
    sudo mkdir -p "$DEST_DIR"
    check_status $? "Diretório de ícones criado: $DEST_DIR" "Erro ao criar diretório de ícones"
fi

# Encontrar todas as pastas chamadas "files" dentro do repositório
find "$ICONS_DIR" -type d -name "files" | while read -r files_dir; do
    # O nome do tema é o nome da pasta pai da pasta "files"
    icon_name=$(basename "$(dirname "$files_dir")")

    # Copiar cada subpasta de "files/" diretamente para /usr/share/icons/
    find "$files_dir" -mindepth 1 -maxdepth 1 -type d | while read -r subfolder; do
        subfolder_name=$(basename "$subfolder")
        dest_icon_dir="$DEST_DIR/$subfolder_name"

        # Sempre sobrescreve, mesmo se já existir
        sudo cp -rf "$subfolder/" "$dest_icon_dir/"
        check_status $? "Ícones copiados: $subfolder_name" "Erro ao copiar ícones: $subfolder_name"
    done
done

# Garantir que o diretório de ícones tenha permissões de leitura para o usuário
log_message "Ajustando permissões de leitura para os ícones..." "$YELLOW" "[✔]"
sudo chmod -R a+r /usr/share/icons
check_status $? "Permissões ajustadas com sucesso" "Erro ao ajustar permissões"

# Se quiser alterar a propriedade para o seu usuário (substitua 'seu_usuario' pelo seu nome de usuário)
# sudo chown -R seu_usuario:seu_usuario /usr/share/icons
# check_status $? "Propriedade alterada para o usuário" "Erro ao alterar a propriedade dos ícones"

log_message "Processo de instalação e permissão concluído." "$GREEN" "[✔]"
