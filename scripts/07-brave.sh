#!/bin/bash
# Script de instalação do Brave Browser no Debian

set -e

echo "Atualizando lista de pacotes..."
sudo apt update -y

echo "Instalando dependências necessárias..."
sudo apt install -y apt-transport-https curl

echo "Adicionando chave GPG do Brave..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
  https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "Adicionando repositório do Brave..."
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
https://brave-browser-apt-release.s3.brave.com/ stable main" | \
sudo tee /etc/apt/sources.list.d/brave-browser-release.list

echo "Atualizando lista de pacotes novamente..."
sudo apt update -y

echo "Instalando Brave Browser..."
sudo apt install -y brave-browser

echo "Instalação concluída! 🎉"
echo "Você pode abrir o Brave digitando: brave-browser"
