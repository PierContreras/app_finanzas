import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';

class LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSource({required this.sharedPreferences});

  // Keys for SharedPreferences
  static const String _expensesKey = 'expenses';
  static const String _userKey = 'current_user';
  static const String _categoriesKey = 'categories';
  static const String _budgetsKey = 'budgets';
  static const String _settingsKey = 'app_settings';

  // ============ USER METHODS ============

  /// Save user to local storage
  Future<void> saveUser(UserModel user) async {
    try {
      await sharedPreferences.setString(_userKey, json.encode(user.toMap()));
    } catch (e) {
      throw Exception('Error saving user: $e');
    }
  }

  /// Get current user from local storage
  Future<UserModel?> getUser() async {
    try {
      final userData = sharedPreferences.getString(_userKey);
      if (userData != null) {
        final map = json.decode(userData) as Map<String, dynamic>;
        return UserModel.fromMap(map);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  /// Delete user from local storage (logout)
  Future<void> deleteUser() async {
    try {
      await sharedPreferences.remove(_userKey);
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // ============ EXPENSE METHODS ============

  /// Get all expenses from local storage
  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final expensesData = sharedPreferences.getString(_expensesKey);
      if (expensesData != null) {
        final List<dynamic> jsonList = json.decode(expensesData);
        return jsonList.map((json) => ExpenseModel.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error getting expenses: $e');
    }
  }

  /// Save all expenses to local storage
  Future<void> saveExpenses(List<ExpenseModel> expenses) async {
    try {
      final jsonList = expenses.map((expense) => expense.toMap()).toList();
      await sharedPreferences.setString(_expensesKey, json.encode(jsonList));
    } catch (e) {
      throw Exception('Error saving expenses: $e');
    }
  }

  /// Add a new expense
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final expenses = await getExpenses();
      expenses.add(expense);
      await saveExpenses(expenses);
    } catch (e) {
      throw Exception('Error adding expense: $e');
    }
  }

  /// Update an existing expense
  Future<void> updateExpense(ExpenseModel updatedExpense) async {
    try {
      final expenses = await getExpenses();
      final index = expenses.indexWhere((expense) => expense.id == updatedExpense.id);
      if (index != -1) {
        expenses[index] = updatedExpense;
        await saveExpenses(expenses);
      } else {
        throw Exception('Expense not found');
      }
    } catch (e) {
      throw Exception('Error updating expense: $e');
    }
  }

  /// Delete an expense by ID
  Future<void> deleteExpense(String id) async {
    try {
      final expenses = await getExpenses();
      expenses.removeWhere((expense) => expense.id == id);
      await saveExpenses(expenses);
    } catch (e) {
      throw Exception('Error deleting expense: $e');
    }
  }

  /// Get expenses for a specific month
  Future<List<ExpenseModel>> getMonthlyExpenses(DateTime month) async {
    try {
      final expenses = await getExpenses();
      return expenses.where((expense) {
        return expense.date.year == month.year && expense.date.month == month.month;
      }).toList();
    } catch (e) {
      throw Exception('Error getting monthly expenses: $e');
    }
  }

  /// Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory(String categoryId) async {
    try {
      final expenses = await getExpenses();
      return expenses.where((expense) => expense.category == categoryId).toList();
    } catch (e) {
      throw Exception('Error getting expenses by category: $e');
    }
  }

  /// Get total amount spent for a specific month
  Future<double> getTotalMonthlyExpenses(DateTime month) async {
    try {
      final monthlyExpenses = await getMonthlyExpenses(month);
      return monthlyExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      throw Exception('Error calculating total monthly expenses: $e');
    }
  }

  // ============ CATEGORY METHODS ============

  /// Get all categories from local storage
  Future<List<CategoryModel>> getCategories() async {
    try {
      final categoriesData = sharedPreferences.getString(_categoriesKey);
      if (categoriesData != null) {
        final List<dynamic> jsonList = json.decode(categoriesData);
        return jsonList.map((json) => CategoryModel.fromMap(json)).toList();
      }
      
      // Default categories if none exist
      return _getDefaultCategories();
    } catch (e) {
      throw Exception('Error getting categories: $e');
    }
  }

  /// Save all categories to local storage
  Future<void> saveCategories(List<CategoryModel> categories) async {
    try {
      final jsonList = categories.map((category) => category.toMap()).toList();
      await sharedPreferences.setString(_categoriesKey, json.encode(jsonList));
    } catch (e) {
      throw Exception('Error saving categories: $e');
    }
  }

  /// Add a new category
  Future<void> addCategory(CategoryModel category) async {
    try {
      final categories = await getCategories();
      categories.add(category);
      await saveCategories(categories);
    } catch (e) {
      throw Exception('Error adding category: $e');
    }
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final categories = await getCategories();
      return categories.firstWhere(
        (category) => category.id == id,
        orElse: () => throw Exception('Category not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if category name already exists
  Future<bool> categoryExists(String name) async {
    try {
      final categories = await getCategories();
      return categories.any((category) => 
        category.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return false;
    }
  }

  /// Get default categories
  List<CategoryModel> _getDefaultCategories() {
    return [
      CategoryModel(id: '1', name: 'Alimentación', color: 0xFF4CAF50),
      CategoryModel(id: '2', name: 'Transporte', color: 0xFF2196F3),
      CategoryModel(id: '3', name: 'Entretenimiento', color: 0xFF9C27B0),
      CategoryModel(id: '4', name: 'Salud', color: 0xFFF44336),
      CategoryModel(id: '5', name: 'Educación', color: 0xFFFF9800),
      CategoryModel(id: '6', name: 'Ropa', color: 0xFFE91E63),
      CategoryModel(id: '7', name: 'Hogar', color: 0xFF795548),
      CategoryModel(id: '8', name: 'Servicios', color: 0xFF607D8B),
      CategoryModel(id: '9', name: 'Otros', color: 0xFF9E9E9E),
    ];
  }

  // ============ BUDGET METHODS ============

  /// Get all budgets from local storage
  Future<List<BudgetModel>> getBudgets() async {
    try {
      final budgetsData = sharedPreferences.getString(_budgetsKey);
      if (budgetsData != null) {
        final List<dynamic> jsonList = json.decode(budgetsData);
        return jsonList.map((json) => BudgetModel.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error getting budgets: $e');
    }
  }

  /// Save all budgets to local storage
  Future<void> saveBudgets(List<BudgetModel> budgets) async {
    try {
      final jsonList = budgets.map((budget) => budget.toMap()).toList();
      await sharedPreferences.setString(_budgetsKey, json.encode(jsonList));
    } catch (e) {
      throw Exception('Error saving budgets: $e');
    }
  }

  /// Add a new budget
  Future<void> addBudget(BudgetModel budget) async {
    try {
      final budgets = await getBudgets();
      budgets.add(budget);
      await saveBudgets(budgets);
    } catch (e) {
      throw Exception('Error adding budget: $e');
    }
  }

  /// Update an existing budget
  Future<void> updateBudget(BudgetModel updatedBudget) async {
    try {
      final budgets = await getBudgets();
      final index = budgets.indexWhere((budget) => budget.id == updatedBudget.id);
      if (index != -1) {
        budgets[index] = updatedBudget;
        await saveBudgets(budgets);
      } else {
        throw Exception('Budget not found');
      }
    } catch (e) {
      throw Exception('Error updating budget: $e');
    }
  }

  /// Delete a budget by ID
  Future<void> deleteBudget(String id) async {
    try {
      final budgets = await getBudgets();
      budgets.removeWhere((budget) => budget.id == id);
      await saveBudgets(budgets);
    } catch (e) {
      throw Exception('Error deleting budget: $e');
    }
  }

  /// Get budget for a specific category and month
  Future<BudgetModel?> getBudgetForCategory(String categoryId, DateTime month) async {
    try {
      final budgets = await getBudgets();
      return budgets.firstWhere(
        (budget) => budget.categoryId == categoryId && 
                   budget.month.year == month.year && 
                   budget.month.month == month.month,
        orElse: () => throw Exception('Budget not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all budgets for a specific month
  Future<List<BudgetModel>> getMonthlyBudgets(DateTime month) async {
    try {
      final budgets = await getBudgets();
      return budgets.where((budget) =>
        budget.month.year == month.year && budget.month.month == month.month
      ).toList();
    } catch (e) {
      throw Exception('Error getting monthly budgets: $e');
    }
  }

  // ============ SETTINGS METHODS ============

  /// Save app settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      await sharedPreferences.setString(_settingsKey, json.encode(settings));
    } catch (e) {
      throw Exception('Error saving settings: $e');
    }
  }

  /// Get app settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final settingsData = sharedPreferences.getString(_settingsKey);
      if (settingsData != null) {
        final Map<String, dynamic> settings = json.decode(settingsData);
        return settings;
      }
      return {
        'theme': 'light',
        'currency': '\$',
        'firstTime': true,
      };
    } catch (e) {
      throw Exception('Error getting settings: $e');
    }
  }

  /// Clear all data (for debugging or reset)
  Future<void> clearAllData() async {
    try {
      await sharedPreferences.remove(_expensesKey);
      await sharedPreferences.remove(_userKey);
      await sharedPreferences.remove(_categoriesKey);
      await sharedPreferences.remove(_budgetsKey);
      await sharedPreferences.remove(_settingsKey);
    } catch (e) {
      throw Exception('Error clearing data: $e');
    }
  }

  // ============ UTILITY METHODS ============

  /// Get total spent for a specific category in a month
  Future<double> getCategorySpent(String categoryId, DateTime month) async {
    try {
      final monthlyExpenses = await getMonthlyExpenses(month);
      final categoryExpenses = monthlyExpenses.where(
        (expense) => expense.category == categoryId
      );
      return categoryExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      throw Exception('Error calculating category spent: $e');
    }
  }

  /// Check if there's any data in the app
  Future<bool> hasData() async {
    try {
      final hasUser = await getUser() != null;
      final hasExpenses = (await getExpenses()).isNotEmpty;
      final hasBudgets = (await getBudgets()).isNotEmpty;
      
      return hasUser || hasExpenses || hasBudgets;
    } catch (e) {
      return false;
    }
  }

  /// Get app statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final expenses = await getExpenses();
      final categories = await getCategories();
      final budgets = await getBudgets();
      
      final totalExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      final currentMonth = DateTime.now();
      final monthlyExpenses = await getTotalMonthlyExpenses(currentMonth);
      
      return {
        'totalExpenses': totalExpenses,
        'monthlyExpenses': monthlyExpenses,
        'totalCategories': categories.length,
        'totalBudgets': budgets.length,
        'expenseCount': expenses.length,
      };
    } catch (e) {
      throw Exception('Error getting statistics: $e');
    }
  }
}