# 目标：清理本地开发环境
# 删除本地所有分支和stash缓存，保留${targetBranch}分支

#!/bin/bash
echo Welcome to the roubing999 tool...

function confirm {
  if [[ $yn == "y" ]]
  then 
    return 
  elif [[ $yn == "n" || $yn == "" ]]
  then 
    yn="n"
  elif [[ $yn == -1 ]]
  then
    exit
  else 
    echo -e "\033[31m error \033[0m"
    read -p "input error value: ${yn}, please re-enter (y | n): " yn
    confirm yn
  fi
}

function show_stashes {
  for path in $(ls $1)
  do
    if test -d $1/${path}
    then
      if test -e $1/$path/.git
      then
        echo -e "\033[34m current repo path $1/$path\033[0m"
        cd $1/$path
        git stash list
      else
        show_stashes $1/${path}
      fi
    fi
  done
}

function clear_stashes {
  for path in $(ls $1)
  do
    if test -d $1/${path}
    then
      if test -e $1/$path/.git
      then
        echo -e "\033[34m current repo path $1/$path\033[0m"
        cd $1/$path
        git stash clear
      else
        clear_stashes $1/${path}
      fi
    fi
  done
}

function show_branches {
  for path in $(ls $1)
  do
    if test -d $1/${path}
    then
      if test -e $1/$path/.git
      then
        echo -e "\033[34m current repo path $1/$path\033[0m"
        cd $1/$path
        git branch
      else
        show_branches $1/${path}
      fi
    fi
  done
}

function switch_and_update_branch {
  for path in $(ls $1)
  do
    if test -d $1/${path}
    then
      if test -e $1/$path/.git
      then
        echo -e "\033[34m current repo path $1/$path\033[0m"
        cd $1/$path
        git stash save $3

        hasTargetBranch="n"
        for branch in $(git branch)
        do
          if [[ $branch == $2 ]]
          then
            hasTargetBranch="y"
          fi
        done

        if [[ $hasTargetBranch == "y" ]]
        then
          git switch $2
        else
          # 在本地未找到目标分支，则尝试更新与远程的关联，切换到默认目标分支
          git remote update origin --prune
          git checkout -b develop origin/develop
        fi
        git branch | xargs git branch -D
        git pull
      else
        switch_and_update_branch $1/${path} $2 $3
      fi
    fi
  done
}

# 主流程
CURRENT_DIR=$(cd `dirname $0`; pwd)
read -p "Whether to show the cache in stash (y | n)? " yn
confirm yn
if [[ $yn == "y" ]]
then 
  show_stashes $CURRENT_DIR
  echo -e "\033[32m -----查看当前目录下所有仓库中的stash缓存数据完成-----\033[0m \033[34m"
fi

read -p "Whether to delete the cache in stash (y | n)? " yn
confirm yn
if [[ $yn == "y" ]]
then
  clear_stashes $CURRENT_DIR
  echo -e "\033[32m -----批量删除当前目录下所有仓库中的stash缓存数据完成-----\033[0m \033[34m"
fi

read -p "Whether to show all branches (y | n)? " yn
confirm yn
if [[ $yn == "y" ]]
then
  show_branches $CURRENT_DIR
  echo -e "\033[32m -----查看当前目录下的所有仓库分支完成-----\033[0m \033[34m"
fi

read -p "Whether to continue the batch delete (y | n)? " yn
confirm yn
if [[ $yn != "y" ]]
then
  exit
fi

read -p "Please enter the target branch (develop): " branch
if [[ $branch == "" ]]
then
  branch="develop"
fi
echo "target branch: "$branch
now = date +%Y/%m/%d-%H:%M:%S
echo "now: "$now
switch_and_update_branch $CURRENT_DIR $branch $now
echo -e "\033[32m -----批量删除当前本地分支完成-----\033[0m \033[34m"