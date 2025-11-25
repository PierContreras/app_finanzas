import 'package:finanzas_app1/domain/repositories/auth_repository.dart';
import 'package:finanzas_app1/domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../datasources/local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<UserEntity> signIn(String email, String password) async {
    // Simulación de login - en una app real aquí iría Firebase Auth
    await Future.delayed(const Duration(seconds: 1));
    
    final user = UserModel(
      id: '1',
      email: email,
      name: 'Usuario',
      createdAt: DateTime.now(),
    );
    
    await localDataSource.saveUser(user);
    return user.toEntity();
  }

  @override
  Future<UserEntity> signUp(String email, String password, String name) async {
    // Simulación de registro
    await Future.delayed(const Duration(seconds: 1));
    
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
    
    await localDataSource.saveUser(user);
    return user.toEntity();
  }

  @override
  Future<void> signOut() async {
    await localDataSource.deleteUser();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = await localDataSource.getUser();
    return user?.toEntity();
  }
}