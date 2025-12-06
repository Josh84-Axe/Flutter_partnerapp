# Fix Config Loading

## Goal Description
Ensure all configuration data (including Additional Devices) is loaded during app startup, and remove duplicate API calls.

## Proposed Changes

### State Management
#### [MODIFY] [app_state.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/providers/app_state.dart)
-   Update `loadDashboardData` method:
    -   Add `fetchAdditionalDevices()` to the `Future.wait` list.
    -   Remove the duplicate `fetchIdleTimeouts()` call.

## Verification Plan
1.  **Build**: Rebuild the application.
2.  **Manual Verification**:
    -   Login to the app.
    -   Navigate to "Additional Devices Configuration".
    -   Verify that the list loads correctly (or shows empty state without error).
    -   Verify other config screens still load correctly.
