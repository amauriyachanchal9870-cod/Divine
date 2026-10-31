import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/review_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class MyReviewsController extends GetxController {
  var isLoading = false.obs;
  var reviewsList = <ReviewItem>[].obs;
  var errorMessage = ''.obs;

  var selectedUserFilter = 'All'.obs; // Options: 'All', 'Donor', 'NGO'
  var selectedSortFilter = 'Newest'.obs; // Options: 'Newest', 'Oldest', 'Highest Rating', 'Lowest Rating'
  var selectedRatingFilter = 'All'.obs; // Options: 'All', '5 Stars', '4 Stars', '3 Stars', '2 Stars', '1 Star'

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  Future<void> fetchReviews({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (!forceRefresh && reviewsList.isNotEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Repositories().getApi(
        url: ApiUrls.donorReviewsUrl,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = ReviewModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          reviewsList.value = model.data!;
        } else {
          reviewsList.clear();
        }
      } else {
        reviewsList.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint("Error fetching reviews: $e");
      reviewsList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  double get averageRating {
    if (reviewsList.isEmpty) return 0.0;
    double sum = reviewsList.fold(0.0, (prev, element) => prev + (element.rating ?? 0.0));
    return sum / reviewsList.length;
  }

  double getRatingRatio(int star) {
    if (reviewsList.isEmpty) return 0.0;
    int count = reviewsList.where((r) => (r.rating ?? 0).round() == star).length;
    return count / reviewsList.length;
  }

  List<ReviewItem> get filteredReviews {
    List<ReviewItem> list = List.from(reviewsList);

    if (selectedUserFilter.value != 'All') {
      final filterVal = selectedUserFilter.value.toLowerCase();
      list = list.where((r) {
        final role = (r.userRole ?? '').toLowerCase();
        final type = (r.type ?? '').toLowerCase();
        return role == filterVal || type == filterVal;
      }).toList();
    }

    if (selectedRatingFilter.value != 'All') {
      final star = int.tryParse(selectedRatingFilter.value.split(' ')[0]) ?? 0;
      if (star > 0) {
        list = list.where((r) => (r.rating ?? 0).round() == star).toList();
      }
    }

    if (selectedSortFilter.value == 'Highest Rating') {
      list.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    } else if (selectedSortFilter.value == 'Lowest Rating') {
      list.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
    } else if (selectedSortFilter.value == 'Oldest') {
      list.sort((a, b) {
        DateTime dtA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
        DateTime dtB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
        return dtA.compareTo(dtB);
      });
    } else {
      // Default: Newest
      list.sort((a, b) {
        DateTime dtA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
        DateTime dtB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
        return dtB.compareTo(dtA);
      });
    }

    return list;
  }
}
