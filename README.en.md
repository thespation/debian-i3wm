<p align="center">
  <a href="https://github.com/thespation/debian-i3wm/blob/main/README.md">🇧🇷 Switch to Portuguese</a>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/0219a0af-9254-4921-9481-d8916a53d647" alt="Debian i3wm Desktop" />
  <br>
  <sub>Theme Selector</sub>
</p>


<p align="center">
  <img src="https://github.com/user-attachments/assets/0219a0af-9254-4921-9481-d8916a53d647" alt="Debian i3wm Desktop" />
  <br>
  <sub>Theme Selector</sub>
</p>

---

<p align="center">
  <img src="https://img.shields.io/github/stars/thespation/debian-i3wm?color=5E81AC&style=for-the-badge&logo=github" />
  <img src="https://img.shields.io/github/forks/thespation/debian-i3wm?color=A3BE8C&style=for-the-badge&logo=github" />
  <img src="https://img.shields.io/github/issues/thespation/debian-i3wm?color=4C566A&style=for-the-badge&logo=github" />
</p>

<p align="center">
  <img src="https://img.shields.io/github/license/thespation/debian-i3wm?color=D8DEE9&style=for-the-badge&logo=gnu" />
  <img src="https://img.shields.io/github/last-commit/thespation/debian-i3wm?color=88C0D0&style=for-the-badge&logo=git" />
  <img src="https://img.shields.io/badge/size-25MB-5E81AC?style=for-the-badge&logo=files" />
</p>

# Debian i3wm
Customization for Debian using **i3wm**, with integration of **polybar**, **rofi**, **dunst**, and automated scripts to enhance usability.

## 📖 About the Project

This repository gathers configurations and scripts created to install **i3wm** on minimal Debian.  
The goal is to provide a minimalist, functional, and beautiful environment, with automations that simplify daily use.

<details>
  <summary><b> Click to see what was selected in the minimal installation </b></summary>
  <br>
  <div align="center" style="margin-top:10px; margin-bottom:10px;">
    <img src="https://github.com/user-attachments/assets/4de36882-52ff-433f-a5dc-7c52a39fff62" alt="DebianMinimal" style="max-width: 100%; border: 1px solid #ccc; border-radius: 8px;" />
    <p><i>Example showing how the minimal installation was done before configuring i3wm.</i></p>
  </div>
</details>

## 🎨 Screens

### Colors

<p align="center">
  <img src="https://github.com/user-attachments/assets/bd1b4f52-96e6-4d74-b9fe-99db64035476" alt="Themes" />
  <br>
  <sub>Available colors</sub>
</p>

### Available Themes

![themes](https://github.com/user-attachments/assets/eb4619c7-1cba-42f1-930c-9a2cb63b4cd3)

## 📂 Repository Structure

```text
debian-i3wm/
├── scripts/                           # Helper scripts for automation
│   ├── 00-instalar.sh                 # Interactive menu
│   ├── 01-instalar_pacotes.sh         # Install all required packages
│   ├── 01-pacotes.txt                 # List of packages to install
│   ├── 02-themes.sh                   # Download all themes from Archcraft repo
│   ├── 03-icons.sh                    # Download all icons from Archcraft repo
│   ├── 04-zsh.sh                      # Install and set ZSH as default shell
│   ├── 05-files.sh                    # Copy customizations to folders (creates backup if folder exists)
│   ├── 06-ksuperkey.sh                # Enable Super key with ksuperkey
│   ├── 07-brave.sh                    # Install and configure Brave browser
│   └── extras/                        # Extra scripts/utilities (must be run manually)
│       ├── 00-GerarVersionamento.sh   # Automatic versioning generation
│       └── ativar-tap(leptop).sh      # Enable touchpad on laptops
└── backup-AAAA-MM-DD_HH-MM-SS.zip     # Auto-generated backup file (used by 05-files.sh)
```

## 🚀 Features

- **Custom Polybar** with extra modules (battery, CPU, memory, volume, etc.)
- **Rofi** configured with launcher, theme selector, powermenu, screenshot, run as root, and more
- **Dunst** for styled notifications
- **Automated scripts** for:
  - Quick backup
  - Dependency installation
  - Service initialization
  - Visual and functional tweaks for i3wm

## 🔧 Installation

Clone the repository and run the installation script:

```bash
git clone https://github.com/thespation/debian-i3wm
cd debian-i3wm/scripts
chmod +x *.sh
./00-instalar.sh
```

## ⌨️ Keyboard Shortcuts

<details>
  <summary><b> Click here to see keyboard shortcuts </b></summary>

### 🖥️ Terminal
| Shortcut | Action |
|----------|--------|
| `$mod+Return` | Open Alacritty |
| `$mod+Shift+Return` | Open floating terminal via script |

---

### 📂 Applications
| Shortcut | Action |
|----------|--------|
| `$mod+e` | Open Thunar (file manager) |
| `$mod+Shift+e` | Open Geany (text editor) |
| `$alt+Ctrl+h` | Open htop in Alacritty |

---

### ⚙️ Configuration
| Shortcut | Action |
|----------|--------|
| `$alt+Ctrl+n` | Switch polybar config (icons or numbers) |

---

### 🚀 Rofi
| Shortcut | Action |
|----------|--------|
| `$alt+F1` / `$mod+d` | Launcher |
| `$mod+x` | Powermenu |
| `$mod+s` | Screenshot |
| `$mod+r` | Run as root |
| `$mod+w` | Window manager |
| `$mod+b` | Bluetooth |
| `$mod+Alt+n` | Change theme |
| `$mod+t` | Theme selector |

---

### 🪟 i3 Functions
| Shortcut | Action |
|----------|--------|
| `$mod+q` | Close window |
| `$mod+c` | Close window |
| `$mod+Shift+c` | Reload configuration |
| `$mod+space` | Toggle tiling/floating |
| `$mod+f` | Toggle fullscreen |
| `$alt+Ctrl+l` | Lock screen (i3lock) |

---

### 🔊 Audio
| Shortcut | Action |
|----------|--------|
| `XF86AudioRaiseVolume` | Increase volume (+5) |
| `XF86AudioLowerVolume` | Decrease volume (-5) |
| `XF86AudioMute` | Mute audio |

---

### 🎯 Navigation and Movement
| Shortcut | Action |
|----------|--------|
| `$mod+Left` | Focus left |
| `$mod+Down` | Focus down |
| `$mod+Up` | Focus up |
| `$mod+Right` | Focus right |
| `$mod+Shift+Left` | Move window left |
| `$mod+Shift+Down` | Move window down |
| `$mod+Shift+Up` | Move window up |
| `$mod+Shift+Right` | Move window right |

---

### 🛠️ Special Modes

#### 🔧 Resize Mode
| Shortcut | Action |
|----------|--------|
| `$mod+Shift+r` | Enter Resize mode |
| `h / Left` | Decrease width |
| `l / Right` | Increase width |
| `j / Down` | Increase height |
| `k / Up` | Decrease height |
| `Return / Escape / $mod+Shift+r` | Exit Resize mode |

---

#### 📦 Move Mode
| Shortcut | Action |
|----------|--------|
| `$mod+Shift+m` | Enter Move mode |
| `h / Left` | Move window left |
| `l / Right` | Move window right |
| `j / Down` | Move window down |
| `k / Up` | Move window up |
| `Return / Escape / $mod+Shift+m` | Exit Move mode |

---

#### 🎨 Gaps Mode
| Shortcut | Action |
|----------|--------|
| `$mod+Shift+g` | Enter Gaps mode |
| `+ / = / KP_Add` | Increase inner gaps |
| `- / KP_Subtract` | Decrease inner gaps |
| `Shift+plus / Shift+equal` | Increase outer gaps |
| `Shift+minus` | Decrease outer gaps |
| `r` | Reset gaps (inner and outer) |
| `t` | Toggle gaps |
| `i` | Set inner gaps = 10 |
| `o` | Set outer gaps = 10 |
| `Return / Escape / $mod+Shift+g` | Exit Gaps mode |

</details>

## 📚 References

This project was inspired by and uses resources from other
