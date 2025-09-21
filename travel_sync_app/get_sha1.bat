@echo off
echo Getting SHA1 fingerprint for debug keystore...
keytool -list -v -keystore android\app\debug.keystore -alias androiddebugkey -storepass android -keypass android | findstr SHA1
pause
