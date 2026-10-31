import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../Model/social_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';
import '../Utilities/helper.dart';
import 'home_controller.dart';

class FollowsController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var socialData = Rxn<SocialData>();
  var searchQuery = ''.obs;

  // Local follow status override to avoid waiting for API refreshes
  var localFollowingNgoIds = <String>{}.obs;
  var localFollowingUserIds = <String>{}.obs;

  var isFollowingLoading = false.obs;
  var isFollowersLoading = false.obs;

  var apiFollowingNgos = <SocialNgo>[].obs;
  var apiFollowingUsers = <SocialDonor>[].obs;

  var apiFollowersNgos = <SocialNgo>[].obs;
  var apiFollowersUsers = <SocialDonor>[].obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchFollowingList();
    });
  }

  Future<void> fetchFollowingList({bool forceRefresh = false}) async {
    if (isFollowingLoading.value) return;
    if (!forceRefresh && (apiFollowingNgos.isNotEmpty || apiFollowingUsers.isNotEmpty)) return;

    try {
      isFollowingLoading.value = true;
      final response = await Repositories().getApi(
        context: null,
        url: ApiUrls.followingUrl,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          final List<SocialNgo> ngosList = [];
          final List<SocialDonor> usersList = [];

          final rawNgos = jsonResponse['followingNgos'] ?? jsonResponse['ngos'];
          if (rawNgos != null && rawNgos is List) {
            ngosList.addAll(rawNgos.map((e) => SocialNgo.fromJson(e)).toList());
          }

          final rawUsers = jsonResponse['followingUsers'] ?? jsonResponse['users'] ?? jsonResponse['individuals'];
          if (rawUsers != null && rawUsers is List) {
            usersList.addAll(rawUsers.map((e) => SocialDonor.fromJson(e)).toList());
          }

          final rawMain = jsonResponse['data'] ?? jsonResponse['following'];
          if (rawMain != null && rawMain is List) {
            for (var item in rawMain) {
              if (item is Map<String, dynamic>) {
                String type = (item['type'] ?? item['role'] ?? '').toString().toLowerCase();
                String id = (item['_id'] ?? item['id'] ?? '').toString();
                if (type == 'ngo' || item.containsKey('organizationName')) {
                  if (!ngosList.any((e) => e.id == id)) {
                    ngosList.add(SocialNgo.fromJson(item));
                  }
                } else {
                  if (!usersList.any((e) => e.id == id)) {
                    usersList.add(SocialDonor.fromJson(item));
                  }
                }
              }
            }
          }

          apiFollowingNgos.assignAll(ngosList);
          apiFollowingUsers.assignAll(usersList);

          localFollowingNgoIds.clear();
          for (var ngo in ngosList) {
            if (ngo.id != null && ngo.id!.isNotEmpty) {
              localFollowingNgoIds.add(ngo.id!);
            }
          }
          localFollowingUserIds.clear();
          for (var user in usersList) {
            if (user.id != null && user.id!.isNotEmpty) {
              localFollowingUserIds.add(user.id!);
            }
          }

          // If followers list was already loaded, align their NGO IDs with authoritative followed NGOs
          if (apiFollowersNgos.isNotEmpty) {
            _resolveAuthoritativeNgoIds(apiFollowersNgos);
          }
        }
      }
    } catch (e) {
      print("Error fetching following list: $e");
    } finally {
      isFollowingLoading.value = false;
    }
  }

  Future<void> fetchFollowersList({bool forceRefresh = false}) async {
    if (isFollowersLoading.value) return;
    if (!forceRefresh && (apiFollowersNgos.isNotEmpty || apiFollowersUsers.isNotEmpty)) return;

    try {
      isFollowersLoading.value = true;
      final response = await Repositories().getApi(
        context: null,
        url: ApiUrls.followersUrl,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          final List<SocialNgo> ngosList = [];
          final List<SocialDonor> usersList = [];

          final rawNgos = jsonResponse['ngos'] ?? jsonResponse['followerNgos'];
          if (rawNgos != null && rawNgos is List) {
            ngosList.addAll(rawNgos.map((e) => SocialNgo.fromJson(e)).toList());
          }

          final rawUsers = jsonResponse['users'] ?? jsonResponse['followers'] ?? jsonResponse['individuals'];
          if (rawUsers != null && rawUsers is List) {
            usersList.addAll(rawUsers.map((e) => SocialDonor.fromJson(e)).toList());
          }

          final rawMain = jsonResponse['data'];
          if (rawMain != null && rawMain is List) {
            for (var item in rawMain) {
              if (item is Map<String, dynamic>) {
                String type = (item['type'] ?? item['role'] ?? '').toString().toLowerCase();
                String id = (item['_id'] ?? item['id'] ?? '').toString();
                if (type == 'ngo' || item.containsKey('organizationName')) {
                  if (!ngosList.any((e) => e.id == id)) {
                    ngosList.add(SocialNgo.fromJson(item));
                  }
                } else {
                  if (!usersList.any((e) => e.id == id)) {
                    usersList.add(SocialDonor.fromJson(item));
                  }
                }
              }
            }
          }

          // Align any NGO follower's ID with the authoritative NGO document ID
          _resolveAuthoritativeNgoIds(ngosList);

          apiFollowersNgos.assignAll(ngosList);
          apiFollowersUsers.assignAll(usersList);
        }
      }
    } catch (e) {
      print("Error fetching followers list: $e");
    } finally {
      isFollowersLoading.value = false;
    }
  }

  void _resolveAuthoritativeNgoIds(List<SocialNgo> ngosList) {
    for (var ngo in ngosList) {
      if (ngo.name == null || ngo.name!.trim().isEmpty) continue;
      final ngoName = ngo.name!.trim().toLowerCase();

      // 1. Check apiFollowingNgos (the authoritative list from /donor/following)
      final matchingFollowing = apiFollowingNgos.firstWhereOrNull(
        (f) => f.name?.trim().toLowerCase() == ngoName && f.id != null && f.id!.isNotEmpty,
      );
      if (matchingFollowing != null) {
        ngo.id = matchingFollowing.id;
        ngo.ngoId = matchingFollowing.id;
        continue;
      }

      // 2. Check topNgos from socialData
      final matchingSocial = (socialData.value?.topNgos ?? []).firstWhereOrNull(
        (t) => t.name?.trim().toLowerCase() == ngoName && t.id != null && t.id!.isNotEmpty,
      );
      if (matchingSocial != null) {
        ngo.id = matchingSocial.id;
        ngo.ngoId = matchingSocial.id;
        continue;
      }

      // 3. Check donorNgosList from HomeController if registered
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        final matchingHome = homeCtrl.donorNgosList.firstWhereOrNull(
          (h) => h.name?.trim().toLowerCase() == ngoName && h.id != null && h.id!.isNotEmpty,
        );
        if (matchingHome != null) {
          ngo.id = matchingHome.id;
          ngo.ngoId = matchingHome.id;
          continue;
        }
      }
    }
  }

  Future<void> fetchSocialData({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (!forceRefresh && socialData.value != null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Repositories().getApi(
        context: null,
        url: ApiUrls.socialUrl,
        showResponse: true,
      );

      if (response != null) {
        print("========================================");
        print("SOCIAL API RESPONSE: $response");
        print("========================================");
        final jsonResponse = jsonDecode(response);
        final model = SocialModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          socialData.value = model.data;
          
          final followedList = model.data!.followingNgos ?? [];
          localFollowingNgoIds.addAll(followedList.map((ngo) => ngo.id ?? '').where((id) => id.isNotEmpty));

          final followedUsersList = model.data!.followingUsers ?? [];
          localFollowingUserIds.addAll(followedUsersList.map((u) => u.id ?? '').where((id) => id.isNotEmpty));
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
    if (ngoId.isEmpty) return false;
    if (localFollowingNgoIds.contains(ngoId)) return true;
    for (var ngo in apiFollowingNgos) {
      if (ngo.id == ngoId || (ngo.ngoId != null && ngo.ngoId == ngoId)) {
        return true;
      }
    }
    return false;
  }

  bool isUserFollowed(String userId) {
    return localFollowingUserIds.contains(userId);
  }

  Future<void> toggleFollowNgoApi(String ngoId) async {
    try {
      final wasFollowed = isNgoFollowed(ngoId);
      SocialNgo? cachedNgo;
      for (var n in apiFollowingNgos) {
        if (n.id == ngoId || (n.ngoId != null && n.ngoId == ngoId)) {
          cachedNgo = n;
          break;
        }
      }

      final targetNgoId = cachedNgo?.id ?? (cachedNgo?.ngoId?.isNotEmpty == true ? cachedNgo!.ngoId! : ngoId);

      if (wasFollowed) {
        localFollowingNgoIds.remove(ngoId);
        localFollowingNgoIds.remove(targetNgoId);
        apiFollowingNgos.removeWhere((ngo) => ngo.id == targetNgoId || ngo.id == ngoId || ngo.ngoId == targetNgoId || ngo.ngoId == ngoId);
      } else {
        localFollowingNgoIds.add(targetNgoId);
      }

      final response = await Repositories().postApi(
        url: ApiUrls.followNgoUrl(targetNgoId),
        mapData: {},
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          final isFollowing = jsonResponse['isFollowing'] ?? false;
          if (isFollowing) {
            localFollowingNgoIds.add(targetNgoId);
            fetchFollowingList(forceRefresh: true);
          } else {
            localFollowingNgoIds.remove(targetNgoId);
            localFollowingNgoIds.remove(ngoId);
            apiFollowingNgos.removeWhere((ngo) => ngo.id == targetNgoId || ngo.id == ngoId);
          }
          final msg = jsonResponse['message'] ?? '';
          if (msg.isNotEmpty) {
            showSnackBar(msg, isFollowing);
          }
        } else {
          if (wasFollowed) {
            localFollowingNgoIds.add(targetNgoId);
            if (cachedNgo != null && !apiFollowingNgos.any((n) => n.id == targetNgoId)) {
              apiFollowingNgos.add(cachedNgo);
            }
          } else {
            localFollowingNgoIds.remove(targetNgoId);
            localFollowingNgoIds.remove(ngoId);
            apiFollowingNgos.removeWhere((ngo) => ngo.id == targetNgoId || ngo.id == ngoId);
          }
          showSnackBar("Failed to toggle follow status", false);
        }
      } else {
        if (wasFollowed) {
          localFollowingNgoIds.add(targetNgoId);
          if (cachedNgo != null && !apiFollowingNgos.any((n) => n.id == targetNgoId)) {
            apiFollowingNgos.add(cachedNgo);
          }
        } else {
          localFollowingNgoIds.remove(targetNgoId);
          localFollowingNgoIds.remove(ngoId);
          apiFollowingNgos.removeWhere((ngo) => ngo.id == targetNgoId || ngo.id == ngoId);
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
      SocialDonor? cachedUser;
      for (var u in apiFollowingUsers) {
        if (u.id == userId) {
          cachedUser = u;
          break;
        }
      }

      if (wasFollowed) {
        localFollowingUserIds.remove(userId);
        apiFollowingUsers.removeWhere((u) => u.id == userId);
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
            fetchFollowingList(forceRefresh: true);
          } else {
            localFollowingUserIds.remove(userId);
            apiFollowingUsers.removeWhere((u) => u.id == userId);
          }
          final msg = jsonResponse['message'] ?? '';
          if (msg.isNotEmpty) {
            showSnackBar(msg, isFollowing);
          }
        } else {
          if (wasFollowed) {
            localFollowingUserIds.add(userId);
            if (cachedUser != null && !apiFollowingUsers.any((u) => u.id == userId)) {
              apiFollowingUsers.add(cachedUser);
            }
          } else {
            localFollowingUserIds.remove(userId);
            apiFollowingUsers.removeWhere((u) => u.id == userId);
          }
          showSnackBar("Failed to toggle follow status", false);
        }
      } else {
        if (wasFollowed) {
          localFollowingUserIds.add(userId);
          if (cachedUser != null && !apiFollowingUsers.any((u) => u.id == userId)) {
            apiFollowingUsers.add(cachedUser);
          }
        } else {
          localFollowingUserIds.remove(userId);
          apiFollowingUsers.removeWhere((u) => u.id == userId);
        }
        showSnackBar("No response from server", false);
      }
    } catch (e) {
      showSnackBar("Error: ${e.toString()}", false);
    }
  }

  // Reactive filtered lists
  List<SocialNgo> get topNgos {
    final list = (socialData.value?.topNgos ?? [])
        .where((ngo) => !localFollowingNgoIds.contains(ngo.id))
        .toList();
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list.where((ngo) => (ngo.name ?? '').toLowerCase().contains(query)).toList();
  }

  List<SocialNgo> get followingNgos {
    final list = apiFollowingNgos
        .where((ngo) => localFollowingNgoIds.contains(ngo.id))
        .toList();
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list.where((ngo) => (ngo.name ?? '').toLowerCase().contains(query)).toList();
  }

  List<SocialDonor> get followers {
    final list = apiFollowersUsers;
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list.where((user) => (user.name ?? '').toLowerCase().contains(query) || (user.phone ?? '').contains(query)).toList();
  }

  List<SocialNgo> get followersNgos {
    final list = apiFollowersNgos;
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list.where((ngo) => (ngo.name ?? '').toLowerCase().contains(query)).toList();
  }

  List<SocialDonor> get followingUsers {
    final list = apiFollowingUsers
        .where((user) => localFollowingUserIds.contains(user.id))
        .toList();
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list.where((user) => (user.name ?? '').toLowerCase().contains(query) || (user.phone ?? '').contains(query)).toList();
  }
}
