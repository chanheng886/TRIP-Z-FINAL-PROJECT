@echo off
echo Building Flutter Web (Release) without icon tree shaking...
flutter build web --release --no-tree-shake-icons
echo Build finished! Run 'firebase deploy --only hosting' to deploy.
pause
