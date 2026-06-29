# syirkah

A new Flutter project.

## Getting Started


### Development 
```
adb pair HOST[:PORT] [PAIRING CODE]
```

### Generate Icon
```
flutter pub run flutter_launcher_icons
```

### Build

```
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

```
keytool -importcert -file <google-play-console-certificate>.der -keystore <your-keystore-name>.jks
```


```
keytool -list -keystore <your-keystore-name>.jks 
```

### Build Appbundle
```
flutter build appbundle --target-platform android-arm,android-arm64,android-x64 --obfuscate --no-tree-shake-icons --release --split-debug-info=/<directory>
```

### Build APK
```
flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi --release --obfuscate --no-tree-shake-icons --split-debug-info=/<directory>
```



