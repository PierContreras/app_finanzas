import 'package:flutter/foundation.dart';
import 'package:finanzas_app1/domain/entities/category_entity.dart';
import 'package:finanzas_app1/domain/usecases/category_usecases.dart';

class CategoryProvider with ChangeNotifier {
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final GetCategoryByIdUseCase getCategoryByIdUseCase;
  final CategoryExistsUseCase categoryExistsUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryProvider({
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.getCategoryByIdUseCase,
    required this.categoryExistsUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  });

  List<CategoryEntity> _categories = [];
  List<CategoryEntity> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Cargar todas las categorías
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await getCategoriesUseCase();
    } catch (e) {
      _error = 'Error al cargar categorías: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar nueva categoría
  Future<void> addCategory(CategoryEntity category) async {
    _error = null;
    try {
      // Verificar si la categoría ya existe
      final exists = await categoryExistsUseCase(category.name);
      if (exists) {
        throw Exception('Ya existe una categoría con el nombre "${category.name}"');
      }

      await addCategoryUseCase(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar categoría: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Obtener categoría por ID
  Future<CategoryEntity?> getCategoryById(String id) async {
    try {
      return await getCategoryByIdUseCase(id);
    } catch (e) {
      _error = 'Error al obtener categoría: $e';
      notifyListeners();
      return null;
    }
  }

  // Buscar categoría por ID en la lista local
  CategoryEntity? findCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Buscar categoría por nombre
  CategoryEntity? findCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase()
      );
    } catch (e) {
      return null;
    }
  }

  // Actualizar categoría
  Future<void> updateCategory(CategoryEntity category) async {
    _error = null;
    try {
      await updateCategoryUseCase(category);
      final index = _categories.indexWhere((cat) => cat.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al actualizar categoría: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Eliminar categoría
  Future<void> deleteCategory(String id) async {
    _error = null;
    try {
      await deleteCategoryUseCase(id);
      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar categoría: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Verificar si existe categoría por nombre
  Future<bool> categoryExists(String name) async {
    try {
      return await categoryExistsUseCase(name);
    } catch (e) {
      return false;
    }
  }

  // Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Obtener categorías populares (las más usadas)
  List<CategoryEntity> getPopularCategories() {
    if (_categories.isEmpty) return [];
    
    // Por ahora devolvemos las primeras 5 como "populares"
    // En una implementación real, esto se basaría en estadísticas de uso
    return _categories.take(5).toList();
  }
}