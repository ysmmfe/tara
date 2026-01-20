import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/analysis_state.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  static const routeName = '/results';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(analysisControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendações'),
      ),
      body: analysis.when(
        data: (result) {
          if (result == null) {
            return const _EmptyState();
          }
          final recommendation = result.recommendation;
          if (recommendation is! Map<String, dynamic>) {
            return _FallbackRecommendation(recommendation: recommendation);
          }
          final items =
              (recommendation['escolhas'] as List<dynamic>?)?.cast<dynamic>() ??
                  [];
          final totals = recommendation['total'] as Map<String, dynamic>? ?? {};
          final tip = recommendation['dica']?.toString();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Recomendação',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline),
      ),
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
              _MacroChip(label: '$calories kcal'),
              _MacroChip(label: 'P: $protein g'),
              _MacroChip(label: 'C: $carbs g'),
              _MacroChip(label: 'G: $fat g'),
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
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.totals});

  final Map<String, dynamic> totals;

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
              ),
              _TotalItem(
                value: _formatNumber(totals['proteina_g'], 'g'),
                label: 'proteína',
              ),
              _TotalItem(
                value: _formatNumber(totals['carboidrato_g'], 'g'),
                label: 'carboidratos',
              ),
              _TotalItem(
                value: _formatNumber(totals['gordura_g'], 'g'),
                label: 'gordura',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalItem extends StatelessWidget {
  const _TotalItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
      ),
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
    final colors = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Recomendação',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline),
          ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Erro ao analisar: $error',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
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
