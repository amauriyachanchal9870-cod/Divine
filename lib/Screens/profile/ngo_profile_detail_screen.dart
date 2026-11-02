import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/profile_controller.dart';
import '../../Controller/home_controller.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Routes/my_routes.dart';
import '../../Model/profile_model.dart';
import '../../Model/review_model.dart';
import '../../Utilities/helper.dart';

class NgoProfileDetailScreen extends StatefulWidget {
  const NgoProfileDetailScreen({super.key});

  @override
  State<NgoProfileDetailScreen> createState() => _NgoProfileDetailScreenState();
}

class _NgoProfileDetailScreenState extends State<NgoProfileDetailScreen> {
  late final ProfileController profileController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ProfileController>()) {
      profileController = Get.find<ProfileController>();
    } else {
      profileController = Get.put(ProfileController());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchProfile(context, forceRefresh: true);
    });
  }

  void _openDocumentPreview(BuildContext context, String title, String url) {
    if (url.trim().isEmpty) return;
    final bool isPdf = url.toLowerCase().contains('.pdf');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isPdf ? const Color(0xFFFFEBEE) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isPdf ? Icons.picture_as_pdf_outlined : Icons.description_outlined,
                            size: 18,
                            color: isPdf ? const Color(0xFFD32F2F) : AppTheme.primaryDeepBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: url,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (c, u) => Center(
                    child: LoadingAnimationWidget.threeRotatingDots(
                      color: AppTheme.primaryDeepBlue,
                      size: 32,
                    ),
                  ),
                  errorWidget: (c, u, e) => Container(
                    height: 180,
                    width: double.infinity,
                    color: const Color(0xFFF8FAFC),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPdf ? Icons.picture_as_pdf_outlined : Icons.description_outlined,
                            color: isPdf ? const Color(0xFFD32F2F) : Colors.blueGrey,
                            size: 48,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isPdf ? "PDF Document Attached" : "Document Attached",
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              url,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 18),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton.icon(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppTheme.primaryDeepBlue,
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              //       padding: const EdgeInsets.symmetric(vertical: 12),
              //       elevation: 0,
              //     ),
              //     onPressed: () {
              //       Clipboard.setData(ClipboardData(text: url));
              //       Navigator.pop(ctx);
              //       showSnackBar("Document link copied to clipboard", true);
              //     },
              //     icon: const Icon(Icons.copy, size: 16, color: Colors.white),
              //     label: Text("Copy Document Link", style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  String _cleanRegistrationType(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    String text = raw.trim();
    if (text.toLowerCase().startsWith('yes - as a ')) {
      text = text.substring(11).trim();
    } else if (text.toLowerCase().startsWith('yes - ')) {
      text = text.substring(6).trim();
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final p = profileController.profileData.value;
          final userRole = (p?.role ?? (Get.isRegistered<HomeController>() ? Get.find<HomeController>().user?.role : "") ?? "").toLowerCase();
          final bool isCorporate = userRole == 'corporate' || p?.organizationType?.toLowerCase() == 'corporate';
          return Text(
            isCorporate ? "Corporate Profile" : "NGO Profile",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
          );
        }),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDeepBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () async {
                await Get.toNamed(MyRouters.editProfileScreen);
                if (!context.mounted) return;
                profileController.fetchProfile(context, forceRefresh: true);
              },
              icon: const Icon(Icons.edit_outlined, size: 15, color: Colors.white),
              label: Text(
                AppString.editProfile.tr,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final p = profileController.profileData.value;
        final isLoading = profileController.isLoading.value;

        if (isLoading && p == null) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
        }

        if (p == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "Failed to load profile details.",
                  style: AppFonts.mediumText.copyWith(color: AppTheme.textGrey500),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDeepBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => profileController.fetchProfile(context, forceRefresh: true),
                  child: const Text("Retry", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        final userRole = (p.role ?? (Get.isRegistered<HomeController>() ? Get.find<HomeController>().user?.role : "") ?? "").toLowerCase();
        final bool isCorporate = userRole == 'corporate' || p.organizationType?.toLowerCase() == 'corporate';

        return RefreshIndicator(
          onRefresh: () async {
            await profileController.fetchProfile(context, forceRefresh: true);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =============================================================
                // FIELD 4 FIRST: Logo of your Organization & Hero Identity Card
                // =============================================================
                _buildField4LogoFirst(p, isCorporate: isCorporate),
                const SizedBox(height: 24),

                if (isCorporate) ...[
                  ..._buildCorporateFields(p),
                ] else ...[
                  ..._buildNgoFields(p),
                ],

                const SizedBox(height: 14),

                // =============================================================
                // RATINGS & REVIEWS SECTION
                // =============================================================
                // _buildReviewsSection(p),
                // const SizedBox(height: 32),

                // =============================================================
                // EDIT PROFILE BOTTOM ACTION BUTTON
                // =============================================================
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Get.toNamed(MyRouters.editProfileScreen);
                      if (!context.mounted) return;
                      profileController.fetchProfile(context, forceRefresh: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDeepBlue,
                      elevation: 2,
                      shadowColor: AppTheme.primaryDeepBlue.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
                    label: Text(
                      AppString.editProfile.tr,
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }


  // ===========================================================================
  // FIELD 4: Logo of your Organization (SHOWN FIRST - HERO CARD)
  // ===========================================================================
  Widget _buildField4LogoFirst(ProfileData p, {bool isCorporate = false}) {
    final logoUrl = (p.logo != null && p.logo!.trim().isNotEmpty)
        ? p.logo!.trim()
        : (p.profilePhoto != null ? p.profilePhoto!.trim() : '');
    final orgName = (p.organizationName != null && p.organizationName!.trim().isNotEmpty)
        ? p.organizationName!.trim()
        : ((p.legalName != null && p.legalName!.trim().isNotEmpty)
            ? p.legalName!.trim()
            : (p.name ?? (isCorporate ? "Corporate Organization" : "NGO Organization")));

    final orgType = _cleanRegistrationType(isCorporate ? (p.isRegisteredCompany ?? p.isRegisteredNonProfit ?? p.organizationType) : (p.isRegisteredNonProfit ?? p.organizationType));
    final email = p.email ?? '';
    final phone = p.phone ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDeepBlue,
            const Color(0xFF1E3A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDeepBlue.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle background decorative pattern circle
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top header label row
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       "Logo of your Organization",
                //       style: GoogleFonts.poppins(
                //         fontSize: 12,
                //         fontWeight: FontWeight.w500,
                //         color: Colors.white.withValues(alpha: 0.8),
                //       ),
                //     ),
                //     Container(
                //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                //       decoration: BoxDecoration(
                //         color: const Color(0xFF10B981).withValues(alpha: 0.2),
                //         borderRadius: BorderRadius.circular(20),
                //         border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                //       ),
                //       child: Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           const Icon(Icons.verified, size: 13, color: Color(0xFF34D399)),
                //           const SizedBox(width: 4),
                //           Text(
                //             "Verified Non-Profit",
                //             style: GoogleFonts.poppins(
                //               fontSize: 11,
                //               fontWeight: FontWeight.w600,
                //               color: const Color(0xFF34D399),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 20),

                // Logo Avatar with double ring
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        width: 92,
                        height: 92,
                        color: const Color(0xFFF1F5F9),
                        child: logoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                key: ValueKey(logoUrl),
                                imageUrl: logoUrl,
                                width: 92,
                                height: 92,
                                fit: BoxFit.cover,
                                placeholder: (c, u) => const ShimmerWidget(
                                  width: 92,
                                  height: 92,
                                  borderRadius: BorderRadius.all(Radius.circular(46)),
                                ),
                                errorWidget: (c, u, e) => Image.asset(AppAssets.appLogo, width: 92, height: 92, fit: BoxFit.cover),
                              )
                            : Image.asset(AppAssets.appLogo, width: 92, height: 92, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Organization Name
                Text(
                  orgName,
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // if (orgType.isNotEmpty) ...[
                //   const SizedBox(height: 6),
                //   Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                //     decoration: BoxDecoration(
                //       color: Colors.white.withValues(alpha: 0.15),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: Text(
                //       orgType,
                //       style: GoogleFonts.poppins(
                //         fontSize: 12,
                //         fontWeight: FontWeight.w500,
                //         color: Colors.white.withValues(alpha: 0.95),
                //       ),
                //     ),
                //   ),
                // ],

                // Quick info pills (Email / Phone)
                if (email.isNotEmpty || phone.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (email.isNotEmpty)
                        _buildHeroMetaPill(Icons.mail_outline_rounded, email),
                      if (phone.isNotEmpty)
                        _buildHeroMetaPill(Icons.phone_outlined, formatPhoneWithCountryCode(phone)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetaPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.8)),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // NGO FIELDS ORDER (FIELDS 1, 2, 3, 5-25)
  // ===========================================================================
  List<Widget> _buildNgoFields(ProfileData p) {
    return [
      _buildField1(p),
      const SizedBox(height: 14),
      _buildField2(p),
      const SizedBox(height: 14),
      _buildField3(p),
      const SizedBox(height: 24),
      _buildField5(p),
      const SizedBox(height: 14),
      _buildField6(p),
      const SizedBox(height: 14),
      _buildField7(p),
      const SizedBox(height: 24),
      _buildField8(p),
      const SizedBox(height: 14),
      _buildField9(p),
      const SizedBox(height: 14),
      _buildField10(p),
      const SizedBox(height: 24),
      _buildField11(p),
      const SizedBox(height: 14),
      _buildField12(p),
      const SizedBox(height: 14),
      _buildField13(p),
      const SizedBox(height: 14),
      _buildField14(p),
      const SizedBox(height: 14),
      _buildField15(p),
      const SizedBox(height: 14),
      _buildField16(p),
      const SizedBox(height: 24),
      _buildField17(p),
      const SizedBox(height: 14),
      _buildField18(p),
      const SizedBox(height: 14),
      _buildField19(p),
      const SizedBox(height: 14),
      _buildField20(p),
      const SizedBox(height: 24),
      _buildField21(p),
      const SizedBox(height: 14),
      _buildField22(p),
      const SizedBox(height: 14),
      _buildField23(p),
      const SizedBox(height: 14),
      _buildField24(p),
      const SizedBox(height: 24),
      _buildField25(p),
    ];
  }

  // ===========================================================================
  // CORPORATE FIELDS ORDER (FIELDS 1-3, 5-21 ACCORDING TO CORPORATE PDF)
  // ===========================================================================
  List<Widget> _buildCorporateFields(ProfileData p) {
    return [
      _buildCorporateField1(p),
      const SizedBox(height: 14),
      _buildCorporateField2(p),
      const SizedBox(height: 14),
      _buildCorporateField3(p),
      const SizedBox(height: 24),
      _buildCorporateField5(p),
      const SizedBox(height: 14),
      _buildCorporateField6(p),
      const SizedBox(height: 14),
      _buildCorporateField7(p),
      const SizedBox(height: 14),
      _buildCorporateField8(p),
      const SizedBox(height: 24),
      _buildCorporateField9(p),
      const SizedBox(height: 14),
      _buildCorporateField10(p),
      const SizedBox(height: 14),
      _buildCorporateField11(p),
      const SizedBox(height: 14),
      _buildCorporateField12(p),
      const SizedBox(height: 24),
      _buildCorporateField13(p),
      const SizedBox(height: 14),
      _buildCorporateField14(p),
      const SizedBox(height: 14),
      _buildCorporateField15(p),
      const SizedBox(height: 14),
      _buildCorporateField16(p),
      const SizedBox(height: 24),
      _buildCorporateField17(p),
      const SizedBox(height: 14),
      _buildCorporateField18(p),
      const SizedBox(height: 14),
      _buildCorporateField19(p),
      const SizedBox(height: 24),
      _buildCorporateField20(p),
      const SizedBox(height: 24),
      _buildCorporateField21(p),
    ];
  }

  // ===========================================================================
  // CORPORATE FIELD BUILDERS (FIELDS 1, 2, 3, 5-21)
  // ===========================================================================
  Widget _buildCorporateField1(ProfileData p) {
    final value = p.isRegisteredCompany ?? p.isRegisteredNonProfit ?? p.organizationType ?? '';
    final clean = _cleanRegistrationType(value);

    return _buildCard(
      title: "Is your organization a registered Company?",
      icon: Icons.apartment_rounded,
      iconColor: const Color(0xFF2563EB),
      child: value.isNotEmpty
          ? Row(
              children: [
                _buildYesNoBadge(true),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      clean.isNotEmpty ? clean : value,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : _buildEmptyValue(),
    );
  }

  Widget _buildCorporateField2(ProfileData p) {
    final name = p.legalName ?? p.organizationName ?? p.name ?? '';
    return _buildCard(
      title: "Legal Name of your Organization",
      icon: Icons.gavel_rounded,
      iconColor: const Color(0xFF0F766E),
      child: name.isNotEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            )
          : _buildEmptyValue(),
    );
  }

  Widget _buildCorporateField3(ProfileData p) {
    final address = p.registeredAddress ?? '';
    final docUrl = p.addressCertificate;

    return _buildCard(
      title: "Registered Address of your Organization",
      icon: Icons.location_on_outlined,
      iconColor: const Color(0xFFEA580C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              address.isNotEmpty ? address : "Not Provided",
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: address.isNotEmpty ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                fontStyle: address.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildDocumentCard(
            "Registration Certificate / Certificate of Incorporation / LLPIN",
            docUrl,
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateField5(ProfileData p) {
    final dynamic moa = p.moaAoaDocuments;
    List<String> docs = [];
    if (moa is List) {
      docs = moa.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    } else if (moa is String && moa.trim().isNotEmpty) {
      docs = [moa.trim()];
    }

    return _buildCard(
      title: "MOA & AOA / LLP Agreement/ Partnership Deed",
      icon: Icons.description_outlined,
      iconColor: const Color(0xFF7C3AED),
      child: docs.isNotEmpty
          ? Column(
              children: docs.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildDocumentCard(
                    "Constitutional Document ${docs.length > 1 ? '#${e.key + 1}' : ''}".trim(),
                    e.value,
                  ),
                );
              }).toList(),
            )
          : _buildEmptyValue("No statutory documents uploaded"),
    );
  }

  Widget _buildCorporateField6(ProfileData p) {
    return _buildCopyableField(
      label: "PAN",
      value: p.panNumber,
      docTitle: "PAN Document",
      docUrl: p.panImage,
      icon: Icons.badge_outlined,
      iconColor: const Color(0xFF2563EB),
    );
  }

  Widget _buildCorporateField7(ProfileData p) {
    return _buildCopyableField(
      label: "TAN",
      value: p.tanNumber,
      docTitle: "TAN Document",
      docUrl: p.tanImage,
      icon: Icons.receipt_long_outlined,
      iconColor: const Color(0xFF0D9488),
    );
  }

  Widget _buildCorporateField8(ProfileData p) {
    return _buildCopyableField(
      label: "GST",
      value: p.gstNumber,
      docTitle: "GST Document",
      docUrl: p.gstDocument,
      icon: Icons.receipt_outlined,
      iconColor: const Color(0xFF4F46E5),
    );
  }

  Widget _buildCorporateField9(ProfileData p) {
    final text = p.briefProfile ?? p.about ?? '';
    return _buildCard(
      title: "Brief Profile of your Organization",
      icon: Icons.article_outlined,
      iconColor: const Color(0xFF0284C7),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          text.isNotEmpty ? text : "Not Provided",
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            color: text.isNotEmpty ? const Color(0xFF334155) : const Color(0xFF94A3B8),
            fontStyle: text.isNotEmpty ? FontStyle.normal : FontStyle.italic,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCorporateField10(ProfileData p) {
    return _buildField9(p);
  }

  Widget _buildCorporateField11(ProfileData p) {
    return _buildField10(p);
  }

  Widget _buildCorporateField12(ProfileData p) {
    final url = p.websiteUrl ?? '';
    return _buildCard(
      title: "Website URL of your Organization",
      icon: Icons.language_outlined,
      iconColor: const Color(0xFF2563EB),
      child: url.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, size: 18, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _copyToClipboard(url, "Website URL"),
                      child: Text(
                        url,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1D4ED8),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF2563EB)),
                    onPressed: () => _copyToClipboard(url, "Website URL"),
                    tooltip: "Copy URL",
                  ),
                ],
              ),
            )
          : _buildEmptyValue("No website URL provided"),
    );
  }

  Widget _buildCorporateField13(ProfileData p) {
    final text = p.csrObligation ?? '';
    return _buildCard(
      title: "Last Financial Year's CSR Obligation",
      icon: Icons.volunteer_activism_outlined,
      iconColor: const Color(0xFFD97706),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          text.isNotEmpty ? text : "Not Provided",
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            color: text.isNotEmpty ? const Color(0xFF334155) : const Color(0xFF94A3B8),
            fontStyle: text.isNotEmpty ? FontStyle.normal : FontStyle.italic,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCorporateField14(ProfileData p) {
    final val = p.csrAmountSpentPreviousYear ?? '';
    return _buildCard(
      title: "Amount Spent on CSR in Previous Financial Year",
      icon: Icons.currency_rupee_rounded,
      iconColor: const Color(0xFF059669),
      child: val.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Text(
                val,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF065F46),
                ),
              ),
            )
          : _buildEmptyValue(),
    );
  }

  Widget _buildCorporateField15(ProfileData p) {
    List<String> areas = [];
    if (p.csrFocusAreas is List) {
      areas = (p.csrFocusAreas as List).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    } else if (p.csrFocusAreas is String && (p.csrFocusAreas as String).isNotEmpty) {
      areas = [(p.csrFocusAreas as String).trim()];
    }

    return _buildCard(
      title: "What are your organization's CSR focus areas?",
      icon: Icons.hub_outlined,
      iconColor: const Color(0xFF6366F1),
      child: areas.isNotEmpty
          ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: areas.map((area) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 6),
                      Text(
                        area,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3730A3),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          : _buildEmptyValue("No focus areas selected"),
    );
  }

  Widget _buildCorporateField16(ProfileData p) {
    final val = p.fundingPreferences?.toString() ?? '';
    return _buildCard(
      title: "What are your organization's funding preferences?",
      icon: Icons.payments_outlined,
      iconColor: const Color(0xFF0284C7),
      child: val.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Text(
                val,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0369A1),
                ),
              ),
            )
          : _buildEmptyValue(),
    );
  }

  Widget _buildCorporateField17(ProfileData p) {
    return _buildField17(p);
  }

  Widget _buildCorporateField18(ProfileData p) {
    Map<String, dynamic> officer = {};
    if (p.csrOfficerDetails is Map) {
      officer = Map<String, dynamic>.from(p.csrOfficerDetails);
    }
    final name = officer['name']?.toString() ?? '';
    final desig = officer['designation']?.toString() ?? '';
    final dept = officer['department']?.toString() ?? '';
    final email = officer['email']?.toString() ?? '';
    final phone = officer['phone']?.toString() ?? '';
    final linkedIn = officer['linkedInUrl']?.toString() ?? officer['linkedIn']?.toString() ?? '';

    final hasOfficer = name.isNotEmpty || email.isNotEmpty || phone.isNotEmpty;

    return _buildCard(
      title: "Details of CSR officer of your organization",
      icon: Icons.badge_outlined,
      iconColor: const Color(0xFF0D9488),
      child: hasOfficer
          ? Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.15),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'C',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F766E),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isNotEmpty ? name : "CSR Officer",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            if (desig.isNotEmpty || dept.isNotEmpty)
                              Text(
                                [desig, dept].where((e) => e.isNotEmpty).join(' • '),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  if (email.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              email,
                              style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (phone.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              formatPhoneWithCountryCode(phone),
                              style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (linkedIn.isNotEmpty)
                    InkWell(
                      onTap: () => _copyToClipboard(linkedIn, "LinkedIn Profile URL"),
                      child: Row(
                        children: [
                          const Icon(Icons.link_rounded, size: 14, color: Color(0xFF0A66C2)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              linkedIn,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF0A66C2),
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          : _buildEmptyValue("No CSR officer details provided"),
    );
  }

  Widget _buildCorporateField19(ProfileData p) {
    final val = p.employeeStrength ?? '';
    return _buildCard(
      title: "What is your organization's total employee strength?",
      icon: Icons.groups_outlined,
      iconColor: const Color(0xFF7C3AED),
      child: val.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Text(
                val,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6D28D9),
                ),
              ),
            )
          : _buildEmptyValue(),
    );
  }

  Widget _buildCorporateField20(ProfileData p) {
    return _buildField22(p);
  }

  Widget _buildCorporateField21(ProfileData p) {
    final declarations = [
      "Documents submitted are genuine and the information filled above is true & accurate.",
      "The representative is authorised to register the organization.",
      "Organization agrees to the platform's Privacy Policy and Terms & Conditions.",
      "Organization agrees to the KYC requirements and verification/ audit by the platform.",
      "Organization understands that the platform may request additional documents.",
    ];

    return _buildCard(
      title: "Compliance & Declarations",
      icon: Icons.verified_user_outlined,
      iconColor: const Color(0xFF059669),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Column(
          children: declarations.map((dec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dec,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF065F46),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  Widget _buildField1(ProfileData p) {
    final value = p.isRegisteredNonProfit ?? p.organizationType ?? '';
    final clean = _cleanRegistrationType(value);

    return _buildCard(
      title: "Is your organization a registered Non-Profit?",
      icon: Icons.account_balance_outlined,
      iconColor: const Color(0xFF2563EB),
      child: value.isNotEmpty
          ? Row(
              children: [
                _buildYesNoBadge(true),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value.startsWith("Yes") ? value : "Yes - $clean",
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                    ),
                  ),
                ),
              ],
            )
          : _buildEmptyText(),
    );
  }

  // ===========================================================================
  // FIELD 2: Legal Name of your Organization
  // ===========================================================================
  Widget _buildField2(ProfileData p) {
    final value = p.legalName ?? p.organizationName ?? p.name ?? '';

    return _buildCard(
      title: "Legal Name of your Organization",
      icon: Icons.badge_outlined,
      iconColor: const Color(0xFF2563EB),
      child: value.isNotEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                value,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
              ),
            )
          : _buildEmptyText(),
    );
  }

  // ===========================================================================
  // FIELD 3: Registered Address of your Organization (+ Registration Certificate)
  // ===========================================================================
  Widget _buildField3(ProfileData p) {
    final address = p.registeredAddress ?? '';
    final docUrl = p.addressCertificate ?? '';

    return _buildCard(
      title: "Registered Address of your Organization",
      icon: Icons.location_on_outlined,
      iconColor: const Color(0xFFEA580C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined, size: 18, color: Color(0xFFEA580C)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.isNotEmpty ? address : "Not Provided",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: address.isNotEmpty ? const Color(0xFF1E293B) : Colors.grey.shade500,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Registration Certificate:",
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          docUrl.isNotEmpty
              ? _buildDocumentButton("Registration Certificate", docUrl)
              : _buildEmptyText("No document uploaded"),
        ],
      ),
    );
  }

  // ===========================================================================
  // FIELD 5: MOA & AOA / Trust Deed / Society Bye-laws
  // ===========================================================================
  Widget _buildField5(ProfileData p) {
    final dynamic docs = p.moaAoaDocuments;
    List<String> docList = [];
    if (docs is List) {
      docList = docs.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    } else if (docs != null && docs.toString().trim().isNotEmpty) {
      docList = [docs.toString().trim()];
    }

    return _buildCard(
      title: "MOA & AOA / Trust Deed / Society Bye-laws",
      icon: Icons.article_outlined,
      iconColor: const Color(0xFF7C3AED),
      child: docList.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: docList.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final url = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildDocumentButton("Bye-laws Document $idx", url),
                );
              }).toList(),
            )
          : _buildEmptyText("No documents uploaded"),
    );
  }

  // ===========================================================================
  // FIELD 6: PAN
  // ===========================================================================
  Widget _buildField6(ProfileData p) {
    final pan = p.panNumber ?? '';
    final docUrl = p.panImage ?? '';

    return _buildCard(
      title: "PAN",
      icon: Icons.credit_card_outlined,
      iconColor: const Color(0xFF7C3AED),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "PAN Number:",
                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Text(
                  pan.isNotEmpty ? pan.toUpperCase() : "Not Provided",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: pan.isNotEmpty ? const Color(0xFF1E293B) : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          if (docUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDocumentButton("PAN Document", docUrl),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // FIELD 7: TAN
  // ===========================================================================
  Widget _buildField7(ProfileData p) {
    final tan = p.tanNumber ?? '';
    final docUrl = p.tanImage ?? '';

    return _buildCard(
      title: "TAN",
      icon: Icons.confirmation_number_outlined,
      iconColor: const Color(0xFF7C3AED),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "TAN Number:",
                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Text(
                  tan.isNotEmpty ? tan.toUpperCase() : "Not Provided",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: tan.isNotEmpty ? const Color(0xFF1E293B) : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          if (docUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDocumentButton("TAN Document", docUrl),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // FIELD 8: Brief Profile of your Organization
  // ===========================================================================
  Widget _buildField8(ProfileData p) {
    final desc = p.briefProfile ?? p.about ?? p.ourMission ?? '';

    return _buildCard(
      title: "Brief Profile of your Organization",
      icon: Icons.notes_outlined,
      iconColor: const Color(0xFF0D9488),
      child: desc.isNotEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                desc,
                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF334155), height: 1.55),
              ),
            )
          : _buildEmptyText(),
    );
  }

  // ===========================================================================
  // FIELD 9: Directors / Trustees / Key Management
  // ===========================================================================
  Widget _buildField9(ProfileData p) {
    final dynamic officialsRaw = p.directorsKeyManagement;
    List<Map<String, dynamic>> officialsList = [];

    if (officialsRaw is List) {
      for (var item in officialsRaw) {
        if (item is Map) {
          officialsList.add(Map<String, dynamic>.from(item));
        }
      }
    }

    return _buildCard(
      title: "Directors / Trustees / Key Management",
      icon: Icons.supervisor_account_outlined,
      iconColor: const Color(0xFF0D9488),
      trailing: officialsList.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFBF1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${officialsList.length} Officials",
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0F766E)),
              ),
            )
          : null,
      child: officialsList.isNotEmpty
          ? Column(
              children: officialsList.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final off = entry.value;
                final name = off['name']?.toString() ?? off['fullName']?.toString() ?? 'Official $idx';
                final designation = off['designation']?.toString() ?? off['role']?.toString() ?? '-';
                final email = off['email']?.toString() ?? '-';
                final pan = off['pan']?.toString() ?? '-';
                final aadhar = off['aadharId']?.toString() ?? off['aadhar']?.toString() ?? '-';
                final linkedIn = off['linkedInUrl']?.toString() ?? off['linkedIn']?.toString() ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.primaryDeepBlue,
                            child: Text(
                              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "$idx",
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                ),
                                if (designation != '-' && designation.isNotEmpty)
                                  Text(
                                    designation,
                                    style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppTheme.primaryDeepBlue),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18, color: Color(0xFFE2E8F0)),
                      _buildSubfieldRow("E-mail ID", email),
                      _buildSubfieldRow("PAN", pan),
                      _buildSubfieldRow("Aadhar / ID", aadhar),
                      if (linkedIn.isNotEmpty)
                        _buildSubfieldRow("LinkedIn Profile", linkedIn, isLink: true),
                    ],
                  ),
                );
              }).toList(),
            )
          : _buildEmptyText("No directors / key management recorded"),
    );
  }

  // ===========================================================================
  // FIELD 10: Details of the person filling this form
  // ===========================================================================
  Widget _buildField10(ProfileData p) {
    Map<String, dynamic> filler = {};
    if (p.formFillerDetails is Map) {
      filler = Map<String, dynamic>.from(p.formFillerDetails);
    }

    final name = filler['name']?.toString() ?? p.authorizedPerson ?? '';
    final designation = filler['designationRole']?.toString() ?? filler['designation']?.toString() ?? p.designation ?? '';
    final phone = filler['phone']?.toString() ?? p.phone ?? '';
    final email = filler['email']?.toString() ?? p.email ?? '';
    final pan = filler['pan']?.toString() ?? '';
    final aadhar = filler['aadharId']?.toString() ?? filler['aadhar']?.toString() ?? '';
    final authLetter = p.authorityLetter ?? filler['authorityLetter']?.toString() ?? '';

    return _buildCard(
      title: "Details of the person filling this form",
      icon: Icons.person_pin_outlined,
      iconColor: const Color(0xFF0D9488),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.15),
                  child: const Icon(Icons.person, color: Color(0xFF0D9488), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : "Authorized Representative",
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                      if (designation.isNotEmpty)
                        Text(
                          designation,
                          style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 18, color: Color(0xFFE2E8F0)),
            _buildSubfieldRow("Phone Number", phone.isNotEmpty ? formatPhoneWithCountryCode(phone) : "Not Provided"),
            _buildSubfieldRow("E-mail ID", email.isNotEmpty ? email : "Not Provided"),
            _buildSubfieldRow("PAN", pan.isNotEmpty ? pan : "Not Provided"),
            _buildSubfieldRow("Aadhar / Other ID", aadhar.isNotEmpty ? aadhar : "Not Provided"),
            const SizedBox(height: 8),
            Text(
              "Authority Letter:",
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            authLetter.isNotEmpty
                ? _buildDocumentButton("Authority Letter", authLetter)
                : _buildEmptyText("No document uploaded"),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // FIELD 11: Does your Organization have 12A Certification?
  // ===========================================================================
  Widget _buildField11(ProfileData p) {
    final bool hasCert = (p.certificate12A != null && p.certificate12A!.isNotEmpty) ||
        (p.registration12A != null && p.registration12A!.isNotEmpty);
    final docUrl = p.certificate12A ?? '';

    return _buildCard(
      title: "Does your Organization have 12A Certification?",
      icon: Icons.verified_outlined,
      iconColor: const Color(0xFF059669),
      trailing: _buildYesNoBadge(hasCert),
      child: hasCert && docUrl.isNotEmpty
          ? _buildDocumentButton("12A Certificate", docUrl)
          : (hasCert ? const Text("Certified (No document attached)") : const SizedBox.shrink()),
    );
  }

  // ===========================================================================
  // FIELD 12: Does your Organization have 80G Certification?
  // ===========================================================================
  Widget _buildField12(ProfileData p) {
    final bool hasCert = (p.certificate80G != null && p.certificate80G!.isNotEmpty) ||
        (p.registration80G != null && p.registration80G!.isNotEmpty);
    final docUrl = p.certificate80G ?? '';

    return _buildCard(
      title: "Does your Organization have 80G Certification?",
      icon: Icons.card_giftcard_outlined,
      iconColor: const Color(0xFF059669),
      trailing: _buildYesNoBadge(hasCert),
      child: hasCert && docUrl.isNotEmpty
          ? _buildDocumentButton("80G Certificate", docUrl)
          : (hasCert ? const Text("Certified (No document attached)") : const SizedBox.shrink()),
    );
  }

  // ===========================================================================
  // FIELD 13: Does your Organization have DARPAN Registration?
  // ===========================================================================
  Widget _buildField13(ProfileData p) {
    final bool hasReg = p.hasDarpan == true ||
        (p.darpanNumber != null && p.darpanNumber!.isNotEmpty) ||
        (p.darpanCertificate != null && p.darpanCertificate!.isNotEmpty);
    final number = p.darpanNumber ?? '';
    final docUrl = p.darpanCertificate ?? '';

    return _buildCard(
      title: "Does your Organization have DARPAN Registration?",
      icon: Icons.account_balance_wallet_outlined,
      iconColor: const Color(0xFF059669),
      trailing: _buildYesNoBadge(hasReg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasReg && number.isNotEmpty) ...[
            _buildHighlightNumberRow("DARPAN ID", number),
            const SizedBox(height: 8),
          ],
          if (hasReg && docUrl.isNotEmpty) ...[
            _buildDocumentButton("DARPAN Certificate", docUrl),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // FIELD 14: Does your Organization have CSR-1 Certification?
  // ===========================================================================
  Widget _buildField14(ProfileData p) {
    final bool hasCert = p.hasCSR1 == true ||
        (p.csr1Number != null && p.csr1Number!.isNotEmpty) ||
        (p.csr1Certificate != null && p.csr1Certificate!.isNotEmpty);
    final number = p.csr1Number ?? '';
    final docUrl = p.csr1Certificate ?? '';

    return _buildCard(
      title: "Does your Organization have CSR-1 Certification?",
      icon: Icons.handshake_outlined,
      iconColor: const Color(0xFF059669),
      trailing: _buildYesNoBadge(hasCert),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCert && number.isNotEmpty) ...[
            _buildHighlightNumberRow("CSR-1 Number", number),
            const SizedBox(height: 8),
          ],
          if (hasCert && docUrl.isNotEmpty) ...[
            _buildDocumentButton("CSR-1 Certificate", docUrl),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // FIELD 15: Does your Organization have FCRA Certification?
  // ===========================================================================
  Widget _buildField15(ProfileData p) {
    final bool hasCert = p.hasFCRA == true ||
        (p.fcraNumber != null && p.fcraNumber!.isNotEmpty) ||
        (p.fcraCertificate != null && p.fcraCertificate!.isNotEmpty);
    final number = p.fcraNumber ?? '';
    final docUrl = p.fcraCertificate ?? '';

    return _buildCard(
      title: "Does your Organization have FCRA Certification?",
      icon: Icons.language_outlined,
      iconColor: const Color(0xFF059669),
      trailing: _buildYesNoBadge(hasCert),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCert && number.isNotEmpty) ...[
            _buildHighlightNumberRow("FCRA Number", number),
            const SizedBox(height: 8),
          ],
          if (hasCert && docUrl.isNotEmpty) ...[
            _buildDocumentButton("FCRA Certificate", docUrl),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // FIELD 16: Website URL of your Organization
  // ===========================================================================
  Widget _buildField16(ProfileData p) {
    final url = p.websiteUrl ?? '';

    return _buildCard(
      title: "Website URL of your Organization",
      icon: Icons.public_outlined,
      iconColor: const Color(0xFF059669),
      child: url.isNotEmpty
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: url));
                  showSnackBar("Website URL copied: $url", true);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, size: 18, color: Color(0xFF1D4ED8)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          url,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF1D4ED8),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.copy_rounded, size: 15, color: Color(0xFF1D4ED8)),
                    ],
                  ),
                ),
              ),
            )
          : _buildEmptyText(),
    );
  }

  // ===========================================================================
  // FIELD 17: Bank Details of your Organization
  // ===========================================================================
  Widget _buildField17(ProfileData p) {
    final bankName = p.bankName ?? '';
    final branch = p.bankBranch ?? '';
    final holder = p.bankAccountHolder ?? '';
    final accNo = p.bankAccountNumber ?? '';
    final ifsc = p.bankIFSC ?? '';
    final chequeUrl = p.cancelledChequeDoc ?? '';

    return _buildCard(
      title: "Bank Details of your Organization",
      icon: Icons.account_balance_outlined,
      iconColor: const Color(0xFFD97706),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_rounded, color: Color(0xFFD97706), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bankName.isNotEmpty ? bankName : "Bank Details",
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
            const Divider(height: 18, color: Color(0xFFFDE68A)),
            _buildSubfieldRow("Branch", branch.isNotEmpty ? branch : "Not Provided"),
            _buildSubfieldRow("Account Name", holder.isNotEmpty ? holder : "Not Provided"),
            if (accNo.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text("Account No.", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF78350F))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: accNo));
                          showSnackBar("Account number copied: $accNo", true);
                        },
                        child: Row(
                          children: [
                            Text(
                              accNo,
                              style: GoogleFonts.robotoMono(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.copy, size: 14, color: Color(0xFFD97706)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (ifsc.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text("IFSC Code", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF78350F))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: ifsc));
                          showSnackBar("IFSC copied: $ifsc", true);
                        },
                        child: Row(
                          children: [
                            Text(
                              ifsc.toUpperCase(),
                              style: GoogleFonts.robotoMono(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.copy, size: 14, color: Color(0xFFD97706)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              "Cancelled Cheque / Passbook Image:",
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF92400E)),
            ),
            const SizedBox(height: 6),
            chequeUrl.isNotEmpty
                ? _buildDocumentButton("Cancelled Cheque / Passbook", chequeUrl)
                : _buildEmptyText("No document uploaded"),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // FIELD 18: Last Financial Year's Budget
  // ===========================================================================
  Widget _buildField18(ProfileData p) {
    final value = p.lastFinancialYearBudget ?? '';

    return _buildCard(
      title: "Last Financial Year's Budget",
      icon: Icons.payments_outlined,
      iconColor: const Color(0xFFD97706),
      child: value.isNotEmpty
          ? _buildMetricBadge(Icons.currency_rupee_rounded, value)
          : _buildEmptyText(),
    );
  }

  // ===========================================================================
  // FIELD 19: Total Donor Database Strength
  // ===========================================================================
  Widget _buildField19(ProfileData p) {
    final value = p.donorDatabaseStrength ?? '';

    return _buildCard(
      title: "Total Donor Database Strength",
      icon: Icons.people_alt_outlined,
      iconColor: const Color(0xFFD97706),
      child: value.isNotEmpty
          ? _buildMetricBadge(Icons.volunteer_activism_outlined, "$value Donors")
          : _buildEmptyText(),
    );
  }

  // ===========================================================================
  // FIELD 20: What is your organization's total employee strength?
  // ===========================================================================
  Widget _buildField20(ProfileData p) {
    final value = p.employeeStrength ?? '';

    return _buildCard(
      title: "What is your organization's total employee strength?",
      icon: Icons.badge_outlined,
      iconColor: const Color(0xFFD97706),
      child: value.isNotEmpty
          ? _buildMetricBadge(Icons.groups, "$value Employees")
          : _buildEmptyText(),
    );
  }

  // ===========================================================================
  // FIELD 21: Have you crowdfunded before?
  // ===========================================================================
  Widget _buildField21(ProfileData p) {
    bool hasCrowdfunded = false;
    if (p.hasCrowdfundedBefore != null) {
      final s = p.hasCrowdfundedBefore.toString().toLowerCase();
      hasCrowdfunded = s == 'true' || s == 'yes' || s == '1';
    }
    final platform = p.crowdfundingPlatformsUsed ?? '';

    return _buildCard(
      title: "Have you crowdfunded before?",
      icon: Icons.campaign_outlined,
      iconColor: const Color(0xFFE11D48),
      trailing: _buildYesNoBadge(hasCrowdfunded),
      child: hasCrowdfunded && platform.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.devices_other, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Platforms Used: $platform",
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // ===========================================================================
  // FIELD 22: Awards & Recognitions
  // ===========================================================================
  Widget _buildField22(ProfileData p) {
    final dynamic awardsRaw = p.awardsRecognitions;
    List<Map<String, dynamic>> awardsList = [];

    if (awardsRaw is List) {
      for (var item in awardsRaw) {
        if (item is Map) {
          awardsList.add(Map<String, dynamic>.from(item));
        }
      }
    }

    final bool hasAwards = awardsList.isNotEmpty;

    return _buildCard(
      title: "Awards & Recognitions",
      icon: Icons.emoji_events_outlined,
      iconColor: const Color(0xFFF59E0B),
      trailing: _buildYesNoBadge(hasAwards),
      child: hasAwards
          ? Column(
              children: awardsList.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final a = entry.value;
                final name = a['name']?.toString() ?? a['title']?.toString() ?? 'Award $idx';
                final by = a['awardedBy']?.toString() ?? '-';
                final year = a['year']?.toString() ?? '-';
                final desc = a['description']?.toString() ?? '';
                final doc = a['supportingDocument']?.toString() ?? a['document']?.toString() ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF92400E)),
                            ),
                          ),
                          if (year != '-' && year.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Text(
                                year,
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFB45309)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildSubfieldRow("Awarded by", by),
                      if (desc.isNotEmpty) _buildSubfieldRow("Description", desc),
                      if (doc.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDocumentButton("Supporting Document", doc),
                      ],
                    ],
                  ),
                );
              }).toList(),
            )
          : const SizedBox.shrink(),
    );
  }

  // ===========================================================================
  // FIELD 23: How soon are you planning to create a fundraising campaign?
  // ===========================================================================
  Widget _buildField23(ProfileData p) {
    final value = p.campaignPlanningTimeframe ?? '';

    return _buildCard(
      title: "How soon are you planning to create a fundraising campaign on our platform?",
      icon: Icons.schedule_outlined,
      iconColor: const Color(0xFFE11D48),
      child: value.isNotEmpty
          ? _buildMetricBadge(Icons.calendar_today_outlined, value)
          : _buildEmptyText(),
    );
  }

  // ===========================================================================
  // FIELD 24: Purpose of fundraising/ Cause/s Supported
  // ===========================================================================
  Widget _buildField24(ProfileData p) {
    final value = p.purposeOfFundraising ?? '';

    return _buildCard(
      title: "Purpose of fundraising/ Cause/s Supported",
      icon: Icons.volunteer_activism_outlined,
      iconColor: const Color(0xFFE11D48),
      child: value.isNotEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                value,
                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF334155), height: 1.55),
              ),
            )
          : _buildEmptyText(),
    );
  }

  // ===========================================================================
  // FIELD 25: Compliance & Declarations
  // ===========================================================================
  Widget _buildField25(ProfileData p) {
    final declarations = [
      "Documents submitted are genuine and the information filled above is true & accurate.",
      "Donations will be used only for declared purposes and not for any prohibited activities.",
      "Organization will maintain proper records and provide utilisation reports where required.",
      "Organization agrees to the platform's Privacy Policy and Fundraising Terms & Conditions.",
      "Organization agrees to the KYC requirements and verification/ audit by the platform.",
      "Organization understands that fundraising campaigns may be suspended pending verification.",
    ];

    return _buildCard(
      title: "Compliance & Declarations",
      icon: Icons.gavel_outlined,
      iconColor: const Color(0xFF0F766E),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 12, color: Color(0xFF2E7D32)),
            const SizedBox(width: 4),
            Text(
              "Agreed",
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF2E7D32)),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: declarations.map((dec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 15),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dec,
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF166534), height: 1.45),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ===========================================================================
  // REVIEWS SECTION
  // ===========================================================================
  Widget _buildReviewsSection(ProfileData p) {
    final double rating = p.rating ?? 0.0;
    final List<ReviewItem> reviews = p.reviews ?? [];
    final int reviewCount = p.reviewCount ?? reviews.length;
    final bool hasReviews = reviews.isNotEmpty || reviewCount > 0 || rating > 0;

    return _buildCard(
      title: "Ratings & Reviews",
      icon: Icons.star_rate_rounded,
      iconColor: const Color(0xFFF59E0B),
      child: !hasReviews
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "No reviews yet",
                  style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 24),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF92400E)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(5, (sIdx) {
                            return Icon(
                              sIdx < rating.floor() ? Icons.star_rounded : Icons.star_border_rounded,
                              color: const Color(0xFFF59E0B),
                              size: 18,
                            );
                          }),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$reviewCount ${reviewCount == 1 ? 'Customer Review' : 'Customer Reviews'}",
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                if (reviews.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    height: reviews.any((r) => r.hasVideo) ? 220 : 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = reviews[index];
                        return Container(
                          width: 250,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.comment ?? item.targetName ?? '',
                                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: AppTheme.primaryDeepBlue.withValues(alpha: 0.1),
                                    child: Icon(Icons.person, size: 12, color: AppTheme.primaryDeepBlue),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.userName ?? "Community Member",
                                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  // ===========================================================================
  // COMMON HELPERS
  // ===========================================================================
  void _copyToClipboard(String text, String label) {
    if (text.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: text.trim()));
    showSnackBar("$label copied to clipboard", true);
  }

  Widget _buildEmptyValue([String message = "Not Provided"]) {
    return _buildEmptyText(message);
  }

  Widget _buildDocumentCard(String label, String? url) {
    if (url == null || url.trim().isEmpty) {
      return _buildEmptyText("No document uploaded");
    }
    return _buildDocumentButton(label, url.trim());
  }

  Widget _buildCopyableField({
    required String label,
    required String? value,
    required String docTitle,
    required String? docUrl,
    required IconData icon,
    required Color iconColor,
  }) {
    final val = value?.trim() ?? '';
    final hasVal = val.isNotEmpty;
    final url = docUrl?.trim() ?? '';

    return _buildCard(
      title: label,
      icon: icon,
      iconColor: iconColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "$label Number:",
                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: hasVal ? () => _copyToClipboard(val, label) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasVal ? val.toUpperCase() : "Not Provided",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: hasVal ? const Color(0xFF1E293B) : Colors.grey.shade500,
                        ),
                      ),
                      if (hasVal) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF64748B)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (url.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDocumentButton(docTitle, url),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    IconData? icon,
    Color? iconColor,
    Widget? trailing,
    required Widget child,
  }) {
    final accent = iconColor ?? AppTheme.primaryDeepBlue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 15, color: accent),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                    height: 1.35,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyText([String message = "Not Provided"]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: const Color(0xFF94A3B8),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildYesNoBadge(bool isYes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isYes ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isYes ? const Color(0xFFA7F3D0) : const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isYes ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: isYes ? const Color(0xFF059669) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Text(
            isYes ? "Yes" : "No",
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isYes ? const Color(0xFF059669) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightNumberRow(String label, String number) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
          ),
          Text(
            number,
            style: GoogleFonts.robotoMono(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2563EB)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentButton(String label, String url) {
    final bool isPdf = url.toLowerCase().contains('.pdf');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDocumentPreview(context, label, url),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPdf ? Icons.picture_as_pdf_outlined : Icons.description_outlined,
                size: 16,
                color: isPdf ? const Color(0xFFD32F2F) : const Color(0xFF1D4ED8),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  "View $label",
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1D4ED8)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF1D4ED8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubfieldRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isLink && value.isNotEmpty
                ? InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      showSnackBar("Link copied: $value", true);
                    },
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF1D4ED8),
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: value == "Not Provided" || value == "-" ? Colors.grey.shade400 : const Color(0xFF1E293B),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
