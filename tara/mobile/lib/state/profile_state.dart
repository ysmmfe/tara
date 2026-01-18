import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile.dart';
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
  });

  final double? weightKg;
  final double? heightCm;
  final int? age;
  final Sex? sex;
  final ActivityLevel? activityLevel;
  final double deficitPercent;
  final int mealsPerDay;

  static const _unset = Object();

  bool get isComplete =>
      weightKg != null &&
      heightCm != null &&
      age != null &&
      sex != null &&
      activityLevel != null;

  ProfileFormState copyWith({
    Object? weightKg = _unset,
    Object? heightCm = _unset,
    Object? age = _unset,
    Object? sex = _unset,
    Object? activityLevel = _unset,
    Object? deficitPercent = _unset,
    Object? mealsPerDay = _unset,
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
    };
  }

  Map<String, dynamic> toRequestJson() {
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

  static ProfileFormState fromJson(Map<String, dynamic> json) {
    return ProfileFormState(
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      age: json['age'] as int?,
      sex: Sex.fromApiValue(json['sex'] as String?),
      activityLevel: ActivityLevel.fromApiValue(json['activity_level'] as String?),
      deficitPercent: (json['deficit_percent'] as num?)?.toDouble() ?? 0.20,
      mealsPerDay: json['meals_per_day'] as int? ?? 3,
    );
  }
}

class ProfileController extends StateNotifier<ProfileFormState> {
  ProfileController(this._storage) : super(const ProfileFormState()) {
    _load();
  }

  final ProfileStorage _storage;

  Future<void> _load() async {
    final stored = await _storage.load();
    if (stored != null) {
      state = state.copyFrom(ProfileFormState.fromJson(stored));
    }
  }

  Future<void> save() => _storage.save(state.toJson());

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
}

final profileStorageProvider = Provider<ProfileStorage>(
  (ref) => const ProfileStorage(),
);

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileFormState>(
  (ref) => ProfileController(ref.read(profileStorageProvider)),
);
