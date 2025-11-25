import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  Future<List<ExpenseEntity>> call() {
    return repository.getExpenses();
  }
}

class AddExpenseUseCase {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  Future<void> call(ExpenseEntity expense) {
    return repository.addExpense(expense);
  }
}

class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteExpense(id);
  }
}

class GetMonthlyExpensesUseCase {
  final ExpenseRepository repository;

  GetMonthlyExpensesUseCase(this.repository);

  Future<List<ExpenseEntity>> call(DateTime month) {
    return repository.getMonthlyExpenses(month);
  }
}

class GetTotalMonthlyExpensesUseCase {
  final ExpenseRepository repository;

  GetTotalMonthlyExpensesUseCase(this.repository);

  Future<double> call(DateTime month) {
    return repository.getTotalMonthlyExpenses(month);
  }
}