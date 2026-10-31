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
import '../../Controller/home_controller.dart';
import '../../Model/home_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/helper.dart';
import '../../Routes/my_routes.dart';
import '../../Services/donation_receipt_service.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  final HomeController _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeController.clearAllDonationFilters();
      _homeController.fetchDonationHistory();
    });
  }

  Future<DateTime?> _pickDate({
    required BuildContext context,
    required DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final now = DateTime.now();
    final init = initialDate ?? now;
    return await showDatePicker(
      context: context,
      initialDate: init.isAfter(lastDate)
          ? lastDate
          : (init.isBefore(firstDate) ? firstDate : init),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryDeepBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<DateTimeRange?> _pickRange({
    required BuildContext context,
    DateTimeRange? initialRange,
  }) async {
    final now = DateTime.now();
    return await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryDeepBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _downloadTransactionsPdf() async {
    final transactions = _homeController.filteredDonationHistory;
    if (transactions.isEmpty) {
      showSnackBar("No donation history found for selected filter.", false);
      return;
    }

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
      } catch (_) {
        // Fallback to default fonts
      }

      final pdf = pw.Document(
        theme: font != null && fontBold != null
            ? pw.ThemeData.withFont(base: font, bold: fontBold)
            : null,
      );

      final totalDonations = transactions.fold<int>(0, (sum, item) => sum + (item.amount ?? 0));
      final campaignsSupported = transactions.map((e) => e.item).where((item) => item != null && item.isNotEmpty).toSet().length;

      final df = DateFormat('dd MMM yyyy');
      String periodSubtitle = "All Transactions";
      if (_homeController.donationStartDate.value != null && _homeController.donationEndDate.value != null) {
        periodSubtitle = "Period: ${df.format(_homeController.donationStartDate.value!)} to ${df.format(_homeController.donationEndDate.value!)}";
      } else if (_homeController.donationStartDate.value != null) {
        periodSubtitle = "From: ${df.format(_homeController.donationStartDate.value!)}";
      } else if (_homeController.donationEndDate.value != null) {
        periodSubtitle = "Up to: ${df.format(_homeController.donationEndDate.value!)}";
      }
      if (_homeController.selectedDonationType.value != 'All') {
        periodSubtitle += " | Type: ${_homeController.selectedDonationType.value}";
      }

      String cleanPdfText(String? input) {
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

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Divine Foundation",
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1A2E40'),
                      ),
                    ),
                    pw.Text(
                      "Donation History",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0066CC'),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      cleanPdfText(periodSubtitle),
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.Text(
                      "Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}",
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 10),
              ],
            );
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                "Page ${context.pageNumber} of ${context.pagesCount}",
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            );
          },
          build: (pw.Context context) => [
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F3F4F6'),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColor.fromHex('#E5E7EB')),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        "$campaignsSupported",
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text("Items Supported", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Container(height: 24, width: 1, color: PdfColors.grey400),
                  pw.Column(
                    children: [
                      pw.Text(
                        "Rs. ${formatPrice(totalDonations)}",
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0066CC')),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text("Total Donations", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E5E7EB'), width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 11),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#1A2E40')),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.centerLeft,
              headers: ['#', 'Date', 'Type', 'Campaign / Item', 'Donor', 'Status', 'Amount (Rs.)'],
              data: List.generate(transactions.length, (index) {
                final txn = transactions[index];
                String displayDate = txn.date ?? '';
                if (displayDate.length > 10) {
                  displayDate = displayDate.substring(0, 10);
                }
                return [
                  '${index + 1}',
                  cleanPdfText(displayDate),
                  txn.isDaan ? 'Daan' : 'Campaign',
                  cleanPdfText(txn.item),
                  cleanPdfText(txn.donor),
                  cleanPdfText(txn.status),
                  "Rs. ${formatPrice(txn.amount ?? 0)}",
                ];
              }),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();

      final fileName = 'Donation_History_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String savedFilePath = '';

      // Save PDF to public Downloads folder on Android/iOS
      if (Platform.isAndroid) {
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          final file = File('${downloadDir.path}/$fileName');
          await file.writeAsBytes(bytes);
          savedFilePath = file.path;
        } catch (e) {
          print("Error saving to Android Downloads folder: $e");
        }
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

      showSnackBar("PDF downloaded successfully!", true);

      // Open device native file/PDF sharing or open-with app chooser dialog
      if (savedFilePath.isNotEmpty) {
        bool openedNativeChooser = false;

        try {
          await Share.shareXFiles(
            [XFile(savedFilePath, mimeType: 'application/pdf')],
            subject: 'Donation History PDF',
          );
          openedNativeChooser = true;
        } catch (_) {}

        if (!openedNativeChooser) {
          try {
            await Printing.sharePdf(
              bytes: bytes,
              filename: fileName,
            );
            openedNativeChooser = true;
          } catch (_) {}
        }

        if (!openedNativeChooser) {
          try {
            await OpenFilex.open(savedFilePath);
          } catch (_) {}
        }
      } else {
        try {
          await Share.shareXFiles(
            [XFile.fromData(bytes, name: fileName, mimeType: 'application/pdf')],
            subject: 'Donation History PDF',
          );
        } catch (_) {}
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      print("Error generating PDF: ${e.toString()}");
      showSnackBar("Failed to generate PDF statement: ${e.toString()}", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(AppString.donationHistory.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.black),
            onPressed: _downloadTransactionsPdf,
            tooltip: "Download PDF",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (_homeController.isDonationHistoryLoading.value) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
        }

        final history = _homeController.filteredDonationHistory;
        final totalDonations = history.fold<int>(0, (sum, item) => sum + (item.amount ?? 0));
        final campaignsSupported = history.map((e) => e.item).where((item) => item != null && item.isNotEmpty).toSet().length;

        return RefreshIndicator(
          onRefresh: () => _homeController.fetchDonationHistory(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchAndFilterRow(context, _homeController),
                  _buildActiveFiltersBar(_homeController),
                  const SizedBox(height: 8),
                  _buildTotalDonationSummary(campaignsSupported, totalDonations),
                  const SizedBox(height: 20),
                  if (history.isEmpty)
                    Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 44, color: AppTheme.textGrey400),
                          const SizedBox(height: 10),
                          Text(
                            "No donation history found",
                            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500),
                          ),
                          if (_homeController.hasActiveDonationFilters) ...[
                            const SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: () => _homeController.clearAllDonationFilters(),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text("Reset Filters"),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryDeepBlue,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final txn = history[index];
                        return _buildHistoryItem(txn);
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSearchAndFilterRow(BuildContext context, HomeController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: _buildSearchBar(controller),
          ),
          const SizedBox(width: 8),
          _buildFilterButton(context, controller),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, HomeController controller) {
    return Obx(() {
      final hasActiveFilter = controller.selectedDonationType.value != 'All' ||
          controller.donationStartDate.value != null ||
          controller.donationEndDate.value != null;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFilterBottomSheet(context, controller),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: hasActiveFilter
                  ? AppTheme.primaryDeepBlue
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasActiveFilter
                    ? AppTheme.primaryDeepBlue
                    : AppTheme.fieldBorderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: hasActiveFilter ? Colors.white : AppTheme.primaryDeepBlue,
                ),
                // const SizedBox(width: 6),
                // Text(
                //   "Filter",
                //   style: TextStyle(
                //     fontSize: 13,
                //     fontWeight: FontWeight.w600,
                //     color: hasActiveFilter ? Colors.white : Colors.black87,
                //   ),
                // ),
                if (hasActiveFilter) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildActiveFiltersBar(HomeController controller) {
    final df = DateFormat('dd MMM');
    return Obx(() {
      final type = controller.selectedDonationType.value;
      final start = controller.donationStartDate.value;
      final end = controller.donationEndDate.value;
      final hasType = type != 'All';
      final hasDate = start != null || end != null;

      if (!hasType && !hasDate) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (hasType)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(
                    label: Text(
                      type,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                    backgroundColor: const Color(0xFFDBEAFE),
                    deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF1E40AF)),
                    onDeleted: () => controller.selectedDonationType.value = 'All',
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              if (hasDate)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(
                    label: Text(
                      start != null && end != null
                          ? "${df.format(start)} - ${df.format(end)}"
                          : (start != null ? "From ${df.format(start)}" : "To ${df.format(end!)}"),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                    backgroundColor: const Color(0xFFDBEAFE),
                    deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF1E40AF)),
                    onDeleted: () => controller.clearDonationDateRange(),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              InkWell(
                onTap: () => controller.clearAllDonationFilters(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    "Clear all",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showFilterBottomSheet(BuildContext context, HomeController controller) {
    String tempType = controller.selectedDonationType.value;
    DateTime? tempStart = controller.donationStartDate.value;
    DateTime? tempEnd = controller.donationEndDate.value;
    final df = DateFormat('dd MMM yyyy');

    final types = [
      {'label': 'All Types', 'value': 'All', 'icon': Icons.tune_rounded},
      {'label': 'Campaigns', 'value': 'Campaign', 'icon': Icons.campaign_outlined},
      {'label': 'Daan', 'value': 'Daan', 'icon': Icons.volunteer_activism_outlined},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final hasDateSelected = tempStart != null || tempEnd != null;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 6),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.tune_rounded, size: 20, color: AppTheme.primaryDeepBlue),
                                const SizedBox(width: 8),
                                Text(
                                  "Filter Donations",
                                  style: AppFonts.titleStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20, color: Colors.black54),
                              onPressed: () => Navigator.pop(bottomSheetContext),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 0.6),

                      // Scrollable Filters Body
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Type Filter Section
                              Text(
                                "FILTER BY TYPE",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: AppTheme.textGrey500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: types.map((item) {
                                  final val = item['value'] as String;
                                  final label = item['label'] as String;
                                  final icon = item['icon'] as IconData;
                                  final isSelected = tempType == val;

                                  return InkWell(
                                    onTap: () {
                                      setModalState(() {
                                        tempType = val;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryDeepBlue
                                            : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primaryDeepBlue
                                              : const Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            icon,
                                            size: 15,
                                            color: isSelected ? Colors.white : const Color(0xFF4B5563),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isSelected ? Colors.white : const Color(0xFF374151),
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 22),

                              // 2. Date Range Section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "FILTER BY DATE",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      color: AppTheme.textGrey500,
                                    ),
                                  ),
                                  if (hasDateSelected)
                                    InkWell(
                                      onTap: () {
                                        setModalState(() {
                                          tempStart = null;
                                          tempEnd = null;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        child: Text(
                                          "Clear Date",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.redTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Quick Preset Chips (This Month, Last 30 Days, This Year)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildDatePresetChip(
                                      label: "This Month",
                                      onTap: () {
                                        final now = DateTime.now();
                                        setModalState(() {
                                          tempStart = DateTime(now.year, now.month, 1);
                                          tempEnd = now;
                                        });
                                      },
                                      isSelected: _isThisMonth(tempStart, tempEnd),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildDatePresetChip(
                                      label: "Last 30 Days",
                                      onTap: () {
                                        final now = DateTime.now();
                                        setModalState(() {
                                          tempStart = now.subtract(const Duration(days: 30));
                                          tempEnd = now;
                                        });
                                      },
                                      isSelected: _isLast30Days(tempStart, tempEnd),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildDatePresetChip(
                                      label: "This Year",
                                      onTap: () {
                                        final now = DateTime.now();
                                        setModalState(() {
                                          tempStart = DateTime(now.year, 1, 1);
                                          tempEnd = now;
                                        });
                                      },
                                      isSelected: _isThisYear(tempStart, tempEnd),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Date Selection Boxes (From & To)
                              Row(
                                children: [
                                  // FROM
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final picked = await _pickDate(
                                          context: context,
                                          initialDate: tempStart ?? tempEnd,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now(),
                                        );
                                        if (picked != null) {
                                          setModalState(() {
                                            tempStart = picked;
                                            if (tempEnd != null && picked.isAfter(tempEnd!)) {
                                              tempEnd = picked;
                                            }
                                          });
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: tempStart != null
                                              ? AppTheme.primaryDeepBlue.withValues(alpha: 0.05)
                                              : const Color(0xFFF9FAFB),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: tempStart != null
                                                ? AppTheme.primaryDeepBlue
                                                : AppTheme.fieldBorderColor,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "FROM",
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: AppTheme.textGrey400,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 13,
                                                  color: tempStart != null
                                                      ? AppTheme.primaryDeepBlue
                                                      : AppTheme.textGrey400,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    tempStart != null ? df.format(tempStart!) : "Start Date",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: tempStart != null ? Colors.black87 : AppTheme.textGrey400,
                                                      fontWeight: tempStart != null ? FontWeight.w600 : FontWeight.normal,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.textGrey400),
                                  ),
                                  // TO
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final picked = await _pickDate(
                                          context: context,
                                          initialDate: tempEnd ?? (tempStart ?? DateTime.now()),
                                          firstDate: tempStart ?? DateTime(2020),
                                          lastDate: DateTime.now(),
                                        );
                                        if (picked != null) {
                                          setModalState(() {
                                            tempEnd = picked;
                                          });
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: tempEnd != null
                                              ? AppTheme.primaryDeepBlue.withValues(alpha: 0.05)
                                              : const Color(0xFFF9FAFB),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: tempEnd != null
                                                ? AppTheme.primaryDeepBlue
                                                : AppTheme.fieldBorderColor,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "TO",
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: AppTheme.textGrey400,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 13,
                                                  color: tempEnd != null
                                                      ? AppTheme.primaryDeepBlue
                                                      : AppTheme.textGrey400,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    tempEnd != null ? df.format(tempEnd!) : "End Date",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: tempEnd != null ? Colors.black87 : AppTheme.textGrey400,
                                                      fontWeight: tempEnd != null ? FontWeight.w600 : FontWeight.normal,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Date Range Picker dialog quick trigger
                              Center(
                                child: TextButton.icon(
                                  onPressed: () async {
                                    final picked = await _pickRange(
                                      context: context,
                                      initialRange: (tempStart != null && tempEnd != null)
                                          ? DateTimeRange(start: tempStart!, end: tempEnd!)
                                          : null,
                                    );
                                    if (picked != null) {
                                      setModalState(() {
                                        tempStart = picked.start;
                                        tempEnd = picked.end;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.date_range_rounded, size: 16, color: AppTheme.primaryDeepBlue),
                                  label: Text(
                                    "Pick Range From Calendar",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryDeepBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(height: 1, thickness: 0.6),

                      // Bottom Sticky Action Buttons
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        child: Row(
                          children: [
                            // Clear All Button
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: () {
                                  controller.clearAllDonationFilters();
                                  Navigator.pop(bottomSheetContext);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppTheme.fieldBorderColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                ),
                                child: Text(
                                  "Clear All",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textGrey500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Apply Filter Button
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.selectedDonationType.value = tempType;
                                  controller.setDonationDateRange(tempStart, tempEnd);
                                  Navigator.pop(bottomSheetContext);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryDeepBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Apply Filter",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _isThisMonth(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    return start.year == now.year &&
        start.month == now.month &&
        start.day == 1 &&
        end.year == now.year &&
        end.month == now.month &&
        end.day == now.day;
  }

  bool _isLast30Days(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    final expectedStart = now.subtract(const Duration(days: 30));
    return start.year == expectedStart.year &&
        start.month == expectedStart.month &&
        start.day == expectedStart.day &&
        end.year == now.year &&
        end.month == now.month &&
        end.day == now.day;
  }

  bool _isThisYear(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    return start.year == now.year &&
        start.month == 1 &&
        start.day == 1 &&
        end.year == now.year &&
        end.month == now.month &&
        end.day == now.day;
  }

  Widget _buildDatePresetChip({
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryDeepBlue.withValues(alpha: 0.12)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryDeepBlue
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.primaryDeepBlue : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(HomeController controller) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Colors.grey, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (val) {
                controller.donationSearchQuery.value = val;
              },
              decoration: InputDecoration(
                hintText: AppString.searchForCampaigns.tr,
                hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Obx(() {
            if (controller.donationSearchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                onPressed: () {
                  controller.donationSearchQuery.value = '';
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildTotalDonationSummary(int campaigns, int totalAmount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$campaigns", style: AppFonts.titleStyle.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text("Items Supported", style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500)),
            ],
          ),
          Container(height: 30, width: 1, color: AppTheme.fieldBorderColor),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₹${formatPrice(totalAmount)}", style: AppFonts.titleStyle.copyWith(fontSize: 16, color: AppTheme.primaryDeepBlue)),
              const SizedBox(height: 4),
              Text(AppString.totalDonations.tr, style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(HomeDonationHistory txn) {
    final title = txn.item ?? 'Donation';
    final subtitle = txn.donor != null ? 'by ${txn.donor}' : (txn.status ?? '');
    final isDaan = txn.isDaan;
    final isNgo = txn.isNgo;
    final typeLabel = isDaan ? 'Daan' : (isNgo ? 'NGO' : 'Campaign');

    String displayDate = txn.date ?? '';
    if (txn.parsedDate != null) {
      displayDate = DateFormat('dd MMM yyyy').format(txn.parsedDate!);
    } else if (displayDate.length > 10) {
      displayDate = displayDate.substring(0, 10);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.fieldBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Get.toNamed(MyRouters.donationDetailsScreen, arguments: txn),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDaan
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                            : (isNgo
                                ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                                : AppTheme.primaryDeepBlue.withValues(alpha: 0.1)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isDaan
                              ? Icons.volunteer_activism_rounded
                              : (isNgo ? Icons.corporate_fare_rounded : Icons.campaign_rounded),
                          color: isDaan
                              ? const Color(0xFFD97706)
                              : (isNgo ? const Color(0xFF7C3AED) : AppTheme.primaryDeepBlue),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: AppFonts.mediumText.copyWith(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDaan
                                      ? const Color(0xFFFEF3C7)
                                      : (isNgo
                                          ? const Color(0xFFEDE9FE)
                                          : const Color(0xFFE0F2FE)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  typeLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDaan
                                        ? const Color(0xFFB45309)
                                        : (isNgo
                                            ? const Color(0xFF6D28D9)
                                            : const Color(0xFF0369A1)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${formatPrice(txn.amount ?? 0)}",
                          style: AppFonts.semiBoldText.copyWith(fontSize: 15, color: AppTheme.progressGreen),
                        ),
                        const SizedBox(height: 2),
                        Text(displayDate, style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey400)),
                      ],
                    ),
                  ],
                ),
                // const SizedBox(height: 8),
                // const Divider(height: 1, thickness: 0.6),
                // const SizedBox(height: 6),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Row(
                //       children: [
                //         Icon(Icons.check_circle_outline, size: 13, color: AppTheme.progressGreen),
                //         const SizedBox(width: 4),
                //         Text(
                //           txn.status ?? 'Success',
                //           style: TextStyle(fontSize: 11, color: AppTheme.progressGreen, fontWeight: FontWeight.w500),
                //         ),
                //       ],
                //     ),
                //     InkWell(
                //       borderRadius: BorderRadius.circular(6),
                //       onTap: () => DonationReceiptService.downloadReceipt(txn),
                //       child: Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                //         child: Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Icon(Icons.download_rounded, size: 14, color: AppTheme.primaryDeepBlue),
                //             const SizedBox(width: 4),
                //             Text(
                //               "Download Receipt",
                //               style: TextStyle(
                //                 fontSize: 11,
                //                 color: AppTheme.primaryDeepBlue,
                //                 fontWeight: FontWeight.w600,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
