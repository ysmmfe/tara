enum Sex {
  male('male', 'Masculino'),
  female('female', 'Feminino');

  const Sex(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static Sex? fromApiValue(String? value) {
    if (value == null) {
      return null;
    }
    for (final sex in Sex.values) {
      if (sex.apiValue == value) {
        return sex;
      }
    }
    return null;
  }
}

enum ActivityLevel {
  sedentary('sedentary', 'Sedentário'),
  light('light', 'Leve (1-3x/semana)'),
  moderate('moderate', 'Moderado (3-5x/semana)'),
  active('active', 'Ativo (6-7x/semana)'),
  veryActive('very_active', 'Muito ativo');

  const ActivityLevel(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ActivityLevel? fromApiValue(String? value) {
    if (value == null) {
      return null;
    }
    for (final level in ActivityLevel.values) {
      if (level.apiValue == value) {
        return level;
      }
    }
    return null;
  }
}
