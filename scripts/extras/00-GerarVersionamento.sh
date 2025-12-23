#!/bin/bash

# Definição de cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Cria pasta com data e hora no diretório atual
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DEST="$HOME/Downloads/backup-$TIMESTAMP"

mkdir -p "$DEST"

echo -e "${CYAN}Backup será salvo em:${RESET} $DEST"

#############################
### BACKUP DE ~/.config  ####
#############################

CONFIG_DIR="$HOME/.config"
for folder in alacritty geany gtk-3.0 i3 Thunar; do
    if [ -d "$CONFIG_DIR/$folder" ]; then
        cp -r "$CONFIG_DIR/$folder" "$DEST/"
        echo -e "${GREEN}Copiado:${RESET} $CONFIG_DIR/$folder"
    else
        echo -e "${YELLOW}Aviso:${RESET} pasta $CONFIG_DIR/$folder não encontrada"
    fi
done

#############################
### ARQUIVOS SOLTOS       ###
#############################

if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$DEST/"
    echo -e "${GREEN}Copiado:${RESET} $HOME/.zshrc"
fi

if [ -d "$HOME/.local/share/asciiart" ]; then
    cp -r "$HOME/.local/share/asciiart" "$DEST/asciiart"
    echo -e "${GREEN}Copiado:${RESET} $HOME/.local/share/asciiart"
fi

if [ -d "$HOME/.local/share/fonts" ]; then
    cp -r "$HOME/.local/share/fonts" "$DEST/fonts"
    echo -e "${GREEN}Copiado:${RESET} $HOME/.local/share/fonts"
fi

echo -e "\n${CYAN}Backup concluído!${RESET}"

###########################################
### OPÇÃO DE COMPACTAR PASTA DE SAÍDA    ###
###########################################

ARCHIVE="$DEST.zip"

echo ""

while true; do
    read -p "Deseja compactar o backup em ZIP? (s/n): " choice
    case "$choice" in
        ""|[Ss])
            if ! command -v zip >/dev/null 2>&1; then
                echo -e "${YELLOW}O utilitário 'zip' não está instalado.${RESET}"
                echo -e "${BLUE}==> Instalando 'zip'...${RESET}"
                sudo apt-get update && sudo apt-get install -y zip
            fi

            echo -e "${BLUE}==> Compactando backup em arquivo ZIP...${RESET}"

            (
                cd "$(dirname "$DEST")" || exit
                zip -qr -9 "$ARCHIVE" "$(basename "$DEST")" >/dev/null 2>&1
            ) &

            ZIP_PID=$!

            SPINNER='|/-\\'
            while kill -0 $ZIP_PID 2>/dev/null; do
                for i in $(seq 0 3); do
                    printf "\r[%c] Compactando..." "${SPINNER:$i:1}"
                    sleep 0.2
                done
            done

            wait $ZIP_PID
            if [ -f "$ARCHIVE" ]; then
                printf "\r${GREEN}Backup compactado em:${RESET} $ARCHIVE\n"
            else
                printf "\r${RED}Erro: arquivo ZIP não foi criado!${RESET}\n"
            fi

            while true; do
                read -p "Deseja remover a pasta original e manter apenas o ZIP? (s/n): " remove_choice
                case "$remove_choice" in
                    ""|[Ss])
                        rm -rf "$DEST"
                        echo -e "${YELLOW}Pasta original removida.${RESET} Apenas o arquivo $ARCHIVE foi mantido."
                        break
                        ;;
                    [Nn])
                        echo -e "${CYAN}Pasta original mantida junto com o arquivo ZIP.${RESET}"
                        break
                        ;;
                    *)
                        echo -e "${RED}Resposta inválida. Digite 's' ou 'n'.${RESET}"
                        ;;
                esac
            done
            break
            ;;
        [Nn])
            echo -e "${CYAN}Backup não foi compactado.${RESET} Pasta disponível em: $DEST"
            break
            ;;
        *)
            echo -e "${RED}Resposta inválida. Digite 's' ou 'n'.${RESET}"
            ;;
    esac
done
