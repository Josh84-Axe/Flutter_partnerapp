# Partner App Test Scenarios (QA)

This document provides a detailed list of test cases for validating the Partner App functionalities.

---

## Test Environment
- **Device Support**: Android, iOS, Web Browser.
- **Pre-requisites**: Stable Internet connection, "fix/token-storage-windows" branch or latest production build.

---

## 1. Authentication & Registration

| ID | Feature | Test Case | Pre-conditions | Test Steps | Expected Result |
|:---|:---|:---|:---|:---|:---|
| **AUTH-01** | Login | Valid Login | Registered Account | 1. Enter valid email.<br>2. Enter valid password.<br>3. Tap Login. | User redirects to Dashboard. |
| **AUTH-02** | Login | Invalid Password | - | 1. Enter valid email.<br>2. Enter wrong password.<br>3. Tap Login. | Error "Invalid credentials" displayed. |
| **AUTH-03** | Register | **Full Field Validation** | - | 1. Open Register Screen.<br>2. Leave "Full Name" empty.<br>3. Enter password < 6 chars.<br>4. Tap Submit. | Errors displayed for Name Required and Password Min Length. |
| **AUTH-04** | Register | Successful Registration | - | 1. Fill all fields (Name, Phone, Email, Address, City, Routers=1).<br>2. Agree to Terms.<br>3. Tap Submit. | Account created. Redirect to Home or Email Verification. |
| **AUTH-05** | Auth | IP Detection | - | 1. Open Register Screen. | Country dropdown Auto-selects based on user IP. |

## 2. Dashboard

| ID | Feature | Test Case | Pre-conditions | Test Steps | Expected Result |
|:---|:---|:---|:---|:---|:---|
| **DASH-01** | Metrics | Data Refresh | - | 1. Pull-to-refresh Dashboard. | Loading spinners appear, numbers update. |
| **DASH-02** | Nav | Navigation | - | 1. Tap "Settings" Quick Action.<br>2. Tap Back.<br>3. Tap "Internet Plans". | Navigation works smoothly without crashes. |
| **DASH-03** | Data Usage | Visual Bar | User has usage | 1. Check Data Usage Card. | Progress bar reflects (Used / Total) %. |

## 3. User Management

| ID | Feature | Test Case | Pre-conditions | Test Steps | Expected Result |
|:---|:---|:---|:---|:---|:---|
| **USER-01** | Search | Filter by Name | Users exist | 1. Type "John" in search bar. | List shows only users named "John". |
| **USER-02** | Search | Filter by Phone | Users exist | 1. Type "055" in search bar. | List shows users with that phone number prefix. |
| **USER-03** | Actions | **Block User** | User Active | 1. Select User -> Three Dots -> Block.<br>2. Confirm. | User status turns "Blocked". Active sessions disconnected. |
| **USER-04** | Actions | **Unblock User** | User Blocked | 1. Select User -> Three Dots -> Unblock. | User status turns "Active". |
| **USER-05** | Router | **Assign Router** | Worker User | 1. User -> Assign Router.<br>2. Select "Router A" & "Router B".<br>3. Save. | Success message. Worker can now manage these routers. |

## 4. Internet Plans

| ID | Feature | Test Case | Pre-conditions | Test Steps | Expected Result |
|:---|:---|:---|:---|:---|:---|
| **PLAN-01** | Create | Unlimited Plan | - | 1. Add Plan.<br>2. Select Data Limit: "Unlimited".<br>3. Fill Price/Validity.<br>4. Save. | Plan created with infinite data badge. |
| **PLAN-02** | Create | Capped Plan | - | 1. Add Plan.<br>2. Select Data Limit: "50 GB".<br>3. Save. | Plan created with 50GB limit. |
| **PLAN-03** | Edit | Update Price | Existing Plan | 1. Edit Plan.<br>2. Change Price.<br>3. Save. | Price updates in list. |
| **PLAN-04** | Logic | Delete Active Plan | Plan has users | 1. Try to delete plan with active users. | Error "Cannot delete plan with active subscribers". |

## 5. Active Sessions

| ID | Feature | Test Case | Pre-conditions | Test Steps | Expected Result |
|:---|:---|:---|:---|:---|:---|
| **SESS-01** | Display | Field Verification | Online User | 1. Expand Online User Card. | Verify IP, Uptime, and Router Name are not null/empty. |
| **SESS-02** | Action | **Disconnect** | Online User | 1. Toggle Switch to OFF. | Session removed from list immediately. |

## 6. Financials (Payouts)

| ID | Feature | Test Case | Pre-conditions | Test Steps | Expected Result |
|:---|:---|:---|:---|:---|:---|
| **PAY-01** | Request | **Fee Logic (MoMo)** | Balance > 100 | 1. Request Payout.<br>2. Select "Mobile Money".<br>3. Enter 100. | Summary shows Fee: 2.00, Receive: 98.00 (2%). |
| **PAY-02** | Request | **Fee Logic (Bank)** | Balance > 100 | 1. Request Payout.<br>2. Select "Bank".<br>3. Enter 100. | Summary shows Fee: 1.50, Receive: 98.50 (1.5%). |
| **PAY-03** | Request | Max Button | Balance = 500 | 1. Tap "Max". | Amount field fills with 500.00. |
| **PAY-04** | Add Method | Dynamic Add | - | 1. Tap "Add New".<br>2. Fill Details.<br>3. Save. | New method selected in dropdown. |

## 7. Settings & Config

| ID | Feature | Test Case | Pre-conditions | Test Steps | Expected Result |
|:---|:---|:---|:---|:---|:---|
| **CONF-01** | Profile | Hotspot Profile | - | 1. Create Profile.<br>2. Set Rate Limit + Idle Timeout.<br>3. Save. | Profile usable in Plan Creation. |
| **CONF-02** | Lang | Switch Language | - | 1. Settings -> Language -> French. | Application text changes to French immediately. |
| **CONF-03** | Theme | Dark Mode | - | 1. Settings -> Theme -> Dark. | Background becomes dark, text becomes white. |

---
**End of Test Scenarios**
