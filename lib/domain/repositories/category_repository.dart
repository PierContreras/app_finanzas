import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<void> addCategory(CategoryEntity category);
  Future<CategoryEntity?> getCategoryById(String id);
  Future<bool> categoryExists(String name);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String id);
}