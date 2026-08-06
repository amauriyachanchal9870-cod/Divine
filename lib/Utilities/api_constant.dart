

class ApiUrls{
  static const String apiBaseUrl = 'https://divinebackend-v5gl.onrender.com/api';
  static const String loginUrl = "$apiBaseUrl/auth/login";
  static const String verifyOtpUrl = "$apiBaseUrl/auth/verify-otp";
  static const String resendOtpUrl = "$apiBaseUrl/auth/resend-otp";
  static const String profileSetupUrl = "$apiBaseUrl/auth/profile-setup";
  static const String logoutUrl = "$apiBaseUrl/auth/logout";
  static const String registerUrl = "$apiBaseUrl/auth/register";
  static const String homeUrl = "$apiBaseUrl/home";
  static const String notificationsUrl = "$apiBaseUrl/donor/notifications";
  static const String readNotificationsUrl = "$apiBaseUrl/donor/notifications/read";
  static const String recentSearchesUrl = "$apiBaseUrl/donor/recent-searches";
  static const String profileUrl = "$apiBaseUrl/donor/profile";
  static const String ngoProfileUrl = "$apiBaseUrl/ngo/profile";
  static String getCampaignDetailsUrl(String id) => "$apiBaseUrl/donor/campaigns/$id";
  static const String donorCampaignsUrl = "$apiBaseUrl/donor/campaigns";
  static const String couponsUrl = "$apiBaseUrl/donor/coupons";
  static const String claimCouponUrl = "$apiBaseUrl/donor/coupons/claim";
  static const String socialUrl = "$apiBaseUrl/donor/social";
  static String followNgoUrl(String id) => "$apiBaseUrl/donor/follow/ngo/$id";
  static String followUserUrl(String id) => "$apiBaseUrl/donor/follow/user/$id";
  static String getNgoDetailsUrl(String id) => "$apiBaseUrl/donor/ngos/$id";
  static const String donateUrl = "$apiBaseUrl/auth/wallet/donate";
  static const String submitReviewUrl = "$apiBaseUrl/donor/reviews";
  static const String walletUrl = "$apiBaseUrl/donor/wallet";
  static const String topupUrl = "$apiBaseUrl/auth/wallet/topup";
  static const String danCategoriesUrl = "$apiBaseUrl/dan/categories";
  static String danSubCategoriesUrl(String categoryId) => "$apiBaseUrl/dan/subcategories?categoryId=$categoryId";
  static String danItemsUrl(String subcategoryId) => "$apiBaseUrl/dan/items?subcategory=$subcategoryId";
  static const String danDonateUrl = "$apiBaseUrl/dan/donate";
  static const String referralsUrl = "$apiBaseUrl/donor/referrals";
  static const String campaignCategoriesUrl = "$apiBaseUrl/campaign-categories";
}
