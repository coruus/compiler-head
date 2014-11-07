#!/usr/bin/env sh
source ../gcc.vars
mkdir gcc
cd gcc
git init
git remote add origin git://gcc.gnu.org/git/gcc.git
git config --add remote.origin.fetch 'refs/remotes/*:refs/remotes/svn/*'
git fetch
git checkout -b trunk svn/trunk

# Update
git pull --rebase
