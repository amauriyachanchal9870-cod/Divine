import 'dart:convert';
import 'package:get/get.dart';
import '../Model/social_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';
import '../Utilities/helper.dart';

class FollowsController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var socialData = Rxn<SocialData>();
  var searchQuery = ''.obs;

  // Local follow status override to avoid waiting for API refreshes
  var localFollowingNgoIds = <String>{}.obs;
  var localFollowingUserIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSocialData();
  }

  Future<void> fetchSocialData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Repositories().getApi(
        context: null,
        url: ApiUrls.socialUrl,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = SocialModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          socialData.value = model.data;
          
          // Populate local following sets
          final followedList = model.data!.followingNgos ?? [];
          localFollowingNgoIds.assignAll(followedList.map((ngo) => ngo.id ?? '').where((id) => id.isNotEmpty));

          final followedUsersList = model.data!.followingUsers ?? [];
          localFollowingUserIds.assignAll(followedUsersList.map((u) => u.id ?? '').where((id) => id.isNotEmpty));
        } else {
          errorMessage.value = 'Failed to load social data.';
        }
      } else {
        errorMessage.value = 'No response from server.';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  bool isNgoFollowed(String ngoId) {
    return localFollowingNgoIds.contains(ngoId);
  }

  bool isUserFollowed(String userId) {
    return localFollowingUserIds.contains(userId);
  }

  Future<void> toggleFollowNgoApi(String ngoId) async {
    try {
      final wasFollowed = localFollowingNgoIds.contains(ngoId);
      if (wasFollowed) {
        localFollowingNgoIds.remove(ngoId);
      } else {
        localFollowingNgoIds.add(ngoId);
      }

      final response = await Repositories().postApi(
        url: ApiUrls.followNgoUrl(ngoId),
        mapData: {},
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          final isFollowing = jsonResponse['isFollowing'] ?? false;
          if (isFollowing) {
            localFollowingNgoIds.add(ngoId);
          } else {
            localFollowingNgoIds.remove(ngoId);
          }
          final msg = jsonResponse['message'] ?? '';
          if (msg.isNotEmpty) {
            showSnackBar(msg, isFollowing);
          }
        } else {
          if (wasFollowed) {
            localFollowingNgoIds.add(ngoId);
          } else {
            localFollowingNgoIds.remove(ngoId);
          }
          showSnackBar("Failed to toggle follow status", false);
        }
      } else {
        if (wasFollowed) {
          localFollowingNgoIds.add(ngoId);
        } else {
          localFollowingNgoIds.remove(ngoId);
        }
        showSnackBar("No response from server", false);
      }
    } catch (e) {
      showSnackBar("Error: ${e.toString()}", false);
    }
  }

  Future<void> toggleFollowUserApi(String userId) async {
    try {
      final wasFollowed = localFollowingUserIds.contains(userId);
      if (wasFollowed) {
        localFollowingUserIds.remove(userId);
      } else {
        localFollowingUserIds.add(userId);
      }

      final response = await Repositories().postApi(
        url: ApiUrls.followUserUrl(userId),
        mapData: {},
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          final isFollowing = jsonResponse['isFollowing'] ?? false;
          if (isFollowing) {
            localFollowingUserIds.add(userId);
          } else {
            localFollowingUserIds.remove(userId);
          }
          final msg = jsonResponse['message'] ?? '';
          if (msg.isNotEmpty) {
            showSnackBar(msg, isFollowing);
          }
        } else {
          if (wasFollowed) {
            localFollowingUserIds.add(userId);
          } else {
            localFollowingUserIds.remove(userId);
          }
          showSnackBar("Failed to toggle follow status", false);
        }
      } else {
        if (wasFollowed) {
          localFollowingUserIds.add(userId);
        } else {
          localFollowingUserIds.remove(userId);
        }
        showSnackBar("No response from server", false);
      }
    } catch (e) {
      showSnackBar("Error: ${e.toString()}", false);
    }
  }

  // Reactive filtered lists
  List<SocialNgo> get topNgos {
    final list = socialData.value?.topNgos ?? [];
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list.where((ngo) => (ngo.name ?? '').toLowerCase().contains(query)).toList();
  }

  List<SocialNgo> get followingNgos {
    // Return all topNgos that are marked as followed in localFollowingNgoIds (so toggling reflects instantly)
    final allNgos = socialData.value?.topNgos ?? [];
    final followedNgos = allNgos.where((ngo) => localFollowingNgoIds.contains(ngo.id)).toList();
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return followedNgos;
    return followedNgos.where((ngo) => (ngo.name ?? '').toLowerCase().contains(query)).toList();
  }

  List<SocialDonor> get followers {
    final list = socialData.value?.followers ?? [];
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list.where((user) => (user.name ?? '').toLowerCase().contains(query) || (user.phone ?? '').contains(query)).toList();
  }

  List<SocialDonor> get followingUsers {
    final list = socialData.value?.followingUsers ?? [];
    // Filter using localFollowingUserIds so toggling unfollow removes them instantly from the list
    final followedUsers = list.where((user) => localFollowingUserIds.contains(user.id)).toList();
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return followedUsers;
    return followedUsers.where((user) => (user.name ?? '').toLowerCase().contains(query) || (user.phone ?? '').contains(query)).toList();
  }
}
