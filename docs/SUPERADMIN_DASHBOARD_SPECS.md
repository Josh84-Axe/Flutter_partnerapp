# Superadmin Dashboard Specifications

> [!NOTE]
> This specification is derived directly from an audit of the Flutter Partner App codebase (`lib/models`, `lib/repositories`). It defines the "upstream" functionalities required to support the Partner App's features.

## 1. Dashboard Overview (Home)
The landing page providing a high-level health check of the platform.

**Key Metrics (Live Data):**
- **Total Partners**: Active vs. Pending Approval vs. Blocked.
- **Total Routers Online**: Aggregated from all partner routers.
- **Total Active Sessions**: Live end-users connected across the entire network.
- **Platform Revenue**: Total earnings (Commission/Subscription fees).
- **Pending Payouts**: Number of withdrawal requests waiting for processing.

---

## 2. User & Partner Management
**Context**: Partners register via `AuthRepository.register` with business details (`entreprise_name`, `number_of_router`, `address`).

### Menu: **Partners**
#### **2.1 Partner List**
- **View**: Table listing all registered partners.
- **Columns**: Business Name, Owner Name, Email, Country, Subscription Tier, Status (Active/Blocked), Registration Date.
- **Filters**: By Country, Status, Subscription Tier.
- **Actions**: 
    - `View Details`: Navigate to Profile.
    - `Block/Unblock`: Toggles `isBlocked` flag (found in `UserModel`).
    - `Delete`: Hard delete (restricted).

#### **2.2 Partner Approval Queue** (If applicable)
- **Function**: List newly registered partners waiting for KYC/Verification.
- **Actions**: `Approve`, `Reject` (with reason).

#### **2.3 Partner Detail View**
- **Profile**: Full details passed during registration.
- **Router Stats**: Number of assigned routers vs. limit (`numberOfRouters`).
- **Financials**: Current Wallet Balance, Lifetime Payouts.
- **Activity Log**: Last login `lastConnection`, API usage stats.

---

## 3. Financial Management
**Context**: The Partner App has a `TransactionRepository` handling `createWithdrawal` and fetching `wallet` history.

### Menu: **Finance**
#### **3.1 Withdrawal Requests (Payouts)**
- **Source**: `POST /partner/wallet/withdrawls/create/` from Partner App.
- **View**: Queue of pending withdrawal requests.
- **Columns**: Partner Name, Amount, Method (Mobile Money/Bank), Account Number, Date Requested, Status (Pending).
- **Actions**:
    - `Mark as Paid`: Updates status to 'Paid' in Partner App. Triggers notification.
    - `Reject`: Refunds amount to Partner Wallet. Updates status to 'Failed'.

#### **3.2 Revenue & Commissions**
- **View**: Ledger of platform earnings.
- **Components**:
    - **Subscription Revenue**: Fees paid by partners for App usage (e.g., Verified/Gold tiers).
    - **Transaction Fees**: % cut from end-user plan purchases (if applicable).
- **Actions**: Export Report (CSV/PDF) - mirroring `ReportRepository`.

#### **3.3 Global Currency Config**
- **Context**: App handles multiple currencies (`GHS`, `NGN`, `KES`, `XOF` in `AppState`).
- **Function**: Set exchange rates or enable/disable specific currencies for payouts.

---

## 4. Subscription & Plan Management
**Context**: Partners subscribe to tiers (`SubscriptionModel`) which define their limits (e.g., max routers, custom branding).

### Menu: **Subscriptions**
#### **4.1 Partner Plans (Tiers)**
- **Manage**: Create/Edit plans available to Partners.
- **Fields**: 
    - `Name` (e.g., Starter, Growth, Enterprise).
    - `Price` (Monthly Fee).
    - `Limits`: Max Routers, Max Staff Members.
    - `Features`: Toggleable flags (e.g., "White Labeling", "Priority Support").

#### **4.2 Subscription Status**
- **View**: List of active partner subscriptions.
- **Actions**: Manually upgrade/downgrade a partner's tier.

---

## 5. Router & Network Management
**Context**: `RouterRepository` manages device inventory. The Superadmin controls the ecosystem.

### Menu: **Network**
#### **5.1 Global Router Inventory**
- **View**: All routers connected to the platform.
- **Columns**: Router Name, IP Address, Partner Owner, Status (Online/Offline), Model/Firmware.
- **Actions**: 
    - `Reboot` (Remote command).
    - `Unbind`: Force remove from a Partner account (for dispute resolution).

#### **5.2 Router Firmware/Config** (Advanced)
- **Function**: Manage default Mikrotik configurations pushed to new routers.

---

## 6. System Configuration
### Menu: **Settings**
#### **6.1 App Version Control**
- **Context**: App uses `version.json` for updates.
- **Function**: Update the `latestVersion`, `downloadUrl`, and `releaseNotes` served to the Partner App.
- **Flag**: `forceUpdate` (Boolean) to mandate critical updates.

#### **6.2 Notification Center**
- **Source**: `LocalNotificationService` consumes notifications.
- **Function**: Send global broadcast messages to all Partners (e.g., "Maintenance Window").
- **Targeting**: All Partners, Specific Country, or Specific Tier.

#### **6.3 Admin Access Control**
- **Function**: Manage Superadmin users and roles (Viewer, Editor, Super Admin).

## 7. Audit Logs
- **Function**: Immutable log of all Superadmin actions (e.g., "Admin X approved Payout Y", "Admin Z blocked Partner A").
