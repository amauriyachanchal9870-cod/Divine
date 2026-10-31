

class ApiUrls{
  // static const String apiBaseUrl = 'https://divinebackend-v5gl.onrender.com/api';
  static const String apiBaseUrl = 'http://195.35.20.150:8000/api';



  static const String loginUrl = "$apiBaseUrl/auth/login";
  static const String verifyOtpUrl = "$apiBaseUrl/auth/verify-otp";
  static const String resendOtpUrl = "$apiBaseUrl/auth/resend-otp";
  static const String profileSetupUrl = "$apiBaseUrl/auth/profile-setup";
  static const String logoutUrl = "$apiBaseUrl/auth/logout";
  static const String registerUrl = "$apiBaseUrl/auth/register";
  static const String googleLoginUrl = "$apiBaseUrl/auth/google";
  static const String appleLoginUrl = "$apiBaseUrl/auth/apple";
  static const String deviceTokenUrl = "$apiBaseUrl/device-token";
  static const String removeDeviceTokenUrl = "$apiBaseUrl/device-token/remove";
  static const String homeUrl = "$apiBaseUrl/home";
  static String bannersUrl(String screen) => "$apiBaseUrl/banners?screen=$screen";
  static const String notificationsUrl = "$apiBaseUrl/donor/notifications";
  static const String readNotificationsUrl = "$apiBaseUrl/donor/notifications/read";
  static const String recentSearchesUrl = "$apiBaseUrl/donor/recent-searches";
  static const String profileUrl = "$apiBaseUrl/donor/profile";
  static const String donationHistoryUrl = "$apiBaseUrl/donor/donation-history";
  static const String ngoProfileUrl = "$apiBaseUrl/ngo/profile";
  static const String ngoDashboardUrl = "$apiBaseUrl/ngo/dashboard";
  static String getCampaignDetailsUrl(String id) => "$apiBaseUrl/donor/campaigns/$id";
  static const String donorCampaignsUrl = "$apiBaseUrl/donor/campaigns";
  static const String couponsUrl = "$apiBaseUrl/donor/coupons";
  static const String claimCouponUrl = "$apiBaseUrl/donor/coupons/claim";
  static const String socialUrl = "$apiBaseUrl/donor/social";
  static String followNgoUrl(String id) => "$apiBaseUrl/donor/follow/ngo/$id";
  static String followUserUrl(String id) => "$apiBaseUrl/donor/follow/user/$id";
  static String getNgoDetailsUrl(String id) => "$apiBaseUrl/donor/ngos/$id";
  static const String donorNgosUrl = "$apiBaseUrl/donor/ngos";
  static const String donateUrl = "$apiBaseUrl/auth/wallet/donate";
  static const String addReviewUrl = "$apiBaseUrl/donor/reviews";
  static const String submitReviewUrl = "$apiBaseUrl/donor/reviews";
  static const String donorReviewsUrl = "$apiBaseUrl/donor/reviews";
  static String campaignReviewsUrl(String campaignId) => "$apiBaseUrl/campaigns/$campaignId/reviews";
  static const String walletUrl = "$apiBaseUrl/donor/wallet";
  static const String topupUrl = "$apiBaseUrl/auth/wallet/topup";
  static const String danCategoriesUrl = "$apiBaseUrl/dan/categories";
  static String danSubCategoriesUrl(String categoryId) => "$apiBaseUrl/dan/subcategories?categoryId=$categoryId";
  static String danItemsUrl(String subcategoryId) => "$apiBaseUrl/dan/items?subcategory=$subcategoryId";
  static const String danDonateUrl = "$apiBaseUrl/dan/donate";
  static const String referralsUrl = "$apiBaseUrl/donor/referrals";
  static const String campaignCategoriesUrl = "$apiBaseUrl/campaign-categories";
  static const String donorCampaignCategoriesUrl = "$apiBaseUrl/donor/campaign-categories";
  static const String myCampaignsUrl = "$apiBaseUrl/donor/my-campaigns";
  static String activateCampaignUrl(String campaignId) => "$apiBaseUrl/donor/campaigns/$campaignId/activate";
  static String deactivateCampaignUrl(String campaignId) => "$apiBaseUrl/donor/campaigns/$campaignId/deactivate";
  static const String followersUrl = "$apiBaseUrl/donor/followers";
  static const String followingUrl = "$apiBaseUrl/donor/following";
  static const String masterSettingsUrl = "$apiBaseUrl/master-settings";
  static const String razorpayKey = "rzp_test_TWj8ZkqNeZ488K";

  /// ImgBB API key for image uploads (permanent, works in India without ISP blocks).
  /// Get your FREE key in 2 minutes: https://api.imgbb.com/
  /// Steps: 1. Sign up at https://imgbb.com  2. Go to https://api.imgbb.com  3. Copy key here
  static const String imgbbApiKey = "31806e69ed56d8d20d20ae994961528f";
}
