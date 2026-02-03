

<p align="center">
  <img src="https://img.shields.io/github/downloads/thespation/debian-i3wm/total?color=88C0D0&style=for-the-badge&logo=github" />
  <img src="https://img.shields.io/github/stars/thespation/debian-i3wm?color=5E81AC&style=for-the-badge&logo=github" />
  <img src="https://img.shields.io/github/forks/thespation/debian-i3wm?color=A3BE8C&style=for-the-badge&logo=github" />
  <img src="https://img.shields.io/github/issues/thespation/debian-i3wm?color=4C566A&style=for-the-badge&logo=github" />
</p>

<p align="center">
  <img src="https://img.shields.io/github/license/thespation/debian-i3wm?color=D8DEE9&style=for-the-badge&logo=gnu" />
  <img src="https://img.shields.io/github/last-commit/thespation/debian-i3wm?color=88C0D0&style=for-the-badge&logo=git" />
  <img src="https://img.shields.io/github/repo-size/thespation/debian-i3wm?color=5E81AC&style=for-the-badge&logo=files" />
</p>

# Debian i3wm
Personalização para Debian utilizando **i3wm**, com integração de **polybar**, **rofi**, **dunst** e scripts automatizados para melhorar a experiência de uso.




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

<img width="1920" height="1080" alt="Screenshot_2026-01-09-12-02-57" src="https://github.com/user-attachments/assets/0219a0af-9254-4921-9481-d8916a53d647" />


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
└── backup-AAAA-MM-DD_HH-MM-SS.zip     # Arquivo de backup gerado automaticamente (arquivos que serão utilizados pelo 05-files.sh)
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
git clone https://github.com/thespation/debian-i3wm
cd debian-i3wm/scripts
chmod +x *.sh
./00-instalar.sh
```
## ⌨️ Atalhos de Teclado

<details>
  <summary><b> Clique aqui para ver os atalhos de teclado </b></summary>

### 🖥️ Terminal
| Atalho | Ação |
|--------|------|
| `$mod+Return` | Abrir Alacritty |
| `$mod+Shift+Return` | Abrir terminal flutuante via script |

---

### 📂 Aplicativos
| Atalho | Ação |
|--------|------|
| `$mod+e` | Abrir Thunar (gerenciador de arquivos) |
| `$mod+Shift+e` | Abrir Geany (editor de texto) |
| `$alt+Ctrl+h` | Abrir htop no Alacritty |

---

### ⚙️ Configuração
| Atalho | Ação |
|--------|------|
| `$alt+Ctrl+n` | Trocar configuração da polybar (exibe ícones ou números) |

---

### 🚀 Rofi
| Atalho | Ação |
|--------|------|
| `$alt+F1` / `$mod+d` | Launcher |
| `$mod+x` | Powermenu |
| `$mod+s` | Screenshot |
| `$mod+r` | Abrir como root |
| `$mod+w` | Gerenciar janelas |
| `$mod+b` | Bluetooth |
| `$mod+Alt+n` | Trocar tema |
| `$mod+t` | Seletor de temas |

---

### 🪟 Funções do i3
| Atalho | Ação |
|--------|------|
| `$mod+q` | Fechar janela |
| `$mod+c` | Fechar janela |
| `$mod+Shift+c` | Recarregar configuração |
| `$mod+space` | Alternar entre tiling/flutuante |
| `$mod+f` | Alternar fullscreen |
| `$alt+Ctrl+l` | Bloquear tela (i3lock) |

---

### 🔊 Áudio
| Atalho | Ação |
|--------|------|
| `XF86AudioRaiseVolume` | Aumentar volume (+5) |
| `XF86AudioLowerVolume` | Diminuir volume (-5) |
| `XF86AudioMute` | Mutar áudio |

---

### 🎯 Navegação e Movimento
| Atalho | Ação |
|--------|------|
| `$mod+Left` | Foco para esquerda |
| `$mod+Down` | Foco para baixo |
| `$mod+Up` | Foco para cima |
| `$mod+Right` | Foco para direita |
| `$mod+Shift+Left` | Mover janela para esquerda |
| `$mod+Shift+Down` | Mover janela para baixo |
| `$mod+Shift+Up` | Mover janela para cima |
| `$mod+Shift+Right` | Mover janela para direita |

---

### 🛠️ Modos Especiais

#### 🔧 Resize Mode
| Atalho | Ação |
|--------|------|
| `$mod+Shift+r` | Entrar no modo Resize |
| `h / Left` | Diminuir largura |
| `l / Right` | Aumentar largura |
| `j / Down` | Aumentar altura |
| `k / Up` | Diminuir altura |
| `Return / Escape / $mod+Shift+r` | Sair do modo Resize |

---

#### 📦 Move Mode
| Atalho | Ação |
|--------|------|
| `$mod+Shift+m` | Entrar no modo Move |
| `h / Left` | Mover janela para esquerda |
| `l / Right` | Mover janela para direita |
| `j / Down` | Mover janela para baixo |
| `k / Up` | Mover janela para cima |
| `Return / Escape / $mod+Shift+m` | Sair do modo Move |

---

#### 🎨 Gaps Mode
| Atalho | Ação |
|--------|------|
| `$mod+Shift+g` | Entrar no modo Gaps |
| `+ / = / KP_Add` | Aumentar gaps internos |
| `- / KP_Subtract` | Diminuir gaps internos |
| `Shift+plus / Shift+equal` | Aumentar gaps externos |
| `Shift+minus` | Diminuir gaps externos |
| `r` | Resetar gaps (internos e externos) |
| `t` | Alternar gaps |
| `i` | Definir gaps internos = 10 |
| `o` | Definir gaps externos = 10 |
| `Return / Escape / $mod+Shift+g` | Sair do modo Gaps |

</details>


## 📚 Referências

Este projeto foi inspirado e utiliza recursos de outros trabalhos incríveis:

- [gh0stzk/dotfiles](https://github.com/gh0stzk/dotfiles) → inspiração geral e uso dos arquivos `zsh`
- [Aditya Shakya (adi1090x)](https://github.com/adi1090x) → scripts utilizados para temas, ícones, rofi, dunst e automações.
