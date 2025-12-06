# Role Creation and Assignment Audit Report

## 1. Existing Infrastructure

### Role Creation (`CreateRoleScreen`)
- **UI**: Exists. Allows entering a role name and selecting permissions via checkboxes.
- **Data Source**: Fetches available permissions from `/partner/permissions/list/`.
- **Submission**:
  - **Create**: POST to `/partner/roles/create/` with `name` and `permissions` (list of IDs).
  - **Update**: PUT to `/partner/roles/$slug/update/`.
- **State Management**: Handled in `AppState`.

### Role Assignment (`UsersScreen` -> `_showAssignRoleDialog`)
- **UI**: Exists. Dialog with a dropdown of available roles.
- **Target**: Workers only (as requested).
- **Submission**: POST to `/partner/collaborators/$username/assign-role/` with `role` (slug).
- **State Management**: `AppState.assignRoleToWorker`.

### Models
- **RoleModel**: Contains `id`, `name`, `permissions`.
- **WorkerModel**: Contains `roleSlug`, `roleName`.

## 2. Identified Gaps & Potential Issues

### A. Role Identification (ID vs Slug)
- **Issue**: The `RoleModel` currently has an `id` field but no explicit `slug` field.
- **Usage**:
  - `RoleRepository` methods (`updateRole`, `deleteRole`) expect a `slug`.
  - `UserRoleScreen` passes `role.id` to `deleteRole`.
  - `CreateRoleScreen` tries to use `roleData['slug']` or falls back to `roleData['id']`.
- **Risk**: If the backend uses integer IDs for `id` and string slugs (e.g., "manager") for URL parameters, the current implementation might fail when trying to delete or update a role using the ID instead of the slug.
- **Recommendation**: Update `RoleModel` to explicitly include a `slug` field if the API provides it, or verify if `id` serves as the slug.

### B. Permission Data Consistency
- **Issue**: `CreateRoleScreen` sends a list of **Permission IDs** (integers).
- **Verification**: Need to ensure the backend expects IDs for role creation/update, not permission codenames.
- **Current State**: The code collects IDs (`_selectedPermissionIds`), which is standard, but worth verifying.

### C. Role Assignment Payload
- **Issue**: `assignRoleToWorker` sends `{'role': roleSlug}`.
- **Verification**: `WorkerModel` has `roleSlug`. The dropdown in `UsersScreen` uses `role.id` as the value.
- **Conflict**: If `role.id` is different from the role's slug, the assignment might fail.
- **Recommendation**: Ensure the dropdown uses the correct identifier (slug) expected by the backend.

## 3. Implementation Plan

1.  **Update RoleModel**: Add `slug` field to `RoleModel` to strictly differentiate between database ID and URL slug.
2.  **Verify Dropdown Values**: Update `UserRoleScreen` and `UsersScreen` (assign role dialog) to use `role.slug` for API calls instead of `role.id`.
3.  **Refine Create/Update Logic**: Ensure `CreateRoleScreen` uses `slug` for updates.

## 4. Missing Features (Based on standard RBAC)
- **Role Details View**: There is no dedicated screen to view role details without editing. (Low priority if Edit serves both).
- **System Roles Protection**: Logic to prevent editing/deleting system roles (e.g., "Administrator", "Owner") if the backend doesn't already enforce it.

