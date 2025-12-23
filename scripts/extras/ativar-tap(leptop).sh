#!/bin/bash

# Cores
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Ícones (Nerd Fonts)
ICON_TOUCHPAD=""
ICON_OK=""
ICON_FAIL=""
ICON_SEARCH=""
ICON_INSTALL=""
ICON_SAVE=""

echo -e "${BLUE}${ICON_SEARCH} Verificando dependências...${RESET}"

# Verifica se xinput está instalado
if ! command -v xinput &> /dev/null; then
    echo -e "${YELLOW}${ICON_INSTALL} xinput não encontrado. Instalando...${RESET}"
    sudo apt update && sudo apt install -y xinput

    if ! command -v xinput &> /dev/null; then
        echo -e "${RED}${ICON_FAIL} Falha ao instalar xinput.${RESET}"
        exit 1
    fi

    echo -e "${GREEN}${ICON_OK} xinput instalado com sucesso!${RESET}"
fi

echo -e "${BLUE}${ICON_SEARCH} Procurando touchpad...${RESET}"

# Detecta automaticamente o nome do touchpad
TOUCHPAD=$(xinput list | grep -i "touchpad" | awk -F'id=' '{print $1}' | sed 's/.*↳ //;s/[ \t]*$//')

if [ -z "$TOUCHPAD" ]; then
    echo -e "${RED}${ICON_FAIL} Nenhum touchpad encontrado!${RESET}"
    exit 1
fi

echo -e "${YELLOW}Touchpad detectado:${RESET} ${GREEN}$TOUCHPAD${RESET}"

echo -e "${BLUE}${ICON_TOUCHPAD} Ativando Tap-to-Click agora...${RESET}"

# Ativa o tap-to-click imediatamente
xinput set-prop "$TOUCHPAD" "libinput Tapping Enabled" 1 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}${ICON_OK} Tap-to-Click ativado com sucesso!${RESET}"
else
    echo -e "${RED}${ICON_FAIL} Falha ao ativar Tap-to-Click.${RESET}"
    exit 1
fi

echo -e "${BLUE}${ICON_SAVE} Criando configuração permanente...${RESET}"

# Cria o diretório se não existir
sudo mkdir -p /etc/X11/xorg.conf.d

# Cria o arquivo permanente
sudo bash -c 'cat > /etc/X11/xorg.conf.d/40-libinput.conf <<EOF
Section "InputClass"
    Identifier "touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lrm"
EndSection
EOF'

echo -e "${GREEN}${ICON_OK} Configuração permanente criada em:${RESET} /etc/X11/xorg.conf.d/40-libinput.conf"
echo -e "${GREEN}${ICON_OK} Tap-to-Click estará ativo em todos os boots.${RESET}"
