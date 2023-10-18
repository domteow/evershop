@echo off
rem Github token
set TOKEN="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"

rem Github repo details
set REPO_OWNER="domteow"
set REPO_NAME="cme-project-template"
set BRANCH="main"


rem Set variables
set CURRENT_BUILD=current
for /f "usebackq tokens=1,* delims=_" %%a in ('wmic os get LocalDateTime ^| find "."') do set TIMESTAMP=%%a_%%b
set NEW_BUILD=build_%TIMESTAMP%

rem Download source from GitHub archive
echo Downloading source from GitHub...
curl -H "Authorization: token %TOKEN%" -o %NEW_BUILD%.tar.gz https://api.github.com/repos/%REPO_OWNER%/%REPO_NAME%/tarball

rem Unzip source to new build directory
echo Extracting source to %NEW_BUILD%...
mkdir %NEW_BUILD%
7z x %NEW_BUILD%.tar.gz -o%NEW_BUILD% -aos

rem Install npm dependencies
echo Installing npm dependencies...
cd %NEW_BUILD%
npm install --unsafe-perm

rem Build the app
echo Building the app...
npm run build
cd ..

rem Rename current build folder to previous build folder
if exist previous-build (
    rmdir /s /q previous-build
)

echo Rename the current build to previous-build
ren %CURRENT_BUILD% previous-build

rem Rename new build folder to current build folder
ren %NEW_BUILD% %CURRENT_BUILD%

rem Copy media and config folder from previous build to current build
if exist previous-build (
    xcopy /e /i previous-build\media %CURRENT_BUILD%\media
    xcopy /e /i previous-build\config %CURRENT_BUILD%\config
)

rem Set permissions for media folder
icacls %CURRENT_BUILD%\media /grant Everyone:(OI)(CI)F

cd %CURRENT_BUILD%

rem Stop app with pm2
pm2 stop all
pm2 start npm -- start
