import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/child_profile.dart';

final childProfileProvider =
    StateNotifierProvider<ChildProfileNotifier, ChildProfile?>((ref) {
  return ChildProfileNotifier();
});

class ChildProfileNotifier extends StateNotifier<ChildProfile?> {
  ChildProfileNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('child_profile');
    if (json != null) {
      state = ChildProfile.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    }
  }

  Future<void> save(ChildProfile profile) async {
    state = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_profile', jsonEncode(profile.toJson()));
  }

  Future<void> clear() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('child_profile');
  }
}
