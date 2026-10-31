import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Utilities/api_constant.dart';

class RazorpayService {
  late Razorpay _razorpay;

  Function(PaymentSuccessResponse)? _onSuccessCallback;
  Function(PaymentFailureResponse)? _onFailureCallback;
  Function(ExternalWalletResponse)? _onExternalWalletCallback;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint("Razorpay Payment Success: ${response.paymentId}");
    if (_onSuccessCallback != null) {
      _onSuccessCallback!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Razorpay Payment Error: Code ${response.code} - ${response.message}");
    if (_onFailureCallback != null) {
      _onFailureCallback!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("Razorpay External Wallet: ${response.walletName}");
    if (_onExternalWalletCallback != null) {
      _onExternalWalletCallback!(response);
    }
  }

  void openCheckout({
    required double amountInRupees,
    required String description,
    String? name,
    String? userEmail,
    String? userPhone,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    Function(ExternalWalletResponse)? onExternalWallet,
    String? customKey,
  }) {
    _onSuccessCallback = onSuccess;
    _onFailureCallback = onFailure;
    _onExternalWalletCallback = onExternalWallet;

    // Convert amount in Rupees to Paise (Razorpay expects amount in paise)
    final int amountInPaise = (amountInRupees * 100).toInt();

    final Map<String, dynamic> options = {
      'key': (customKey != null && customKey.isNotEmpty) ? customKey : ApiUrls.razorpayKey,
      'amount': amountInPaise,
      'currency': 'INR',
      'name': name ?? 'Divine Foundation',
      'description': description,
      'timeout': 120,
    };

    final Map<String, String> prefill = {};
    if (userPhone != null && userPhone.trim().isNotEmpty) {
      prefill['contact'] = userPhone.trim();
    }
    if (userEmail != null && userEmail.trim().isNotEmpty) {
      prefill['email'] = userEmail.trim();
    }
    if (prefill.isNotEmpty) {
      options['prefill'] = prefill;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error opening Razorpay checkout: $e");
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
