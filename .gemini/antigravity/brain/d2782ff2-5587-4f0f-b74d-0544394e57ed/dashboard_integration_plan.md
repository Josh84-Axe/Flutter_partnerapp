# Dashboard Integration Implementation Plan

## Overview
Integrate the transaction history screen with the dashboard by adding revenue breakdown widgets and navigation with tab pre-selection.

## Current State
- Dashboard shows single "Total Revenue" widget
- No separate widgets for Assigned/Online revenue
- `_showRevenueDetails()` shows a modal with old transaction data
- Transactions are not loaded on dashboard initialization

## Proposed Changes

### 1. Update Dashboard Layout

Add revenue breakdown section below total revenue:

```dart
// Current: Single Total Revenue widget
Row([
  Total Revenue Widget
  Active Users Widget
])

// New: Total Revenue + Breakdown
Column([
  // Total Revenue (clickable → All Transactions tab)
  Total Revenue Widget,
  
  // Revenue Breakdown Row
  Row([
    Assigned Revenue Widget (clickable → Assigned tab),
    Online Revenue Widget (clickable → Wallet tab)
  ])
])
```

### 2. Update Transaction History Screen

Add support for initial tab selection via route arguments:

**TransactionHistoryScreen:**
- Accept optional `initialTab` parameter (0=All, 1=Assigned, 2=Wallet)
- Set `TabController` initial index based on parameter

### 3. Update Dashboard Navigation

Replace `_showRevenueDetails()` with navigation to transaction history:

**Total Revenue Widget:**
```dart
onTap: () => Navigator.pushNamed(
  context,
  '/transaction-history',
  arguments: {'initialTab': 0}, // All tab
)
```

**Assigned Revenue Widget:**
```dart
onTap: () => Navigator.pushNamed(
  context,
  '/transaction-history',
  arguments: {'initialTab': 1}, // Assigned tab
)
```

**Online Revenue Widget:**
```dart
onTap: () => Navigator.pushNamed(
  context,
  '/transaction-history',
  arguments: {'initialTab': 2}, // Wallet tab
)
```

### 4. Ensure Transaction Data Loading

Update `loadDashboardData()` in AppState to include transactions:

```dart
Future<void> loadDashboardData() async {
  await Future.wait([
    loadProfile(),
    loadWalletBalance(),
    loadAllTransactions(), // ← Add this
    loadActiveSessions(),
    // ... other loads
  ]);
}
```

## Implementation Steps

1. [x] Update `TransactionHistoryScreen` to accept `initialTab` argument
2. [ ] Add revenue breakdown widgets to dashboard
3. [ ] Update dashboard navigation to use transaction history screen
4. [ ] Remove old `_showRevenueDetails()` method
5. [ ] Ensure transactions load on dashboard initialization
6. [ ] Test navigation and tab pre-selection

## Files to Modify

- `lib/screens/transaction_history_screen.dart` - Add initialTab support
- `lib/screens/dashboard_screen.dart` - Add revenue widgets, update navigation
- `lib/providers/app_state.dart` - Ensure loadDashboardData includes transactions

## Testing

- [ ] Verify total revenue calculates correctly (assigned + wallet)
- [ ] Test navigation from each revenue widget
- [ ] Verify correct tab opens for each widget
- [ ] Test pull-to-refresh on dashboard
- [ ] Verify transaction data loads on dashboard init
