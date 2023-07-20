# DOTFILES

## Basic Usage
### 1. Create directory code

```bash
mkdir ~/code
cd ~/code
```

### 2. Clone this repository
```bash
git clone git@github.com:tedante/dotfiles.git
git clone git@github.com:zsh-users/zsh-syntax-highlighting.git
```
### 3. Install some terminal tools
- Install [zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
- Instal [oh-my-zsh](https://ohmyz.sh/#install)
- Install [zsh-autosuggestion](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh)
- Install [meslo nerd font](https://github.com/romkatv/powerlevel10k)
- Instal [powerline110k](https://github.com/romkatv/powerlevel10k)
### 4. create symbolic links

```bash
ln -s ~/code/dotfiles/home/.zshrc ~/
```

## Snippets
### Nginx config
Example [here](./templates/sub.domain.com.bak)

This config placed on the server at `/etc/nginx/sites-available/`

## Server
Script for install nginx and docker

### Prerequisite
Install git in your machine

1. Clone this repository
2. change folder to `dotfiles`
```bash
cd dotfiles
```
3. run the script 
```bash
bash ./script/install-server.sh
```
4. waiting until process done

