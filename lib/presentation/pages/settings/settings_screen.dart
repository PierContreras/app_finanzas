import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finanzas_app1/presentation/providers/auth_provider.dart';
import 'package:finanzas_app1/presentation/providers/theme_provider.dart';
import 'package:finanzas_app1/presentation/pages/auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Apariencia'),
          Card(
            child: SwitchListTile(
              title: const Text('Modo Oscuro'),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.setTheme(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
              secondary: const Icon(Icons.dark_mode),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Cuenta'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Información de la cuenta'),
                  subtitle: Text(
                    _getUserEmail(authProvider),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    _showLogoutDialog(context, authProvider);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Datos'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Exportar datos'),
                  onTap: () => _showExportDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.orange),
                  title: const Text(
                    'Restablecer datos',
                    style: TextStyle(color: Colors.orange),
                  ),
                  onTap: () => _showResetDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Acerca de'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Versión'),
                  subtitle: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_android),
                  title: const Text('Soporte'),
                  subtitle: const Text('contacto@finanzasapp.com'),
                  onTap: () => _showSupportDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Método SIMPLIFICADO y seguro para obtener el email del usuario
  String _getUserEmail(AuthProvider authProvider) {
    try {
      // SOLUCIÓN 1: Si existe userEmail
      if (authProvider.userEmail != null) {
        return authProvider.userEmail!;
      }
      
      // SOLUCIÓN 2: Si existe una propiedad de usuario
      if (authProvider.isAuthenticated) {
        return 'Usuario autenticado';
      }
      
      // SOLUCIÓN 3: Por defecto
      return 'No hay usuario logueado';
    } catch (e) {
      return 'Información no disponible';
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Mostrar indicador de carga
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                await authProvider.signOut();
                
                if (context.mounted) {
                  Navigator.pop(context); // Cerrar loading
                  
                  // Navegar al login de forma segura
                  _navigateToLogin(context);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Cerrar loading
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al cerrar sesión: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Método seguro para navegar al login
  void _navigateToLogin(BuildContext context) {
    try {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Fallback si hay error en la navegación
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soporte'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Necesitas ayuda?'),
            SizedBox(height: 8),
            Text('Email: contacto@finanzasapp.com'),
            SizedBox(height: 4),
            Text('Teléfono: +1 234 567 890'),
            SizedBox(height: 8),
            Text('Horario: Lunes a Viernes 9:00 - 18:00'),
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

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Datos'),
        content: const Text(
          'Esta función exportará todos tus datos financieros en formato CSV. '
          '¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de exportación en desarrollo'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer Datos'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todos tus datos? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de restablecimiento en desarrollo'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Restablecer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}