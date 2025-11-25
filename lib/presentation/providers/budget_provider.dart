// presentation/providers/budget_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetEntity {
  final String id;
  final String category;
  final double allocatedAmount;
  final double spentAmount;
  final DateTime period;

  BudgetEntity({
    required this.id,
    required this.category,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.period,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
      'period': period.toIso8601String(),
    };
  }

  factory BudgetEntity.fromJson(Map<String, dynamic> json) {
    return BudgetEntity(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      allocatedAmount: (json['allocatedAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      period: DateTime.tryParse(json['period'] ?? '') ?? DateTime.now(),
    );
  }

  double get remainingAmount => allocatedAmount - spentAmount;
  double get progressPercentage => allocatedAmount > 0 ? (spentAmount / allocatedAmount) : 0;
  bool get isOverBudget => spentAmount > allocatedAmount;
}

class BudgetProvider with ChangeNotifier {
  List<BudgetEntity> _budgets = [];
  bool _isLoading = false;
  String? _error;
  final SharedPreferences _prefs;

  BudgetProvider(this._prefs);

  List<BudgetEntity> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Presupuesto total configurable
  double get totalBudget {
    return _prefs.getDouble('total_budget') ?? 1500.00;
  }
  
  set totalBudget(double value) {
    _prefs.setDouble('total_budget', value);
    notifyListeners();
  }

  double get totalSpent {
    return _budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
  }
  
  double get totalRemaining => totalBudget - totalSpent;
  double get totalProgressPercentage => totalBudget > 0 ? (totalSpent / totalBudget) : 0;

  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cargar desde SharedPreferences
      final budgetsJson = _prefs.getStringList('user_budgets') ?? [];
      
      if (budgetsJson.isEmpty) {
        // Si no hay presupuestos guardados, crear unos por defecto
        _budgets = _getDefaultBudgets();
        await _saveBudgetsToPrefs();
      } else {
        _budgets = budgetsJson.map((json) {
          try {
            // Convertir el string JSON a Map
            final cleanedJson = json.replaceAll('{', '').replaceAll('}', '');
            final pairs = cleanedJson.split(', ');
            final Map<String, dynamic> data = {};
            
            for (var pair in pairs) {
              final keyValue = pair.split(': ');
              if (keyValue.length == 2) {
                final key = keyValue[0].trim();
                var value = keyValue[1].trim();
                
                // Limpiar y convertir valores
                if (value.startsWith("'") && value.endsWith("'")) {
                  value = value.substring(1, value.length - 1);
                }
                
                data[key] = value;
              }
            }
            
            return BudgetEntity.fromJson(data);
          } catch (e) {
            debugPrint('Error parsing budget JSON: $e');
            return _getDefaultBudgets().firstWhere((b) => b.id == '1');
          }
        }).toList();
      }
      
      _error = null;
    } catch (e) {
      _error = 'Error al cargar presupuestos: $e';
      _budgets = _getDefaultBudgets();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveBudgetsToPrefs() async {
    try {
      final budgetsJson = _budgets.map((budget) => budget.toJson().toString()).toList();
      await _prefs.setStringList('user_budgets', budgetsJson);
    } catch (e) {
      debugPrint('Error saving budgets to prefs: $e');
    }
  }

  Future<void> updateBudget(String category, double newAllocatedAmount) async {
    final index = _budgets.indexWhere((budget) => budget.category == category);
    
    if (index != -1) {
      _budgets[index] = BudgetEntity(
        id: _budgets[index].id,
        category: _budgets[index].category,
        allocatedAmount: newAllocatedAmount,
        spentAmount: _budgets[index].spentAmount,
        period: _budgets[index].period,
      );
    } else {
      // Crear nuevo presupuesto si no existe
      _budgets.add(BudgetEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        allocatedAmount: newAllocatedAmount,
        spentAmount: 0.0,
        period: DateTime.now(),
      ));
    }
    
    await _saveBudgetsToPrefs();
    notifyListeners();
  }

  Future<void> updateSpentAmount(String category, double newSpentAmount) async {
    final index = _budgets.indexWhere((budget) => budget.category == category);
    if (index != -1) {
      _budgets[index] = BudgetEntity(
        id: _budgets[index].id,
        category: _budgets[index].category,
        allocatedAmount: _budgets[index].allocatedAmount,
        spentAmount: newSpentAmount,
        period: _budgets[index].period,
      );
      await _saveBudgetsToPrefs();
      notifyListeners();
    }
  }

  // MÉTODO QUE FALTABA - AGREGAR ESTO
  void syncWithExpenses(Map<String, double> categoryExpenses) {
    for (var budget in _budgets) {
      final spent = categoryExpenses[budget.category] ?? 0.0;
      final index = _budgets.indexWhere((b) => b.category == budget.category);
      if (index != -1) {
        _budgets[index] = BudgetEntity(
          id: _budgets[index].id,
          category: _budgets[index].category,
          allocatedAmount: _budgets[index].allocatedAmount,
          spentAmount: spent,
          period: _budgets[index].period,
        );
      }
    }
    _saveBudgetsToPrefs();
    notifyListeners();
  }

  Future<void> addCustomBudget(String category, double allocatedAmount) async {
    // Verificar si la categoría ya existe
    final existingIndex = _budgets.indexWhere((budget) => budget.category == category);
    
    if (existingIndex != -1) {
      // Actualizar presupuesto existente
      await updateBudget(category, allocatedAmount);
    } else {
      // Agregar nuevo presupuesto
      _budgets.add(BudgetEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        allocatedAmount: allocatedAmount,
        spentAmount: 0.0,
        period: DateTime.now(),
      ));
      await _saveBudgetsToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteBudget(String category) async {
    _budgets.removeWhere((budget) => budget.category == category);
    await _saveBudgetsToPrefs();
    notifyListeners();
  }

  List<BudgetEntity> _getDefaultBudgets() {
    return [
      BudgetEntity(
        id: '1',
        category: 'Comida',
        allocatedAmount: 300.0,
        spentAmount: 0.0,
        period: DateTime.now(),
      ),
      BudgetEntity(
        id: '2',
        category: 'Transporte',
        allocatedAmount: 200.0,
        spentAmount: 0.0,
        period: DateTime.now(),
      ),
      BudgetEntity(
        id: '3',
        category: 'Entretenimiento',
        allocatedAmount: 150.0,
        spentAmount: 0.0,
        period: DateTime.now(),
      ),
      BudgetEntity(
        id: '4',
        category: 'Compras',
        allocatedAmount: 250.0,
        spentAmount: 0.0,
        period: DateTime.now(),
      ),
      BudgetEntity(
        id: '5',
        category: 'Salud',
        allocatedAmount: 100.0,
        spentAmount: 0.0,
        period: DateTime.now(),
      ),
      BudgetEntity(
        id: '6',
        category: 'Educación',
        allocatedAmount: 150.0,
        spentAmount: 0.0,
        period: DateTime.now(),
      ),
      BudgetEntity(
        id: '7',
        category: 'Hogar',
        allocatedAmount: 200.0,
        spentAmount: 0.0,
        period: DateTime.now(),
      ),
      BudgetEntity(
        id: '8',
        category: 'Otros',
        allocatedAmount: 150.0,
        spentAmount: 0.0,
        period: DateTime.now(),
      ),
    ];
  }

  // Obtener presupuesto por categoría
  BudgetEntity? getBudgetForCategory(String category) {
    try {
      return _budgets.firstWhere((budget) => budget.category == category);
    } catch (e) {
      return null;
    }
  }

  // Reiniciar presupuestos a valores por defecto
  Future<void> resetToDefault() async {
    _budgets = _getDefaultBudgets();
    await _saveBudgetsToPrefs();
    notifyListeners();
  }
}