# How to Create a GitHub Release for OTA Updates

To make the automatic update feature work, you need to create a Release on GitHub and upload the APK file.

## Prerequisites
1.  **Build the Release APK**:
    Run the following command in your terminal to build the APK:
    ```bash
    flutter build apk --release
    ```
    The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

2.  **Verify Version**:
    Ensure the version in your `pubspec.yaml` (e.g., `1.0.1+2`) matches the version you plan to release.

## Steps to Create Release

1.  **Go to GitHub Releases**:
    Navigate to: [https://github.com/Josh84-Axe/Flutter_partnerapp/releases](https://github.com/Josh84-Axe/Flutter_partnerapp/releases)

2.  **Draft a New Release**:
    Click on **"Draft a new release"**.

3.  **Choose a Tag**:
    -   Click "Choose a tag".
    -   Type a version tag (e.g., `v1.0.1`) and select "Create new tag: v1.0.1" on publish.

4.  **Release Title**:
    Enter a title (e.g., "v1.0.1 - Automatic Updates & Performance Improvements").

5.  **Description**:
    Add release notes describing the changes.

6.  **Upload Assets (CRITICAL)**:
    -   Drag and drop the `app-release.apk` file (from `build/app/outputs/flutter-apk/`) into the "Attach binaries by dropping them here" box.
    -   **IMPORTANT**: The file MUST be named `app-release.apk` (or match the filename in `version.json`).

7.  **Publish Release**:
    Click **"Publish release"**.

## Updating `version.json`
Once the release is published, you must update `version.json` in the *repository* (edit it on GitHub directly or push a change) to point to the new version:

```json
{
    "latestVersion": "1.0.1",
    "downloadUrl": "https://github.com/Josh84-Axe/Flutter_partnerapp/releases/download/v1.0.1/app-release.apk",
    "forceUpdate": false,
    "releaseNotes": "• Automatic update system implemented.\n• Bug fixes and performance enhancements."
}
```

This tells the app that a new version `1.0.1` is available at that URL. The app (currently `1.0.0`) will see `1.0.1 > 1.0.0` and prompt the user to update.
