# Tiknet Africa — Family_App Workspace Memory & Operational Rules

## 1. Absolute Directives & Architectural Invariants

> [!IMPORTANT]
> **MANDATORY DIRECTIVE — ZERO UNAPPROVED BUSINESS LOGIC MUTATIONS**
> * **Preserve Authentic Multi-Tenancy & Hardware Isolation**: Family routers (`SalonTogo`) and Hotspot commercial routers (`MySXTsp`) use fundamentally distinct network profiles and authentication.
> * **Family Router Architecture**: Private WPA2/WPA3 Wi-Fi, DHCP leases, persistent MikroTik address-lists (`TIKNET_POLICY_FAMILY_SAFE`, `TIKNET_PAUSED`), and content filtering via DNSdist (ports 5301–5304) upstream to Cloudflare Zero Trust.
> * **Subscribers & Devices**: Subscribers link family devices (`FamilyDevice` model) identified by MAC address, hostname, and DUID.

---

## 2. Client Repositories & Application Variants Map

| App / Role | Local Directory | Remote Repository / Branch | Target Platform / Role |
| :--- | :--- | :--- | :--- |
| **Backend API (Django)** | `/Users/josh/Claude review/tiknetafrica-api` | `Josh84-Axe/tiknetafrica-api` (`main`) | Production VPS1 (`51.75.72.56`), FreeRADIUS AAA, PostgreSQL 17 |
| **SuperAdmin Dashboard** | `/Users/josh/Dashboard_Tiknet` | `Josh84-Axe/Tiknet_Dash` (`main`) | Next.js 14 web app for superadmin operations, billing, and fee toggles |
| **Partner Mobile App** | `/Users/josh/Flutter_partnerapp` | `Josh84-Axe/Flutter_partnerapp` (`fix/billing-payout-fees`) | Flutter app for hotspot partners (vouchers, router analytics, withdrawals) |
| **Family & Multi-Variant App** | `/Users/josh/Family_App` | `Josh84-Axe/Flavor_3apps.git` (`flavor3`) | Flutter app for Family subscribers (parental controls, device pause, zones, campus) |
| **Family Captive Portal** | `/Users/josh/Family_portal` | Cloudflare Pages | Web captive portal for Family subscriber onboarding and Wi-Fi login |

---

## 3. Family_App Subsystems & Features
* **Authentication**: Multi-factor OTP login and JWT token lifecycle (`lib/feature/auth/`, `lib/providers/split/auth_provider.dart`).
* **Family Device Management**: `lib/screens/family_add_device_screen.dart`, device pausing (`TIKNET_PAUSED`), network policy selection.
* **Network Zones & Content Filtering**: Four Pillars content safety rules (`lib/screens/family_network_zones_screen.dart`, `lib/screens/family_rules_screen.dart`).
* **Time-Gating & Schedules**: Screen time rules and bedtime schedules (`lib/screens/family_schedule_manager_screen.dart`).
* **Campus & Hotel Variants**: Multi-variant UI modules for campus subscribers (`lib/screens/campus_dashboard_screen.dart`, `campus_registration_screen.dart`).
* **Multi-Flavor Web & PWA Deployment**: Automated web build script `deploy_all_web.sh` generating targeted builds.
