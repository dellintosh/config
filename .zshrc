# set umask
umask 0002 # group writable

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set umask so brew stops complaining about stuff not owned by group
umask 002

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="mrtazz"

# Example aliases
alias zshconfig="vim ~/.zshrc"
alias zsource="source ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git osx brew python svn sublime)

autoload -U zmv
alias mmv='noglob zmv -W'

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=/usr/local/bin:/usr/bin:/bin:~/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/share/python:/usr/X11/bin:/src/devconfigs/bin:/Users/jluthy/pear/bin
export PATH="$(brew --prefix josegonzalez/php/php53)/bin:$PATH"
#iTerm / Maccy stuff
growl() { echo -e $'\e]9;'${1}'\007' ; return  ; }
export EDITOR='vim'

# stuff for lnetPortal testing/operation
export LNETPORTAL_URL=http://`hostname`/
export WORKON_HOME=$HOME/.virtualenvs
export DEBUG=1
export MAXIMIZE=1
export SANDBOX="/src/portal"
export PYTHONPATH="${SANDBOX}/tests/python"
export CMS_DROPBOX_LOCATION=/Volumes/envision/testing/cms
#export XDEBUG_CONFIG='idekey=bananasandwich'
source /usr/local/bin/virtualenvwrapper.sh
source ~/.bash_aliases

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
