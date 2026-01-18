# ==============================================================================
# 1. POWERLEVEL10K INSTANT PROMPT
# ==============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
# 2. GLOBAL VARIABLES & PATHS
# ==============================================================================
export DOTFILES="$HOME/dotfiles" # Sesuaikan dengan folder dotfiles kamu
export EDITOR="nvim"
export PATH="$HOME/.local/bin:$PATH"

# Zsh History Configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS  # Jangan simpan perintah duplikat
setopt HIST_REDUCE_BLANKS    # Hapus spasi berlebih

# ==============================================================================
# 3. ZINIT PLUGIN MANAGER (Fast & Minimalist)
# ==============================================================================
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} Installing Zinit...%f"
    command mkdir -p "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

autoload -Uz compinit && compinit
zinit cdreplay -q

# Load Theme & Essential Plugins
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load OMZ Snippets (Tanpa me-load seluruh Oh-My-Zsh)
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::command-not-found

# ==============================================================================
# 4. CUSTOM FUNCTIONS (Cleaned Up)
# ==============================================================================

# Bootstrapping JS Projects (Instruktur Workflow)
function cjsbe() {
    local TEMPLATES="$DOTFILES/templates"
    
    [[ ! -d ".git" ]] && git init
    [[ ! -f ".gitignore" ]] && cp "$TEMPLATES/node-gitignore" ./.gitignore

    if [[ ! -f "package.json" ]]; then
        npm init -y
        npm i express jsonwebtoken bcryptjs pg sequelize
        npm i -D sequelize-cli nodemon
    fi

    [[ ! -d "models" ]] && npx sequelize-cli init

    if [[ ! -f "app.js" ]]; then
        cp "$TEMPLATES/cjs-app.js" ./app.js
        mkdir -p routes controllers views
        cp "$TEMPLATES/cjs-router.js" ./routes/index.js
    fi
    echo "✅ Project CJS initialized successfully."
}

function nd() {
    if ! npm list --depth=0 | grep -q nodemon; then
        echo "Nodemon missing. Installing..."
        npm install -D nodemon
    fi
    npx nodemon "$1"
}

function sreset() {
    npx sequelize-cli db:drop && \
    npx sequelize-cli db:create && \
    npx sequelize-cli db:migrate && \
    npx sequelize-cli db:seed:all
}

function gl() {
    git log --pretty=format:"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr)%Creset %C(blue)[%an]" --abbrev-commit -30
}

function setup_nginx_proxy() {
    local DOMAIN=$1
    local PORT=$2
    
    if [[ -z "$DOMAIN" || -z "$PORT" ]]; then
        echo "Usage: setup_nginx_proxy <domain> <port>"
        return 1
    fi

    local CONF_PATH="/etc/nginx/sites-available/$DOMAIN"
    local ZONE_NAME="limit_$(echo $DOMAIN | tr '.' '_')"

    echo "🚀 Creating optimized Nginx config for $DOMAIN on port $PORT..."

    sudo tee $CONF_PATH > /dev/null <<EOF
# Rate Limiting Zone
limit_req_zone \$binary_remote_addr zone=$ZONE_NAME:10m rate=5r/s;

server {
    listen 80;
    server_name $DOMAIN;

    gzip on;
    gzip_types text/plain text/css application/json application/javascript;

    location / {
        limit_req zone=$ZONE_NAME burst=10 nodelay;
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    sudo ln -sf $CONF_PATH /etc/nginx/sites-enabled/
    
    if sudo nginx -t; then
        sudo systemctl restart nginx
        echo "✅ Domain $DOMAIN is now linked to port $PORT!"
    else
        echo "❌ Nginx config error. Please check the logs."
    fi
}

# ==============================================================================
# 5. ALIASES (Organized)
# ==============================================================================
# Replacement Aliases
alias ls='eza -a -l -h --icons'
alias bat='batcat'
alias cat='bat --paging=never'
alias grep='rg'
alias c="clear"
alias x="exit"

# Dev Shortcuts
alias nv="nvim"
alias v="nvim"
alias vzsh='nvim $DOTFILES/zsh/.zshrc'
alias r="source ~/.zshrc"
alias cdcode="cd ~/development"
alias docker="podman"
alias s="npx sequelize-cli"
alias sreset="sreset"
alias nd="nd "
alias setupNginx=setup_nginx_proxy

# Git Aliases
alias gc='git add . && git commit -m'
alias gp='git push'
alias gcl='git clone'

# ==============================================================================
# 6. EXTERNAL TOOLS INIT
# ==============================================================================
eval "$(zoxide init zsh)"
eval "$(vfox activate zsh)"

# NVM (Lazy Load Logic to keep startup fast)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# GVM
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# Powerlevel10k Config Source
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Secret Overrides (Jika kamu punya API keys pribadi)
[[ -f ~/.zshrc_local ]] && source ~/.zshrc_local
