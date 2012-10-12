Github Configuration Management
===============================

The following describes a simple way to manage your profile
configuration files using GitHub.

Features
--------
 * Centralized configuration management
 * Files live in their native locations (no symbolic linking)
 * Home directory is not a Git repository
 * All the power of git with a simple alias

Initialization
--------------

1. Login to Github and create a repository named config

2. [Add public keys][pubkeys] to Github (if you haven't already done so)

3. Create Configuration directory
```
cd ~
mkdir .config.git
```

4. Add the following alias to your current session and your `.bash_profile`
```
alias config='git --git-dir=$HOME/.config.git/ --work-tree=$HOME'
echo "alias config='git --git-dir=$HOME/.config.git/ --work-tree=$HOME'" >> .bash_profile
```

5. Add `.bash_profile` to the configuration repository and commit
```
config add .bash_profile
config commit -m 'Initial Commit'
```

6. Change origin to Github (change GITHUB_USERNAME to your username) and push changes
```
config remote add origin git@github.com:GITHUB_USERNAME/config.git
config push origin master
```

Install on Other Computers
--------------------------

1. [Add public keys][pubkeys] to Gihub

2. Switch to home directory
```
cd ~
```

3. Backup any local configuration files (e.g.)
```
mv .bash_profile .bash_profile.bak
```

4. Clone configuration respository (change GITHUB_USERNAME to your username)
```
git clone git@github.com:GITHUB_USERNAME/config.git config.git
```

5. Move git metadata and config files
```
mv config.git/.git .config.git
mv -i config.git/* .
```

6. Delete the config.git directory
```
rmdir config.git
```

7. Restart terminal session

Basic Usage
-----------

  * `config pull` : get latest configuration changes
  * `config add FILENAME` : add configuration file
  * `config commit -a` : save all configuration changes
  * `config push` : push changes to Github
  * `config GIT_OPTIONS` : operates just like `git GIT_OPTIONS` on configuration repository

Thanks
------
Source [Silas Sewell](http://www.silassewell.com/blog/2009/03/08/profile-management-with-git-and-github/)

[pubkeys]: http://github.com/guides/providing-your-ssh-key
