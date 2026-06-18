
import 'package:get/get.dart';

import '../Screens/auth/login_screen.dart';
import '../Screens/auth/otp_verification_screen.dart';
import '../Screens/auth/phone_verification_screen.dart';
import '../Screens/auth/signup_screen.dart';
import '../Screens/auth/success_screen.dart';
import '../Screens/onboarding_screen.dart';
import '../Screens/profile/profile_setup_screen.dart';
import '../Screens/auth/role_selection_screen.dart';
import '../Screens/auth/ngo_profile_setup_screen.dart';
import '../Screens/auth/ngo_documents_verification_screen.dart';
import '../Screens/auth/ngo_bank_details_screen.dart';
import '../Screens/splash_screen.dart';
import '../Screens/dashboard/main_navigation_screen.dart';
import '../Screens/dashboard/home_screen.dart';
import '../Screens/dashboard/search_screen.dart';
import '../Screens/dashboard/donate_screen.dart';
import '../Screens/dashboard/fundraisers_screen.dart';
import '../Screens/dashboard/campaign_details_screen.dart';
import '../Screens/dashboard/donate_amount_screen.dart';
import '../Screens/dashboard/payment_method_screen.dart';
import '../Screens/dashboard/payment_success_screen.dart';
import '../Screens/daan/choose_daan_type_screen.dart';
import '../Screens/daan/donate_food_screen.dart';
import '../Screens/daan/daan_details_screen.dart';
import '../Screens/daan/choose_impact_screen.dart';
import '../Screens/daan/review_pay_screen.dart';
import '../Screens/dashboard/notification_screen.dart';
import '../Screens/dashboard/ngo_categories_screen.dart';
import '../Screens/dashboard/ngos_screen.dart';
import '../Screens/dashboard/ngo_details_screen.dart';
import '../Screens/dashboard/raise_campaign_wizard_screen.dart';
import '../Screens/dashboard/raise_campaign_preview_screen.dart';
import '../Screens/wallet/wallet_screen.dart';
import '../Screens/wallet/transactions_screen.dart';



import '../Screens/wallet/add_money_screen.dart';
import '../Screens/profile/profile_screen.dart';
import '../Screens/profile/donation_history_screen.dart';
import '../Screens/profile/active_campaigns_screen.dart';
import '../Screens/profile/following_ngos_screen.dart';
import '../Screens/profile/referral_rewards_screen.dart';
import '../Screens/profile/help_support_screen.dart';
import '../Screens/profile/settings_screen.dart';
import '../Screens/profile/privacy_policy_screen.dart';
import '../Screens/profile/inactive_account_screen.dart';
import '../Screens/profile/terms_condition_screen.dart';
import '../Screens/profile/about_us_screen.dart';
import '../Screens/profile/edit_profile_screen.dart';
import '../Screens/profile/coupons_screen.dart';
import '../Screens/profile/my_reviews_screen.dart';
import '../Controller/home_controller.dart';
import '../Controller/daan_controller.dart';

class MyRouters {
  static var splash = "/splash";
  static var loginScreen = "/loginScreen";
  static var signupScreen = "/signupScreen";
  static var phoneVerificationScreen = "/phoneVerificationScreen";
  static var otpVerificationScreen = "/otpVerificationScreen";
  static var roleSelectionScreen = "/roleSelectionScreen";
  static var ngoProfileSetupScreen = "/ngoProfileSetupScreen";
  static var ngoDocumentsVerificationScreen = "/ngoDocumentsVerificationScreen";
  static var ngoBankDetailsScreen = "/ngoBankDetailsScreen";
  static var profileSetupScreen = "/profileSetupScreen";
  static var onboardingScreen = "/onboardingScreen";
  static var successScreen = "/successScreen";
  static var mainNav = "/mainNav";
  static var homeScreen = "/homeScreen";
  static var searchScreen = "/searchScreen";
  static var donateScreen = "/donateScreen";
  static var fundraisersScreen = "/fundraisersScreen";
  static var campaignDetailsScreen = "/campaignDetailsScreen";
  static var donateAmountScreen = "/donateAmountScreen";
  static var paymentMethodScreen = "/paymentMethodScreen";
  static var paymentSuccessScreen = "/paymentSuccessScreen";
  
  // Daan Screens
  static var chooseDaanTypeScreen = "/chooseDaanTypeScreen";
  static var donateFoodScreen = "/donateFoodScreen";
  static var daanDetailsScreen = "/daanDetailsScreen";
  static var chooseImpactScreen = "/chooseImpactScreen";
  static var reviewPayScreen = "/reviewPayScreen";
  static var notificationScreen = "/notificationScreen";
  static var ngosScreen = "/ngosScreen";
  static var ngosGridScreen = "/ngosGridScreen";
  static var ngoDetailsScreen = "/ngoDetailsScreen";
  static var raiseCampaignWizardScreen = "/raiseCampaignWizardScreen";
  static var raiseCampaignPreviewScreen = "/raiseCampaignPreviewScreen";
  static var walletScreen = "/walletScreen";
  static var transactionsScreen = "/transactionsScreen";
  static var addMoneyScreen = "/addMoneyScreen";
  static var profileScreen = "/profileScreen";
  static var donationHistoryScreen = "/donationHistoryScreen";
  static var activeCampaignsScreen = "/activeCampaignsScreen";
  static var followingNgosScreen = "/followingNgosScreen";
  static var referralRewardsScreen = "/referralRewardsScreen";
  static var helpSupportScreen = "/helpSupportScreen";
  static var settingsScreen = "/settingsScreen";
  static var privacyPolicyScreen = "/privacyPolicyScreen";
  static var inactiveAccountScreen = "/inactiveAccountScreen";
  static var termsConditionScreen = "/termsConditionScreen";
  static var aboutUsScreen = "/aboutUsScreen";
  static var editProfileScreen = "/editProfileScreen";
  static var couponsScreen = "/couponsScreen";
  static var myReviewsScreen = "/myReviewsScreen";

  static var route = [
    GetPage(name: '/', page: () => const SplashScreen()),
    GetPage(name: "/loginScreen", page: () => const LoginScreen()),
    GetPage(name: "/signupScreen", page: () => const SignupScreen()),
    GetPage(name: "/phoneVerificationScreen", page: () => const PhoneVerificationScreen()),
    GetPage(name: "/otpVerificationScreen", page: () => const OTPVerificationScreen()),
    GetPage(name: "/roleSelectionScreen", page: () => const RoleSelectionScreen()),
    GetPage(name: "/ngoProfileSetupScreen", page: () => const NgoProfileSetupScreen()),
    GetPage(name: "/ngoDocumentsVerificationScreen", page: () => const NgoDocumentsVerificationScreen()),
    GetPage(name: "/ngoBankDetailsScreen", page: () => const NgoBankDetailsScreen()),
    GetPage(name: "/profileSetupScreen", page: () => const ProfileSetupScreen()),
    GetPage(name: "/onboardingScreen", page: () => const OnboardingScreen()),
    GetPage(name: "/successScreen", page: () => const SuccessScreen()),
    GetPage(
      name: "/mainNav",
      page: () => const MainNavigationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
        Get.lazyPut<DaanController>(() => DaanController());
      }),
    ),
    GetPage(name: "/homeScreen", page: () => const HomeScreen()),
    GetPage(name: "/searchScreen", page: () => const SearchScreen()),
    GetPage(name: "/donateScreen", page: () => const DonateScreen()),
    GetPage(name: "/fundraisersScreen", page: () => const FundraisersScreen()),
    GetPage(name: "/campaignDetailsScreen", page: () => const CampaignDetailsScreen()),
    GetPage(name: "/donateAmountScreen", page: () => const DonateAmountScreen()),
    GetPage(name: "/paymentMethodScreen", page: () => const PaymentMethodScreen()),
    GetPage(name: "/paymentSuccessScreen", page: () => const PaymentSuccessScreen()),
    
    // Daan Pages
    GetPage(
      name: "/chooseDaanTypeScreen",
      page: () => const ChooseDaanTypeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DaanController>(() => DaanController());
      }),
    ),
    GetPage(
      name: "/donateFoodScreen",
      page: () => const DonateFoodScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DaanController>(() => DaanController());
      }),
    ),
    GetPage(
      name: "/daanDetailsScreen",
      page: () => const DaanDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DaanController>(() => DaanController());
      }),
    ),
    GetPage(
      name: "/chooseImpactScreen",
      page: () => const ChooseImpactScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DaanController>(() => DaanController());
      }),
    ),
    GetPage(
      name: "/reviewPayScreen",
      page: () => const ReviewPayScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DaanController>(() => DaanController());
      }),
    ),
    GetPage(name: "/notificationScreen", page: () => const NotificationScreen()),
    GetPage(name: "/ngosScreen", page: () => const NgoCategoriesScreen()),
    GetPage(name: "/ngosGridScreen", page: () => const NgosScreen()),
    GetPage(name: "/ngoDetailsScreen", page: () => const NgoDetailsScreen()),
    GetPage(name: "/raiseCampaignWizardScreen", page: () => const RaiseCampaignWizardScreen()),
    GetPage(name: "/raiseCampaignPreviewScreen", page: () => const RaiseCampaignPreviewScreen()),
    GetPage(name: "/walletScreen", page: () => const WalletScreen()),
    GetPage(name: "/transactionsScreen", page: () => const TransactionsScreen()),
    GetPage(name: "/addMoneyScreen", page: () => const AddMoneyScreen()),
    GetPage(name: "/profileScreen", page: () => const ProfileScreen()),
    GetPage(name: "/donationHistoryScreen", page: () => const DonationHistoryScreen()),
    GetPage(name: "/activeCampaignsScreen", page: () => const ActiveCampaignsScreen()),
    GetPage(name: "/followingNgosScreen", page: () => const FollowingNgosScreen()),
    GetPage(name: "/referralRewardsScreen", page: () => const ReferralRewardsScreen()),
    GetPage(name: "/helpSupportScreen", page: () => const HelpSupportScreen()),
    GetPage(name: "/settingsScreen", page: () => const SettingsScreen()),
    GetPage(name: "/privacyPolicyScreen", page: () => const PrivacyPolicyScreen()),
    GetPage(name: "/inactiveAccountScreen", page: () => const InactiveAccountScreen()),
    GetPage(name: "/termsConditionScreen", page: () => const TermsConditionScreen()),
    GetPage(name: "/aboutUsScreen", page: () => const AboutUsScreen()),
    GetPage(name: "/editProfileScreen", page: () => const EditProfileScreen()),
    GetPage(name: "/couponsScreen", page: () => const CouponsScreen()),
    GetPage(name: "/myReviewsScreen", page: () => const MyReviewsScreen()),
  ];
}
