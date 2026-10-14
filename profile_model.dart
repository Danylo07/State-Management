import 'package:flutter/foundation.dart';

import '../api/fake_api.dart';
import 'user_profile.dart';

enum ProfileStatus { loading, error, data }

/// Дані профілю з трьома станами: завантаження, помилка, дані.
class ProfileModel extends ChangeNotifier {
  ProfileModel(this._api);

  final FakeApi _api;

  ProfileStatus _status = ProfileStatus.loading;
  UserProfile? _profile;
  String? _error;
  String? _email;
  int _session = 0; // щоб запізніла відповідь після виходу не "воскресила" дані

  ProfileStatus get status => _status;
  UserProfile? get profile => _profile;
  String? get error => _error;

  Future<void> load(String email) {
    _email = email;
    return _fetch(email);
  }

  Future<void> retry() {
    final email = _email;
    if (email == null) return Future.value();
    return _fetch(email);
  }

  Future<void> _fetch(String email) async {
    final session = ++_session;
    _status = ProfileStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.fetchProfile(email);
      if (session != _session) return;
      _profile = result;
      _status = ProfileStatus.data;
    } catch (e) {
      if (session != _session) return;
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = ProfileStatus.error;
    }
    notifyListeners();
  }

  void update({required String name, required String bio}) {
    final current = _profile;
    if (current == null) return;
    _profile = current.copyWith(name: name.trim(), bio: bio.trim());
    notifyListeners();
  }

  void clear() {
    _session++;
    _status = ProfileStatus.loading;
    _profile = null;
    _error = null;
    _email = null;
    notifyListeners();
  }
}
