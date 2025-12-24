@echo off
echo Cleaning comandera_app android...
cd comandera_app\android
if exist .classpath del /s /q .classpath
if exist .project del /s /q .project
if exist .settings rmdir /s /q .settings
if exist .gradle rmdir /s /q .gradle
if exist app\.classpath del /s /q app\.classpath
if exist app\.project del /s /q app\.project
if exist app\.settings rmdir /s /q app\.settings

echo Cleaning repartidor_app android...
cd ..\..\repartidor_app\android
if exist .classpath del /s /q .classpath
if exist .project del /s /q .project
if exist .settings rmdir /s /q .settings
if exist .gradle rmdir /s /q .gradle
if exist app\.classpath del /s /q app\.classpath
if exist app\.project del /s /q app\.project
if exist app\.settings rmdir /s /q app\.settings

echo Done. Please restart your IDE/Editor.
pause
