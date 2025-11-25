import 'package:finanzas_app1/data/models/expense_model.dart';

class ExpenseService {
  // Lista temporal en memoria (reemplazar con base de datos después)
  static final List<ExpenseModel> _expenses = [];

  // Obtener todos los gastos
  static Future<List<ExpenseModel>> getExpenses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Devolver copia de la lista para evitar modificaciones externas
    return List<ExpenseModel>.from(_expenses);
  }

  // Obtener gastos por categoría
  static Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _expenses
        .where((expense) => expense.category == category)
        .toList();
  }

  // Agregar un nuevo gasto
  static Future<void> addExpense(ExpenseModel expense) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _expenses.add(expense);
    // Ordenar por fecha (más reciente primero)
    _expenses.sort((a, b) => b.date.compareTo(a.date));
  }

  // Actualizar un gasto existente
  static Future<bool> updateExpense(ExpenseModel updatedExpense) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _expenses.indexWhere((expense) => expense.id == updatedExpense.id);
    
    if (index != -1) {
      _expenses[index] = updatedExpense;
      return true;
    }
    return false;
  }

  // Eliminar un gasto
  static Future<bool> deleteExpense(String expenseId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final initialLength = _expenses.length;
    _expenses.removeWhere((expense) => expense.id == expenseId);
    return _expenses.length < initialLength;
  }

  // Obtener gasto por ID
  static Future<ExpenseModel?> getExpenseById(String expenseId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _expenses.firstWhere((expense) => expense.id == expenseId);
    } catch (e) {
      return null;
    }
  }

  // Obtener total de gastos
  static Future<double> getTotalExpenses() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    double total = 0.0;
    for (final expense in _expenses) {
      total += expense.amount;
    }
    return total;
  }

  // Obtener gastos del mes actual
  static Future<List<ExpenseModel>> getCurrentMonthExpenses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _expenses
        .where((expense) => 
          expense.date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) && 
          expense.date.isBefore(lastDayOfMonth.add(const Duration(days: 1))))
        .toList();
  }

  // Obtener total por categorías para gastos
  static Future<Map<String, double>> getExpensesByCategorySummary() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final Map<String, double> categoryTotals = {};
    
    for (final expense in _expenses) {
      final currentAmount = categoryTotals[expense.category] ?? 0.0;
      categoryTotals[expense.category] = currentAmount + expense.amount;
    }
    
    return categoryTotals;
  }

  // Obtener gastos por rango de fechas
  static Future<List<ExpenseModel>> getExpensesByDateRange(DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _expenses
        .where((expense) => 
          expense.date.isAfter(start.subtract(const Duration(days: 1))) && 
          expense.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  // Cargar datos de ejemplo (para testing) - CORREGIDO
  static Future<void> loadSampleData() async {
    _expenses.clear();
    
    final sampleExpenses = [
      // Gastos de ejemplo
      ExpenseModel(
        id: '1',
        title: 'Supermercado',
        amount: 150.50,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Alimentación',
        description: 'Compra semanal',
      ),
      ExpenseModel(
        id: '2',
        title: 'Gasolina',
        amount: 45.00,
        date: DateTime.now().subtract(const Duration(days: 3)),
        category: 'Transporte',
      ),
      ExpenseModel(
        id: '3',
        title: 'Cine',
        amount: 25.00,
        date: DateTime.now().subtract(const Duration(days: 5)),
        category: 'Entretenimiento',
        description: 'Película con amigos',
      ),
      ExpenseModel(
        id: '4',
        title: 'Consulta médica',
        amount: 80.00,
        date: DateTime.now().subtract(const Duration(days: 7)),
        category: 'Salud',
      ),
      ExpenseModel(
        id: '5',
        title: 'Libros',
        amount: 60.25,
        date: DateTime.now().subtract(const Duration(days: 10)),
        category: 'Educación',
      ),
      ExpenseModel(
        id: '6',
        title: 'Ropa',
        amount: 120.00,
        date: DateTime.now().subtract(const Duration(days: 12)),
        category: 'Ropa',
        description: 'Zapatos nuevos',
      ),
      ExpenseModel(
        id: '7',
        title: 'Luz',
        amount: 85.30,
        date: DateTime.now().subtract(const Duration(days: 15)),
        category: 'Servicios',
      ),
      ExpenseModel(
        id: '8',
        title: 'Internet',
        amount: 45.00,
        date: DateTime.now().subtract(const Duration(days: 18)),
        category: 'Servicios',
      ),
    ];

    _expenses.addAll(sampleExpenses);
    // Ordenar por fecha (más reciente primero)
    _expenses.sort((a, b) => b.date.compareTo(a.date));
  }

  // Limpiar todos los gastos (solo para desarrollo)
  static Future<void> clearAllExpenses() async {
    _expenses.clear();
  }

  // Verificar si existe un gasto con el mismo título y fecha
  static Future<bool> expenseExists(String title, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _expenses.any((expense) => 
      expense.title == title && 
      expense.date.year == date.year &&
      expense.date.month == date.month &&
      expense.date.day == date.day);
  }

  // Obtener estadísticas mensuales
  static Future<Map<String, dynamic>> getMonthlyStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final monthlyExpenses = await getCurrentMonthExpenses();
    final totalExpenses = await getTotalExpenses();
    
    return {
      'monthlyExpenses': monthlyExpenses.fold<double>(0.0, (double sum, ExpenseModel expense) => sum + expense.amount),
      'totalExpenses': totalExpenses,
      'expenseCount': _expenses.length,
      'monthlyExpenseCount': monthlyExpenses.length,
    };
  }

  // Obtener gastos recientes (últimos 10)
  static Future<List<ExpenseModel>> getRecentExpenses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _expenses.take(10).toList();
  }

  // Obtener total de gastos del mes actual
  static Future<double> getCurrentMonthTotal() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final monthlyExpenses = await getCurrentMonthExpenses();
    return monthlyExpenses.fold<double>(0.0, (double sum, ExpenseModel expense) => sum + expense.amount);
  }
}