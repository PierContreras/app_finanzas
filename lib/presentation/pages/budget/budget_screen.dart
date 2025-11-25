// presentation/pages/budget/budget_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/budget_chart.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final expenseProvider = context.read<ExpenseProvider>();
    final budgetProvider = context.read<BudgetProvider>();
    
    await expenseProvider.loadExpenses();
    await budgetProvider.loadBudgets();
    
    // Sincronizar gastos con presupuestos
    final categorySpending = _calculateCategorySpending(expenseProvider.expenses);
    budgetProvider.syncWithExpenses(categorySpending);
  }

  Map<String, double> _calculateCategorySpending(List<dynamic> expenses) {
    Map<String, double> categorySpending = {};
    
    for (var expense in expenses) {
      String category = _getExpenseCategory(expense);
      categorySpending.update(
        category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return categorySpending;
  }

  String _getExpenseCategory(dynamic expense) {
    // Si el expense tiene campo category, úsalo
    if (expense.category != null) {
      return expense.category.toString();
    }
    return 'Otros';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuestos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer2<ExpenseProvider, BudgetProvider>(
        builder: (context, expenseProvider, budgetProvider, child) {
          if (budgetProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando presupuestos...'),
                ],
              ),
            );
          }

          final expenses = expenseProvider.expenses;
          final categorySpending = _calculateCategorySpending(expenses);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Gráfico de distribución - CORREGIDO
                BudgetChart(budgetProvider: budgetProvider),
                
                const SizedBox(height: 20),
                
                // Tarjeta de resumen general
                _buildTotalBudgetCard(budgetProvider),
                
                const SizedBox(height: 20),
                
                // Encabezado de categorías
                Row(
                  children: [
                    const Text(
                      'Presupuestos por Categoría',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => _showAddBudgetDialog(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Lista de presupuestos por categoría
                _buildCategoryBudgets(budgetProvider, categorySpending),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTotalBudgetCard(BudgetProvider budgetProvider) {
    final isOverBudget = budgetProvider.totalRemaining < 0;
    
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Presupuesto Total del Mes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  onPressed: () => _showEditTotalBudgetDialog(context, budgetProvider),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: budgetProvider.totalProgressPercentage.clamp(0.0, 1.0),
              backgroundColor: Colors.white54,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gastado: \$${budgetProvider.totalSpent.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Presupuesto: \$${budgetProvider.totalBudget.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Text(
                  'Restante: \$${budgetProvider.totalRemaining.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isOverBudget ? Colors.red : Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBudgets(BudgetProvider budgetProvider, Map<String, double> categorySpending) {
    final budgets = budgetProvider.budgets;

    if (budgets.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No hay presupuestos configurados',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Presiona el botón + para agregar tu primer presupuesto',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          final spent = categorySpending[budget.category] ?? 0.0;
          final percentage = budget.allocatedAmount > 0 ? spent / budget.allocatedAmount : 0.0;
          final remaining = budget.allocatedAmount - spent;
          final isOverBudget = remaining < 0;

          return Dismissible(
            key: Key(budget.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await _showDeleteConfirmation(context, budget.category);
            },
            onDismissed: (direction) {
              budgetProvider.deleteBudget(budget.category);
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(budget.category),
                  child: Text(
                    budget.category[0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  budget.category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget ? Colors.red : 
                        percentage > 0.8 ? Colors.orange : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gastado: \$${spent.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverBudget ? Colors.red : Colors.grey[700],
                          ),
                        ),
                        Text(
                          'Presupuesto: \$${budget.allocatedAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${remaining.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isOverBudget ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isOverBudget ? 'Excedido' : 'Restante',
                      style: TextStyle(
                        color: isOverBudget ? Colors.red : Colors.green,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                onTap: () => _showEditBudgetDialog(context, budgetProvider, budget.category, budget.allocatedAmount),
              ),
            ),
          );
        },
      ),
    );
  }

  // Diálogos para edición y configuración
  void _showEditTotalBudgetDialog(BuildContext context, BudgetProvider budgetProvider) {
    final controller = TextEditingController(text: budgetProvider.totalBudget.toStringAsFixed(2));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Presupuesto Total'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Presupuesto total mensual',
            prefixText: '\$',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newBudget = double.tryParse(controller.text) ?? budgetProvider.totalBudget;
              budgetProvider.totalBudget = newBudget;
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, BudgetProvider budgetProvider, String category, double currentAmount) {
    final controller = TextEditingController(text: currentAmount.toStringAsFixed(2));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Presupuesto - $category'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nuevo presupuesto',
            prefixText: '\$',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newAmount = double.tryParse(controller.text) ?? currentAmount;
              budgetProvider.updateBudget(category, newAmount);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>(); // CORREGIDO: sin underscore
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Presupuesto'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  hintText: 'Ej: Ropa, Viajes, etc.',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Presupuesto',
                  prefixText: '\$',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un monto';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Ingresa un monto válido mayor a 0';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final category = categoryController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0.0;
                
                if (category.isNotEmpty && amount > 0) {
                  context.read<BudgetProvider>().addCustomBudget(category, amount);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final budgetProvider = context.read<BudgetProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Presupuestos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Opciones de presupuestos:'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                budgetProvider.resetToDefault();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Presupuestos restablecidos a valores por defecto')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Restablecer a Valores por Defecto'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String category) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Presupuesto'),
        content: Text('¿Estás seguro de que quieres eliminar el presupuesto de "$category"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Comida': Colors.orange,
      'Transporte': Colors.blue,
      'Entretenimiento': Colors.purple,
      'Compras': Colors.red,
      'Salud': Colors.green,
      'Educación': Colors.teal,
      'Hogar': Colors.brown,
      'Otros': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }
}