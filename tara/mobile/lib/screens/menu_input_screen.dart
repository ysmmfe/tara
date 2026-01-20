import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/analysis_state.dart';
import '../state/menu_state.dart';
import '../state/profile_state.dart';
import '../state/theme_state.dart';
import 'profile_screen.dart';
import 'profile_summary_screen.dart';
import 'results_screen.dart';

class MenuInputScreen extends ConsumerWidget {
  const MenuInputScreen({super.key});

  static const routeName = '/menu';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuText = ref.watch(menuTextProvider);
    final mealType = ref.watch(mealTypeProvider);
    final profile = ref.watch(profileControllerProvider);
    final analysis = ref.watch(analysisControllerProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cardápio'),
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          tooltip: 'Perfil',
          onPressed: () {
            final routeName = profile.isComplete
                ? ProfileSummaryScreen.routeName
                : ProfileScreen.routeName;
            Navigator.of(context).pushNamed(routeName);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Tema',
            onPressed: () {
              ref.read(themeControllerProvider.notifier).toggle();
            },
            icon: Text(
              theme.brightness == Brightness.dark ? '🌙' : '☀️',
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Cole o texto do cardápio do restaurante.',
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
                DropdownButtonFormField<int>(
                  key: ValueKey(profile.mealsPerDay),
                  initialValue: profile.mealsPerDay,
                  decoration: const InputDecoration(
                    labelText: 'Refeições por dia',
                    border: OutlineInputBorder(),
                  ),
                  items: const [3, 4, 5, 6]
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text('$value refeições'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(profileControllerProvider.notifier)
                          .updateMealsPerDay(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey(mealType),
                  initialValue: mealType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de refeição',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    'cafe_da_manha',
                    'lanche_manha',
                    'almoco',
                    'lanche_tarde',
                    'jantar',
                    'ceia',
                  ]
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(_mealTypeLabel(value)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(mealTypeProvider.notifier).state = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  minLines: 6,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Frango grelhado, arroz, feijão, salada...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(menuTextProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${menuText.length} caracteres',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                if (analysis.isLoading) {
                  return;
                }
                if (!profile.isComplete) {
                  await _showMissingProfileDialog(context);
                  return;
                }
                if (menuText.trim().isEmpty) {
                  await _showMissingMenuDialog(context);
                  return;
                }
                ref.read(analysisControllerProvider.notifier).analyze(
                      profile: profile,
                      menuText: menuText,
                      mealType: mealType,
                    );
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pushNamed(ResultsScreen.routeName);
              },
              child: analysis.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.onPrimary),
                      ),
                    )
                  : const Text('Gerar recomendações'),
            ),
          ),
        ],
      ),
    );
  }
}

String _mealTypeLabel(String value) {
  const labels = {
    'cafe_da_manha': 'café da manhã',
    'lanche_manha': 'lanche da manhã',
    'almoco': 'almoço',
    'lanche_tarde': 'lanche da tarde',
    'jantar': 'jantar',
    'ceia': 'ceia',
  };
  return labels[value] ?? value.replaceAll('_', ' ');
}

Future<void> _showMissingProfileDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Perfil necessário'),
      content: const Text(
        'Antes de analisar o cardápio, configure seu perfil.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}

Future<void> _showMissingMenuDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cardápio vazio'),
      content: const Text(
        'Digite ou cole o cardápio para continuar.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}
