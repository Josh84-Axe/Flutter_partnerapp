# Implemented API Endpoints

Base URL: `https://api.tiknetafrica.com/v1`

## Auth
- `POST /partner/login/`
- `POST /partner/register/`
- `POST /partner/register-confirm/`
- `POST /partner/verify-email-otp/`
- `POST /partner/resend-verify-email-otp/`
- `GET /partner/check-token/`
- `POST /partner/password-reset/`
- `POST /partner/password-reset-confirm/`
- `POST /partner/change-password/`
- `POST /auth/login/` (Found in PartnerRepository, potential duplicate/inconsistency)

## Wallet
- `GET /partner/wallet/balance/`
- `GET /partner/wallet/all-transactions/`
- `GET /partner/wallet/transactions/`
- `GET /partner/withdrawals/`
- `POST /partner/withdrawals/create/`
- `GET /partner/wallet/transactions/{transactionId}/details/`

## Transactions
- `GET /partner/transactions/`
- `GET /partner/transactions/additional-devices/`
- `GET /partner/transactions/assigned-plans/`

## Sessions
- `GET /partner/sessions/active/`
- `POST /partner/sessions/disconnect/`

## Routers
- `GET /partner/routers/list/`
- `GET /partner/routers/{routerSlug}/details/`
- `GET /partner/routers/{slug}/active-users/`
- `GET /partner/routers/{slug}/resources/`
- `POST /partner/routers-add/`
- `PUT /partner/routers/{routerSlug}/update/`
- `DELETE /partner/routers/{routerId}/delete/`
- `POST /partner/routers/{slug}/reboot/`
- `POST /partner/routers/{slug}/hotspots/restart/`

## Plans
- `GET /partner/plans/`
- `POST /partner/plans/create/`
- `GET /partner/plans/{planSlug}/read/`
- `PUT /partner/plans/{planSlug}/update/`
- `DELETE /partner/plans/{planSlug}/delete/`
- `POST /partner/assign-plan/`
- `GET /partner/assigned-plans/`

## Plan Config
- `GET /partner/rate-limit/`
- `POST /partner/rate-limit/create/`
- `GET /partner/rate-limit/{id}/`
- `DELETE /partner/rate-limit/{id}/delete/`
- `GET /partner/data-limit/`
- `POST /partner/data-limit/create/`
- `GET /partner/data-limit/{id}/`
- `DELETE /partner/data-limit/{id}/delete/`
- `GET /partner/shared-users/`
- `POST /partner/shared-users/create/`
- `GET /partner/shared-users/{id}/`
- `DELETE /partner/shared-users/{id}/delete/`
- `GET /partner/validity/`
- `POST /partner/validity/create/`
- `GET /partner/validity/{id}/`
- `DELETE /partner/validity/{id}/delete/`
- `GET /partner/idle-timeout/`
- `POST /partner/idle-timeout/create/`
- `GET /partner/idle-timeout/{id}/`
- `DELETE /partner/idle-timeout/{id}/delete/`

## Payment Methods
- `GET /partner/payment-methods/list/`
- `POST /partner/payment-methods/create/`
- `GET /partner/payment-methods/{slug}/`
- `PUT /partner/payment-methods/{slug}/update/`
- `DELETE /partner/payment-methods/{slug}/delete/`
- `GET /partner/payment-methods/` (List available methods)

## Password Management
- `POST /partner/change-password/`
- `POST /partner/password-reset-request-otp/`
- `POST /partner/password-reset-otp-verify/`
- `POST /partner/reset-password/`

## Partner Profile
- `GET /partner/profile/`
- `GET /partner/dashboard/`
- `PUT /partner/update/`
- `GET /partner/currency/`
- `GET /partner/currency-code/`
- `GET /partner/countries/`
- `GET /partner/report-types/`

## Hotspots
- `GET /partner/hotspot/profiles/list/`
- `POST /partner/hotspot/profiles/create/`
- `GET /partner/hotspot/profiles/{profileSlug}/detail/`
- `PUT /partner/hotspot/profiles/{profileSlug}/update/`
- `DELETE /partner/hotspot/profiles/{profileSlug}/delete/`
- `GET /partner/hotspot/users/list/`
- `POST /partner/hotspot/users/create/`
- `GET /partner/hotspot/users/{username}/read/`
- `PUT /partner/hotspot/users/{username}/update/`
- `DELETE /partner/hotspot/users/{username}/delete/`

## Customers
- `GET /partner/customers/paginate-list/`
- `GET /partner/customers/all/list/`
- `PUT /partner/customers/{username}/block-or-unblock/`
- `GET /partner/customers/{username}/data-usage/`
- `GET /partner/customers/{username}/transactions/`
- `POST /partner/customers/`
- `PUT /partner/customers/{id}/`
- `DELETE /partner/customers/{id}/`

## Collaborators
- `GET /partner/collaborators/`
- `POST /partner/collaborators/create/`
- `POST /partner/collaborators/{username}/assign-role/`
- `PUT /partner/collaborators/{username}/update-role/`
- `DELETE /partner/collaborators/{username}/delete/`
- `GET /partner/roles/`
- `POST /partner/roles/create/`
- `GET /partner/roles/{slug}/`
- `PUT /partner/roles/{slug}/update/`
- `DELETE /partner/roles/{slug}/delete/`

## Additional Devices
- `GET /partner/additional-devices/`
- `POST /partner/additional-devices/create/`
- `GET /partner/additional-devices/{id}/`
- `PUT /partner/additional-devices/{id}/`
- `DELETE /partner/additional-devices/{id}/delete/`
