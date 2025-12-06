§# Project Knowledge: Flutter Partner App

## Overview
The Flutter Partner App is a comprehensive management tool for internet service partners. It allows partners to manage hotspot users, internet plans, routers, workers, and view financial data (transactions, revenue, wallet).

## Architecture
- **State Management**: `Provider` pattern using a central `AppState` (monolithic state provider) that orchestrates repositories and exposes data to UI.
- **Repository Pattern**: Data access layer separated into repositories (e.g., `AuthRepository`, `TransactionRepository`, `PlanRepository`) handling API calls via `Dio`.
- **API Client**: `tiknet_api_client` (local package) and direct `Dio` configuration in `AppState`/`ApiClientFactory`.
- **Navigation**: Named routes defined in `main.dart`.
- **Localization**: `easy_localization` for English (`en.json`) and French (`fr.json`).

## Key Features

### 1. Authentication
- **Login**: Email/Password flow. Retrieves token and user profile.
- **Registration**: Multi-step flow including enterprise details. OTP verification via email.
- **Password Reset**: OTP-based flow (Request OTP -> Verify OTP -> Reset Password).

### 2. Dashboard
- **Overview**: Displays Total Revenue, Active Users, and Subscription Plan status.
- **Quick Actions**: Navigation to key features (Plans, Sessions, Reporting, Settings).
- **Revenue Breakdown**: Detailed view of Assigned vs. Online revenue.

### 3. Internet Plans
- **Management**: Create, Edit, Delete internet plans.
- **Configuration**: Settings for Rate Limits, Idle Timeouts, Data Limits, Validity Periods.

### 4. Financials (Wallet & Transactions)
- **Wallet Overview**: Current balance, total revenue.
- **Transaction History**: Tabbed view (All, Assigned, Wallet). Search and Date filtering.
- **Transaction Details**: Detailed view of specific transactions.
- **Withdrawals**: Request payouts to mobile money or bank accounts. Two-step OTP verification for adding payment methods.

### 5. Reporting
- **Client-Side Generation**: Generates PDF and CSV reports for Transaction History locally.
- **Dependencies**: `pdf`, `printing`, `csv`.

### 6. User & Worker Management
- **Hotspot Users**: View and manage end-users.
- **Collaborators (Workers)**: Manage staff accounts, assign roles (RBAC).
- **Permissions**: Role-based access control for app features.

## Environment Setup (Ubuntu Linux)

To set up the development environment on a fresh Ubuntu installation, follow these steps:

### 1. System Dependencies
Update packages and install essential build tools:
```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

### 2. Flutter SDK
1.  Download Flutter SDK (stable channel) or use `snap`:
    ```bash
    sudo snap install flutter --classic
    ```
2.  Verify installation:
    ```bash
    flutter doctor
    ```

### 3. Android Setup
1.  Install Android Studio.
2.  Install Android SDK Command-line Tools (latest) via Android Studio SDK Manager.
3.  Accept licenses:
    ```bash
    flutter doctor --android-licenses
    ```

### 4. VS Code (Recommended Editor)
1.  Install VS Code: `sudo snap install code --classic`
2.  Install Extensions:
    -   Flutter
    -   Dart

### 5. Project Setup
1.  Clone repository:
    ```bash
    git clone <repository-url>
    cd Flutter_partnerapp
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run -d linux  # Run as Linux desktop app
    # OR
    flutter run -d chrome # Run in browser
    ```
§*cascade08"(4a0372be293496ced0b6043c52d1a8c77163efcf2bfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/docs/project_knowledge.md:Hfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp