import 'package:flutter/material.dart';
import 'package:finanzas_app1/domain/entities/category_entity.dart';

class CategoryUtils {
  static Color getCategoryColor(CategoryEntity category) {
    return Color(category.color);
  }

  static IconData getCategoryIcon(CategoryEntity category) {
    return _getCategoryIcon(category.name);
  }

  static IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'alimentación': return Icons.restaurant;
      case 'transporte': return Icons.directions_car;
      case 'entretenimiento': return Icons.movie;
      case 'salud': return Icons.medical_services;
      case 'educación': return Icons.school;
      case 'ropa': return Icons.shopping_bag;
      case 'hogar': return Icons.home;
      case 'servicios': return Icons.bolt;
      case 'otros': return Icons.category;
      default: return Icons.attach_money;
    }
  }

  static String getCategoryDisplayName(String categoryName) {
    return categoryName;
  }
}