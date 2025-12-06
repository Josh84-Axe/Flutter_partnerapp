# User/Worker Management UI Fixes

## Issues to Fix
- [x] Ellipsis menu not working on user/worker tabs
- [x] Add User/Worker FAB buttons not visible
- [x] User creation form missing required fields
- [x] Worker creation form missing required fields

## New Requirements: Worker Management Enhancements
- [ ] Add Edit Worker to menu
- [ ] Add View Worker Details to menu
- [ ] Add Assign Router to menu
- [ ] Implement router assignment system

## Implementation Tasks

### Phase 1: Model Updates
- [x] Add `assignedRouters` field to `WorkerModel`
- [x] Update `fromJson` and `toJson` methods

### Phase 2: Repository Methods
- [x] Add `fetchCollaboratorDetails` to `CollaboratorRepository`
- [x] Add `updateCollaborator` to `CollaboratorRepository`
- [x] Add `assignRouter` to `CollaboratorRepository`

### Phase 3: AppState Methods
- [x] Add `fetchWorkerDetails` to `AppState`
- [x] Add `updateWorker` to `AppState`
- [x] Add `assignRouterToWorker` to `AppState`

### Phase 4: UI Implementation
- [/] Update `_showWorkerMenu` with new options
- [ ] Create `_showWorkerDetailsDialog`
- [ ] Create `_showEditWorkerDialog`
- [ ] Create `_showAssignRouterDialog`

### Phase 5: Testing
- [ ] Test View Worker Details
- [ ] Test Edit Worker
- [ ] Test Assign Router
- [ ] Verify worker sees only assigned routers

## Debugging & Fixes
- [x] Fix empty Create Role page (added timeout, error handling, & safe parsing)
- [x] Fix Assign Role screen navigation (added TabController listener & PageStorage persistence)
- [x] Implement Role Slug support (RoleModel, Repository, UI)
- [x] Fix Role Display (RolePermissionScreen loads roles)
- [x] Fix Assign Role Target (AssignRoleScreen uses Workers & dynamic roles)
