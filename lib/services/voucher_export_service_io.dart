import 'dart:io';
import 'package:csv/csv.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import '../models/voucher_model.dart';

class VoucherExportService {
  /// Export vouchers to CSV locally
  static Future<void> exportToCSV(List<VoucherModel> vouchers, String planName) async {
    try {
      List<List<dynamic>> rows = [];
      
      // Header
      rows.add(['Voucher Code', 'Plan', 'Status', 'Generated At', 'Used By']);
      
      // Data
      for (var v in vouchers) {
        rows.add([
          v.code,
          v.planName,
          v.status,
          v.createdAt.toIso8601String(),
          v.usedBy ?? '',
        ]);
      }
      
      String csv = const ListToCsvConverter().convert(rows);
      
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/vouchers_${planName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csv);
      
      await OpenFile.open(path);
    } catch (e) {
      if (kDebugMode) print('❌ [VoucherExportService] CSV Export error: $e');
      rethrow;
    }
  }

  /// Export vouchers to PDF and trigger print/save dialog
  static Future<void> exportToPDF(List<VoucherModel> vouchers, String planName) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text('Vouchers for $planName', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Code', 'Status', 'Generated At'],
              data: vouchers.map((v) => [
                v.code,
                v.status.toUpperCase(),
                v.createdAt.toString().substring(0, 16),
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerRight,
              },
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Vouchers_$planName',
      );
    } catch (e) {
      if (kDebugMode) print('❌ [VoucherExportService] PDF Export error: $e');
      rethrow;
    }
  }
}
