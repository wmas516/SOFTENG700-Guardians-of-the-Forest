# SOFTENG700-Guardians-of-the-Forest
UoA part 4 project 


## Execution Instructions
For Windows systems use:
```
build.exe
```

For Android devices use:
```
build.apk
```
If you want to run APK from non-Android device:

1. Install Android Studio
2. Open Android Studio and import the Godot project 

Note: You can also just create a new project but it's easier to start the apk with the file explorer in android studio

3. Navigate in the top bar to Tools > Device Manager
4. Select + > Create Virtual Device
5. Select a Device to Emulate (I chose Desktop > Large Desktop)
6. Download and system images required and Select Finish
7. Press the triangular play button to start the VD (Virtual Device)
8. Wait for the VD to boot 
9. Drag the APK into the window
10. Click the circular start button in the bottom left
11. Scroll down to find the game and double click to start

Note: You may need to enable hardware input in the top of the android studio emulator handler to interact with the game.

## Build Instructions
To build a verion of the game: 
1. Open the project in Godot v4.6.2
2. In the top menu navigate to Project > Export
3. Select which version from the Presets window
4. Select Export Project on the bottom

If you do not have an android sdk installation: 

5. Download Android studio 
6. Navigate to the SDK installtion. The default path should be in the form: 
```
C:\Users\<User>\AppData\Local\Android\Sdk
```
7. In Godot navigate to Editor > Editor Settings > Export > Android
8. Set Android SDK Path as the path found from step 6 
9. Leave Debug Keystore as is it should be set to Godot Keystore
10. Set Java SDK Path as a Java runtime

