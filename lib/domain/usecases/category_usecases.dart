import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call() {
    return repository.getCategories();
  }
}

class AddCategoryUseCase {
  final CategoryRepository repository;

  AddCategoryUseCase(this.repository);

  Future<void> call(CategoryEntity category) {
    return repository.addCategory(category);
  }
}

class GetCategoryByIdUseCase {
  final CategoryRepository repository;

  GetCategoryByIdUseCase(this.repository);

  Future<CategoryEntity?> call(String id) {
    return repository.getCategoryById(id);
  }
}

class CategoryExistsUseCase {
  final CategoryRepository repository;

  CategoryExistsUseCase(this.repository);

  Future<bool> call(String name) {
    return repository.categoryExists(name);
  }
}

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<void> call(CategoryEntity category) {
    return repository.updateCategory(category);
  }
}

class DeleteCategoryUseCase {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteCategory(id);
  }
}