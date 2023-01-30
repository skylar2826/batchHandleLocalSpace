@REM 目标：清理本地开发环境
@REM 删除本地所有分支和stash缓存，保留${targetBranch}分支

@echo off
setlocal EnableDelayedExpansion
echo Welcome to the roubing999 tool...
echo.
set dp=%~dp0

setlocal
set yn=y
set /p yn="Whether to show the cache in stash (y | n)? "
call :confirm !yn!
echo.
if !yn!==y (
  call :show_stashes %CD%
)
endlocal

setlocal
set yn=n
set /p yn="Whether to delete the cache in stash (y | n)? "
call :confirm !yn!
echo.
if !yn!==y (
  call :clear_stashes %CD%
)
endlocal

setlocal
set yn=y
set /p yn="Whether to show all branches (y | n)? "
call :confirm !yn!
echo.
if !yn!==y (
  call :show_branches %CD%
  echo.
)
endlocal

setlocal
set yn=n
set /p yn="Whether to continue the batch delete (y | n)? "
call :confirm !yn!
if !yn!==n (
  echo exit.
  exit
)
echo.
endlocal

setlocal
set branch=develop
set /p branch="Please enter the target branch (develop): "
echo target branch: %branch%
set now=%date% %time%
set now=!now: =-!
echo now: %now%
call :switch_and_update_branch %CD% %branch% %now%
endlocal
echo.
echo Finished.
exit

:show_branches
for /d %%i in (%1\*) do (
  cd %%i
  if exist .git (
    set p=%%i
    echo The branches under the repo path !p:%dp%=.\!
    git branch
  ) else (
    call :show_branches %%i
  )
)
echo ----------------------------查看当前目录下的所有仓库分支完成----------------------------
goto :EOF

:switch_and_update_branch
for /d %%i in (%1\*) do (
  cd %%i
  if exist .git (
    set p=%%i
    echo.
    echo current path: !p:%dp%=.\!
    git stash save %3
    set hasTargetBranch=n
    for /f "delims=" %%j in ('git branch') do (
      echo %%j | findStr %2 > nul && set hasTargetBranch=y
    )
    if !hasTargetBranch!==y (
      git switch %2
    ) else (
      git remote update origin --prune
      git checkout -b develop origin/develop
    )
    git branch | xargs git branch -D
    git pull
  ) else (
    call :switch_and_update_branch %%i %2 %3
  )
)
echo ----------------------------批量删除本地分支完成----------------------------
goto :EOF

:show_stashes
for /d %%i in (%1\*) do (
  cd %%i
  if exist .git (
    set p=%%i
    echo current repo path !p:%dp%=.\!
    git stash list
  ) else (
    call :show_branches %%i
  )
)
echo ----------------------------查看当前目录下所有仓库中的stash缓存数据完成----------------------------
goto :EOF

:clear_stashes
for /d %%i in (%1\*) do (
  cd %%i
  if exist .git (
    set p=%%i
    echo current repo path !p:%dp%=.\!
    git stash clear
  ) else (
    call :show_branches %%i
  )
)
echo ----------------------------批量删除当前目录下所有仓库中的stash缓存数据完成----------------------------
goto :EOF


:confirm
if !yn!==y (
  echo yes
) else if !yn!==n (
  echo no
) else if !yn!==-1 (
  echo exit.
  exit
) else (
  echo error
  set /p yn="input error value: !yn!, please re-enter (y | n): "
  call :confirm !yn!
)
goto :EOF