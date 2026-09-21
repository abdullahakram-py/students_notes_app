import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/utils/date_formatter.dart';
import '../models/note_model.dart';
import '../models/subject_model.dart';

enum PdfExportMode {
  computerized,
  handwritten,
}

/// Service generating academic study PDFs and managing print/share flows
class PdfExportService {
  static final PdfExportService _instance = PdfExportService._internal();
  factory PdfExportService() => _instance;
  PdfExportService._internal();

  /// Generates PDF document bytes based on selected mode
  Future<Uint8List> generateNotePdf({
    required Note note,
    required Subject subject,
    required PdfExportMode mode,
  }) async {
    final pdf = pw.Document();

    // Fonts for PDF
    final font = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();
    final fontItalic = await PdfGoogleFonts.poppinsItalic();

    // Subject Color
    final primaryPdfColor = PdfColor.fromInt(subject.colorValue);

    if (mode == PdfExportMode.computerized) {
      // Parse plain text or quill delta into structured blocks
      final paragraphs = _extractParagraphs(note);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          header: (context) => _buildHeader(note, subject, fontBold, font, primaryPdfColor),
          footer: (context) => _buildFooter(context, font),
          build: (context) {
            final widgets = <pw.Widget>[];

            // Metadata banner
            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFFFF8E1),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: const PdfColor.fromInt(0xFFFFE082)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Subject: ${subject.name}',
                      style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColors.brown900),
                    ),
                    pw.Text(
                      'Last Revised: ${DateFormatter.formatFullDate(note.updatedAt)}',
                      style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
            );

            // Note Body Content
            for (final p in paragraphs) {
              if (p.trim().isEmpty) {
                widgets.add(pw.SizedBox(height: 8));
              } else {
                widgets.add(
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Text(
                      p,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        lineSpacing: 1.5,
                        color: PdfColors.grey900,
                      ),
                    ),
                  ),
                );
              }
            }

            // Embedded Diagram if present
            if (note.diagramImagePath != null && File(note.diagramImagePath!).existsSync()) {
              widgets.add(pw.SizedBox(height: 16));
              widgets.add(
                pw.Text(
                  'Attached Diagram / Geometry Sketch:',
                  style: pw.TextStyle(font: fontBold, fontSize: 12, color: primaryPdfColor),
                ),
              );
              widgets.add(pw.SizedBox(height: 8));
              final imageBytes = File(note.diagramImagePath!).readAsBytesSync();
              final image = pw.MemoryImage(imageBytes);
              widgets.add(
                pw.Center(
                  child: pw.Container(
                    height: 200,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Image(image, fit: pw.BoxFit.contain),
                  ),
                ),
              );
            }

            return widgets;
          },
        ),
      );
    } else {
      // Handwritten / Diagram Canvas Format
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(note, subject, fontBold, font, primaryPdfColor),
                pw.SizedBox(height: 16),
                if (note.diagramImagePath != null && File(note.diagramImagePath!).existsSync()) ...[
                  pw.Expanded(
                    child: pw.Container(
                      width: double.infinity,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300, width: 1),
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Image(
                        pw.MemoryImage(File(note.diagramImagePath!).readAsBytesSync()),
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),
                ] else ...[
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Text(
                        'No diagram or handwriting canvas found for this note.',
                        style: pw.TextStyle(font: fontItalic, fontSize: 13, color: PdfColors.grey600),
                      ),
                    ),
                  ),
                ],
                pw.SizedBox(height: 12),
                _buildFooter(context, font),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  pw.Widget _buildHeader(
    Note note,
    Subject subject,
    pw.Font fontBold,
    pw.Font font,
    PdfColor primaryColor,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'STUDENT STUDY NOTES',
              style: pw.TextStyle(font: fontBold, fontSize: 9, color: primaryColor, letterSpacing: 1.5),
            ),
            pw.Text(
              'Academic v1.0',
              style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey500),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          note.title.isNotEmpty ? note.title : 'Untitled Note',
          style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.black),
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: primaryColor, thickness: 2),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generated with Student Notes App',
          style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500),
        ),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500),
        ),
      ],
    );
  }

  /// Extracts textual paragraphs from note's contentJson or plainText fallback
  List<String> _extractParagraphs(Note note) {
    if (note.plainText.isNotEmpty) {
      return note.plainText.split('\n');
    }
    try {
      final List<dynamic> deltas = jsonDecode(note.contentJson);
      final buffer = StringBuffer();
      for (final op in deltas) {
        if (op is Map && op.containsKey('insert')) {
          buffer.write(op['insert'].toString());
        }
      }
      return buffer.toString().split('\n');
    } catch (_) {
      return [note.plainText];
    }
  }

  /// Opens native print / preview sheet
  Future<void> previewOrPrintPdf({
    required Note note,
    required Subject subject,
    required PdfExportMode mode,
  }) async {
    final bytes = await generateNotePdf(note: note, subject: subject, mode: mode);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: '${note.title.replaceAll(RegExp(r'[^\w\s]+'), '')}_notes.pdf',
    );
  }

  /// Shares generated PDF file via system share dialog
  Future<void> shareNotePdf({
    required Note note,
    required Subject subject,
    required PdfExportMode mode,
  }) async {
    final bytes = await generateNotePdf(note: note, subject: subject, mode: mode);
    final fileName = '${note.title.replaceAll(RegExp(r'[^\w\s]+'), '_')}_notes.pdf';
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }
}
