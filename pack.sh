flutter build apk
adb install -r ./build/app/outputs/flutter-apk/app-release.apk
adb shell am start -W -n com.cube.beepay/.MainActivity