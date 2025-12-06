# Currency Display Screens - Complete List

This document lists all screens in the Flutter Partner App that display currency amounts and currency symbols.

## Summary

**Total Screens with Currency Display**: 14 screens

**Formatting Methods Used**:
- `MetricCard.formatCurrency()` - 3 screens
- `CurrencyUtils.formatPrice()` - 4 screens  
- `CurrencyUtils.getCurrencySymbol()` - 6 screens (symbol only)
- `appState.formatMoney()` - 7 screens

---

## Screens by Formatting Method

### 1. Using `MetricCard.formatCurrency()`

#### [transactions_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/transactions_screen.dart)
- **Line 162**: Wallet Balance display
- **Line 194**: Total Revenue display
- **Line 298**: Individual transaction amounts in list

#### [plans_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/plans_screen.dart)
- **Line 280**: Plan price display in plan cards

#### [payout_request_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/payout_request_screen.dart)
- **Line 85**: Wallet balance display
- **Line 245**: Final payout amount calculation
- **Line 353**: Amount display in payout breakdown

---

### 2. Using `CurrencyUtils.formatPrice()`

#### [plan_assignment_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/plan_assignment_screen.dart)
- **Line 159**: Plan price in dropdown selection
- **Line 207**: Plan price in detail view

#### [additional_device_config_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/config/additional_device_config_screen.dart)
- **Line 211**: Device configuration price display

#### [bulk_actions_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/bulk_actions_screen.dart)
- **Line 210**: Plan price in bulk action list

---

### 3. Using `CurrencyUtils.getCurrencySymbol()` (Symbol Only)

#### [transaction_payment_history_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/transaction_payment_history_screen.dart)
- **Line 348**: Currency symbol as prefix in input field

#### [transactions_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/transactions_screen.dart)
- **Line 36**: Currency symbol variable (used in input fields)

#### [plans_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/plans_screen.dart)
- **Line 63**: Currency symbol as prefix in price input field

#### [additional_device_config_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/config/additional_device_config_screen.dart)
- **Line 176**: Currency symbol variable (now replaced with formatPrice)

#### [assigned_plans_list_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/assigned_plans_list_screen.dart)
- **Line 99**: Currency symbol variable

#### [active_sessions_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/active_sessions_screen.dart)
- **Line 168**: Currency symbol variable

---

### 4. Using `appState.formatMoney()`

#### [wallet_overview_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/wallet_overview_screen.dart)
- **Line 96**: Wallet balance display
- **Line 178**: Transaction amount in list
- **Line 237**: Total revenue summary
- **Line 243**: Total payouts summary
- **Line 249**: Current balance summary

#### [transaction_payment_history_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/transaction_payment_history_screen.dart)
- **Line 61**: Wallet balance display
- **Line 70**: Earned income display
- **Line 109**: Transaction amount in list

#### [revenue_breakdown_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/revenue_breakdown_screen.dart)
- **Line 45**: Assigned revenue display
- **Line 55**: Online revenue display
- **Line 235**: Transaction amount in list

#### [internet_plan_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/internet_plan_screen.dart)
- **Line 100**: Plan price display

#### [dashboard_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/dashboard_screen.dart)
- **Line 125**: Total revenue metric
- **Line 234**: Transaction amount in detail modal

---

## Formatting Status

### ✅ Already Using Locale-Aware Formatting
- `MetricCard.formatCurrency()` - Uses `CurrencyUtils.formatPrice()` internally
- `CurrencyUtils.formatPrice()` - Implements locale-specific formatting

### ⚠️ Needs Investigation
- `appState.formatMoney()` - Need to check if this uses locale-aware formatting

### ✓ Symbol Only (No Formatting Needed)
- `CurrencyUtils.getCurrencySymbol()` - Only returns symbol, no number formatting

---

## Next Steps

1. **Verify `appState.formatMoney()` implementation**:
   - Check if it uses `CurrencyUtils.formatPrice()` or has its own formatting
   - If it doesn't use locale-aware formatting, update it

2. **Test all screens**:
   - Dashboard
   - Transactions
   - Wallet Overview
   - Plans
   - Payout Request
   - Revenue Breakdown
   - Transaction/Payment History
   - Plan Assignment
   - Additional Device Config
   - Bulk Actions
   - Assigned Plans List
   - Active Sessions
   - Internet Plan

3. **Verify formatting**:
   - CFA countries show: `CFA 1.000,50`
   - European countries show: `€1.000,50`
   - US/Other countries show: `$1,000.00`
