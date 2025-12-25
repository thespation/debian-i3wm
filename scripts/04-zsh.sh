#!/bin/bash

# Definição de cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Arte ASCII inicial
echo -e "${GREEN}
==================================
┬ ┬┌─┐┌┐ ┬┬  ┬┌┬┐┌─┐┬─┐  ┌─┐┌─┐┬ ┬
├─┤├─┤├┴┐││  │ │ ├─┤├┬┘  ┌─┘└─┐├─┤
┴ ┴┴ ┴└─┘┴┴─┘┴ ┴ ┴ ┴┴└─  └─┘└─┘┴ ┴
${NC}"

# Caminho customizado do Oh My Zsh
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Função para instalar dependências apenas se não existirem
instalar_dependencias() {
  echo -e "${YELLOW}📦 Verificando dependências...${NC}"

  for pkg in zsh git curl fonts-powerline; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      echo -e "${YELLOW}→ Instalando $pkg...${NC}"
      sudo apt install -y "$pkg"
    else
      echo -e "${GREEN}✔ $pkg já está instalado.${NC}"
    fi
  done
}

# Função para instalar Oh My Zsh
instalar_ohmyzsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}💻 Instalando Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    echo -e "${GREEN}✔ Oh My Zsh já está instalado.${NC}"
  fi
}

# Função para instalar tema Powerlevel10k
instalar_powerlevel10k() {
  if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo -e "${BLUE}🎨 Instalando tema Powerlevel10k...${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
      "$ZSH_CUSTOM/themes/powerlevel10k"
  else
    echo -e "${GREEN}✔ Powerlevel10k já está instalado.${NC}"
  fi
}

# Função para instalar plugins extras
instalar_plugins() {
  echo -e "${BLUE}🔌 Verificando plugins extras...${NC}"

  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
      "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo -e "${YELLOW}→ Plugin zsh-autosuggestions instalado.${NC}"
  else
    echo -e "${GREEN}✔ Plugin zsh-autosuggestions já está instalado.${NC}"
  fi

  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
      "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    echo -e "${YELLOW}→ Plugin zsh-syntax-highlighting instalado.${NC}"
  else
    echo -e "${GREEN}✔ Plugin zsh-syntax-highlighting já está instalado.${NC}"
  fi
}

# Função para configurar .zshrc
configurar_zshrc() {
  echo -e "${YELLOW}⚙️ Configurando .zshrc...${NC}"
  sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc
  sed -i 's|^plugins=.*|plugins=(git debian zsh-autosuggestions zsh-syntax-highlighting)|' ~/.zshrc
}

# Função para definir Zsh como shell padrão apenas se não for
definir_shell_padrao() {
  CURRENT_SHELL=$(basename "$SHELL")
  if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo -e "${YELLOW}→ Alterando shell padrão para Zsh...${NC}"
    chsh -s "$(which zsh)"
  else
    echo -e "${GREEN}✔ Zsh já é o shell padrão.${NC}"
  fi
}

# Execução
instalar_dependencias
instalar_ohmyzsh
instalar_powerlevel10k
instalar_plugins
configurar_zshrc
definir_shell_padrao

echo -e "\n${GREEN}🎉 Zsh configurado com sucesso! Abra um novo terminal para ver as mudanças.${NC}\n"
