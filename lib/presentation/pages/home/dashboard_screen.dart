import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finanzas_app1/presentation/providers/expense_provider.dart';
import 'package:finanzas_app1/presentation/providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Finanzas'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de bienvenida
            _buildWelcomeHeader(authProvider),
            const SizedBox(height: 20),
            
            // Resumen financiero
            _buildFinancialSummary(expenseProvider),
            const SizedBox(height: 20),
            
            // Acciones rápidas
            _buildQuickActions(context),
            const SizedBox(height: 20),
            
            // Gastos recientes
            Expanded(
              child: _buildRecentExpenses(expenseProvider),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-expense');
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeHeader(AuthProvider authProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.person,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${authProvider.userName ?? "Usuario"}!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bienvenido a tu dashboard financiero',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(ExpenseProvider expenseProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen Financiero',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Gastos del mes
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.arrow_upward,
                title: 'Gastos Mes',
                amount: '\$${_getTotalExpenses(expenseProvider)}',
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            // Presupuesto
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.account_balance_wallet,
                title: 'Presupuesto',
                amount: '\$1,500.00',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ MÉTODO CORREGIDO - Usa la propiedad monthlyTotal que YA existe
  String _getTotalExpenses(ExpenseProvider expenseProvider) {
    try {
      // Tu ExpenseProvider YA tiene la propiedad monthlyTotal
      return expenseProvider.monthlyTotal.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              icon: Icons.add,
              label: 'Agregar Gasto',
              onTap: () => Navigator.pushNamed(context, '/add-expense'),
              color: Colors.red,
            ),
            _buildActionButton(
              icon: Icons.list,
              label: 'Ver Gastos',
              onTap: () => Navigator.pushNamed(context, '/view-expenses'),
              color: Colors.blue,
            ),
            _buildActionButton(
              icon: Icons.account_balance_wallet,
              label: 'Presupuestos',
              onTap: () => Navigator.pushNamed(context, '/budget'),
              color: Colors.green,
            ),
            _buildActionButton(
              icon: Icons.settings,
              label: 'Ajustes',
              onTap: () => Navigator.pushNamed(context, '/settings'),
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha((0.3 * 255).round())),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses(ExpenseProvider expenseProvider) {
    final hasExpenses = expenseProvider.expenses.isNotEmpty;
    final recentExpenses = hasExpenses ? expenseProvider.expenses.take(3).toList() : [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gastos Recientes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (!hasExpenses)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 64, color: Colors.grey[400]!),
                  const SizedBox(height: 16),
                  Text(
                    'No hay gastos recientes',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Presiona el botón + para agregar tu primer gasto',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: recentExpenses.length,
              itemBuilder: (context, index) {
                final expense = recentExpenses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withAlpha((0.2 * 255).round()),
                      child: const Icon(Icons.attach_money, color: Colors.green, size: 20),
                    ),
                    title: Text(
                      expense.description,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(expense.category),
                    trailing: Text(
                      '\$${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}