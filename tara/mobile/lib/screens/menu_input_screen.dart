import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/analysis_state.dart';
import '../state/menu_state.dart';
import '../state/profile_state.dart';
import 'profile_screen.dart';
import 'profile_summary_screen.dart';
import 'results_screen.dart';
import '../widgets/tara_background.dart';
import '../widgets/tara_card.dart';

class MenuInputScreen extends ConsumerStatefulWidget {
  const MenuInputScreen({super.key});

  static const routeName = '/menu';

  @override
  ConsumerState<MenuInputScreen> createState() => _MenuInputScreenState();
}

class _MenuInputScreenState extends ConsumerState<MenuInputScreen> {
  late final TextEditingController _menuController;

  @override
  void initState() {
    super.initState();
    _menuController = TextEditingController(
      text: ref.read(menuTextProvider),
    );
    _menuController.addListener(_handleMenuTextChanged);
  }

  @override
  void dispose() {
    _menuController
      ..removeListener(_handleMenuTextChanged)
      ..dispose();
    super.dispose();
  }

  void _handleMenuTextChanged() {
    final next = _menuController.text;
    final current = ref.read(menuTextProvider);
    if (current != next) {
      ref.read(menuTextProvider.notifier).state = next;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: TaraBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Cole o texto do cardápio do restaurante.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 16),
            TaraCard(
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
                    controller: _menuController,
                    minLines: 6,
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    enableSuggestions: false,
                    autocorrect: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Frango grelhado, arroz, feijão, salada...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _menuController,
                      builder: (context, value, child) {
                        return Text(
                          '${value.text.length} caracteres',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        );
                      },
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
                  final menuText = _menuController.text;
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
