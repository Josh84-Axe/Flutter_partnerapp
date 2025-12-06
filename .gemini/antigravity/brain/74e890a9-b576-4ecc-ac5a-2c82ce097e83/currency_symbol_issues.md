# Currency Symbol Issue Analysis

## Problem Summary

**4 out of 14 screens** are NOT displaying the correct partner currency symbol because they're missing the `country` parameter in `MetricCard.formatCurrency()` calls.

---

## Root Cause

`MetricCard.formatCurrency(amount, [country])` has an **optional** `country` parameter. When this parameter is omitted, it defaults to `null`, which causes `CurrencyUtils.formatPrice()` to use the default currency symbol (`$` USD) instead of the partner's actual currency.

```dart
// Current implementation in MetricCard
static String formatCurrency(double amount, [String? country]) {
  return CurrencyUtils.formatPrice(amount, country);
}

// In CurrencyUtils
static String formatPrice(double price, String? country) {
  final symbol = getCurrencySymbol(country); // Returns '$' if country is null
  final locale = getLocaleForCountry(country); // Returns 'en_US' if country is null
  // ...
}
```

---

## Affected Screens

### ❌ **plans_screen.dart**
- **Line 280**: `MetricCard.formatCurrency(plan.price)` 
- **Issue**: Missing country parameter
- **Impact**: Shows `$` instead of partner currency (e.g., `CFA`, `€`)

### ❌ **payout_request_screen.dart** (3 locations)
- **Line 85**: `MetricCard.formatCurrency(appState.walletBalance)`
- **Line 245**: `MetricCard.formatCurrency(_finalAmount)`
- **Line 353**: `MetricCard.formatCurrency(amount)`
- **Line 114**: Hardcoded `'$ '` prefix in TextField
- **Issue**: Missing country parameter + hardcoded `$`
- **Impact**: Always shows USD format regardless of partner country

---

## Screens Working Correctly

### ✅ **transactions_screen.dart**
- **Lines 162, 194**: Uses `partnerCountry` variable
- **Line 298**: `MetricCard.formatCurrency(transaction.amount.abs(), partnerCountry)`
- **Status**: ✅ Correct

### ✅ **plan_assignment_screen.dart**
- Uses `CurrencyUtils.formatPrice(plan.price, partnerCountry)`
- **Status**: ✅ Correct

### ✅ **additional_device_config_screen.dart**
- Uses `CurrencyUtils.formatPrice(..., appState.currentUser?.country)`
- **Status**: ✅ Correct

### ✅ **bulk_actions_screen.dart**
- Uses `CurrencyUtils.formatPrice(plan.price, partnerCountry)`
- **Status**: ✅ Correct

### ✅ **All screens using `appState.formatMoney()`**
- dashboard_screen.dart
- wallet_overview_screen.dart
- transaction_payment_history_screen.dart
- revenue_breakdown_screen.dart
- internet_plan_screen.dart
- **Status**: ✅ Correct (uses `_partnerCountry` internally)

### ✅ **Screens using `getCurrencySymbol()` only**
- active_sessions_screen.dart
- assigned_plans_list_screen.dart
- **Status**: ✅ Correct (symbol only, no formatting)

---

## Required Fixes

### 1. **plans_screen.dart** - Line 280
```dart
// BEFORE
MetricCard.formatCurrency(plan.price),

// AFTER
MetricCard.formatCurrency(plan.price, appState.currentUser?.country),
```

### 2. **payout_request_screen.dart** - Lines 85, 245, 353
```dart
// BEFORE
MetricCard.formatCurrency(appState.walletBalance),
MetricCard.formatCurrency(_finalAmount),
MetricCard.formatCurrency(amount),

// AFTER
MetricCard.formatCurrency(appState.walletBalance, appState.currentUser?.country),
MetricCard.formatCurrency(_finalAmount, appState.currentUser?.country),
MetricCard.formatCurrency(amount, appState.currentUser?.country),
```

### 3. **payout_request_screen.dart** - Line 114 (Hardcoded prefix)
```dart
// BEFORE
prefixText: '$ ',

// AFTER
prefixText: '${appState.currencySymbol} ',
```

---

## Impact

**Before Fix**:
- CFA partner sees: `$1,000.00` ❌
- EUR partner sees: `$1,000.00` ❌  
- NGN partner sees: `$1,000.00` ❌

**After Fix**:
- CFA partner sees: `CFA 1.000,00` ✅
- EUR partner sees: `€1.000,00` ✅
- NGN partner sees: `₦1,000.00` ✅

---

## Summary

| Screen | Status | Fix Needed |
|--------|--------|------------|
| plans_screen.dart | ❌ | Add country parameter (1 location) |
| payout_request_screen.dart | ❌ | Add country parameter (3 locations) + fix hardcoded $ (1 location) |
| transactions_screen.dart | ✅ | None |
| plan_assignment_screen.dart | ✅ | None |
| additional_device_config_screen.dart | ✅ | None |
| bulk_actions_screen.dart | ✅ | None |
| dashboard_screen.dart | ✅ | None |
| wallet_overview_screen.dart | ✅ | None |
| transaction_payment_history_screen.dart | ✅ | None |
| revenue_breakdown_screen.dart | ✅ | None |
| internet_plan_screen.dart | ✅ | None |
| active_sessions_screen.dart | ✅ | None |
| assigned_plans_list_screen.dart | ✅ | None |

**Total fixes needed**: 2 screens, 5 locations
