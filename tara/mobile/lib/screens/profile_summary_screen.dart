import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/profile_state.dart';
import '../state/profile_summary_state.dart';
import 'menu_input_screen.dart';
import 'profile_screen.dart';

class ProfileSummaryScreen extends ConsumerWidget {
  const ProfileSummaryScreen({super.key});

  static const routeName = '/profile-summary';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    final summary = ref.watch(profileSummaryProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (!profile.isComplete) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Seu perfil'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Confira seus dados e metas diárias.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 20),
            _InfoCard(
              title: 'Perfil incompleto',
              child: Text(
                'Preencha seus dados para ver as metas nutricionais.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(ProfileScreen.routeName);
                },
                child: const Text('Preencher perfil'),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Confira seus dados e metas diárias.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 20),
          _InfoCard(
            title: 'Dados do perfil',
            child: Column(
              children: [
                _InfoRow(
                  label: 'Peso',
                  value: _formatNumber(profile.weightKg, 'kg'),
                ),
                _InfoRow(
                  label: 'Altura',
                  value: _formatNumber(profile.heightCm, 'cm'),
                ),
                _InfoRow(
                  label: 'Idade',
                  value: _formatNumber(profile.age, 'anos'),
                ),
                _InfoRow(
                  label: 'Sexo',
                  value: profile.sex?.label ?? '-',
                ),
                _InfoRow(
                  label: 'Nível de atividade',
                  value: profile.activityLevel?.label ?? '-',
                ),
                _InfoRow(
                  label: 'Déficit',
                  value: '${(profile.deficitPercent * 100).toStringAsFixed(0)}%',
                ),
                _InfoRow(
                  label: 'Refeições por dia',
                  value: profile.mealsPerDay.toString(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Metas nutricionais diárias',
            child: summary.when(
              data: (value) {
                if (value == null) {
                  return Text(
                    'Complete o perfil para ver as metas.',
                    style: theme.textTheme.bodyMedium,
                  );
                }
                final macros =
                    (value['macros'] as Map<String, dynamic>?) ?? {};
                return Column(
                  children: [
                    _InfoRow(
                      label: 'Calorias por dia',
                      value: _formatNumber(value['target_calories'], 'kcal'),
                    ),
                    _InfoRow(
                      label: 'Proteína',
                      value: _formatNumber(macros['protein_g'], 'g'),
                    ),
                    _InfoRow(
                      label: 'Carboidratos',
                      value: _formatNumber(macros['carbs_g'], 'g'),
                    ),
                    _InfoRow(
                      label: 'Gorduras',
                      value: _formatNumber(macros['fat_g'], 'g'),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Text(
                'Não foi possível carregar as metas: $error',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.error,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(ProfileScreen.routeName);
              },
              child: const Text('Editar perfil'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  MenuInputScreen.routeName,
                  (route) => false,
                );
              },
              child: const Text('Ir para a análise do menu'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatNumber(Object? value, String suffix) {
  if (value == null) {
    return '-';
  }
  if (value is num) {
    final rounded = value.round();
    return '$rounded $suffix'.trim();
  }
  return '$value $suffix'.trim();
}
