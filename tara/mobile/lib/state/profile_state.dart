import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile.dart';
import '../services/api_client.dart';
import '../services/api_client_provider.dart';
import '../services/profile_storage.dart';

class ProfileFormState {
  const ProfileFormState({
    this.weightKg,
    this.heightCm,
    this.age,
    this.sex,
    this.activityLevel,
    this.deficitPercent = 0.20,
    this.mealsPerDay = 3,
    this.daysAvailable = const [],
    this.sessionMinutes,
    this.musclePriorities = const [],
    this.experienceLevel,
    this.equipment,
  });

  final double? weightKg;
  final double? heightCm;
  final int? age;
  final Sex? sex;
  final ActivityLevel? activityLevel;
  final double deficitPercent;
  final int mealsPerDay;
  final List<String> daysAvailable;
  final int? sessionMinutes;
  final List<String> musclePriorities;
  final String? experienceLevel;
  final String? equipment;

  static const _unset = Object();

  bool get isComplete =>
      weightKg != null &&
      heightCm != null &&
      age != null &&
      sex != null &&
      activityLevel != null &&
      sessionMinutes != null &&
      daysAvailable.isNotEmpty &&
      musclePriorities.isNotEmpty &&
      experienceLevel != null &&
      equipment != null;

  bool get isBasicComplete =>
      weightKg != null && heightCm != null && age != null && sex != null;

  ProfileFormState copyWith({
    Object? weightKg = _unset,
    Object? heightCm = _unset,
    Object? age = _unset,
    Object? sex = _unset,
    Object? activityLevel = _unset,
    Object? deficitPercent = _unset,
    Object? mealsPerDay = _unset,
    Object? daysAvailable = _unset,
    Object? sessionMinutes = _unset,
    Object? musclePriorities = _unset,
    Object? experienceLevel = _unset,
    Object? equipment = _unset,
  }) {
    return ProfileFormState(
      weightKg:
          weightKg == _unset ? this.weightKg : weightKg as double?,
      heightCm:
          heightCm == _unset ? this.heightCm : heightCm as double?,
      age: age == _unset ? this.age : age as int?,
      sex: sex == _unset ? this.sex : sex as Sex?,
      activityLevel: activityLevel == _unset
          ? this.activityLevel
          : activityLevel as ActivityLevel?,
      deficitPercent: deficitPercent == _unset
          ? this.deficitPercent
          : deficitPercent as double,
      mealsPerDay: mealsPerDay == _unset
          ? this.mealsPerDay
          : mealsPerDay as int,
      daysAvailable: daysAvailable == _unset
          ? this.daysAvailable
          : List<String>.from(daysAvailable as List),
      sessionMinutes: sessionMinutes == _unset
          ? this.sessionMinutes
          : sessionMinutes as int?,
      musclePriorities: musclePriorities == _unset
          ? this.musclePriorities
          : List<String>.from(musclePriorities as List),
      experienceLevel: experienceLevel == _unset
          ? this.experienceLevel
          : experienceLevel as String?,
      equipment: equipment == _unset ? this.equipment : equipment as String?,
    );
  }

  ProfileFormState copyFrom(ProfileFormState other) {
    return copyWith(
      weightKg: other.weightKg,
      heightCm: other.heightCm,
      age: other.age,
      sex: other.sex,
      activityLevel: other.activityLevel,
      deficitPercent: other.deficitPercent,
      mealsPerDay: other.mealsPerDay,
      daysAvailable: other.daysAvailable,
      sessionMinutes: other.sessionMinutes,
      musclePriorities: other.musclePriorities,
      experienceLevel: other.experienceLevel,
      equipment: other.equipment,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'age': age,
      'sex': sex?.apiValue,
      'activity_level': activityLevel?.apiValue,
      'deficit_percent': deficitPercent,
      'meals_per_day': mealsPerDay,
      'days_available': daysAvailable,
      'session_minutes': sessionMinutes,
      'muscle_priorities': musclePriorities,
      'experience_level': experienceLevel,
      'equipment': equipment,
    };
  }

  Map<String, dynamic> toProfileRequestJson() {
    if (!isComplete) {
      throw StateError('Perfil incompleto');
    }
    return {
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'age': age,
      'sex': sex!.apiValue,
      'activity_level': activityLevel!.apiValue,
      'deficit_percent': deficitPercent,
      'meals_per_day': mealsPerDay,
    };
  }

  Map<String, dynamic> toPreferencesRequestJson() {
    if (!isComplete) {
      throw StateError('Perfil incompleto');
    }
    return {
      'days_available': daysAvailable,
      'session_minutes': sessionMinutes,
      'muscle_priorities': musclePriorities,
      'experience_level': experienceLevel,
      'equipment': equipment,
    };
  }

  static ProfileFormState fromJson(Map<String, dynamic> json) {
    return ProfileFormState(
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      age: json['age'] as int?,
      sex: Sex.fromApiValue(json['sex'] as String?),
      activityLevel: ActivityLevel.fromApiValue(json['activity_level'] as String?),
      deficitPercent: (json['deficit_percent'] as num?)?.toDouble() ?? 0.20,
      mealsPerDay: json['meals_per_day'] as int? ?? 3,
      daysAvailable: (json['days_available'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      sessionMinutes: json['session_minutes'] as int?,
      musclePriorities: (json['muscle_priorities'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      experienceLevel: json['experience_level'] as String?,
      equipment: json['equipment'] as String?,
    );
  }

  static ProfileFormState fromServer(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final preferences =
        json['training_preferences'] as Map<String, dynamic>? ?? {};
    return ProfileFormState(
      weightKg: (profile['weight_kg'] as num?)?.toDouble(),
      heightCm: (profile['height_cm'] as num?)?.toDouble(),
      age: profile['age'] as int?,
      sex: Sex.fromApiValue(profile['sex'] as String?),
      activityLevel: ActivityLevel.fromApiValue(
        profile['activity_level'] as String?,
      ),
      deficitPercent: (profile['deficit_percent'] as num?)?.toDouble() ?? 0.20,
      mealsPerDay: profile['meals_per_day'] as int? ?? 3,
      daysAvailable: (preferences['days_available'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      sessionMinutes: preferences['session_minutes'] as int?,
      musclePriorities: (preferences['muscle_priorities'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      experienceLevel: preferences['experience_level'] as String?,
      equipment: preferences['equipment'] as String?,
    );
  }
}

class ProfileController extends StateNotifier<ProfileFormState> {
  ProfileController(this._storage, this._api) : super(const ProfileFormState()) {
    _load();
  }

  final ProfileStorage _storage;
  final ApiClient _api;

  Future<void> _load() async {
    final stored = await _storage.load();
    if (stored != null) {
      state = state.copyFrom(ProfileFormState.fromJson(stored));
    }
  }

  Future<void> save() async {
    await _storage.save(state.toJson());
    if (state.isComplete) {
      final remote = await _api.saveProfile(state);
      state = state.copyFrom(remote);
      await _storage.save(state.toJson());
    }
  }

  Future<void> syncFromApi() async {
    final remote = await _api.fetchProfile();
    if (remote != null) {
      state = state.copyFrom(remote);
      await _storage.save(state.toJson());
    }
  }

  void _persist() {
    _storage.save(state.toJson());
  }

  void updateWeight(double? value) {
    state = state.copyWith(weightKg: value);
    _persist();
  }

  void updateHeight(double? value) {
    state = state.copyWith(heightCm: value);
    _persist();
  }

  void updateAge(int? value) {
    state = state.copyWith(age: value);
    _persist();
  }

  void updateSex(Sex? value) {
    state = state.copyWith(sex: value);
    _persist();
  }

  void updateActivity(ActivityLevel? value) {
    state = state.copyWith(activityLevel: value);
    _persist();
  }

  void updateDeficit(double value) {
    state = state.copyWith(deficitPercent: value);
    _persist();
  }

  void updateMealsPerDay(int value) {
    state = state.copyWith(mealsPerDay: value);
    _persist();
  }

  void updateDaysAvailable(List<String> value) {
    state = state.copyWith(daysAvailable: value);
    _persist();
  }

  void updateSessionMinutes(int? value) {
    state = state.copyWith(sessionMinutes: value);
    _persist();
  }

  void updateMusclePriorities(List<String> value) {
    state = state.copyWith(musclePriorities: value);
    _persist();
  }

  void updateExperienceLevel(String? value) {
    state = state.copyWith(experienceLevel: value);
    _persist();
  }

  void updateEquipment(String? value) {
    state = state.copyWith(equipment: value);
    _persist();
  }
}

final profileStorageProvider = Provider<ProfileStorage>(
  (ref) => const ProfileStorage(),
);

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileFormState>(
  (ref) => ProfileController(
    ref.read(profileStorageProvider),
    ref.read(apiClientProvider),
  ),
);
