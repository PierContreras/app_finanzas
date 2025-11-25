// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:finanzas_app1/core/themes/app_theme.dart';

// Data
import 'package:finanzas_app1/data/datasources/local_datasource.dart';
import 'package:finanzas_app1/data/repositories/auth_repository_impl.dart';
import 'package:finanzas_app1/data/repositories/expense_repository_impl.dart';
import 'package:finanzas_app1/data/repositories/category_repository_impl.dart';

// Domain
import 'package:finanzas_app1/domain/repositories/auth_repository.dart';
import 'package:finanzas_app1/domain/repositories/expense_repository.dart';
import 'package:finanzas_app1/domain/repositories/category_repository.dart';
import 'package:finanzas_app1/domain/usecases/auth_usecases.dart';
import 'package:finanzas_app1/domain/usecases/expense_usecases.dart';
import 'package:finanzas_app1/domain/usecases/category_usecases.dart';

// Presentation
import 'package:finanzas_app1/presentation/providers/theme_provider.dart';
import 'package:finanzas_app1/presentation/providers/auth_provider.dart';
import 'package:finanzas_app1/presentation/providers/expense_provider.dart';
import 'package:finanzas_app1/presentation/providers/category_provider.dart';
import 'package:finanzas_app1/presentation/providers/budget_provider.dart';
import 'package:finanzas_app1/presentation/pages/auth/login_screen.dart';
import 'package:finanzas_app1/presentation/pages/home/home_screen.dart';
import 'package:finanzas_app1/presentation/pages/home/dashboard_screen.dart';
import 'package:finanzas_app1/presentation/pages/expenses/view_expenses_screen.dart';
import 'package:finanzas_app1/presentation/pages/expenses/add_expense_screen.dart';
import 'package:finanzas_app1/presentation/pages/budget/budget_screen.dart';
import 'package:finanzas_app1/presentation/pages/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final sharedPreferences = await SharedPreferences.getInstance();

    runApp(buildApp(sharedPreferences));
  } catch (error) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error inicializando la aplicación'),
          ),
        ),
      ),
    );
  }
}

Widget buildApp(SharedPreferences sharedPreferences) {
  final localDataSource = LocalDataSource(sharedPreferences: sharedPreferences);

  // Repositorios
  final AuthRepository authRepository = AuthRepositoryImpl(localDataSource: localDataSource);
  final ExpenseRepository expenseRepository = ExpenseRepositoryImpl(localDataSource: localDataSource);
  final CategoryRepository categoryRepository = CategoryRepositoryImpl(localDataSource: localDataSource);

  // Auth Use Cases
  final SignInUseCase signInUseCase = SignInUseCase(authRepository);
  final SignUpUseCase signUpUseCase = SignUpUseCase(authRepository);
  final SignOutUseCase signOutUseCase = SignOutUseCase(authRepository);
  final GetCurrentUserUseCase getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);

  // Expense Use Cases
  final GetExpensesUseCase getExpensesUseCase = GetExpensesUseCase(expenseRepository);
  final AddExpenseUseCase addExpenseUseCase = AddExpenseUseCase(expenseRepository);
  final DeleteExpenseUseCase deleteExpenseUseCase = DeleteExpenseUseCase(expenseRepository);
  final GetMonthlyExpensesUseCase getMonthlyExpensesUseCase = GetMonthlyExpensesUseCase(expenseRepository);
  final GetTotalMonthlyExpensesUseCase getTotalMonthlyExpensesUseCase = GetTotalMonthlyExpensesUseCase(expenseRepository);

  // Category Use Cases
  final GetCategoriesUseCase getCategoriesUseCase = GetCategoriesUseCase(categoryRepository);
  final AddCategoryUseCase addCategoryUseCase = AddCategoryUseCase(categoryRepository);
  final GetCategoryByIdUseCase getCategoryByIdUseCase = GetCategoryByIdUseCase(categoryRepository);
  final UpdateCategoryUseCase updateCategoryUseCase = UpdateCategoryUseCase(categoryRepository);
  final DeleteCategoryUseCase deleteCategoryUseCase = DeleteCategoryUseCase(categoryRepository);
  final CategoryExistsUseCase categoryExistsUseCase = CategoryExistsUseCase(categoryRepository);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => BudgetProvider(sharedPreferences)),
      ChangeNotifierProvider(
        create: (_) => AuthProvider(
          signInUseCase: signInUseCase,
          signUpUseCase: signUpUseCase,
          signOutUseCase: signOutUseCase,
          getCurrentUserUseCase: getCurrentUserUseCase,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => ExpenseProvider(
          getExpensesUseCase: getExpensesUseCase,
          addExpenseUseCase: addExpenseUseCase,
          deleteExpenseUseCase: deleteExpenseUseCase,
          getMonthlyExpensesUseCase: getMonthlyExpensesUseCase,
          getTotalMonthlyExpensesUseCase: getTotalMonthlyExpensesUseCase,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => CategoryProvider(
          getCategoriesUseCase: getCategoriesUseCase,
          addCategoryUseCase: addCategoryUseCase,
          getCategoryByIdUseCase: getCategoryByIdUseCase,
          updateCategoryUseCase: updateCategoryUseCase,
          deleteCategoryUseCase: deleteCategoryUseCase,
          categoryExistsUseCase: categoryExistsUseCase,
        ),
      ),
    ],
    child: const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Finanzas App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AppWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/home': (context) => const HomeScreen(),
        '/view-expenses': (context) => const ViewExpensesScreen(),
        '/add-expense': (context) => const AddExpenseScreen(),
        '/budget': (context) => const BudgetScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isInitializing = true;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final authProvider = context.read<AuthProvider>();

      await authProvider.initialize();

      // Pequeña delay para mejor UX
      await Future.delayed(const Duration(milliseconds: 800));

    } catch (error) {
      _initializationError = error.toString();
      debugPrint('Error en inicialización: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_isInitializing) {
      return _buildLoadingScreen();
    }

    if (_initializationError != null) {
      return _buildErrorScreen();
    }

    return authProvider.isAuthenticated ? const HomeScreen() : const LoginScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Inicializando Finanzas App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Cargando tus datos...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                'Error al inicializar la aplicación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _initializationError ?? 'Error desconocido',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeApp,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}