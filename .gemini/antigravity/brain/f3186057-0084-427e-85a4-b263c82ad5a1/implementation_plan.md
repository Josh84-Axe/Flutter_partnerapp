# Internet Plans UI Redesign

## Overview

Redesign the Internet Plans screens to match the provided mockups. Two distinct views are required:

1. **Bottom Navigation "Plans" Tab**: Card-based view with "Assign to User" buttons
2. **Settings "Internet Plans"**: Simplified list view with Edit/Delete buttons only

## User Requirements

> [!IMPORTANT]
> - **Screenshot "Plan icon"** → Bottom Nav design (with Assign buttons)
> - **Screenshot "Setting"** → Settings design (Edit/Delete only, no Assign)

## Current State Analysis

### Existing Screens
- `PlansScreen` (lib/screens/plans_screen.dart) - Currently used for bottom nav
- `InternetPlanScreen` (lib/screens/internet_plan_screen.dart) - Legacy screen with Edit/Delete

### Current Issues
- Both screens show similar layouts
- Settings navigation currently routes to `PlansScreen` (which has Assign buttons)
- Need distinct designs for different contexts

## Proposed Changes

### 1. Update `PlansScreen` (Bottom Nav)

**File**: [plans_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/plans_screen.dart)

**Changes**:
- ✅ Already has card-based layout
- ✅ Already has "Assign to User" button
- **Update card design** to match mockup:
  - Plan name as title (larger, bold)
  - Price on the right side
  - Info chips with icons (Data Limit, Device Allowed, Validity)
  - Green "Assign to User" button at bottom
  - Remove Edit functionality from cards (already done)

### 2. Update `InternetPlanScreen` (Settings)

**File**: [internet_plan_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/internet_plan_screen.dart)

**Changes**:
- Redesign to match "Setting" screenshot
- Simpler card layout:
  - Plan name (bold, large)
  - Subtitle: "Data | Speed | Validity" (gray text)
  - Price below subtitle
  - Edit (green circle) and Delete (red circle) buttons on right
- Remove "Assign" functionality
- Keep FAB for "New Plan"

### 3. Routing Configuration

**File**: [main.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/main.dart)

**Verify**:
- `/internet-plan` → `InternetPlanScreen` (for Settings)
- Bottom nav "Plans" tab → `PlansScreen`

---

## Design Specifications

### Bottom Nav "Plans" Card (PlansScreen)

```
┌─────────────────────────────────────┐
│ Plan Name              $XX.XX       │
│                                     │
│ 🔽 Data Limit    💻 Device Allowed │
│    X GB             Y devices       │
│                                     │
│ 📅 Validity                        │
│    Z days                          │
│                                     │
│ [  👤 Assign to User  ]            │
└─────────────────────────────────────┘
```

### Settings "Internet Plans" Card (InternetPlanScreen)

```
┌─────────────────────────────────────┐
│ Plan Name                    ✏️ 🗑️  │
│ X GB | Y Mbps | Z days              │
│ XX,XX CFA                           │
└─────────────────────────────────────┘
```

---

## Implementation Steps

1. **Update PlansScreen card layout**
   - Adjust info chip styling (green background with icons)
   - Ensure "Assign to User" button is prominent
   - Match spacing and typography from mockup

2. **Redesign InternetPlanScreen**
   - Simplify card to single-line info
   - Add circular Edit/Delete buttons
   - Remove any "Assign" functionality
   - Update typography and spacing

3. **Verify routing**
   - Settings → InternetPlanScreen
   - Bottom Nav → PlansScreen

4. **Test both views**
   - Verify distinct designs
   - Test Edit/Delete in Settings
   - Test Assign in Bottom Nav

---

## Verification Plan

### Visual Verification
- [ ] Bottom Nav "Plans" matches "Plan icon" screenshot
- [ ] Settings "Internet Plans" matches "Setting" screenshot
- [ ] Info chips display correctly with icons
- [ ] Buttons are properly styled and positioned

### Functional Verification
- [ ] Assign button works in Bottom Nav
- [ ] Edit/Delete buttons work in Settings
- [ ] No Assign button appears in Settings
- [ ] Navigation routes correctly
