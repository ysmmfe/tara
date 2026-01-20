import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile.dart';
import '../state/profile_state.dart';
import 'menu_input_screen.dart';
import 'profile_summary_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _ageController;
  late final ProviderSubscription<ProfileFormState> _profileSub;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _ageController = TextEditingController();
    final initial = ref.read(profileControllerProvider);
    _syncController(_weightController, initial.weightKg?.toStringAsFixed(0));
    _syncController(_heightController, initial.heightCm?.toStringAsFixed(0));
    _syncController(_ageController, initial.age?.toString());
    _profileSub = ref.listenManual<ProfileFormState>(
      profileControllerProvider,
      (prev, next) {
        _syncController(_weightController, next.weightKg?.toStringAsFixed(0));
        _syncController(_heightController, next.heightCm?.toStringAsFixed(0));
        _syncController(_ageController, next.age?.toString());
      },
    );
  }

  @override
  void dispose() {
    _profileSub.close();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Configure seus dados para calcular as metas.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              children: [
                _NumberField(
                  label: 'Peso (kg)',
                  controller: _weightController,
                  onChanged: (value) =>
                      controller.updateWeight(_parseDouble(value)),
                ),
                const SizedBox(height: 12),
                _NumberField(
                  label: 'Altura (cm)',
                  controller: _heightController,
                  onChanged: (value) =>
                      controller.updateHeight(_parseDouble(value)),
                ),
                const SizedBox(height: 12),
                _NumberField(
                  label: 'Idade',
                  controller: _ageController,
                  onChanged: (value) => controller.updateAge(_parseInt(value)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Sex>(
                  key: ValueKey(profile.sex),
                  initialValue: profile.sex,
                  decoration: const InputDecoration(
                    labelText: 'Sexo',
                    border: OutlineInputBorder(),
                  ),
                  items: Sex.values
                      .map((sex) => DropdownMenuItem(
                            value: sex,
                            child: Text(sex.label),
                          ))
                      .toList(),
                  onChanged: controller.updateSex,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ActivityLevel>(
                  key: ValueKey(profile.activityLevel),
                  initialValue: profile.activityLevel,
                  decoration: const InputDecoration(
                    labelText: 'Nível de atividade',
                    border: OutlineInputBorder(),
                  ),
                  items: ActivityLevel.values
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level.label),
                          ))
                      .toList(),
                  onChanged: controller.updateActivity,
                ),
                const SizedBox(height: 12),
                Text(
                  'Déficit calórico: ${(profile.deficitPercent * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                Slider(
                  min: 0.1,
                  max: 0.3,
                  divisions: 4,
                  value: profile.deficitPercent,
                  label:
                      '${(profile.deficitPercent * 100).toStringAsFixed(0)}%',
                  onChanged: controller.updateDeficit,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: profile.isComplete
                  ? () async {
                      await controller.save();
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        ProfileSummaryScreen.routeName,
                        (route) => route.settings.name ==
                            MenuInputScreen.routeName,
                      );
                    }
                  : null,
              child: const Text('Salvar perfil'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}

void _syncController(TextEditingController controller, String? value) {
  final text = value ?? '';
  if (controller.text == text) {
    return;
  }
  controller.text = text;
  controller.selection = TextSelection.collapsed(offset: text.length);
}

double? _parseDouble(String value) {
  final normalized = value.replaceAll(',', '.');
  return double.tryParse(normalized);
}

int? _parseInt(String value) {
  return int.tryParse(value);
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile.dart';
import '../state/profile_state.dart';
import 'menu_input_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _ageController;
  late final ProviderSubscription<ProfileFormState> _profileSub;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _ageController = TextEditingController();
    final initial = ref.read(profileControllerProvider);
    _syncController(_weightController, initial.weightKg?.toStringAsFixed(0));
    _syncController(_heightController, initial.heightCm?.toStringAsFixed(0));
    _syncController(_ageController, initial.age?.toString());
    _profileSub = ref.listenManual<ProfileFormState>(
      profileControllerProvider,
      (prev, next) {
        _syncController(_weightController, next.weightKg?.toStringAsFixed(0));
        _syncController(_heightController, next.heightCm?.toStringAsFixed(0));
        _syncController(_ageController, next.age?.toString());
      },
    );
  }

  @override
  void dispose() {
    _profileSub.close();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Configure seus dados para calcular as metas.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              children: [
                _NumberField(
                  label: 'Peso (kg)',
                  showRequiredIndicator: profile.weightKg == null,
                  controller: _weightController,
                  onChanged: (value) =>
                      controller.updateWeight(_parseDouble(value)),
                ),
                const SizedBox(height: 12),
                _NumberField(
                  label: 'Altura (cm)',
                  showRequiredIndicator: profile.heightCm == null,
                  controller: _heightController,
                  onChanged: (value) =>
                      controller.updateHeight(_parseDouble(value)),
                ),
                const SizedBox(height: 12),
                _NumberField(
                  label: 'Idade',
                  showRequiredIndicator: profile.age == null,
                  controller: _ageController,
                  onChanged: (value) => controller.updateAge(_parseInt(value)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Sex>(
                  key: ValueKey(profile.sex),
                  initialValue: profile.sex,
                  decoration: InputDecoration(
                    label: _RequiredLabel(
                      label: 'Sexo',
                      showIndicator: profile.sex == null,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: Sex.values
                      .map((sex) => DropdownMenuItem(
                            value: sex,
                            child: Text(sex.label),
                          ))
                      .toList(),
                  onChanged: controller.updateSex,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ActivityLevel>(
                  key: ValueKey(profile.activityLevel),
                  initialValue: profile.activityLevel,
                  decoration: InputDecoration(
                    label: _RequiredLabel(
                      label: 'Nível de atividade',
                      showIndicator: profile.activityLevel == null,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: ActivityLevel.values
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level.label),
                          ))
                      .toList(),
                  onChanged: controller.updateActivity,
                ),
                const SizedBox(height: 12),
                Text(
                  'Déficit calórico: ${(profile.deficitPercent * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                Slider(
                  min: 0.1,
                  max: 0.3,
                  divisions: 4,
                  value: profile.deficitPercent,
                  label:
                      '${(profile.deficitPercent * 100).toStringAsFixed(0)}%',
                  onChanged: controller.updateDeficit,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: profile.isComplete
                  ? () async {
                      await controller.save();
                      if (!context.mounted) {
                        return;
                      }
                      final navigator = Navigator.of(context);
                      if (navigator.canPop()) {
                        navigator.pop();
                      } else {
                        navigator.pushNamed(MenuInputScreen.routeName);
                      }
                    }
                  : null,
              child: const Text('Salvar perfil'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.showRequiredIndicator,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final bool showRequiredIndicator;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        label: _RequiredLabel(
          label: label,
          showIndicator: showRequiredIndicator,
        ),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel({
    required this.label,
    required this.showIndicator,
  });

  final String label;
  final bool showIndicator;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text.rich(
      TextSpan(
        text: label,
        children: showIndicator
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: colors.error),
                ),
              ]
            : const [],
      ),
    );
  }
}

void _syncController(TextEditingController controller, String? value) {
  final text = value ?? '';
  if (controller.text == text) {
    return;
  }
  controller.text = text;
  controller.selection = TextSelection.collapsed(offset: text.length);
}

double? _parseDouble(String value) {
  final normalized = value.replaceAll(',', '.');
  return double.tryParse(normalized);
}

int? _parseInt(String value) {
  return int.tryParse(value);
}
