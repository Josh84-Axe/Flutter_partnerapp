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
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tiknet Partner - Vouchers', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.Text(planName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 15),
            pw.GridView(
              crossAxisCount: 5,
              childAspectRatio: 2.2,
              children: vouchers.map((v) => pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      v.planName.toUpperCase(),
                      style: pw.TextStyle(fontSize: 7, color: PdfColors.grey800),
                      maxLines: 1,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      v.code,
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              )).toList(),
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
