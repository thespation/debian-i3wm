#!/bin/bash
set -e
# Instalador do ksuperkey para Debian
# Padrão visual e estrutural padronizado (PT-BR)

# =====================================================
# Cores
# =====================================================
VERDE='\033[0;32m'
AMARELO='\033[0;33m'
VERMELHO='\033[0;31m'
SEM_COR='\033[0m'

# =====================================================
# ASCII ART
# =====================================================
mostrar_banner() {
echo -e "${VERDE}
========================================================
┬┌┐┌┌─┐┌┬┐┌─┐┬  ┌─┐┬─┐  ┬┌─┌─┐┬ ┬┌─┐┌─┐┬─┐┬┌─┌─┐┬ ┬
││││└─┐ │ ├─┤│  ├─┤├┬┘  ├┴┐└─┐│ │├─┘├┤ ├┬┘├┴┐├┤ └┬┘
┴┘└┘└─┘ ┴ ┴ ┴┴─┘┴ ┴┴└─  ┴ ┴└─┘└─┘┴  └─┘┴└─┴ ┴└─┘ ┴
========================================================
${SEM_COR}"
}

# =====================================================
# Funções utilitárias
# =====================================================
log_mensagem() {
    local mensagem=$1
    local cor=$2
    local simbolo=$3
    echo -e "${cor}${simbolo} ${mensagem}${SEM_COR}"
}

verificar_status() {
    local status=$1
    local mensagem_sucesso=$2
    local mensagem_erro=$3

    if [ "$status" -eq 0 ]; then
        log_mensagem "$mensagem_sucesso" "$VERDE" "[✔]"
    else
        log_mensagem "$mensagem_erro" "$VERMELHO" "[✖]"
        exit 1
    fi
}

# =====================================================
# Variáveis
# =====================================================
URL_REPOSITORIO="https://github.com/hanschen/ksuperkey.git"
DIRETORIO_BUILD="/tmp/ksuperkey"

# =====================================================
# Verificação de instalação existente
# =====================================================
verificar_se_esta_instalado() {
    if command -v ksuperkey &>/dev/null; then
        log_mensagem "ksuperkey já está instalado." "$AMARELO" "[ℹ]"
        echo
        read -r -p "Deseja reinstalar? [S/n]: " resposta
        echo

        case "${resposta,,}" in
            ""|"s"|"sim")
                log_mensagem "Reinstalação confirmada. Continuando..." "$AMARELO" "[➜]"
                ;;
            *)
                log_mensagem "Instalação cancelada pelo usuário." "$VERMELHO" "[✖]"
                exit 0
                ;;
        esac
    fi
}

# =====================================================
# Funções de instalação
# =====================================================
atualizar_sistema() {
    log_mensagem "Atualizando lista de pacotes..." "$AMARELO" "[➜]"
    sudo apt update &>/dev/null
}

instalar_dependencias() {
    log_mensagem "Instalando dependências..." "$AMARELO" "[➜]"
    sudo apt install -y \
        git \
        build-essential \
        libx11-dev \
        libxtst-dev \
        pkg-config &>/dev/null
}

clonar_repositorio() {
    if [ -d "$DIRETORIO_BUILD" ]; then
        log_mensagem "Repositório já existe, atualizando..." "$AMARELO" "[➜]"
        git -C "$DIRETORIO_BUILD" pull &>/dev/null
    else
        log_mensagem "Clonando repositório do ksuperkey..." "$AMARELO" "[➜]"
        git clone "$URL_REPOSITORIO" "$DIRETORIO_BUILD" &>/dev/null
    fi
}

compilar_ksuperkey() {
    log_mensagem "Compilando ksuperkey..." "$AMARELO" "[➜]"
    cd "$DIRETORIO_BUILD"
    make &>/dev/null
}

instalar_ksuperkey() {
    log_mensagem "Instalando ksuperkey no sistema..." "$AMARELO" "[➜]"
    sudo make install &>/dev/null
}

finalizar_instalacao() {
    log_mensagem "Instalação concluída com sucesso." "$VERDE" "[✔]"
    log_mensagem "Adicione ao i3wm:" "$VERDE" "[ℹ]"
    log_mensagem "exec --no-startup-id ksuperkey" "$VERDE" "   "
}

# =====================================================
# Execução
# =====================================================
mostrar_banner
verificar_se_esta_instalado
atualizar_sistema
instalar_dependencias
clonar_repositorio
compilar_ksuperkey
instalar_ksuperkey
finalizar_instalacao
