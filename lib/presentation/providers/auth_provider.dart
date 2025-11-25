import 'package:flutter/foundation.dart';
import 'package:finanzas_app1/domain/usecases/auth_usecases.dart';

class AuthProvider with ChangeNotifier {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthProvider({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _userEmail;
  String? get userEmail => _userEmail;

  String? _userName;
  String? get userName => _userName;

  String? _error;
  String? get error => _error;

  bool get isAuthenticated => _userEmail != null;

  // Inicializar el provider
  Future<void> initialize() async {
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        _userEmail = user.email;
        _userName = user.name;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al inicializar: $e';
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await signInUseCase(email, password);
      _userEmail = user.email;
      _userName = user.name;
    } catch (e) {
      _error = 'Error al iniciar sesión: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await signUpUseCase(email, password, name);
      _userEmail = user.email;
      _userName = user.name;
    } catch (e) {
      _error = 'Error al registrarse: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await signOutUseCase();
      _userEmail = null;
      _userName = null;
    } catch (e) {
      _error = 'Error al cerrar sesión: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

