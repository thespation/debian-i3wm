#!/bin/bash
# Script de instalação do Brave Browser no Debian

set -e

# Definição de cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner inicial
echo -e "${GREEN}
======================================================================
┬┌┐┌┌─┐┌┬┐┌─┐┬  ┌─┐┬─┐  ┌┐┌┌─┐┬  ┬┌─┐┌─┐┌─┐┌┬┐┌─┐┬─┐  ┌┐ ┬─┐┌─┐┬  ┬┌─┐
││││└─┐ │ ├─┤│  ├─┤├┬┘  │││├─┤└┐┌┘├┤ │ ┬├─┤ │││ │├┬┘  ├┴┐├┬┘├─┤└┐┌┘├┤ 
┴┘└┘└─┘ ┴ ┴ ┴┴─┘┴ ┴┴└─  ┘└┘┴ ┴ └┘ └─┘└─┘┴ ┴─┴┘└─┘┴└─  └─┘┴└─┴ ┴ └┘ └─┘
${NC}"

# Função para instalar dependências
instalar_dependencias() {
  echo -e "${YELLOW}📦 Verificando dependências...${NC}"
  for pkg in apt-transport-https curl; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      echo -e "${YELLOW}→ Instalando $pkg...${NC}"
      sudo apt install -y "$pkg"
    else
      echo -e "${GREEN}✔ $pkg já está instalado.${NC}"
    fi
  done
}

# Função para adicionar chave GPG
adicionar_chave() {
  if [ ! -f "/usr/share/keyrings/brave-browser-archive-keyring.gpg" ]; then
    echo -e "${BLUE}🔑 Adicionando chave GPG do Brave...${NC}"
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
      https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  else
    echo -e "${GREEN}✔ Chave GPG já adicionada.${NC}"
  fi
}

# Função para adicionar repositório
adicionar_repositorio() {
  if [ ! -f "/etc/apt/sources.list.d/brave-browser-release.list" ]; then
    echo -e "${BLUE}📂 Adicionando repositório do Brave...${NC}"
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
https://brave-browser-apt-release.s3.brave.com/ stable main" | \
    sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  else
    echo -e "${GREEN}✔ Repositório do Brave já configurado.${NC}"
  fi
}

# Função para instalar Brave
instalar_brave() {
  if ! dpkg -s brave-browser &>/dev/null; then
    echo -e "${YELLOW}🌐 Instalando Brave Browser...${NC}"
    sudo apt update -y
    sudo apt install -y brave-browser
    echo -e "${GREEN}🎉 Instalação concluída!${NC}"
    echo -e "${BLUE}👉 Você pode abrir o Brave digitando: brave-browser${NC}"
  else
    echo -e "${GREEN}✔ Brave Browser já está instalado.${NC}"
  fi
}

# Execução
instalar_dependencias
adicionar_chave
adicionar_repositorio
instalar_brave
