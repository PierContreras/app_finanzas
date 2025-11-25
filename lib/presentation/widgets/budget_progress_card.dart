import 'package:flutter/material.dart';
import 'package:finanzas_app1/domain/entities/budget_entity.dart';
import 'package:finanzas_app1/domain/entities/category_entity.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetEntity budget;
  final CategoryEntity category;
  final double spentAmount;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    required this.category,
    required this.spentAmount,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = _calculatePercentage();
    final isOverBudget = percentage > 100;
    final remaining = budget.amount - spentAmount;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category.color).withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(category.name),
                    color: _getCategoryColor(category.color),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  _formatCurrency(remaining),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isOverBudget ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final progressWidth = (percentage / 100) * constraints.maxWidth;
                    return Container(
                      height: 8,
                      width: progressWidth > constraints.maxWidth 
                          ? constraints.maxWidth 
                          : progressWidth,
                      decoration: BoxDecoration(
                        color: isOverBudget ? Colors.red : _getCategoryColor(category.color),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gastado: ${_formatCurrency(spentAmount)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isOverBudget ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Presupuesto: ${_formatCurrency(budget.amount)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
            if (isOverBudget) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Has excedido tu presupuesto',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _calculatePercentage() {
    if (budget.amount == 0) return 0;
    return (spentAmount / budget.amount) * 100;
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  Color _getCategoryColor(int colorValue) {
    return Color(colorValue);
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'alimentación':
        return Icons.restaurant;
      case 'transporte':
        return Icons.directions_car;
      case 'entretenimiento':
        return Icons.movie;
      case 'salud':
        return Icons.medical_services;
      case 'educación':
        return Icons.school;
      case 'ropa':
        return Icons.shopping_bag;
      case 'hogar':
        return Icons.home;
      case 'servicios':
        return Icons.bolt;
      default:
        return Icons.category;
    }
  }
}