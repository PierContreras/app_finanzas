import 'package:flutter/foundation.dart';
import 'package:finanzas_app1/domain/entities/expense_entity.dart';
import 'package:finanzas_app1/domain/usecases/expense_usecases.dart';

class ExpenseProvider with ChangeNotifier {
  final GetExpensesUseCase getExpensesUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final GetMonthlyExpensesUseCase getMonthlyExpensesUseCase;
  final GetTotalMonthlyExpensesUseCase getTotalMonthlyExpensesUseCase;

  ExpenseProvider({
    required this.getExpensesUseCase,
    required this.addExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.getMonthlyExpensesUseCase,
    required this.getTotalMonthlyExpensesUseCase,
  });

  List<ExpenseEntity> _expenses = [];
  List<ExpenseEntity> get expenses => _expenses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double _monthlyTotal = 0;
  double get monthlyTotal => _monthlyTotal;

  String? _error;
  String? get error => _error;

  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await getExpensesUseCase();
      _monthlyTotal = await getTotalMonthlyExpensesUseCase(DateTime.now());
    } catch (e) {
      _error = 'Error al cargar gastos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(ExpenseEntity expense) async {
    _error = null;
    try {
      await addExpenseUseCase(expense);
      _expenses.add(expense);
      _monthlyTotal += expense.amount;
      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar gasto: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    _error = null;
    try {
      final expense = _expenses.firstWhere((e) => e.id == id);
      await deleteExpenseUseCase(id);
      _expenses.removeWhere((e) => e.id == id);
      _monthlyTotal -= expense.amount;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar gasto: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadMonthlyExpenses(DateTime month) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await getMonthlyExpensesUseCase(month);
      _monthlyTotal = await getTotalMonthlyExpensesUseCase(month);
    } catch (e) {
      _error = 'Error al cargar gastos mensuales: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}