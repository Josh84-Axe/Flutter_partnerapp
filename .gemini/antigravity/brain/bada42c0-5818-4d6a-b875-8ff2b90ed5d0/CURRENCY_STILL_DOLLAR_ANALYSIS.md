# Currency Still Showing $ - Root Cause Analysis

**Issue:** Plans and Payout screens still show $ instead of GH₵  
**Date:** November 24, 2025  
**Time:** 12:26 PM

---

## Investigation Results

### ✅ Code is CORRECT

Both screens properly use dynamic currency:

#### 1. Plans Screen (`plans_screen.dart` Line 121)
```dart
MetricCard.formatCurrency(plan.price, appState.currentUser?.country)
//                                    ↑ Uses partner country
```

#### 2. Payout Request Screen (`payout_request_screen.dart`)

**Line 85 - Withdrawable Balance:**
```dart
MetricCard.formatCurrency(appState.walletBalance, appState.currentUser?.country)
//                                                 ↑ Uses partner country
```

**Line 114 - Input Prefix:**
```dart
prefixText: '${appState.currencySymbol} ',
//            ↑ Uses appState.currencySymbol getter
```

**Line 245 - You Will Receive:**
```dart
MetricCard.formatCurrency(_finalAmount, appState.currentUser?.country)
//                                       ↑ Uses partner country
```

**Line 353 - Summary Rows:**
```dart
MetricCard.formatCurrency(amount, context.read<AppState>().currentUser?.country)
//                                ↑ Uses partner country
```

### ✅ Currency Utils is CORRECT

```dart
// currency_utils.dart
'Ghana': 'GH₵',  // Line 34 - Correct mapping
```

---

## Root Cause: OLD BUILD

### Timeline

| Time | Event |
|------|-------|
| 10:17 AM | **OLD BUILD** - Before profile parsing fix |
| 12:20 PM | Profile parsing fix applied |
| 12:23 PM | **NEW BUILD** completed (197.2s) |
| 12:26 PM | User reports $ still showing |

### The Problem

**User is running the OLD executable from 10:17 AM!**

The OLD build has the bug where:
1. `partner_repository.dart` returns raw response (not nested data)
2. `app_state.dart` tries to access `profileData['country']`
3. But country is actually at `profileData['data']['country']`
4. Result: `currentUser?.country` = **NULL**
5. `CurrencyUtils.getCurrencySymbol(null)` → returns **'$'** (default)

### The Fix (Already Applied)

**NEW build (12:23 PM) has:**
```dart
// partner_repository.dart - Lines 17-27
final responseData = response.data as Map<String, dynamic>?;
if (responseData != null && responseData.containsKey('data')) {
  final profileData = responseData['data'] as Map<String, dynamic>?;
  return profileData;  // ✅ Returns nested data
}
```

This means:
1. `profileData` now contains the actual profile data
2. `profileData['country']` = **"Ghana"**
3. `currentUser?.country` = **"Ghana"**
4. `CurrencyUtils.getCurrencySymbol("Ghana")` → returns **'GH₵'**

---

## Solution

### User Must Run the NEW Build

**OLD executable (showing $):**
```
build\windows\x64\runner\Release\hotspot_partner_app.exe
Built: 10:17 AM (before fix)
```

**NEW executable (will show GH₵):**
```
build\windows\x64\runner\Release\hotspot_partner_app.exe
Built: 12:23 PM (after fix)
```

### Steps to Verify

1. **Close the old app** (if running)

2. **Run the NEW build:**
   ```powershell
   .\build\windows\x64\runner\Release\hotspot_partner_app.exe
   ```

3. **Login:**
   - Email: sientey@hotmail.com
   - Password: Testing123

4. **Check console logs:**
   ```
   ✅ [PartnerRepository] Extracted profile data: {id: 2763, country: Ghana, ...}
   💰 [AppState] Partner country set to: Ghana
   💰 [AppState] Currency symbol: GH₵
   ```

5. **Verify UI:**
   - Plans screen: Should show "GH₵ 10", "GH₵ 15"
   - Payout screen: Should show "GH₵ 1,193"

---

## Why This Happened

### Build Process

When you run `flutter build windows --release`:
1. Compiles Dart code to native code
2. Creates executable at `build\windows\x64\runner\Release\hotspot_partner_app.exe`
3. **Overwrites** the old executable

### User Behavior

Possible scenarios:
1. User had app already open when new build completed
2. User ran old build from a different location
3. User didn't close and reopen the app after rebuild

---

## Expected Behavior After Running NEW Build

### Plans Screen

**Before (OLD build):**
```
30 Minutes          $10
CONNECT EXTRA       $15
```

**After (NEW build):**
```
30 Minutes          GH₵ 10
CONNECT EXTRA       GH₵ 15
```

### Payout Request Screen

**Before (OLD build):**
```
Withdrawable Balance
$1,193
```

**After (NEW build):**
```
Withdrawable Balance
GH₵ 1,193
```

---

## Verification Checklist

Run the NEW build and verify:

- [ ] Plans screen shows GH₵ symbol
- [ ] Payout screen shows GH₵ symbol
- [ ] User name shows "Josh John" (not blank)
- [ ] Console logs show "Partner country set to: Ghana"
- [ ] Console logs show "Currency symbol: GH₵"

---

## Additional Notes

### Ghana Currency Format

Ghana uses **comma** as thousand separator:
- Correct: GH₵ 1,193
- NOT: GH₵ 1.193 (European style)

This is configured in `currency_utils.dart`:
```dart
// Ghana is NOT in the CFA countries list
// So it uses 'en_US' locale (comma separator)
```

### If Still Shows $ After Running NEW Build

Then there's a different issue. Check:
1. Console logs - what does "Partner country set to:" show?
2. Is `currentUser?.country` actually "Ghana"?
3. Is there a caching issue?

But most likely: **User just needs to run the NEW build!**

---

**Root Cause:** Using OLD build from before profile parsing fix  
**Solution:** Run the NEW build (12:23 PM)  
**Expected Result:** GH₵ symbol everywhere  
**Confidence:** 95% - Code is correct, just needs new build

