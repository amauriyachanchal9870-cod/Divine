import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../Widget/review_video_widget.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/follows_controller.dart';
import '../../Controller/ngo_details_controller.dart';
import '../../Model/ngo_details_model.dart';
import '../../Model/review_model.dart';
import '../../Controller/profile_controller.dart';
import '../../Routes/my_routes.dart';
import '../../Utilities/helper.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NgoDetailsScreen extends StatefulWidget {
  const NgoDetailsScreen({super.key});

  @override
  State<NgoDetailsScreen> createState() => _NgoDetailsScreenState();
}

class _NgoDetailsScreenState extends State<NgoDetailsScreen> {
  int _currentAwardIndex = 0;
  final PageController _awardPageController = PageController();

  @override
  void dispose() {
    _awardPageController.dispose();
    super.dispose();
  }

  NgoDetailsData _mapProfileToNgoDetails(dynamic profileData) {
    if (profileData == null) return NgoDetailsData();

    // Map leadership list from directorsKeyManagement
    List<LeadershipMember> leadershipList = [];
    final rawLeadership = profileData.directorsKeyManagement;
    if (rawLeadership is List) {
      for (var item in rawLeadership) {
        if (item is Map) {
          leadershipList.add(LeadershipMember.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    if (leadershipList.isEmpty &&
        profileData.authorizedPerson != null &&
        profileData.authorizedPerson.toString().trim().isNotEmpty) {
      leadershipList.add(
        LeadershipMember(
          name: profileData.authorizedPerson.toString().trim(),
          designation: profileData.designation?.toString().trim() ?? 'Authorized Representative',
          email: profileData.email?.toString().trim(),
        ),
      );
    }

    // Map awards from awardsRecognitions
    List<AwardItem> awardsList = [];
    final rawAwards = profileData.awardsRecognitions;
    if (rawAwards is List) {
      for (var item in rawAwards) {
        if (item is Map) {
          awardsList.add(AwardItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    // Map causes supported
    List<String> causesList = [];
    final rawCauses = profileData.csrFocusAreas;
    if (rawCauses is List) {
      for (var c in rawCauses) {
        if (c != null && c.toString().trim().isNotEmpty) {
          causesList.add(c.toString().trim());
        }
      }
    } else if (profileData.purposeOfFundraising != null &&
        profileData.purposeOfFundraising.toString().trim().isNotEmpty) {
      causesList = [profileData.purposeOfFundraising.toString().trim()];
    }

    return NgoDetailsData(
      id: profileData.id,
      ngoId: profileData.id,
      name: profileData.name ?? profileData.organizationName ?? profileData.legalName,
      legalName: profileData.legalName ?? profileData.organizationName ?? profileData.name,
      logo: profileData.logo ?? profileData.profilePhoto,
      bannerImage: profileData.bannerImage,
      about: profileData.about ?? profileData.briefProfile ?? profileData.ourMission,
      briefProfile: profileData.briefProfile,
      ourMission: profileData.ourMission,
      registeredAddress: profileData.registeredAddress,
      websiteUrl: profileData.websiteUrl,
      email: profileData.email,
      phone: profileData.phone,
      organizationType: profileData.organizationType,
      isRegisteredNonProfit: profileData.isRegisteredNonProfit ?? profileData.organizationType,
      isVerified: profileData.isVerified ?? (profileData.verificationStatus?.toString().toLowerCase() == 'verified'),
      verificationStatus: profileData.verificationStatus,
      rating: profileData.rating ?? 0.0,
      reviewCount: profileData.reviewCount ?? 0,
      reviews: profileData.reviews,
      registration12A: profileData.registration12A,
      certificate12A: profileData.certificate12A,
      has12A: profileData.registration12A != null || profileData.certificate12A != null,
      registration80G: profileData.registration80G,
      certificate80G: profileData.certificate80G,
      has80G: profileData.registration80G != null || profileData.certificate80G != null,
      darpanNumber: profileData.darpanNumber,
      darpanCertificate: profileData.darpanCertificate,
      hasDarpan: profileData.darpanNumber != null || profileData.darpanCertificate != null,
      csr1Number: profileData.csr1Number,
      csr1Certificate: profileData.csr1Certificate,
      hasCSR1: profileData.csr1Number != null || profileData.csr1Certificate != null,
      fcraNumber: profileData.fcraNumber,
      fcraCertificate: profileData.fcraCertificate,
      hasFCRA: profileData.fcraNumber != null || profileData.fcraCertificate != null,
      registrationCertificate: profileData.addressCertificate,
      addressCertificate: profileData.addressCertificate,
      moaAoaDocuments: profileData.moaAoaDocuments,
      panNumber: profileData.panNumber,
      panDocument: profileData.panImage,
      tanNumber: profileData.tanNumber,
      tanDocument: profileData.tanImage,
      gstNumber: profileData.gstNumber,
      gstDocument: profileData.gstDocument,
      leadership: leadershipList,
      directorsKeyManagement: rawLeadership,
      formFillerDetails: profileData.formFillerDetails,
      authorizedPerson: profileData.authorizedPerson,
      designation: profileData.designation,
      authorityLetter: profileData.authorityLetter,
      awards: awardsList,
      causesSupported: causesList,
      purposeOfFundraising: profileData.purposeOfFundraising,
      csrFocusAreas: rawCauses,
      lastFinancialYearBudget: profileData.lastFinancialYearBudget,
      donorDatabaseStrength: profileData.donorDatabaseStrength,
      employeeStrength: profileData.employeeStrength,
      hasCrowdfundedBefore: profileData.hasCrowdfundedBefore,
      crowdfundingPlatformsUsed: profileData.crowdfundingPlatformsUsed,
      campaignPlanningTimeframe: profileData.campaignPlanningTimeframe,
      bankAccountHolder: profileData.bankAccountHolder,
      bankName: profileData.bankName,
      bankBranch: profileData.bankBranch,
      bankAccountNumber: profileData.bankAccountNumber,
      bankIFSC: profileData.bankIFSC,
      cancelledChequeDoc: profileData.cancelledChequeDoc,
      declarations: profileData.declarations,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnProfile = false;
    String ngoId = '';

    if (Get.arguments is Map) {
      isOwnProfile = Get.arguments['isOwnProfile'] ?? false;
      ngoId = Get.arguments['id'] ?? Get.arguments['ngoId'] ?? '';
    } else if (Get.arguments is String) {
      ngoId = Get.arguments;
    }

    NgoDetailsController? detailsController;
    if (ngoId.isNotEmpty) {
      detailsController = Get.isRegistered<NgoDetailsController>(tag: ngoId)
          ? Get.find<NgoDetailsController>(tag: ngoId)
          : Get.put(NgoDetailsController(ngoId: ngoId), tag: ngoId);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppString.ngoDetails.tr,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
        ),
        centerTitle: false,
      ),
      body: detailsController == null
          ? _buildProfileDataFallback(isOwnProfile)
          : Obx(() {
              if (detailsController!.isLoading.value) {
                return Center(
                  child: LoadingAnimationWidget.threeRotatingDots(
                    color: AppTheme.primaryDeepBlue,
                    size: 50,
                  ),
                );
              }
              if (detailsController.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          detailsController.errorMessage.value,
                          style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => detailsController?.fetchNgoDetails(forceRefresh: true),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryDeepBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final data = detailsController.ngoDetails.value;
              if (data == null) {
                return const Center(child: Text("No data available"));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await detailsController?.fetchNgoDetails(forceRefresh: true);
                },
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: isOwnProfile ? 50 : 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(data),
                          const SizedBox(height: 16),
                          _buildAboutUsSection(data),
                          _buildWebsiteUrlSection(data),
                          _buildHaveYouCrowdfundedSection(data),
                          _buildPurposeAndCausesSection(data),
                          // _buildCausesSection(data),
                          _buildOrganizationAndLegalSection(data),
                          // _buildStatutoryTaxSection(data),
                          _buildCertificationsSection(data),
                          _buildLeadershipSection(data),
                          _buildAuthorizedPersonSection(data),
                          // _buildBankDetailsSection(data),
                          // _buildOperationalStrengthSection(data),
                          _buildAwardsSection(data),
                          // _buildDeclarationsSection(data),
                          _buildReviewsSection(context, detailsController),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    _buildBottomBar(data, isOwnProfile),
                  ],
                ),
              );
            }),
    );
  }

  Widget _buildProfileDataFallback(bool isOwnProfile) {
    final profileCtrl = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : null;
    final pData = profileCtrl?.profileData.value;
    if (pData != null) {
      final data = _mapProfileToNgoDetails(pData);
      return Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: isOwnProfile ? 50 : 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(data),
                const SizedBox(height: 16),
                _buildAboutUsSection(data),
                _buildWebsiteUrlSection(data),
                _buildHaveYouCrowdfundedSection(data),
                _buildPurposeAndCausesSection(data),
                _buildCausesSection(data),
                _buildOrganizationAndLegalSection(data),
                _buildStatutoryTaxSection(data),
                _buildCertificationsSection(data),
                _buildLeadershipSection(data),
                _buildAuthorizedPersonSection(data),
                _buildBankDetailsSection(data),
                _buildOperationalStrengthSection(data),
                _buildAwardsSection(data),
                _buildDeclarationsSection(data),
                _buildReviewsSection(context, null),
                const SizedBox(height: 10),
              ],
            ),
          ),
          _buildBottomBar(data, isOwnProfile),
        ],
      );
    }

    return const Center(
      child: Text("No data available"),
    );
  }

  // ===========================================================================
  // 1. TOP HEADER (Dynamic Banner only if available, Overlapping Logo / Monogram, Verified status, Quick info)
  // ===========================================================================
  Widget _buildHeader(NgoDetailsData data) {
    final String address = data.registeredAddress?.trim() ?? '';
    final String subtitleText = address.isNotEmpty ? "📍 $address" : "";
    final String website = data.websiteUrl?.trim() ?? '';
    final String email = data.email?.trim() ?? '';
    final String phone = data.phone?.trim() ?? '';
    final String ngoName = data.name?.trim() ?? data.legalName?.trim() ?? '';
    final bool hasBanner = data.bannerImage != null && data.bannerImage!.trim().isNotEmpty;
    final bool isVerified = data.isVerified == true ||
        (data.status?.toLowerCase() == 'verified') ||
        (data.status?.toLowerCase() == 'active');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Area: Dynamic network image ONLY if present from API; NO STATIC ASSET BANNER IMAGE
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  // gradient: hasBanner
                  //     ? null
                  //     : LinearGradient(
                  //         colors: [
                  //           AppTheme.primaryDeepBlue,
                  //           const Color(0xFF1E3A8A),
                  //         ],
                  //         begin: Alignment.topLeft,
                  //         end: Alignment.bottomRight,
                  //       ),
                  color: hasBanner ? Colors.grey.shade100 : null,
                ),
                child: hasBanner
                    ? CachedNetworkImage(
                        imageUrl: data.bannerImage!.trim(),
                        fit: BoxFit.cover,
                        placeholder: (c, u) => Container(
                          color: const Color(0xFFE2E8F0),
                          child: Center(
                            child: LoadingAnimationWidget.threeRotatingDots(
                              color: AppTheme.primaryDeepBlue,
                              size: 24,
                            ),
                          ),
                        ),
                        // On error: subtle styled gradient, NO STATIC CAMPAIGN ASSET IMAGE
                        errorWidget: (c, u, e) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryDeepBlue,
                                const Color(0xFF1E3A8A),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 40,
                            bottom: -30,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.04),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

              // Overlapping Logo / Monogram Avatar (NO STATIC DUMMY LOGO)
              Positioned(
                bottom: -38,
                left: 16,
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: (data.logo != null && data.logo!.trim().isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: data.logo!.trim(),
                            fit: BoxFit.cover,
                            placeholder: (c, u) => Container(
                              color: const Color(0xFFF1F5F9),
                              child: Center(
                                child: LoadingAnimationWidget.threeRotatingDots(
                                  color: AppTheme.primaryDeepBlue,
                                  size: 18,
                                ),
                              ),
                            ),
                            errorWidget: (c, u, e) => _buildInitialsAvatar(ngoName),
                          )
                        : _buildInitialsAvatar(ngoName),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 46),

          // Organization Name, Verification Status & Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  ngoName.isNotEmpty ? ngoName : "No data available",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF00875A),
                                  size: 19,
                                ),
                              ],
                            ],
                          ),
                          if (subtitleText.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitleText,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Status Badge (Dynamic based on verification status)
                    // Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    //   decoration: BoxDecoration(
                    //     color: isVerified
                    //         ? const Color(0xFFE8F5E9)
                    //         : const Color(0xFFFFF7ED),
                    //     border: Border.all(
                    //       color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFEA580C),
                    //       width: 1,
                    //     ),
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Icon(
                    //         isVerified ? Icons.check_circle_rounded : Icons.pending_outlined,
                    //         size: 13,
                    //         color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFEA580C),
                    //       ),
                    //       const SizedBox(width: 4),
                    //       Text(
                    //         isVerified ? "Verified NGO" : "Registered NGO",
                    //         style: GoogleFonts.poppins(
                    //           fontSize: 11,
                    //           fontWeight: FontWeight.w600,
                    //           color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFEA580C),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),

                // Dynamic Contact & Website Quick Pills
                if (website.isNotEmpty || email.isNotEmpty || phone.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (website.isNotEmpty)
                        _buildQuickActionChip(
                          icon: Icons.link_rounded,
                          label: website,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: website));
                            showSnackBar("Website URL copied", true);
                          },
                        ),
                      if (email.isNotEmpty)
                        _buildQuickActionChip(
                          icon: Icons.mail_outline_rounded,
                          label: email,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: email));
                            showSnackBar("Email address copied", true);
                          },
                        ),
                      if (phone.isNotEmpty)
                        _buildQuickActionChip(
                          icon: Icons.phone_outlined,
                          label: formatPhoneWithCountryCode(phone),
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: formatPhoneWithCountryCode(phone)));
                            showSnackBar("Phone number copied", true);
                          },
                        ),
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

  Widget _buildInitialsAvatar(String name) {
    final String initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'N';
    return Container(
      color: const Color(0xFFEFF6FF),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDeepBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionChip({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppTheme.primaryDeepBlue),
            const SizedBox(width: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF334155),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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

  // ===========================================================================
  // 2. ABOUT US & MISSION SECTION
  // ===========================================================================
  Widget _buildAboutUsSection(NgoDetailsData data) {
    final String aboutText = (data.about != null && data.about!.trim().isNotEmpty)
        ? data.about!.trim()
        : ((data.briefProfile != null && data.briefProfile!.trim().isNotEmpty)
            ? data.briefProfile!.trim()
            : ((data.ourMission != null && data.ourMission!.trim().isNotEmpty)
                ? data.ourMission!.trim()
                : ''));

    if (aboutText.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: "About Us",
      icon: Icons.article_outlined,
      iconColor: const Color(0xFF0284C7),
      child: Text(
        aboutText,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: const Color(0xFF334155),
          height: 1.55,
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. WEBSITE URL OF YOUR ORGANIZATION
  // ===========================================================================
  Widget _buildWebsiteUrlSection(NgoDetailsData data) {
    final String url = data.websiteUrl?.trim() ?? '';
    if (url.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: "Website URL of your Organization",
      icon: Icons.public_outlined,
      iconColor: const Color(0xFF059669),
      child: Material(
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
      ),
    );
  }

  // ===========================================================================
  // 2. HAVE YOU CROWDFUNDED BEFORE?
  // ===========================================================================
  Widget _buildHaveYouCrowdfundedSection(NgoDetailsData data) {
    bool? hasCrowdfunded;
    if (data.hasCrowdfundedBefore != null) {
      final s = data.hasCrowdfundedBefore.toString().trim().toLowerCase();
      if (s == 'true' || s == 'yes' || s == '1') {
        hasCrowdfunded = true;
      } else if (s == 'no' || s == 'false' || s == '0') {
        hasCrowdfunded = false;
      }
    }

    final platform = data.crowdfundingPlatformsUsed?.trim() ?? '';

    // If platform name is present, user has crowdfunded before
    if (hasCrowdfunded == null && platform.isNotEmpty) {
      hasCrowdfunded = true;
    }

    // When in this section data is not available then should not show
    if (hasCrowdfunded == null && platform.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isYes = hasCrowdfunded == true;

    return _buildSectionCard(
      title: "Have you crowdfunded before?",
      icon: Icons.campaign_outlined,
      iconColor: const Color(0xFFE11D48),
      trailing: _buildYesNoBadge(isYes),
      child: isYes && platform.isNotEmpty
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
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
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

  // ===========================================================================
  // 3. PURPOSE OF FUNDRAISING/ CAUSE/S SUPPORTED
  // ===========================================================================
  Widget _buildPurposeAndCausesSection(NgoDetailsData data) {
    final purpose = data.purposeOfFundraising?.trim() ?? '';
    final List<String> causes = (data.causesSupported ?? [])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final displayCauses = causes.where((c) => c.toLowerCase() != purpose.toLowerCase()).toList();

    final bool hasData = purpose.isNotEmpty || displayCauses.isNotEmpty;
    if (!hasData) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: "Purpose of fundraising/ Cause/s Supported",
      icon: Icons.volunteer_activism_outlined,
      iconColor: const Color(0xFFE11D48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (purpose.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                purpose,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF334155),
                  height: 1.55,
                ),
              ),
            ),
          if (purpose.isNotEmpty && displayCauses.isNotEmpty)
            const SizedBox(height: 12),
          if (displayCauses.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: displayCauses.map((cause) {
                final meta = _getCauseMeta(cause);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.08),
                    border: Border.all(color: meta.color.withValues(alpha: 0.25), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(meta.icon, size: 14, color: meta.color),
                      const SizedBox(width: 6),
                      Text(
                        cause,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: meta.color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CAUSES WE SUPPORT SECTION (Legacy fallback)
  // ===========================================================================
  Widget _buildCausesSection(NgoDetailsData data) {
    final List<String> causes = (data.causesSupported ?? [])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (causes.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: "Causes We Support",
      icon: Icons.volunteer_activism_outlined,
      iconColor: const Color(0xFFE11D48),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: causes.map((cause) {
          final meta = _getCauseMeta(cause);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.08),
              border: Border.all(color: meta.color.withValues(alpha: 0.25), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(meta.icon, size: 14, color: meta.color),
                const SizedBox(width: 6),
                Text(
                  cause,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: meta.color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  _CauseMeta _getCauseMeta(String cause) {
    final lower = cause.toLowerCase();
    if (lower.contains('education') || lower.contains('school') || lower.contains('book')) {
      return _CauseMeta(Icons.menu_book_rounded, const Color(0xFF1565C0));
    } else if (lower.contains('food') || lower.contains('hunger') || lower.contains('meal')) {
      return _CauseMeta(Icons.soup_kitchen_rounded, const Color(0xFFE65100));
    } else if (lower.contains('gau') || lower.contains('cow') || lower.contains('animal')) {
      return _CauseMeta(Icons.pets_rounded, const Color(0xFF2E7D32));
    } else if (lower.contains('health') || lower.contains('medical') || lower.contains('care')) {
      return _CauseMeta(Icons.medical_services_rounded, const Color(0xFFC62828));
    } else if (lower.contains('community') || lower.contains('development') || lower.contains('social')) {
      return _CauseMeta(Icons.groups_rounded, const Color(0xFF6A1B9A));
    } else if (lower.contains('environment') || lower.contains('tree') || lower.contains('nature')) {
      return _CauseMeta(Icons.eco_rounded, const Color(0xFF00796B));
    } else if (lower.contains('women') || lower.contains('girl')) {
      return _CauseMeta(Icons.female_rounded, const Color(0xFFAD1457));
    }
    return _CauseMeta(Icons.volunteer_activism_rounded, const Color(0xFF022658));
  }

  // ===========================================================================
  // 4. ORGANIZATION & LEGAL DETAILS SECTION
  // ===========================================================================
  Widget _buildOrganizationAndLegalSection(NgoDetailsData data) {
    final regType = _cleanRegistrationType(data.isRegisteredNonProfit ?? data.organizationType);
    final legalName = data.legalName?.trim() ?? data.name?.trim() ?? '';
    final regNum = data.registrationNumber?.trim() ?? '';
    final address = data.registeredAddress?.trim() ?? '';
    final certDoc = data.registrationCertificate?.trim() ?? data.addressCertificate?.trim() ?? '';

    dynamic moaDocs = data.moaAoaDocuments;
    List<String> byeLawsList = [];
    if (moaDocs is List) {
      byeLawsList = moaDocs.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    } else if (moaDocs != null && moaDocs.toString().trim().isNotEmpty) {
      byeLawsList = [moaDocs.toString().trim()];
    }

    final bool hasAnyData = regType.isNotEmpty ||
        legalName.isNotEmpty ||
        regNum.isNotEmpty ||
        address.isNotEmpty ||
        certDoc.isNotEmpty ||
        byeLawsList.isNotEmpty;

    if (!hasAnyData) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: "Organization & Legal Details",
      icon: Icons.account_balance_outlined,
      iconColor: const Color(0xFF2563EB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (regType.isNotEmpty)
            _buildInfoRow("Registration Type", regType),
          if (legalName.isNotEmpty)
            _buildInfoRow("Legal Organization Name", legalName),
          if (regNum.isNotEmpty)
            _buildInfoRow("Registration Number", regNum, isCopyable: true),
          if (address.isNotEmpty)
            _buildInfoRow("Registered Address", address, isCopyable: true),
          if (certDoc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Registration Certificate:",
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            _buildDocumentButton("Registration Certificate", certDoc),
            const SizedBox(height: 10),
          ],
          if (byeLawsList.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "MOA & AOA / Trust Deed / Bye-laws:",
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            Column(
              children: byeLawsList.asMap().entries.map((e) {
                final title = "Constitutional Document #${e.key + 1}";
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: _buildDocumentButton(title, e.value),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. STATUTORY & TAX IDENTIFIERS SECTION (PAN, TAN, GST)
  // ===========================================================================
  Widget _buildStatutoryTaxSection(NgoDetailsData data) {
    final pan = data.panNumber?.trim() ?? '';
    final panDoc = data.panDocument?.trim() ?? '';
    final tan = data.tanNumber?.trim() ?? '';
    final tanDoc = data.tanDocument?.trim() ?? '';
    final gst = data.gstNumber?.trim() ?? '';
    final gstDoc = data.gstDocument?.trim() ?? '';

    final bool hasPan = pan.isNotEmpty || panDoc.isNotEmpty;
    final bool hasTan = tan.isNotEmpty || tanDoc.isNotEmpty;
    final bool hasGst = gst.isNotEmpty || gstDoc.isNotEmpty;
    final bool hasTaxData = hasPan || hasTan || hasGst;

    if (!hasTaxData) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: "Statutory & Tax Identifiers",
      icon: Icons.badge_outlined,
      iconColor: const Color(0xFF7C3AED),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPan) ...[
            _buildTaxItemCard("PAN", pan, panDoc),
            if (hasTan || hasGst) const SizedBox(height: 10),
          ],
          if (hasTan) ...[
            _buildTaxItemCard("TAN", tan, tanDoc),
            if (hasGst) const SizedBox(height: 10),
          ],
          if (hasGst)
            _buildTaxItemCard("GST", gst, gstDoc),
        ],
      ),
    );
  }

  Widget _buildTaxItemCard(String label, String value, String docUrl) {
    final bool hasValue = value.isNotEmpty;
    final bool hasDoc = docUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$label Number:",
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
              ),
              if (hasValue)
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    showSnackBar("$label copied: $value", true);
                  },
                  child: Row(
                    children: [
                      Text(
                        value.toUpperCase(),
                        style: GoogleFonts.robotoMono(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF2563EB)),
                    ],
                  ),
                )
              else
                Text(
                  "No data available",
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
            ],
          ),
          if (hasDoc) ...[
            const SizedBox(height: 8),
            _buildDocumentButton("$label Document", docUrl),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. VERIFICATION & CERTIFICATIONS SECTION (12A, 80G, DARPAN, CSR-1, FCRA)
  // ===========================================================================
  Widget _buildCertificationsSection(NgoDetailsData data) {
    final certItems = <_CertBadgeItem>[];

    // 1. 12A
    final has12a = data.has12A == true ||
        (data.registration12A != null && data.registration12A!.isNotEmpty) ||
        (data.certificate12A != null && data.certificate12A!.isNotEmpty);
    if (has12a) {
      certItems.add(
        _CertBadgeItem(
          title: "12A",
          subtitle: "Certified",
          icon: Icons.verified_user_outlined,
          documentUrl: data.certificate12A,
          number: data.registration12A,
        ),
      );
    }

    // 2. 80G
    final has80g = data.has80G == true ||
        (data.registration80G != null && data.registration80G!.isNotEmpty) ||
        (data.certificate80G != null && data.certificate80G!.isNotEmpty);
    if (has80g) {
      certItems.add(
        _CertBadgeItem(
          title: "80G",
          subtitle: "Certified",
          icon: Icons.card_giftcard_outlined,
          documentUrl: data.certificate80G,
          number: data.registration80G,
        ),
      );
    }

    // 3. DARPAN
    final hasDarpan = data.hasDarpan == true ||
        (data.darpanNumber != null && data.darpanNumber!.isNotEmpty) ||
        (data.darpanCertificate != null && data.darpanCertificate!.isNotEmpty);
    if (hasDarpan) {
      certItems.add(
        _CertBadgeItem(
          title: "DARPAN",
          subtitle: "Registered",
          icon: Icons.account_balance_wallet_outlined,
          documentUrl: data.darpanCertificate,
          number: data.darpanNumber,
        ),
      );
    }

    // 4. CSR-1
    final hasCsr1 = data.hasCSR1 == true ||
        (data.csr1Number != null && data.csr1Number!.isNotEmpty) ||
        (data.csr1Certificate != null && data.csr1Certificate!.isNotEmpty);
    if (hasCsr1) {
      certItems.add(
        _CertBadgeItem(
          title: "CSR-1",
          subtitle: "Certified",
          icon: Icons.handshake_outlined,
          documentUrl: data.csr1Certificate,
          number: data.csr1Number,
        ),
      );
    }

    // 5. FCRA
    final hasFcra = data.hasFCRA == true ||
        (data.fcraNumber != null && data.fcraNumber!.isNotEmpty) ||
        (data.fcraCertificate != null && data.fcraCertificate!.isNotEmpty);
    if (hasFcra) {
      certItems.add(
        _CertBadgeItem(
          title: "FCRA",
          subtitle: "Certified",
          icon: Icons.language_outlined,
          documentUrl: data.fcraCertificate,
          number: data.fcraNumber,
        ),
      );
    }

    // 6. Other Registration
    if (data.hasOtherRegistration == true || (data.otherRegistrationName != null && data.otherRegistrationName!.isNotEmpty)) {
      certItems.add(
        _CertBadgeItem(
          title: data.otherRegistrationName ?? "Other",
          subtitle: "Registered",
          icon: Icons.assignment_outlined,
          documentUrl: data.otherRegistrationCertificate,
          number: null,
        ),
      );
    }

    if (certItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: "Verification & Certifications",
      icon: Icons.verified_outlined,
      iconColor: const Color(0xFF059669),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: certItems.map((item) {
            return InkWell(
              onTap: () => _showCertDetailsDialog(context, item),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 96,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE8F5E9),
                      ),
                      child: Icon(
                        item.icon,
                        color: const Color(0xFF2E7D32),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCertDetailsDialog(BuildContext context, _CertBadgeItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "${item.title} Certification",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status: ${item.subtitle}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            if (item.number != null && item.number!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text("Registration ID: ", style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B))),
                  Expanded(
                    child: Text(
                      item.number!,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
            ],
            if (item.documentUrl != null && item.documentUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openDocumentPreview(context, "${item.title} Certificate", item.documentUrl!);
                  },
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                  label: const Text("View Certificate Document"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDeepBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. OUR LEADERSHIP & MANAGEMENT SECTION
  // ===========================================================================
  Widget _buildLeadershipSection(NgoDetailsData data) {
    final List<LeadershipMember> leadership = (data.leadership ?? [])
        .where((m) => (m.name?.trim().isNotEmpty ?? false) || (m.designation?.trim().isNotEmpty ?? false))
        .toList();

    if (leadership.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: "Our Leadership & Management",
      icon: Icons.supervisor_account_outlined,
      iconColor: const Color(0xFF0D9488),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFCCFBF1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "${leadership.length} Members",
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0F766E)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: leadership.map((member) => _buildLeadershipCard(member)).toList(),
        ),
      ),
    );
  }

  Widget _buildLeadershipCard(LeadershipMember member) {
    final String name = member.name?.trim() ?? "No data available";
    final String designation = member.designation?.trim() ?? "Executive";
    final String email = member.email?.trim() ?? '';
    final String linkedIn = member.linkedInUrl?.trim() ?? '';
    final String pan = member.pan?.trim() ?? '';

    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primaryDeepBlue.withValues(alpha: 0.1),
                child: member.photo != null && member.photo!.trim().isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: member.photo!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorWidget: (c, u, e) => Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'L',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryDeepBlue),
                          ),
                        ),
                      )
                    : Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'L',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryDeepBlue),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      designation,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFE2E8F0)),
          if (email.isNotEmpty)
            _buildMiniSubfield("Email", email),
          if (pan.isNotEmpty)
            _buildMiniSubfield("PAN", pan),
          if (linkedIn.isNotEmpty) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: linkedIn));
                showSnackBar("LinkedIn URL copied", true);
              },
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0077B5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        "in",
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, height: 1.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text("LinkedIn Profile", style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF0077B5), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniSubfield(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        children: [
          Text("$label: ", style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 8. AUTHORIZED REPRESENTATIVE DETAILS SECTION
  // ===========================================================================
  Widget _buildAuthorizedPersonSection(NgoDetailsData data) {
    Map<String, dynamic> filler = {};
    if (data.formFillerDetails is Map) {
      filler = Map<String, dynamic>.from(data.formFillerDetails);
    }

    final name = data.authorizedPerson?.trim() ?? filler['name']?.toString().trim() ?? '';
    final desig = data.designation?.trim() ?? filler['designationRole']?.toString().trim() ?? filler['designation']?.toString().trim() ?? '';
    final phone = filler['phone']?.toString().trim() ?? data.phone?.trim() ?? '';
    final email = filler['email']?.toString().trim() ?? data.email?.trim() ?? '';
    final authLetter = data.authorityLetter?.trim() ?? filler['authorityLetter']?.toString().trim() ?? '';

    final bool hasData = name.isNotEmpty || desig.isNotEmpty || phone.isNotEmpty || email.isNotEmpty || authLetter.isNotEmpty;

    if (!hasData) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: "Authorized Representative",
      icon: Icons.person_pin_outlined,
      iconColor: const Color(0xFF0D9488),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name.isNotEmpty)
            _buildInfoRow("Representative Name", name),
          if (desig.isNotEmpty)
            _buildInfoRow("Designation", desig),
          if (phone.isNotEmpty)
            _buildInfoRow("Contact Phone", formatPhoneWithCountryCode(phone), isCopyable: true),
          if (email.isNotEmpty)
            _buildInfoRow("Contact Email", email, isCopyable: true),
          if (authLetter.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("Authority Letter:", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
            const SizedBox(height: 6),
            _buildDocumentButton("Authority Letter", authLetter),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // 9. BANK & PAYOUT DETAILS SECTION
  // ===========================================================================
  Widget _buildBankDetailsSection(NgoDetailsData data) {
    final bankName = data.bankName?.trim() ?? '';
    final branch = data.bankBranch?.trim() ?? '';
    final holder = data.bankAccountHolder?.trim() ?? '';
    final accNo = data.bankAccountNumber?.trim() ?? '';
    final ifsc = data.bankIFSC?.trim() ?? '';
    final chequeUrl = data.cancelledChequeDoc?.trim() ?? '';

    final bool hasBankData = bankName.isNotEmpty || holder.isNotEmpty || accNo.isNotEmpty || ifsc.isNotEmpty || chequeUrl.isNotEmpty;
    if (!hasBankData) return const SizedBox.shrink();

    return _buildSectionCard(
      title: "Bank & Payout Details",
      icon: Icons.account_balance_rounded,
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
            if (holder.isNotEmpty)
              _buildSubfieldRow("Account Name", holder),
            if (branch.isNotEmpty)
              _buildSubfieldRow("Branch", branch),
            if (accNo.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
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
                      width: 120,
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
            if (chequeUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                "Cancelled Cheque / Passbook Image:",
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF92400E)),
              ),
              const SizedBox(height: 6),
              _buildDocumentButton("Cancelled Cheque / Passbook", chequeUrl),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 10. OPERATIONAL & FUNDRAISING PROFILE SECTION
  // ===========================================================================
  Widget _buildOperationalStrengthSection(NgoDetailsData data) {
    final budget = data.lastFinancialYearBudget?.trim() ?? '';
    final donors = data.donorDatabaseStrength?.trim() ?? '';
    final staff = data.employeeStrength?.trim() ?? '';
    final timeframe = data.campaignPlanningTimeframe?.trim() ?? '';
    final platform = data.crowdfundingPlatformsUsed?.trim() ?? '';

    final bool hasData = budget.isNotEmpty || donors.isNotEmpty || staff.isNotEmpty || timeframe.isNotEmpty || platform.isNotEmpty;
    if (!hasData) return const SizedBox.shrink();

    return _buildSectionCard(
      title: "Operational & Fundraising Profile",
      icon: Icons.insights_outlined,
      iconColor: const Color(0xFF0284C7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (budget.isNotEmpty)
            _buildMetricBadgeRow("Last Financial Year's Budget", Icons.currency_rupee_rounded, budget),
          if (donors.isNotEmpty)
            _buildMetricBadgeRow("Total Donor Database", Icons.volunteer_activism_outlined, "$donors Donors"),
          if (staff.isNotEmpty)
            _buildMetricBadgeRow("Total Employee Strength", Icons.groups, "$staff Employees"),
          if (platform.isNotEmpty)
            _buildMetricBadgeRow("Crowdfunding Platforms Used", Icons.devices_other, platform),
          if (timeframe.isNotEmpty)
            _buildMetricBadgeRow("Campaign Planning Timeframe", Icons.calendar_today_outlined, timeframe),
        ],
      ),
    );
  }

  Widget _buildMetricBadgeRow(String title, IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: AppTheme.primaryDeepBlue),
                const SizedBox(width: 5),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 11. AWARDS & RECOGNITION SECTION
  // ===========================================================================
  Widget _buildAwardsSection(NgoDetailsData data) {
    final List<AwardItem> awards = (data.awards ?? []).where((a) {
      final name = a.name?.trim() ?? '';
      final desc = a.description?.trim() ?? '';
      final by = a.awardedBy?.trim() ?? '';
      final year = a.year?.trim() ?? '';
      return name.isNotEmpty || desc.isNotEmpty || by.isNotEmpty || year.isNotEmpty;
    }).toList();

    if (awards.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      title: "Awards & Recognitions",
      icon: Icons.emoji_events_outlined,
      iconColor: const Color(0xFFF59E0B),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "${awards.length} Awards",
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF92400E)),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _awardPageController,
              itemCount: awards.length,
              onPageChanged: (i) {
                setState(() {
                  _currentAwardIndex = i;
                });
              },
              itemBuilder: (context, index) {
                final award = awards[index];
                return _buildAwardCard(award);
              },
            ),
          ),
          if (awards.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(awards.length, (i) {
                final bool isActive = i == _currentAwardIndex;
                return Container(
                  width: isActive ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primaryDeepBlue : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAwardCard(AwardItem award) {
    final String name = award.name?.trim() ?? "Honorary Award";
    final String awardedBy = award.awardedBy?.trim() ?? '';
    final String year = award.year?.trim() ?? '';
    final String description = award.description?.trim() ?? '';
    final String docUrl = award.supportingDocument?.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFFDE68A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFF59E0B),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF92400E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (awardedBy.isNotEmpty)
                  Text("Awarded by: $awardedBy", style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF475569)), maxLines: 1),
                if (year.isNotEmpty)
                  Text("Year: $year", style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B))),
                if (description.isNotEmpty)
                  Text(description, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (docUrl.isNotEmpty) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _openDocumentPreview(context, name, docUrl),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFFDE68A)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.description_outlined, size: 18, color: Color(0xFFB45309)),
                    const SizedBox(height: 3),
                    Text(
                      "View\nDoc",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w600, color: const Color(0xFFB45309), height: 1.1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // 12. COMPLIANCE & DECLARATIONS SECTION
  // ===========================================================================
  Widget _buildDeclarationsSection(NgoDetailsData data) {
    final decData = data.declarations;
    final bool hasDeclaration = decData != null &&
        decData != false &&
        decData != 'false' &&
        decData.toString().trim().isNotEmpty &&
        !(decData is List && decData.isEmpty);

    if (!hasDeclaration) return const SizedBox.shrink();

    final List<String> declarations = [];
    if (decData is List) {
      for (final item in decData) {
        if (item != null && item.toString().trim().isNotEmpty) {
          declarations.add(item.toString().trim());
        }
      }
    } else if (decData is String &&
        decData.trim().isNotEmpty &&
        decData.trim().toLowerCase() != 'true' &&
        decData.trim().toLowerCase() != 'false') {
      declarations.add(decData.trim());
    }

    if (declarations.isEmpty) {
      declarations.addAll([
        "Documents submitted are verified and certified under applicable Non-Profit regulations.",
        "Donations received will be strictly utilized for authorized public charitable causes.",
        "Proper records and financial utilization reports are maintained and audited.",
      ]);
    }

    return _buildSectionCard(
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: declarations.map((dec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dec,
                      style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF166534), height: 1.4),
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
  // 13. RATINGS & REVIEWS SECTION (Complete breakdown & video support)
  // ===========================================================================
  Widget _buildReviewsSection(BuildContext context, NgoDetailsController? controller) {
    final ngoData = controller?.ngoDetails.value;
    final double rating = ngoData?.rating ?? 0.0;
    final List<ReviewItem> reviews = ngoData?.reviews ?? [];
    final int reviewCount = (ngoData?.reviewCount != null && ngoData!.reviewCount! > 0)
        ? ngoData.reviewCount!
        : reviews.length;
    final bool hasReviews = reviews.isNotEmpty;
    final bool hasReviewData = hasReviews || rating > 0 || reviewCount > 0;

    final Widget writeReviewButton = SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () => _showRateUsBottomSheet(context, controller),
        icon: Icon(Icons.rate_review_outlined, color: AppTheme.primaryDeepBlue, size: 18),
        label: Text(
          "Write a Review",
          style: GoogleFonts.poppins(color: AppTheme.primaryDeepBlue, fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.primaryDeepBlue),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );

    if (!hasReviewData) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: writeReviewButton,
      );
    }

    final int count5 = reviews.where((r) => (r.rating ?? 0) >= 4.5).length;
    final int count4 = reviews.where((r) => (r.rating ?? 0) >= 3.5 && (r.rating ?? 0) < 4.5).length;
    final int count3 = reviews.where((r) => (r.rating ?? 0) >= 2.5 && (r.rating ?? 0) < 3.5).length;
    final int count2 = reviews.where((r) => (r.rating ?? 0) >= 1.5 && (r.rating ?? 0) < 2.5).length;
    final int count1 = reviews.where((r) => (r.rating ?? 0) > 0 && (r.rating ?? 0) < 1.5).length;

    final int total = reviews.isNotEmpty ? reviews.length : 1;
    final double star5 = reviews.isNotEmpty ? (count5 / total) : ((rating >= 4.5) ? 1.0 : 0.0);
    final double star4 = reviews.isNotEmpty ? (count4 / total) : ((rating >= 3.5 && rating < 4.5) ? 1.0 : (rating >= 4.5 ? 0.3 : 0.0));
    final double star3 = reviews.isNotEmpty ? (count3 / total) : ((rating >= 2.5 && rating < 3.5) ? 1.0 : 0.0);
    final double star2 = reviews.isNotEmpty ? (count2 / total) : ((rating >= 1.5 && rating < 2.5) ? 1.0 : 0.0);
    final double star1 = reviews.isNotEmpty ? (count1 / total) : ((rating > 0 && rating < 1.5) ? 1.0 : 0.0);

    return _buildSectionCard(
      title: AppString.ratingsAndReviewsUpper.tr,
      icon: Icons.star_rounded,
      iconColor: const Color(0xFFF59E0B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.star, color: AppTheme.amberStars, size: 22),
                    ],
                  ),
                  Text(
                    "$reviewCount ${reviewCount == 1 ? 'Review' : 'Reviews'}",
                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBarRow("5", star5),
                    _buildRatingBarRow("4", star4),
                    _buildRatingBarRow("3", star3),
                    _buildRatingBarRow("2", star2),
                    _buildRatingBarRow("1", star1),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (hasReviews) ...[
            if (reviews.length == 1)
              _buildReviewCard(reviews[0], width: double.infinity)
            else
              SizedBox(
                height: reviews.any((r) => r.hasVideo) ? 255 : 135,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _buildReviewCard(reviews[index], width: 260),
                ),
              ),
            const SizedBox(height: 16),
          ],

          // Write a Review Button
          writeReviewButton,
          if (hasReviews) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: () => Get.toNamed(MyRouters.myReviewsScreen),
                child: Text(
                  "View All Reviews",
                  style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewItem item, {required double width}) {
    final double rVal = item.rating ?? 0.0;
    final String commentText = (item.comment != null && item.comment!.isNotEmpty)
        ? item.comment!
        : "No review comment";
    final String authorStr = (item.userName != null && item.userName!.isNotEmpty)
        ? item.userName!
        : "Donor";
    final bool hasVideo = item.hasVideo;

    return Container(
      width: width,
      height: width == double.infinity ? null : (hasVideo ? 250 : 135),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                commentText,
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                maxLines: hasVideo ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasVideo) ...[
                const SizedBox(height: 8),
                ReviewVideoWidget(
                  videoUrl: item.effectiveVideoUrl,
                  height: 110,
                  width: double.infinity,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  authorStr,
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.ratingGreenBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: AppTheme.whiteColor, size: 10),
                    const SizedBox(width: 2),
                    Text(
                      rVal.toStringAsFixed(1),
                      style: GoogleFonts.poppins(color: AppTheme.whiteColor, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBarRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E293B)),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 14. BOTTOM BAR (Follow + Donate / Support Us)
  // ===========================================================================
  Widget _buildBottomBar(NgoDetailsData data, bool isOwnProfile) {
    final String ngoId = data.id ?? (Get.arguments is Map ? Get.arguments['id'] : (Get.arguments is String ? Get.arguments : '')) ?? '';
    final FollowsController followsController = Get.put(FollowsController());

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: isOwnProfile
              ? SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00875A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Get.toNamed('/editProfileScreen'),
                    icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                    label: Text(
                      AppString.editProfile.tr,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : Row(
                  children: [
                    // Follow/Unfollow Button
                    Expanded(
                      flex: 1,
                      child: Obx(() {
                        final bool isFollowing = ngoId.isNotEmpty && followsController.isNgoFollowed(ngoId);
                        return OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.primaryDeepBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            if (ngoId.isNotEmpty) {
                              followsController.toggleFollowNgoApi(ngoId);
                            }
                          },
                          child: Text(
                            isFollowing ? AppString.unfollow.tr : AppString.follow.tr,
                            style: TextStyle(color: AppTheme.primaryDeepBlue, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),

                    // Donate / Support Us Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00875A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          final String? logoUrl = data.logo;
                          final String ngoName = data.name ?? (Get.arguments is Map ? Get.arguments['name'] : 'NGO');

                          Get.toNamed(
                            MyRouters.donateAmountScreen,
                            arguments: {
                              'isNgo': true,
                              'id': ngoId,
                              'name': ngoName,
                              'logoUrl': logoUrl ?? "",
                            },
                          );
                        },
                        icon: const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                        label: Text(
                          "Donate / Support Us",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPER WIDGETS (Section Cards, Document Buttons, Info Rows, Empty States)
  // ===========================================================================
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (child is! SizedBox || child.width != 0 || child.height != 0) ...[
            const SizedBox(height: 14),
            child,
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isCopyable = false}) {
    final bool isNone = value == "No data available";
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isCopyable && !isNone
                ? InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      showSnackBar("$label copied", true);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            value,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF2563EB)),
                      ],
                    ),
                  )
                : Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: isNone ? FontWeight.w400 : FontWeight.w600,
                      color: isNone ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubfieldRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isLink
                ? InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      showSnackBar("Copied: $value", true);
                    },
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB), decoration: TextDecoration.underline),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Text(
                    value,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentButton(String title, String url) {
    if (url.trim().isEmpty) return _buildNoDataCard(text: "No document uploaded");

    final bool isPdf = url.toLowerCase().contains('.pdf');

    return InkWell(
      onTap: () => _openDocumentPreview(context, title, url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          children: [
            Icon(
              isPdf ? Icons.picture_as_pdf_outlined : Icons.description_outlined,
              size: 18,
              color: isPdf ? const Color(0xFFD32F2F) : AppTheme.primaryDeepBlue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Text(
                "View Doc",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryDeepBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard({String text = "No data available"}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: const Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _openDocumentPreview(BuildContext context, String title, String url) {
    if (url.trim().isEmpty) return;
    final bool isPdf = url.toLowerCase().contains('.pdf');
    bool isDownloading = false;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isPdf ? Icons.picture_as_pdf_outlined : Icons.description_outlined,
                          size: 18,
                          color: isPdf ? const Color(0xFFD32F2F) : AppTheme.primaryDeepBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: url,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (c, u) => Center(
                    child: LoadingAnimationWidget.threeRotatingDots(
                      color: AppTheme.primaryDeepBlue,
                      size: 30,
                    ),
                  ),
                  errorWidget: (c, u, e) => Container(
                    height: 160,
                    width: double.infinity,
                    color: const Color(0xFFF8FAFC),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPdf ? Icons.picture_as_pdf_outlined : Icons.description_outlined,
                            color: isPdf ? const Color(0xFFD32F2F) : Colors.blueGrey,
                            size: 44,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isPdf ? "PDF Document Attached" : "Document Attached",
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              url,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (buttonCtx, setBtnState) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isDownloading
                          ? null
                          : () async {
                              setBtnState(() => isDownloading = true);
                              await _downloadDocument(url, title);
                              if (buttonCtx.mounted) {
                                setBtnState(() => isDownloading = false);
                              }
                            },
                      icon: isDownloading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                      label: Text(
                        isDownloading ? "Downloading..." : "Download",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryDeepBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadDocument(String url, String title) async {
    try {
      final cleanUrl = url.trim();
      final uri = Uri.tryParse(cleanUrl);
      if (uri == null || !uri.hasScheme) {
        showSnackBar("Invalid document URL", false);
        return;
      }

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        showSnackBar("Failed to download file (HTTP ${response.statusCode})", false);
        return;
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        showSnackBar("Downloaded file is empty", false);
        return;
      }

      final lowerUrl = cleanUrl.toLowerCase();
      String ext = '.jpg';
      if (lowerUrl.contains('.pdf')) {
        ext = '.pdf';
      } else if (lowerUrl.contains('.png')) {
        ext = '.png';
      } else if (lowerUrl.contains('.jpeg')) {
        ext = '.jpeg';
      } else if (lowerUrl.contains('.webp')) {
        ext = '.webp';
      }

      String fileName = '';
      if (cleanUrl.contains('#')) {
        final fragment = Uri.tryParse(cleanUrl)?.fragment ?? '';
        final match = RegExp(r'name=([^&]+)').firstMatch(fragment);
        if (match != null) {
          fileName = Uri.decodeComponent(match.group(1)!);
        }
      }

      if (fileName.isEmpty) {
        final pathWithoutQuery = cleanUrl.split('#').first.split('?').first;
        final cleanUri = Uri.tryParse(pathWithoutQuery);
        final lastSeg = cleanUri?.pathSegments.isNotEmpty == true ? cleanUri!.pathSegments.last : '';
        if (lastSeg.isNotEmpty && (lastSeg.contains('.') || lastSeg.length > 3)) {
          fileName = lastSeg;
        }
      }

      final safeTitle = title.trim().replaceAll(RegExp(r'[^\w\s\.-]'), '').replaceAll(' ', '_');
      if (fileName.isEmpty) {
        fileName = '${safeTitle.isNotEmpty ? safeTitle : "document"}_${DateTime.now().millisecondsSinceEpoch}$ext';
      } else if (!fileName.contains('.')) {
        fileName += ext;
      }

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

      if (savedFilePath.isNotEmpty) {
        showSnackBar("Downloaded successfully: $fileName", true);
        try {
          await OpenFilex.open(savedFilePath);
        } catch (_) {}
      } else {
        showSnackBar("Could not save file to device storage", false);
      }
    } catch (e) {
      showSnackBar("Error downloading document: ${e.toString()}", false);
    }
  }

  // ===========================================================================
  // RATE US BOTTOM SHEET
  // ===========================================================================
  void _showRateUsBottomSheet(BuildContext context, NgoDetailsController? controller) {
    int selectedStars = 0;
    final TextEditingController feedbackController = TextEditingController();
    XFile? selectedVideo;
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Rate Us",
                              style: AppFonts.titleStyle.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 20, color: Color(0xFF475569)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tell us your experience",
                        style: AppFonts.regularText.copyWith(color: const Color(0xFF64748B), fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedStars = index + 1;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.star,
                                color: index < selectedStars ? const Color(0xFFFFB800) : Colors.grey.shade300,
                                size: 36,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.fieldBorderColor),
                        ),
                        child: TextField(
                          controller: feedbackController,
                          maxLines: 4,
                          maxLength: 200,
                          onChanged: (_) => setState(() {}),
                          style: AppFonts.regularText.copyWith(fontSize: 14, color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: "Write your Feedback...",
                            hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                            counterText: "",
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${feedbackController.text.length}/200",
                          style: AppFonts.regularText.copyWith(fontSize: 12, color: const Color(0xFF94A3B8)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (selectedVideo != null)
                        ReviewVideoWidget(
                          videoFile: File(selectedVideo!.path),
                          height: 130,
                          width: double.infinity,
                          onDelete: () {
                            setState(() {
                              selectedVideo = null;
                            });
                          },
                        )
                      else
                        InkWell(
                          onTap: () async {
                            final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
                            if (video != null) {
                              final file = File(video.path);
                              if (file.existsSync()) {
                                final int sizeInBytes = await file.length();
                                const int max10MB = 10 * 1024 * 1024;
                                if (sizeInBytes > max10MB) {
                                  showSnackBar("Video size must not exceed 10 MB", false);
                                  return;
                                }
                              }
                              setState(() {
                                selectedVideo = video;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.fieldBorderColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.videocam_outlined, color: Color(0xFF1E293B), size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  "Upload Video Review (Optional)",
                                  style: AppFonts.semiBoldText.copyWith(
                                    color: const Color(0xFF1E293B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  "May be later",
                                  style: AppFonts.semiBoldText.copyWith(
                                    color: const Color(0xFF475569),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: controller != null
                                  ? Obx(() {
                                      bool isLoading = controller.isSubmittingReview.value;
                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () async {
                                                if (selectedStars <= 0) {
                                                  showSnackBar("Rating is required", false);
                                                  return;
                                                }
                                                if (feedbackController.text.trim().isEmpty) {
                                                  showSnackBar("Review message is required", false);
                                                  return;
                                                }
                                                File? videoFile = selectedVideo != null ? File(selectedVideo!.path) : null;
                                                if (videoFile != null && videoFile.existsSync()) {
                                                  final int sizeInBytes = await videoFile.length();
                                                  const int max10MB = 10 * 1024 * 1024;
                                                  if (sizeInBytes > max10MB) {
                                                    showSnackBar("Video size must not exceed 10 MB", false);
                                                    return;
                                                  }
                                                }
                                                String targetName = controller.ngoDetails.value?.name ??
                                                    (Get.arguments is Map ? Get.arguments['name'] : 'NGO') ??
                                                    'NGO';
                                                bool success = await controller.addReview(
                                                  targetName,
                                                  selectedStars,
                                                  feedbackController.text.trim(),
                                                  type: "NGO",
                                                  videoFile: videoFile,
                                                );
                                                if (success) {
                                                  controller.fetchNgoDetails(forceRefresh: true);
                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                    _showThanksBottomSheet(context, selectedStars);
                                                  }
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryDeepBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Text(
                                                "Submit",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      );
                                    })
                                  : ElevatedButton(
                                      onPressed: () {
                                        if (selectedStars <= 0) {
                                          showSnackBar("Rating is required", false);
                                          return;
                                        }
                                        if (feedbackController.text.trim().isEmpty) {
                                          showSnackBar("Review is required", false);
                                          return;
                                        }
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryDeepBlue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        "Submit",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
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

  String _getSmileyForRating(int rating) {
    switch (rating) {
      case 1:
        return "😡";
      case 2:
        return "🙁";
      case 3:
        return "😐";
      case 4:
        return "🙂";
      case 5:
        return "😍";
      default:
        return "😍";
    }
  }

  void _showThanksBottomSheet(BuildContext context, int rating) {
    final String smiley = _getSmileyForRating(rating);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(smiley, style: const TextStyle(fontSize: 48)),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.greyBg50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18, color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text("Thanks!", style: AppFonts.titleStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Tell us your experience", style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star,
                      color: index < rating ? AppTheme.amberStars : Colors.grey.shade300,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _CauseMeta {
  final IconData icon;
  final Color color;
  _CauseMeta(this.icon, this.color);
}

class _CertBadgeItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? documentUrl;
  final String? number;

  _CertBadgeItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.documentUrl,
    this.number,
  });
}
