
// presentation/widgets/budget_chart.dart
import 'package:flutter/material.dart';
import '../providers/budget_provider.dart';

class BudgetChart extends StatelessWidget {
  final BudgetProvider budgetProvider;

  const BudgetChart({super.key, required this.budgetProvider});

  @override
  Widget build(BuildContext context) {
    final budgets = budgetProvider.budgets
        .where((b) => b.allocatedAmount > 0)
        .toList();

    if (budgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso de Presupuestos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBudgetProgressList(budgets),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetProgressList(List<BudgetEntity> budgets) {
    return Column(
      children: budgets.map((budget) {
        final percentage = budget.allocatedAmount > 0
            ? (budget.spentAmount / budget.allocatedAmount)
            : 0.0;
        final isOverBudget = budget.isOverBudget;
        final remaining = budget.remainingAmount;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(budget.category),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      budget.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isOverBudget ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget
                      ? Colors.red
                      : percentage > 0.8
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gastado: \$${budget.spentAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverBudget ? Colors.red : Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Presupuesto: \$${budget.allocatedAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    isOverBudget
                        ? 'Excedido: \$${remaining.abs().toStringAsFixed(2)}'
                        : 'Restante: \$${remaining.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isOverBudget ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = <String, Color>{
      'Comida': Colors.orange,
      'Transporte': Colors.blue,
      'Entretenimiento': Colors.purple,
      'Compras': Colors.red,
      'Salud': Colors.green,
      'Educación': Colors.teal,
      'Hogar': Colors.brown,
      'Otros': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }
}
