@echo off
set ANDROID_HOME=C:\Users\46815\AppData\Local\Android\Sdk
set ANDROID_SDK_ROOT=C:\Users\46815\AppData\Local\Android\Sdk
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot
set GRADLE_OPTS=-Xmx2g -Dfile.encoding=UTF-8
cd /d E:\VPN\v2rayNG\V2rayNG
call gradlew.bat assembleFdroidDebug > E:\VPN\outputs\build-apk.log 2>&1
echo RC=%ERRORLEVEL% >> E:\VPN\outputs\build-apk.log
