alias ll="ls -l"
alias l='ls -l'
alias la='ls -la'
alias g="gvim"
alias findcode="svn status | grep -v \"^D\" | awk '{ print \$2 }'"
#alias findcode="svn status | grep -v \"^D\" | egrep \"(.css)|(.html)|(.js)|(.py)\" | awk '{ print \$2 }'"
alias hack="findcode | xargs -r gvim"
alias squig="ssh -X root@squigherder"
alias ispy="ps ax | grep python"
alias psuite='ps ax | grep "python\|nginx\|slapd"'
alias crontab="VIM_CRONTAB=true crontab"
#alias mocha="export CURRENTDIR=`pwd` && cd $SANDBOX/tests/mocha && mocha --ui tdd --reporter spec && cd $CURRENTDIR"
alias bpython='nocorrect bpython'

#git / svn
alias sst="svn status"
alias pull="git pull"
alias push="git push"
alias gbr='git branch'
alias gst='git status'
alias gdi='git diff'
alias gco='git checkout'
alias gitd='sudo git daemon --export-all --base-path=/Users/jboatrig/src/ --reuseaddr --detach'
alias config='git --git-dir=$HOME/.config.git/ --work-tree=$HOME'

#Linux
alias pdbot='python /usr/lib/python2.5/site-packages/robotframework-2.1.1-py2.5.egg/robot/runner.py --noncritical noncritical --exclude notimplemented -L DEBUG'
alias macterm='export TERM=xterm-color'

#LodgeNet
alias linstall="/Users/jboatrig/src/portal/scripts/drupal_install.sh -u lnet -p 1pass234 -fmr -ld -no-swf -d lnetPortal"
alias zsource="source ~/.zshrc"
alias cdt="cd /Users/jboatrig/src/portal"
alias cdl="cd /Users/jboatrig/src/portal/tests/lettuce"
alias jenkins="ssh -A ptd-its.ct.lodgenet.com"
alias murdock="ssh -A etd-atd1.ct.lodgenet.com"
alias hannibal="ssh -A hannibal.ct.lodgenet.com"
alias drush="~/bin/drushfolder/drush.php --uri=http://lnetportal.local"
alias ptest="nocorrect ptest"
alias envision="ssh -A envision.lodgenet.com"
alias aegir="ssh -A aegir.ct.lodgenet.com"

