Git example
===================================
## コミットログを変更
    git commit --amend
ブランチ操作
----------------------------------
    git branch temp01
    git checkout temp01
# 表示
git branch
git show-branch
### 確認
    git branche

プロジェクトのコミット前に、git --config でユーザーをかえる事.

taku start git project
----------------------------------------------
    mkdir taku
    cd taku
    mkdir vim-paste-marker
    cd vim-paste-marker
    git init

    touch README
    git add README
    git commit -m "README add"
    git status

server setup for collaboration
----------------------------------------------
    mkdir server
    cd server
    mkdir vim-paste-marker.git
    cd vim-paste-marker.git
    git --bare init

taku publish master branch to newly created repository
----------------------------------------------
    cd taku/vim-paste-marker
    git remote add origin server/vim-paste-marker.git
    git push origin master

yurie clone taku's repository to collaborate
----------------------------------------------
    git clone server/vim-paste-marker.git
    cd vim-paste-marker
    touch VERSION
    git add VERSION
    git commit -m "add VERSION"
    git push origin master

taku pull yurie's change by `git pull`
----------------------------------------------
    cd taku/vim-paste-marker
    git pull origin master

 Git Configuration
===================================
プロジェクトのコミット前に、git --config でユーザーをかえる事.
" vim: ft=markdown:
