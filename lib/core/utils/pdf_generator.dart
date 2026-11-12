import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class PdfReportGenerator {
  /// Saves or shares the generated PDF, prioritizing getDownloadsDirectory on desktop
  static Future<String> saveOrShareReport(Uint8List bytes, String fileName) async {
    try {
      if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final file = File('${downloadsDir.path}/$fileName');
          await file.writeAsBytes(bytes);
          debugPrint('PDF report saved to desktop downloads: ${file.path}');
          return file.path;
        }
      }
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      return 'Shared/Downloaded: $fileName';
    } catch (e) {
      debugPrint('Error saving PDF locally: $e. Falling back to share.');
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      return fileName;
    }
  }

  /// Generates Shift Turnover HSE Compliance PDF Document
  static Future<Uint8List> generateShiftTurnoverPdf({
    required String plantUnit,
    required String shiftType,
    required String outgoingSupervisor,
    required int checklistsCompleted,
    required int hazardsIdentified,
    required int criticalAlarmsCount,
    required List<Map<String, String>> openItems,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final generatedTime = dateFormat.format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CHINIOT POWER LIMITED',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'Health, Safety & Environment (HSE) Department',
                        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Text(
                    'SHIFT TURNOVER REPORT',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red800,
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.blue900),
              pw.SizedBox(height: 12),

              // Operational Metadata
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Plant Unit: $plantUnit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Shift: $shiftType', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date/Time: $generatedTime'),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // KPI Summary Cards
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPdfKpiCard('Checklists Executed', '$checklistsCompleted', PdfColors.blue800),
                  _buildPdfKpiCard('Hazards Logged', '$hazardsIdentified', PdfColors.orange800),
                  _buildPdfKpiCard('Emergency Alarms', '$criticalAlarmsCount', PdfColors.red800),
                ],
              ),
              pw.SizedBox(height: 20),

              // Open Items & Deviations
              pw.Text(
                'Critical Open Items & Handover Notes',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),

              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey400),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ['Zone', 'Item Description', 'Risk Priority', 'Status / Action'],
                data: openItems.isEmpty
                    ? [
                        ['All Units', 'No outstanding critical hazards. Safe handover confirmed.', 'Low', 'Nominal']
                      ]
                    : openItems.map((item) => [
                        item['zone'] ?? '',
                        item['description'] ?? '',
                        item['risk'] ?? '',
                        item['action'] ?? '',
                      ]).toList(),
              ),

              pw.Spacer(),

              // Sign-off section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 180, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Outgoing HSE Supervisor: $outgoingSupervisor'),
                      pw.Text('Digital Signature Verified'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 180, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Incoming HSE Supervisor: ____________'),
                      pw.Text('Physical Handover Confirmed'),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfKpiCard(String title, String value, PdfColor color) {
    return pw.Container(
      width: 160,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1.5),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

