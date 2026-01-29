import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile.dart';
import '../state/profile_state.dart';
import 'menu_input_screen.dart';
import 'profile_summary_screen.dart';
import '../widgets/tara_background.dart';
import '../widgets/tara_card.dart';

class TrainingProfileScreen extends ConsumerWidget {
  const TrainingProfileScreen({super.key});

  static const routeName = '/training-profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferências de treino'),
      ),
      body: TaraBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Estamos quase lá...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            TaraCard(
              child: Column(
                children: [
                  DropdownButtonFormField<ActivityLevel>(
                    initialValue: profile.activityLevel,
                    decoration: InputDecoration(
                      label: _RequiredLabel(
                        label: 'Nível de atividade',
                        showIndicator: profile.activityLevel == null,
                      ),
                      border: const OutlineInputBorder(),
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
                  _NumberField(
                    label: 'Minutos por treino',
                    showRequiredIndicator: profile.sessionMinutes == null,
                    initialValue: profile.sessionMinutes?.toString(),
                    onChanged: (value) => controller.updateSessionMinutes(
                      _parseInt(value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionLabel(
                    label: 'Dias da semana de treino',
                    showIndicator: profile.daysAvailable.isEmpty,
                  ),
                  const SizedBox(height: 8),
                  _ChipSelector(
                    options: _weekDays,
                    selected: profile.daysAvailable,
                    onChanged: controller.updateDaysAvailable,
                  ),
                  const SizedBox(height: 12),
                  _SectionLabel(
                    label: 'Grupos musculares (até 3)',
                    showIndicator: profile.musclePriorities.isEmpty,
                  ),
                  const SizedBox(height: 8),
                  _LimitedChipSelector(
                    options: _muscleGroups,
                    selected: profile.musclePriorities,
                    maxSelection: 3,
                    onChanged: controller.updateMusclePriorities,
                    onLimitReached: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecione até 3 grupos musculares.'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: profile.experienceLevel,
                    decoration: InputDecoration(
                      label: _RequiredLabel(
                        label: 'Nível de experiência',
                        showIndicator: profile.experienceLevel == null,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    items: _experienceLevels.entries
                        .map((entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ))
                        .toList(),
                    onChanged: controller.updateExperienceLevel,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: profile.equipment,
                    decoration: InputDecoration(
                      label: _RequiredLabel(
                        label: 'Equipamentos disponíveis',
                        showIndicator: profile.equipment == null,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    items: _equipmentOptions.entries
                        .map((entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ))
                        .toList(),
                    onChanged: controller.updateEquipment,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: profile.isComplete
                    ? () async {
                        try {
                          await controller.save();
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao salvar perfil: $error'),
                            ),
                          );
                          return;
                        }
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          ProfileSummaryScreen.routeName,
                          (route) =>
                              route.settings.name == MenuInputScreen.routeName,
                        );
                      }
                    : null,
                child: const Text('Salvar perfil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.showRequiredIndicator,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final bool showRequiredIndicator;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue ?? '',
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
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
        style: Theme.of(context).textTheme.titleSmall,
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

class _ChipSelector extends StatelessWidget {
  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<_Option> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option.value);
        return FilterChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (value) {
            final next = List<String>.from(selected);
            if (value) {
              next.add(option.value);
            } else {
              next.remove(option.value);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}

class _LimitedChipSelector extends StatelessWidget {
  const _LimitedChipSelector({
    required this.options,
    required this.selected,
    required this.maxSelection,
    required this.onChanged,
    required this.onLimitReached,
  });

  final List<_Option> options;
  final List<String> selected;
  final int maxSelection;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback onLimitReached;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option.value);
        return FilterChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (value) {
            final next = List<String>.from(selected);
            if (value) {
              if (next.length >= maxSelection) {
                onLimitReached();
                return;
              }
              next.add(option.value);
            } else {
              next.remove(option.value);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}

int? _parseInt(String value) {
  return int.tryParse(value);
}

const _weekDays = [
  _Option('seg', 'Segunda'),
  _Option('ter', 'Terça'),
  _Option('qua', 'Quarta'),
  _Option('qui', 'Quinta'),
  _Option('sex', 'Sexta'),
  _Option('sab', 'Sábado'),
  _Option('dom', 'Domingo'),
];

const _muscleGroups = [
  _Option('peito', 'Peito'),
  _Option('costas', 'Costas'),
  _Option('ombros', 'Ombros'),
  _Option('pernas', 'Pernas'),
  _Option('gluteos', 'Glúteos'),
  _Option('bracos', 'Braços'),
  _Option('core', 'Core'),
];

const _experienceLevels = {
  'iniciante': 'Iniciante',
  'intermediario': 'Intermediário',
  'avancado': 'Avançado',
};

const _equipmentOptions = {
  'academia_completa': 'Academia completa',
  'academia_predio': 'Academia de prédio',
  'casa': 'Casa',
};

class _Option {
  const _Option(this.value, this.label);

  final String value;
  final String label;
}
