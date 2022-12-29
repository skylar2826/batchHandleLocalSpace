@echo off
setlocal EnableDelayedExpansion
echo Welcome to the roubing999 tool...
echo.
set dp=%~dp0
 
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
    @REM 查看该目录下的所有仓库分支
    set p=%%i
    echo The branches under the repo path !p:%dp%=.\!
    git branch
  ) else (
    call :show_branches %%i
  )
)
goto :EOF
 
:confirm
if !yn!==y (
  echo yes
) else if !yn!==n (
  echo no
) else (
  echo error
  set /p yn="input error value: !yn!, please re-enter (y | n): "
  call :confirm !yn!
)
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
 
    echo --------------------------------------------------
  ) else (
    call :switch_and_update_branch %%i %2 %3
  )
)
goto :EOF