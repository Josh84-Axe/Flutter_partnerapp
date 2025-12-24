# Codebase Optimization & Refactoring Plan

> [!IMPORTANT]
> This plan addresses critical architectural bottlenecks identified during the codebase audit. The primary goal is to improve maintainability, reduce API load, and enhance UI responsiveness.

## 1. State Management Refactoring (Priority: High)
**Current Issue:** `AppState` is a monolithic class (3000+ lines) violating the Single Responsibility Principle. It manages Auth, User Data, Router Inventory, Payments, and UI State simultaneously. This leads to:
- Excessive widget rebuilds (changing one value notifies *all* listeners).
- High maintenance complexity.
- Difficulty in testing.

**Optimization Plan:**
Split `AppState` into focused, domain-specific Providers:

### 1.1 `AuthProvider`
- **Responsibilities:** Login/Logout, Token Management, 2FA, Password Reset.
- **Dependencies:** `AuthRepository`, `TokenStorage`.

### 1.2 `UserProvider`
- **Responsibilities:** Managing Customer lists, profiles, blocking/unblocking.
- **Dependencies:** `CustomerRepository`.

### 1.3 `NetworkProvider`
- **Responsibilities:** Router inventory, Hotspots, Active Sessions, Data Usage.
- **Dependencies:** `RouterRepository`, `HotspotRepository`, `SessionRepository`.

### 1.4 `BillingProvider`
- **Responsibilities:** Wallet balance, Transactions, Payouts, Report generation.
- **Dependencies:** `WalletRepository`, `TransactionRepository`, `ReportRepository`.

> [!TIP]
> Use `MultiProvider` in `main.dart` to inject these new providers. Use `ProxyProvider` if there are inter-dependencies (e.g., Billing needing Auth).

---

## 2. API & Caching Strategy (Priority: Medium)
**Current Issue:** `CacheService` exists but is largely unused. Most repositories perform direct network requests every time, wasting bandwidth and slowing down the UX.
**Current Issue:** `loadDashboardData` waits for *all* futures to complete before showing content suitable for interaction.

**Optimization Plan:**
### 2.1 Implement Repository Caching
Modify Repositories (`CustomerRepository`, `TransactionRepository`, `RouterRepository`) to use `CacheService`:
- **Read-through Cache:** Check `CacheService.getData(key)` before API call.
- **Write-through Policy:** On successful API fetch, call `CacheService.saveData(key, data)`.
- **Background Refresh:** Return cached data immediately, then fetch fresh data silently to update UI.

### 2.2 Optimize Dashboard Loading
- **Progressive Loading:** Split `loadDashboardData`. Load critical info (Wallet Balance, Active Users) first. Load secondary info (Charts, History) lazily.
- **Parallelization:** Ensure strictly independent calls are run in `Future.wait`.

---

## 3. UI Rendering Performance (Priority: Medium)
**Current Issue:** Global `Consumer<AppState>` usage typically triggers rebuilds for the entire screen when a minor state changes.

**Optimization Plan:**
- **Selector Pattern:** Use `Selector<AppState, DataType>` instead of `Consumer<AppState>` to listen only to specific data changes.
- **const Constructors:** Enforce `const` for static widgets (Icons, Text styles) to prevent unnecessary object allocation.
- **Lazy Loading Lists:** Ensure all lists (Users, Transactions) use `ListView.builder` with pagination, not massive single-page fetches.

---

## 4. Asset & Resource Optimization (Priority: Low)
**Current Issue:** Potential uncached images or large assets.

**Optimization Plan:**
- **Image Caching:** Use `cached_network_image` for checking user avatars or remote branding assets.
- **SVG Usage:** Prefer SVG icons over PNGs for resolution independence and smaller size.

---

## 5. API Safety Guarantee
> [!IMPORTANT]
> The optimization plan is designed to be **non-destructive** to existing API integrations.

**Safety Mechanisms:**
1.  **Zero-Touch Repositories:** We will **NOT modify any file in `lib/repositories/`**. The data layer that communicates with your backend remains 100% intact.
2.  **Shared Dio Instance:** The HTTP client (`Dio`) configured with your interceptors and token storage will be preserved and injected into the new Providers, ensuring authentication works exactly as it does now.

## 6. Migration Strategy (Strangler Pattern)
To eliminate risk, we will use an incremental approach instead of a "Big Bang" rewrite:

1.  **Phase 1 (Setup):** Create the new Provider classes (`AuthProvider`, `BillingProvider`) but keep them empty. Register them in `main.dart`.
2.  **Phase 2 (Incremental Move):**
    -   Move *only* Wallet/Transaction logic to `BillingProvider`.
    -   Update screens to consume `BillingProvider` instead of `AppState`.
    -   **Verify:** Check if Payments/History work.
3.  **Phase 3 (Repeat):** Repeat for `UserProvider` and `NetworkProvider`.
4.  **Phase 4 (Cleanup):** Once `AppState` is empty, delete it.

**Rollback Plan:** Since we are creating *new* files and slowly migrating UI consumers, we can revert to `AppState` instantly if any specific feature shows regression.
