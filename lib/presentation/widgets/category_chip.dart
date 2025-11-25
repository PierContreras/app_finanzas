import 'package:flutter/material.dart';
import 'package:finanzas_app1/domain/entities/category_entity.dart';

class CategoryChip extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showIcon;
  final bool showAmount;
  final double? amount;
  final bool compact;
  

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.showIcon = true,
    this.showAmount = false,
    this.amount,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = Color(category.color);
    final categoryIcon = _getCategoryIcon(category.name);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? categoryColor 
              : categoryColor.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: categoryColor,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: categoryColor.withAlpha(76),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                categoryIcon,
                color: isSelected ? Colors.white : categoryColor,
                size: compact ? 14 : 16,
              ),
              SizedBox(width: compact ? 4 : 6),
            ],
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : categoryColor,
                fontWeight: FontWeight.w500,
                fontSize: compact ? 12 : 14,
              ),
            ),
            if (showAmount && amount != null) ...[
              SizedBox(width: compact ? 4 : 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withAlpha(51) 
                      : categoryColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '\$${amount!.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : categoryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 10 : 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'alimentación':
      case 'comida':
      case 'restaurante':
        return Icons.restaurant;
      
      case 'transporte':
      case 'gasolina':
      case 'taxi':
        return Icons.directions_car;
      
      case 'entretenimiento':
      case 'cine':
      case 'streaming':
        return Icons.movie;
      
      case 'salud':
      case 'medicina':
      case 'hospital':
        return Icons.medical_services;
      
      case 'educación':
      case 'libros':
      case 'cursos':
        return Icons.school;
      
      case 'ropa':
      case 'moda':
      case 'zapatos':
        return Icons.shopping_bag;
      
      case 'hogar':
      case 'casa':
      case 'decoración':
        return Icons.home;
      
      case 'servicios':
      case 'luz':
      case 'agua':
      case 'internet':
        return Icons.bolt;
      
      case 'regalos':
      case 'donaciones':
        return Icons.card_giftcard;
      
      case 'viajes':
      case 'vacaciones':
        return Icons.flight;
      
      case 'deportes':
      case 'gimnasio':
        return Icons.fitness_center;
      
      case 'otros':
      default:
        return Icons.category;
    }
  }
}