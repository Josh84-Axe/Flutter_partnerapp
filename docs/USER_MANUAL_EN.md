# Partner App User Manual

This manual provides a comprehensive, step-by-step guide to using the Partner App. It details every screen, field, and process flow available in the application.

---

## Table of Contents
1. [Authentication & Onboarding](#1-authentication--onboarding)
2. [Dashboard Navigation](#2-dashboard-navigation)
3. [User Management](#3-user-management)
4. [Internet Plan Management](#4-internet-plan-management)
5. [Active Session Management](#5-active-session-management)
6. [Router Management](#6-router-management)
7. [Financial Reporting & Payouts](#7-financial-reporting--payouts)
8. [Settings & Configuration](#8-settings--configuration)

---

## 1. Authentication & Onboarding

### 1.1 Partner Registration
To become a partner, you must complete the registration form with accurate business details.

**Navigation**: Launch App -> Tap "Create Account"

**Fields**:
- **Full Name**: Your legal first and last name.
- **Phone Number**: International format. Select your country code (flag) if not automatically detected.
- **Email Address**: Logic login credential and communication channel.
- **Business Name**: The name of your ISP/Reseller business.
- **Address**: Physical business address.
- **City**: City of operation.
- **Country**: Auto-detected based on IP, or manually selectable.
- **Number of Routers**: Estimate of initial router deployment (default: 1).
- **Password**: Minimum 6 characters.
- **Confirm Password**: Must match exactly.

**Process**:
1. Fill all mandatory fields.
2. Agreements: You must check the box to agree to **Terms of Service** and **Privacy Policy**. Links are provided to read these documents.
3. Tap **"Submit"**.
4. **Verification**: You will receive an email verification link (if configured) or be logged in directly.

### 1.2 Login
**Fields**:
- **Email**: Registered email address.
- **Password**: Your secure password.

### 1.3 Password Recovery
**Navigation**: Login Screen -> Tap "Forgot Password?"
**Process**: Enter your registered email. Examples of reset links will be sent to your inbox. Follow the steps to create a new password.

---

## 2. Dashboard Navigation

The Dashboard is the landing page after login, providing a high-level overview.

**Components**:
- **Legal/Status Banner**: Displays guest mode warnings or connection status.
- **Subscription Card**: Shows your current Partner Tier (e.g., "Gold Partner") and next renewal date.
- **Metric Tiles**:
    - **Total Revenue**: Cumulative revenue. Tapping opens the [Reporting](#7-financial-reporting--payouts) screen.
    - **Active Users**: Count of currently valid customers. Tapping opens the user list.
- **Quick Action Grid**: One-tap access to commonly used features:
    - **Internet Plans**: Create/Manage plans.
    - **Active Sessions**: Monitor live connections.
    - **Reporting**: Financial stats.
    - **Settings**: App preferences.
- **Data Usage Card**: A full-width visual bar showing your aggregate data consumption vs. your limit.

---

## 3. User Management

**Navigation**: Bottom Menu -> "Users"

### 3.1 Searching & Filtering
- **Search Bar**: Enter a **Name** or **Phone Number** to find specific customers.
- **Filter**: Tap the filter icon to show only **Customers**, **Agents**, or **Admins**.

### 3.2 User Details
Tap any user to view:
- **Profile Header**: Name, Role, Login Status.
- **Data Stats**: Total Download/Upload.
- **Wallet**: Current balance.
- **Recent Transactions**: Last 5 payments.

### 3.3 Managing Users
Tap the **Three-Dot Menu** on a user card:
- **View Details**: Full profile view.
- **Assign Router**: Link a specific router to this user (worker/admin).
- **Block User**: Immediately restricts access and disconnects active sessions. Status updates to "Blocked".
- **Unblock User**: Restores access. Status updates to "Active".

---

## 4. Internet Plan Management

**Navigation**: Dashboard -> "Internet Plans"

### 4.1 Creating a Plan
Tap the **"+" (Add)** button.

**Fields**:
- **Plan Name**: Marketing name (e.g., "Weekly Saver").
- **Price**: Cost in local currency.
- **Data Limit**: Select a cap (e.g., 50GB) or **"Unlimited"**.
- **Validity**: Duration (e.g., 30 Days).
- **Device Allowed**: Maximum concurrent devices (Simultaneous Users).
- **Hotspot Profile**: Link to a technical profile (bandwidth/rate-limit configuration).

**Process**: Tap "Create Plan". The plan becomes immediately available for purchase.

### 4.2 Editing & Deleting
- **Edit**: Tap the pencil icon on a plan. Update Name, Price, or Config.
- **Delete**: Tap the trash icon. *Note: Plans with active subscribers typically cannot be deleted.*

---

## 5. Active Session Management

**Navigation**: Dashboard -> "Active Sessions"

### 5.1 Monitoring Tabs
- **Online Users**: Users who purchased a plan via self-service (Payment Gateway).
- **Assigned Users**: Users manually assigned a plan by an admin.

### 5.2 Session Details
Each card displays:
- **Customer Name**: The user identifier.
- **Plan**: Current active plan.
- **Status**: Green Dot (Online) or Gray Dot (Offline).
- **Technical Stats** (When Online):
    - Router Name: The specific device they are connected to.
    - IP Address.
    - Uptime duration.
    - Download/Upload consumption.

### 5.3 Disconnecting Users
1. Identify a user with a **Green Status** (Online).
2. Toggle the switch to **OFF**.
3. The session is terminated immediately.

---

## 6. Router Management

### 6.1 Assigning Routers to Workers
**Navigation**: Users Screen -> Select User -> Three Dots -> "Assign Router"

**Process**:
1. Search for a router by Name or ID.
2. **Checkbox Selection**: You can select multiple routers.
3. Tap **"Save Assignment"**.
   *Impact*: The receiving user (e.g., a Field Worker) will only see and manage the specific routers you assigned to them.

### 6.2 Managing Router Profiles
**Navigation**: Settings -> "Hotspot Profiles"
Manage technical parameters like Rate Limits (Speed) and Idle Timeouts.

**Fields**:
- **Profile Name**: e.g., "Standard 5Mbps".
- **Rate Limit**: Max download/upload speed.
- **Idle Timeout**: Time before auto-disconnect.
- **Promotional**: Flag for special offers.
- **Router Scope**: Specific router or "All Routers".

---

## 7. Financial Reporting & Payouts

### 7.1 Transaction History
**Navigation**: Dashboard -> "Reporting"
- **Inflows**: Money coming in (Plan purchases).
- **Outflows**: Money going out (Payouts, Expenses).
- **Date Filter**: Custom range selection.

### 7.2 Requesting Payouts
**Navigation**: Settings -> "Payouts" -> "Request Payout"

**Fields**:
- **Balance**: Shows current withdrawable amount.
- **Amount**: Enter value or tap **"Max"** to withdraw everything.
- **Payment Method**: Select Mobile Money or Bank Transfer.
  - *Add New*: You can add methods dynamically (Provider, Account Number).
- **Fee Calculation**:
  - **Mobile Money**: 2.0% fee.
  - **Bank Transfer**: 1.5% fee.
  - *Summary*: Shows Amount Requested - Fee = **You Will Receive**.

**Process**: Tap "Request Payout". Processing time varies (1-2 hours for MoMo, 2-3 days for Bank).

---

## 8. Settings & Configuration

**Navigation**: Dashboard -> "Settings" Gear Icon

- **Profile**: Update Name, Phone.
- **Security**: Change Password.
- **Payment Methods**: Manage saved payout accounts.
- **Notifications**: Searchable history of alerts.
- **Language**: Toggle English / French (Instant UI update).
- **Theme**: Toggle Dark / Light mode (or System Default).
- **Help & Support**: Contact details (Email, WhatsApp).

---
**End of Manual**
