# Debian i3wm

Personalização para Debian utilizando **i3wm**, com integração de **polybar**, **rofi**, **dunst** e scripts automatizados para melhorar a experiência de uso.

## 📖 Sobre o Projeto

Este repositório reúne configurações e scripts criados para instalar o **i3wm** no Debian mínimo.  
A proposta é oferecer um ambiente minimalista, funcional e bonito, com automações que facilitem o dia a dia.

<details>
  <summary><b> Clique para ver o que foi selecionado na instalação mínima</b></summary>
  <br>
  <div align="center" style="margin-top:10px; margin-bottom:10px;">
    <img src="https://github.com/user-attachments/assets/4de36882-52ff-433f-a5dc-7c52a39fff62" alt="DebianMinimal" style="max-width: 100%; border: 1px solid #ccc; border-radius: 8px;" />
    <p><i>Exemplo ilustrando como foi feita a instalação mínima antes da configuração do i3wm.</i></p>
  </div>
</details>

## 🎨 Telas
Seletor de temas:

<img width="1920" height="1080" alt="Screenshot_2025-12-28-21-27-56" src="https://github.com/user-attachments/assets/1f5ae30c-2825-4156-8ebc-95f02349de76" />

### Cores
![themes](https://github.com/user-attachments/assets/bd1b4f52-96e6-4d74-b9fe-99db64035476)

### Temas disponíveis

![themes](https://github.com/user-attachments/assets/eb4619c7-1cba-42f1-930c-9a2cb63b4cd3)


## 📂 Estrutura do Repositório

```text
debian-i3wm/
├── scripts/                           # Scripts auxiliares para automação
│   ├── 00-instalar.sh                 # Menu interativo
│   ├── 01-instalar_pacotes.sh         # Instalação de todos os pacotes necessários
│   ├── 01-pacotes.txt                 # Lista de pacotes a instalar
│   ├── 02-themes.sh                   # Baixa todos os themes do repositório do Archcraft
│   ├── 03-icons.sh                    # Baixa todos os ícones do repositório do Archcraft
│   ├── 04-zsh.sh                      # Instala e deixa o shell ZSH como padrão
│   ├── 05-files.sh                    # Copia as personalizações para cada pasta (caso já tenha pasta cria backup antes)
│   ├── 06-ksuperkey.sh                # Ativação da tecla Super com ksuperkey
│   ├── 07-brave.sh                    # Instalação e configuração do navegador Brave
│   └── extras/                        # Scripts extras e utilitários (precisam ser executados manualmente)
│       ├── 00-GerarVersionamento.sh   # Geração de versionamento automático
│       └── ativar-tap(leptop).sh      # Ativação do touchpad em laptops
└── backup-2025-12-21_22-20-25.zip     # Arquivo de backup gerado automaticamente (arquivos que serão utilizados pelo 05-files.sh)
```

## 🚀 Recursos

- **Polybar customizada** com módulos extras (bateria, cpu, memória, volume, etc.)
- **Rofi** configurado com launcher, seletor de tema, powermenu, captura de tela, abrir como root, entre outros
- **Dunst** para notificações estilizadas
- **Scripts automatizados** para:
  - Backup rápido
  - Instalação de dependências
  - Inicialização de serviços
  - Ajustes visuais e funcionais do i3wm

## 🔧 Instalação

Clone o repositório e execute o script de instalação:

```bash
git clone https://github.com/thespation/debian-i3wm.git
cd debian-i3wm/scripts
chmod +x *.sh
./install.sh
```

## 📚 Referências

Este projeto foi inspirado e utiliza recursos de outros trabalhos incríveis:

- [gh0stzk/dotfiles](https://github.com/gh0stzk/dotfiles) → inspiração geral e uso dos arquivos `zsh`
- [Aditya Shakya (adi1090x)](https://github.com/adi1090x) → scripts utilizados para temas, ícones, rofi, dunst e automações.

