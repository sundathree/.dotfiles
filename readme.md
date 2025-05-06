# Komorebi + YASB
#### Mocha
![](https://github.com/sundathree/.dotfiles/blob/main/assets/2.png)
#### Monochrome
![](https://github.com/sundathree/.dotfiles/blob/main/assets/1.png)
#### Gruvbox
![](https://github.com/sundathree/.dotfiles/blob/main/assets/3.png)

## Fonts used:
All fonts are available on [nerdfonts.com](https://www.nerdfonts.com).
- JetBrainsMono Nerd Font
- FiraCode Nerd Font

## Programs:
You're going to need:
- [Komorebi](https://github.com/LGUG2Z/komorebi)
- [YASB](https://github.com/amnweb/yasb)
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch)
- [Starship](https://starship.rs)
- [CAVA](https://github.com/karlstav/cava)

You can download everything through your terminal using scoop:
```
scoop install komorebi yasb fastfetch starship
```

## Installation:

Download this repo or clone it using:
```
git clone https://github.com/sundathree/.dotfiles
```
Move .config folder to your home/userprofile folder and move the contents inside the powershell folder to your powershell folder, if you don't know where it is you can find it by typing ```$PROFILE``` your terminal.

### 🖼️ Komorebi:
You will need to set up a user variable in order for komorebi to work properly, open your start menu and search for View advanced system settings, once open, click on Environment Variables > User Variables > New, set the variable name to ```KOMOREBI_CONFIG_HOME``` and the value to ```$Env:USERPROFILE/.config/komorebi```. If everything has been done correctly, running ```komorebic check``` on your powershell terminal should display ```KOMOREBI_CONFIG_HOME detected: C:/Users/(username)/.config/komorebi```.

### 🍫 YASB:
This repo comes with the default YASB initial config. Inside the YASB folder there are folders for each theme, pick a flavor and move the contents from your selected theme's folder to .config/yasb. By default the location for the weather widget for my themes is set to Rio de Janeiro, you may want to change it to your current location, you can change it by looking for ```weather > options > location``` inside ```config.yaml```.
