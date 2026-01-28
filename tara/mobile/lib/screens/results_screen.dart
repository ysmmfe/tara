import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/analysis_state.dart';
import '../theme/brand_tokens.dart';
import '../widgets/tara_background.dart';
import '../widgets/tara_card.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  static const routeName = '/results';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(analysisControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendações'),
      ),
      body: TaraBackground(
        child: SafeArea(
          child: analysis.when(
            data: (result) {
              if (result == null) {
                return const _EmptyState();
              }
              final recommendation = result.recommendation;
              if (recommendation is! Map<String, dynamic>) {
                return _FallbackRecommendation(recommendation: recommendation);
              }
              final items = (recommendation['escolhas'] as List<dynamic>?)
                      ?.cast<dynamic>() ??
                  [];
              final totals =
                  recommendation['total'] as Map<String, dynamic>? ?? {};
              final tip = recommendation['dica']?.toString();
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  for (final item in items)
                    _FoodCard(
                      item: item is Map<String, dynamic>
                          ? item
                          : <String, dynamic>{},
                    ),
                  const SizedBox(height: 16),
                  _TotalsCard(totals: totals),
                  if (tip != null && tip.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _TipCard(tip: tip),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorState(error: error.toString()),
          ),
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = item['alimento']?.toString() ?? 'Item';
    final grams = item['gramas']?.toString() ?? '-';
    final calories = item['calorias_estimadas']?.toString() ?? '-';
    final protein = item['proteina_g']?.toString() ?? '-';
    final carbs = item['carboidrato_g']?.toString() ?? '-';
    final fat = item['gordura_g']?.toString() ?? '-';
    final justification = item['justificativa']?.toString();
    final chipPalette = _MacroPalette.from(colors);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TaraCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$grams g',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _MacroChip(
                label: '$calories kcal',
                backgroundColor: chipPalette.caloriesBg,
                textColor: chipPalette.caloriesText,
              ),
              _MacroChip(
                label: 'P: $protein g',
                backgroundColor: chipPalette.proteinBg,
                textColor: chipPalette.proteinText,
              ),
              _MacroChip(
                label: 'C: $carbs g',
                backgroundColor: chipPalette.carbsBg,
                textColor: chipPalette.carbsText,
              ),
              _MacroChip(
                label: 'G: $fat g',
                backgroundColor: chipPalette.fatBg,
                textColor: chipPalette.fatText,
              ),
            ],
          ),
            if (justification != null && justification.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                '"$justification"',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _MacroPalette {
  const _MacroPalette({
    required this.caloriesBg,
    required this.caloriesText,
    required this.proteinBg,
    required this.proteinText,
    required this.carbsBg,
    required this.carbsText,
    required this.fatBg,
    required this.fatText,
  });

  final Color caloriesBg;
  final Color caloriesText;
  final Color proteinBg;
  final Color proteinText;
  final Color carbsBg;
  final Color carbsText;
  final Color fatBg;
  final Color fatText;

  factory _MacroPalette.from(ColorScheme colors) {
    return _MacroPalette(
      caloriesBg: BrandTokens.accentSoft,
      caloriesText: BrandTokens.accentDark,
      proteinBg: BrandTokens.primarySoft,
      proteinText: BrandTokens.primaryDark,
      carbsBg: BrandTokens.warning.withValues(alpha: 0.18),
      carbsText: BrandTokens.warning,
      fatBg: BrandTokens.success.withValues(alpha: 0.18),
      fatText: BrandTokens.success,
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.totals});

  final Map<String, dynamic> totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _MacroPalette.from(theme.colorScheme);
    return TaraCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total da refeição',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TotalItem(
                value: _formatNumber(totals['calorias'], 'kcal'),
                label: 'kcal',
                backgroundColor: palette.caloriesBg,
                textColor: palette.caloriesText,
              ),
              _TotalItem(
                value: _formatNumber(totals['proteina_g'], 'g'),
                label: 'proteína',
                backgroundColor: palette.proteinBg,
                textColor: palette.proteinText,
              ),
              _TotalItem(
                value: _formatNumber(totals['carboidrato_g'], 'g'),
                label: 'carbos',
                backgroundColor: palette.carbsBg,
                textColor: palette.carbsText,
              ),
              _TotalItem(
                value: _formatNumber(totals['gordura_g'], 'g'),
                label: 'gordura',
                backgroundColor: palette.fatBg,
                textColor: palette.fatText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalItem extends StatelessWidget {
  const _TotalItem({
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String value;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TaraCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: colors.tertiaryContainer,
      borderColor: colors.tertiary.withValues(alpha: 0.4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.85),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackRecommendation extends StatelessWidget {
  const _FallbackRecommendation({required this.recommendation});

  final dynamic recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TaraCard(
          padding: const EdgeInsets.all(16),
          child: Text(
            recommendation?.toString() ?? 'Sem recomendação',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Nenhuma recomendação gerada ainda.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: TaraCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: colors.surface,
          borderColor: colors.outline,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Erro ao analisar: $error',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatNumber(Object? value, String suffix) {
  if (value == null) {
    return '-';
  }
  return '$value $suffix'.trim();
}
