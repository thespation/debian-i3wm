#!/bin/bash

# Script para instalar e configurar Zsh com Oh My Zsh + Powerlevel10k no Debian
# Inclui fontes Nerd Fonts para ícones e define Zsh como shell padrão

# Atualiza pacotes
sudo apt update && sudo apt upgrade -y

# Instala Zsh e dependências
sudo apt install -y zsh git curl fonts-powerline

# Define Zsh como shell padrão para o usuário atual
chsh -s $(which zsh)

# Instala Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Instalando Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Instala tema Powerlevel10k
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "Instalando Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Instala plugins extras
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Configura o tema e plugins no .zshrc
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc
sed -i 's|^plugins=.*|plugins=(git debian zsh-autosuggestions zsh-syntax-highlighting)|' ~/.zshrc

echo "✅ Instalação concluída!"
echo "➡️ Reinicie sua sessão ou faça logout/login para aplicar o Zsh como padrão."
echo "➡️ Ao abrir o terminal, o Powerlevel10k vai iniciar a configuração interativa."
