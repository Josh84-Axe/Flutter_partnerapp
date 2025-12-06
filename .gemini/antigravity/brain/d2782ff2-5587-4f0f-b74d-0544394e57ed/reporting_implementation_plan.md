# Reporting Feature Implementation Plan (Client-Side Generation)

## Goal
Implement "Data export and reporting" by fetching transaction details from existing endpoints and generating PDF/CSV reports **client-side**.

## User Review Required
> [!IMPORTANT]
> The backend does not generate reports. We will fetch data from:
> - `/partner/transactions/assigned/{id}/details/`
> - `/partner/transactions/wallet/{id}/details/`
> And use clients-side libraries to create PDF and CSV files.

## Proposed Changes

### 1. Dependencies
- Add packages: `pdf`, `printing`, `csv`, `path_provider`, `open_file` (or `url_launcher` for web).

### 2. Repository Layer
#### [NEW] [report_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/report_repository.dart)
- `generateTransactionReport(DateTimeRange range, String format)`
  - 1. Fetch all transactions (assigned & wallet) for the date range.
  - 2. Fetch details for each transaction (using existing `TransactionRepository` methods).
  - 3. Generate PDF/CSV file in memory/temporary storage.
  - 4. Return file path or bytes.

### 3. State Management
#### [MODIFY] [app_state.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/providers/app_state.dart)
- Add `generateReport(DateTimeRange range, String format)` method.
- Handle loading state extraction and file saving/opening.

### 4. UI Layer
#### [MODIFY] [reporting_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/reporting_screen.dart)
- Update "Generate Report" to trigger client-side generation.
- Simplify UI to focus on "Transaction History" since that's the only supported data source for now.
- Remove "Recent Reports" list if persistent storage isnt implemented (or implement simple local storage for history).

## Verification Plan
### Automated Tests
- Parse generated CSV content to verify columns.

### Manual Verification
1. Select "Transaction History".
2. Pick a date range with known transactions.
3. Generate PDF -> Verify layout, totals, and transaction details.
4. Generate CSV -> Verify headers and data rows.
