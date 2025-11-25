// data/repositories/expense_repository_impl.dart
import 'package:finanzas_app1/domain/repositories/expense_repository.dart';
import 'package:finanzas_app1/domain/entities/expense_entity.dart';
import '../models/expense_model.dart';
import '../datasources/local_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final LocalDataSource localDataSource;

  ExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ExpenseEntity>> getExpenses() async {
    try {
      final models = await localDataSource.getExpenses();
      return models.map((model) => _convertToEntity(model)).toList();
    } catch (e) {
      throw Exception('Error al obtener gastos: $e');
    }
  }

  @override
  Future<void> addExpense(ExpenseEntity expense) async {
    try {
      final model = _convertToModel(expense);
      await localDataSource.addExpense(model);
    } catch (e) {
      throw Exception('Error al agregar gasto: $e');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await localDataSource.deleteExpense(id);
    } catch (e) {
      throw Exception('Error al eliminar gasto: $e');
    }
  }

  @override
  Future<List<ExpenseEntity>> getMonthlyExpenses(DateTime month) async {
    try {
      final allExpenses = await getExpenses();
      return allExpenses.where((expense) {
        return expense.date.year == month.year && expense.date.month == month.month;
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener gastos mensuales: $e');
    }
  }

  @override
  Future<double> getTotalMonthlyExpenses(DateTime month) async {
    try {
      final monthlyExpenses = await getMonthlyExpenses(month);
      // CORREGIDO: Usar fold con tipos explícitos
      return monthlyExpenses.fold<double>(0.0, (double sum, expense) => sum + expense.amount);
    } catch (e) {
      throw Exception('Error al calcular total mensual: $e');
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByCategory(String categoryId) async {
    try {
      final allExpenses = await getExpenses();
      return allExpenses.where((expense) => expense.categoryId == categoryId).toList();
    } catch (e) {
      throw Exception('Error al obtener gastos por categoría: $e');
    }
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    try {
      final model = _convertToModel(expense);
      await localDataSource.updateExpense(model);
    } catch (e) {
      throw Exception('Error al actualizar gasto: $e');
    }
  }

  // Método auxiliar para convertir Model a Entity
  ExpenseEntity _convertToEntity(ExpenseModel model) {
    return ExpenseEntity(
      id: model.id,
      title: model.title,
      amount: model.amount,
      date: model.date,
      categoryId: model.category,
      description: model.description ?? '',
    );
  }

  // Método auxiliar para convertir Entity a Model
  ExpenseModel _convertToModel(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      date: entity.date,
      category: entity.categoryId,
      description: entity.description,
    );
  }
}