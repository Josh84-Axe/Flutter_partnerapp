import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'transaction_repository.dart';

class ReportRepository {
  final TransactionRepository _transactionRepository;

  ReportRepository({required TransactionRepository transactionRepository}) 
      : _transactionRepository = transactionRepository;

  /// Generate a transaction report (PDF or CSV) as bytes
  Future<Uint8List> generateTransactionReport({
    required DateTimeRange range,
    required String format,
    required String partnerName,
  }) async {
    try {
      if (kDebugMode) print('📊 [ReportRepository] Generating $format report for ${range.start} - ${range.end}');
      
      // 1. Fetch transactions (assigned and wallet)
      final assignedTransactions = await _transactionRepository.fetchAssignedPlanTransactions();
      final walletTransactions = await _transactionRepository.getWalletTransactions();
      
      final allTransactions = [...assignedTransactions, ...walletTransactions];
      
      // 2. Filter by date range
      final filteredTransactions = allTransactions.where((t) {
        final dateStr = t['created_at'] ?? t['createdAt'];
        if (dateStr == null) return false;
        final date = DateTime.tryParse(dateStr);
        if (date == null) return false;
        
        return date.isAfter(range.start.subtract(const Duration(days: 1))) && 
               date.isBefore(range.end.add(const Duration(days: 1)));
      }).toList();
      
      // Sort by date (newest first)
      filteredTransactions.sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at'] ?? a['createdAt'] ?? '') ?? DateTime(0);
        final dateB = DateTime.tryParse(b['created_at'] ?? b['createdAt'] ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA);
      });
      
      if (kDebugMode) print('✅ [ReportRepository] Found ${filteredTransactions.length} transactions for report');

      // 3. Generate Bytes
      if (format.toUpperCase() == 'CSV') {
        return await _generateCSV(filteredTransactions);
      } else {
        return await _generatePDF(filteredTransactions, range, partnerName);
      }
    } catch (e) {
      if (kDebugMode) print('❌ [ReportRepository] Generate report error: $e');
      rethrow;
    }
  }

  Future<Uint8List> _generateCSV(List<dynamic> transactions) async {
    final List<List<dynamic>> rows = [];
    
    // Headers
    rows.add([
      'Transaction ID',
      'Date',
      'Type',
      'Amount',
      'Status',
      'Description',
      'Reference'
    ]);
    
    // Data
    for (var t in transactions) {
      rows.add([
        t['id']?.toString() ?? '',
        _formatDate(t['created_at'] ?? t['createdAt']),
        t['type'] ?? '',
        t['amount_paid']?.toString() ?? t['amount']?.toString() ?? '0',
        t['status'] ?? '',
        t['description'] ?? '',
        t['payment_reference'] ?? '',
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    return Uint8List.fromList(csvData.codeUnits);
  }

  Future<Uint8List> _generatePDF(List<dynamic> transactions, DateTimeRange range, String partnerName) async {
    final pdf = pw.Document();
    
    // Calculate totals
    double totalAmount = 0;
    int successCount = 0;
    
    for (var t in transactions) {
      final amount = double.tryParse(t['amount_paid']?.toString() ?? t['amount']?.toString() ?? '0') ?? 0;
      totalAmount += amount;
      if ((t['status']?.toString().toLowerCase() ?? '') == 'success') {
        successCount++;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildPdfHeader(range, partnerName),
            pw.SizedBox(height: 20),
            _buildPdfSummary(transactions.length, successCount, totalAmount),
            pw.SizedBox(height: 20),
            _buildPdfTable(transactions),
          ];
        },
      ),
    );

    return await pdf.save();
  }
  
  pw.Widget _buildPdfHeader(DateTimeRange range, String partnerName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Transaction Report',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Partner: $partnerName'),
        pw.Text('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
        pw.Text('Period: ${DateFormat('yyyy-MM-dd').format(range.start)} to ${DateFormat('yyyy-MM-dd').format(range.end)}'),
        pw.Divider(),
      ],
    );
  }
  
  pw.Widget _buildPdfSummary(int totalCount, int successCount, double totalAmount) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Transactions', totalCount.toString()),
          _buildSummaryItem('Successful', successCount.toString()),
          _buildSummaryItem('Total Amount', 'GHS ${totalAmount.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
  
  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }
  
  pw.Widget _buildPdfTable(List<dynamic> transactions) {
    // Limit rows for PDF performance if needed, or handle pagination
    // For now, taking first 100 to avoid memory issues if list is huge
    final tableData = transactions.take(200).map((t) {
      return [
        _formatDate(t['created_at'] ?? t['createdAt']),
        t['type'] ?? 'Transaction',
        t['payment_reference']?.toString() ?? '#${t['id']}',
        t['status']?.toString().toUpperCase() ?? 'UNKNOWN',
        'GHS ${t['amount_paid']?.toString() ?? t['amount']?.toString() ?? '0.00'}',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: ['Date', 'Type', 'Reference', 'Status', 'Amount'],
      data: tableData,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
