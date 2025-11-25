import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finanzas_app1/presentation/providers/expense_provider.dart';
import 'package:finanzas_app1/presentation/widgets/expense_card.dart';

class ViewExpensesScreen extends StatefulWidget {
  const ViewExpensesScreen({super.key});

  @override
  State<ViewExpensesScreen> createState() => _ViewExpensesScreenState();
}

class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar gastos cuando se inicia la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Gastos'),
        actions: [
          if (expenseProvider.expenses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearAllDialog(context, expenseProvider),
            ),
        ],
      ),
      body: _buildBody(expenseProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de agregar gasto
          Navigator.pushNamed(context, '/add-expense');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ExpenseProvider expenseProvider) {
    if (expenseProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando gastos...'),
          ],
        ),
      );
    }

    if (expenseProvider.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.money_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No hay gastos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega tu primer gasto para comenzar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-expense');
              },
              child: const Text('Agregar Primer Gasto'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenseProvider.expenses.length,
      itemBuilder: (context, index) {
        final expense = expenseProvider.expenses[index];
        return ExpenseCard(
          expense: expense,
          onDelete: () => _showDeleteDialog(context, expenseProvider, expense.id),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, ExpenseProvider provider, String expenseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gasto'),
        content: const Text('¿Estás seguro de que quieres eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await provider.deleteExpense(expenseId);
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Gasto eliminado')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, ExpenseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Todos los Gastos'),
        content: const Text('¿Estás seguro de que quieres eliminar todos los gastos? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar eliminación de todos los gastos
              _clearAllExpenses(provider);
            },
            child: const Text('Eliminar Todos', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllExpenses(ExpenseProvider provider) async {
    try {
      // Crear copia de la lista antes de iterar
      final expenses = List.from(provider.expenses);
      
      for (final expense in expenses) {
        await provider.deleteExpense(expense.id);
        
        // Verificar si el widget sigue montado después de cada operación
        if (!mounted) return;
      }
      
      // Mostrar mensaje de éxito solo si todavía estamos montados
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos los gastos han sido eliminados'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Manejar errores solo si todavía estamos montados
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar gastos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}