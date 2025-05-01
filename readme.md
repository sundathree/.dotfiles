# Komorebi + YASB

## Programs:
You're going to need:
- [Komorebi](https://github.com/LGUG2Z/komorebi)
- [YASB](https://github.com/amnweb/yasb)
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch)
- [Starship](https://starship.rs)

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
By default, the location for the weather widget is set to Rio de Janeiro, you may want to change it to your current location. You can change it by looking for ```weather > options > location``` inside ```config.yaml```.