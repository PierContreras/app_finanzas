import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finanzas_app1/presentation/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas App - Home'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.attach_money, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                '¡Bienvenido a Finanzas App!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Tu aplicación de gestión financiera personal',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              if (authProvider.userName != null) ...[
                Text(
                  'Hola, ${authProvider.userName}!',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
              ],
              
              if (authProvider.userEmail != null)
                Text(
                  'Email: ${authProvider.userEmail}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              
              const SizedBox(height: 40),
              
              // ✅ BOTÓN PRINCIPAL QUE SÍ FUNCIONA
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Comenzar a usar la app',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // ✅ BOTONES SECUNDARIOS QUE SÍ FUNCIONAN
              const Text(
                'Acciones rápidas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildActionChip(
                    icon: Icons.add,
                    label: 'Agregar Gasto',
                    onTap: () {
                      Navigator.pushNamed(context, '/add-expense');
                    },
                    color: Colors.red,
                  ),
                  _buildActionChip(
                    icon: Icons.list,
                    label: 'Ver Gastos',
                    onTap: () {
                      Navigator.pushNamed(context, '/view-expenses');
                    },
                    color: Colors.blue,
                  ),
                  _buildActionChip(
                    icon: Icons.account_balance_wallet,
                    label: 'Presupuestos',
                    onTap: () {
                      Navigator.pushNamed(context, '/budget');
                    },
                    color: Colors.green,
                  ),
                  _buildActionChip(
                    icon: Icons.settings,
                    label: 'Ajustes',
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}