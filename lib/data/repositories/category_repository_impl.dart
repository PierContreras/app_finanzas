import 'package:finanzas_app1/domain/repositories/category_repository.dart';
import 'package:finanzas_app1/domain/entities/category_entity.dart';
import '../models/category_model.dart';
import '../datasources/local_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final LocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final models = await localDataSource.getCategories();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await localDataSource.addCategory(model);
    } catch (e) {
      throw Exception('Error al agregar categoría: $e');
    }
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    try {
      final model = await localDataSource.getCategoryById(id);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Error al obtener categoría por ID: $e');
    }
  }

  @override
  Future<bool> categoryExists(String name) async {
    try {
      return await localDataSource.categoryExists(name);
    } catch (e) {
      throw Exception('Error al verificar existencia de categoría: $e');
    }
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    try {
      // Para actualizar, necesitamos obtener todas las categorías,
      // actualizar la específica y guardar todas
      final categories = await getCategories();
      final index = categories.indexWhere((cat) => cat.id == category.id);
      
      if (index != -1) {
        categories[index] = category;
        final models = categories.map((cat) => CategoryModel.fromEntity(cat)).toList();
        await localDataSource.saveCategories(models);
      } else {
        throw Exception('Categoría no encontrada para actualizar');
      }
    } catch (e) {
      throw Exception('Error al actualizar categoría: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      final categories = await getCategories();
      final updatedCategories = categories.where((cat) => cat.id != id).toList();
      final models = updatedCategories.map((cat) => CategoryModel.fromEntity(cat)).toList();
      await localDataSource.saveCategories(models);
    } catch (e) {
      throw Exception('Error al eliminar categoría: $e');
    }
  }
}