import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../Model/home_model.dart';
import '../Utilities/app_theme.dart';
import '../Utilities/helper.dart';

class DonationReceiptService {
  static String _cleanPdfText(String? input) {
    if (input == null || input.isEmpty) return '-';
    String text = input
        .replaceAll('₹', 'Rs. ')
        .replaceAll('INR', 'Rs. ')
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    StringBuffer clean = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      int code = text.codeUnitAt(i);
      if (code >= 32 && code <= 126) {
        clean.writeCharCode(code);
      } else {
        clean.write(' ');
      }
    }
    String res = clean.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    return res.isEmpty ? '-' : res;
  }

  static Future<void> downloadReceipt(
    HomeDonationHistory txn, {
    bool shareDirectly = false,
  }) async {
    try {
      Get.dialog(
        Center(
          child: LoadingAnimationWidget.threeRotatingDots(
            color: AppTheme.primaryDeepBlue,
            size: 50,
          ),
        ),
        barrierDismissible: false,
      );

      pw.Font? font;
      pw.Font? fontBold;
      try {
        font = await PdfGoogleFonts.robotoRegular();
        fontBold = await PdfGoogleFonts.robotoBold();
      } catch (_) {}

      final pdf = pw.Document(
        theme: font != null && fontBold != null
            ? pw.ThemeData.withFont(base: font, bold: fontBold)
            : null,
      );

      final dfDate = DateFormat('dd MMM yyyy');
      final dfDateTime = DateFormat('dd MMM yyyy, hh:mm a');

      String formattedDate = '-';
      if (txn.parsedDate != null) {
        formattedDate = dfDateTime.format(txn.parsedDate!);
      } else if (txn.date != null && txn.date!.isNotEmpty) {
        formattedDate = txn.date!;
      }

      final receiptNo = txn.transactionId != null && txn.transactionId!.isNotEmpty
          ? txn.transactionId!
          : 'DIVINE-${DateTime.now().millisecondsSinceEpoch}';

      final amount = txn.amount ?? 0;
      final donorName = txn.donor != null && txn.donor!.isNotEmpty
          ? txn.donor!
          : (txn.user != null && txn.user!.isNotEmpty ? txn.user! : 'Valued Donor');
      final cause = txn.item ?? 'Divine Foundation Noble Cause';
      final typeLabel = txn.isDaan
          ? 'Daan / Seva Contribution'
          : (txn.isNgo ? 'Direct NGO Donation' : 'Campaign Donation');
      final statusLabel = txn.status ?? 'Success';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Top Header Row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "DIVINE FOUNDATION",
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1A2E40'),
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          "Empowering Lives & Transforming Communities",
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          "Registered Non-Profit Trust | 80G Tax Exempt",
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#0066CC'),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Text(
                        "DONATION RECEIPT",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),
                pw.Divider(thickness: 1, color: PdfColor.fromHex('#CBD5E1')),
                pw.SizedBox(height: 14),

                // Receipt Metadata Box
                pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F8FAFC'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 1),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Receipt / Transaction ID",
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            _cleanPdfText(receiptNo),
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#1E293B'),
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Transaction Date",
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            _cleanPdfText(formattedDate),
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#1E293B'),
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            "Payment Status",
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#DCFCE7'),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                            ),
                            child: pw.Text(
                              _cleanPdfText(statusLabel),
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#15803D'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Donor & Contribution Table
                pw.Text(
                  "Contribution Details",
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1E293B'),
                  ),
                ),
                pw.SizedBox(height: 8),

                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex('#E2E8F0'),
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2.5),
                    1: const pw.FlexColumnWidth(4.5),
                  },
                  children: [
                    _buildTableRow("Donor Name", _cleanPdfText(donorName), isOdd: false),
                    _buildTableRow("Item / Cause Supported", _cleanPdfText(cause), isOdd: true),
                    _buildTableRow("Donation Type", _cleanPdfText(typeLabel), isOdd: false),
                    if (txn.fundCategory != null && txn.fundCategory!.isNotEmpty)
                      _buildTableRow("Category", _cleanPdfText(txn.fundCategory), isOdd: true),
                    _buildTableRow("Payment Mode", "Online / Razorpay", isOdd: txn.fundCategory != null && txn.fundCategory!.isNotEmpty ? false : true),
                  ],
                ),

                pw.SizedBox(height: 18),

                // Amount Highlight Box
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F0FDF4'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColor.fromHex('#86EFAC'), width: 1),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "Total Amount Donated",
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#166534'),
                        ),
                      ),
                      pw.Text(
                        "Rs. ${formatPrice(amount)}",
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#15803D'),
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // 80G Tax Exemption Note
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#EFF6FF'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColor.fromHex('#BFDBFE'), width: 1),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Tax Exemption Benefit (Section 80G)",
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#1E40AF'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Donations made to Divine Foundation are eligible for tax deduction under Section 80G of the Income Tax Act, 1961. Please retain this receipt for claiming tax deductions while filing income tax returns.",
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey700,
                          lineSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Signatory Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Thank you for your generous support!",
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1A2E40'),
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          "Your contribution makes a meaningful difference.",
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(
                          width: 140,
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 1)),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              "Divine Foundation",
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#0066CC'),
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          "Authorized Signatory",
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),
                pw.Divider(thickness: 0.5, color: PdfColor.fromHex('#E2E8F0')),
                pw.SizedBox(height: 4),

                // Footer Note
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "This is a digitally generated donation receipt and does not require a physical signature.",
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                    ),
                    pw.Text(
                      "Generated: ${dfDate.format(DateTime.now())}",
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final cleanReceiptId = receiptNo.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final fileName = 'Donation_Receipt_${cleanReceiptId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String savedFilePath = '';

      if (Platform.isAndroid) {
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          final file = File('${downloadDir.path}/$fileName');
          await file.writeAsBytes(bytes);
          savedFilePath = file.path;
        } catch (_) {}
      }

      if (savedFilePath.isEmpty) {
        try {
          final dir = await getDownloadsDirectory();
          if (dir != null) {
            final file = File('${dir.path}/$fileName');
            await file.writeAsBytes(bytes);
            savedFilePath = file.path;
          }
        } catch (_) {}
      }

      if (savedFilePath.isEmpty) {
        try {
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/$fileName');
          await file.writeAsBytes(bytes);
          savedFilePath = file.path;
        } catch (_) {}
      }

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      showSnackBar("Donation receipt downloaded successfully!", true);

      // Handle share / open
      if (savedFilePath.isNotEmpty) {
        bool handled = false;
        try {
          await Share.shareXFiles(
            [XFile(savedFilePath, mimeType: 'application/pdf')],
            subject: 'Donation Receipt - $receiptNo',
          );
          handled = true;
        } catch (_) {}

        if (!handled) {
          try {
            await Printing.sharePdf(bytes: bytes, filename: fileName);
            handled = true;
          } catch (_) {}
        }

        if (!handled) {
          try {
            await OpenFilex.open(savedFilePath);
          } catch (_) {}
        }
      } else {
        try {
          await Share.shareXFiles(
            [XFile.fromData(bytes, name: fileName, mimeType: 'application/pdf')],
            subject: 'Donation Receipt - $receiptNo',
          );
        } catch (_) {}
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      showSnackBar("Failed to download receipt: ${e.toString()}", false);
    }
  }

  static pw.TableRow _buildTableRow(String title, String value, {required bool isOdd}) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: isOdd ? PdfColor.fromHex('#F8FAFC') : PdfColors.white,
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#475569'),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromHex('#1E293B'),
            ),
          ),
        ),
      ],
    );
  }
}
