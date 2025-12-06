# Flutter SDK Setup Guide for Windows

This guide will help you set up the Flutter SDK environment on your Windows machine so you can run the Partner App.

## Prerequisites

- **Operating System**: Windows 10 or later (64-bit).
- **Disk Space**: 1.64 GB (does not include disk space for IDE/tools).
- **Tools**: Windows PowerShell 5.0 or newer (pre-installed on Windows 10).

## Step 1: Download Flutter SDK

1.  Go to the official Flutter download page: [https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
2.  Download the stable release zip file (e.g., `flutter_windows_3.x.x-stable.zip`).
3.  Extract the zip file to a location where you want to install Flutter.
    *   **Warning**: Do not install Flutter in a directory like `C:\Program Files\` that requires elevated privileges.
    *   **Recommended**: `C:\src\flutter`

## Step 2: Update Path Variable

1.  From the Start search bar, enter "env" and select **Edit the system environment variables**.
2.  Click the **Environment Variables...** button.
3.  Under **User variables**, check if there is an entry called `Path`:
    *   If the entry exists, append the full path to `flutter\bin` using `;` as a separator.
    *   If the entry does not exist, create a new user variable named `Path` with the full path to `flutter\bin` as its value.
    *   Example: `C:\src\flutter\bin`
4.  Click **OK** to save changes.

## Step 3: Run Flutter Doctor

1.  Open a new PowerShell window.
2.  Run the following command to check for any dependencies you need to install:
    ```powershell
    flutter doctor
    ```
3.  This command checks your environment and displays a report of the status of your Flutter installation. Check the output carefully for other software you might need to install or further tasks to perform.

## Step 4: Android Setup

1.  **Install Android Studio**:
    *   Download and install Android Studio from [https://developer.android.com/studio](https://developer.android.com/studio).
    *   Start Android Studio, and go through the "Android Studio Setup Wizard". This installs the latest Android SDK, Android SDK Command-line Tools, and Android SDK Build-Tools.

2.  **Set up your Android device**:
    *   Enable **Developer options** and **USB debugging** on your device.
    *   Connect your phone to your computer via USB.
    *   Authorize your computer on your device.

3.  **Agree to Android Licenses**:
    *   Run the following command in PowerShell:
        ```powershell
        flutter doctor --android-licenses
        ```
    *   Review and accept the licenses by typing `y` for each one.

## Step 5: Run the App

Once `flutter doctor` shows no issues (checkmarks for Flutter, Android toolchain, and Connected device), you can run the app:

1.  Open your terminal in the project directory:
    ```powershell
    cd c:\Users\ELITEX21012G2\antigravity_partnerapp\Flutter_partnerapp
    ```
2.  Get dependencies:
    ```powershell
    flutter pub get
    ```
3.  Run the app:
    ```powershell
    flutter run
    ```

> [!TIP]
> If you encounter any issues, `flutter doctor -v` provides verbose output that can help diagnose the problem.
