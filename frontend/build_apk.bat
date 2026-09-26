@echo off
echo Building Flutter APK (Release) without icon tree shaking...
flutter build apk --release --no-tree-shake-icons
echo APK build finished!
pause
