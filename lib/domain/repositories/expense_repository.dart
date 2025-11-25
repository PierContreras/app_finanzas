import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getExpenses();
  Future<void> addExpense(ExpenseEntity expense);
  Future<void> deleteExpense(String id);
  Future<void> updateExpense(ExpenseEntity expense);
  Future<List<ExpenseEntity>> getMonthlyExpenses(DateTime month);
  Future<double> getTotalMonthlyExpenses(DateTime month);
  Future<List<ExpenseEntity>> getExpensesByCategory(String categoryId);
}