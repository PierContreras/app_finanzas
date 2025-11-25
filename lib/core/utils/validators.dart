class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa $fieldName';
    }
    if (value.trim().length < 2) {
      return '$fieldName debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa un email';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingresa un email válido';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa un monto';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Por favor ingresa un número válido';
    }
    
    if (amount <= 0) {
      return 'El monto debe ser mayor a 0';
    }
    
    if (amount > 1000000) {
      return 'El monto no puede ser mayor a 1,000,000';
    }
    
    return null;
  }

  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa un título';
    }
    
    if (value.trim().length < 2) {
      return 'El título debe tener al menos 2 caracteres';
    }
    
    if (value.trim().length > 50) {
      return 'El título no puede tener más de 50 caracteres';
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa un nombre';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (value.trim().length > 50) {
      return 'El nombre no puede tener más de 50 caracteres';
    }
    
    // Validar que solo contenga letras y espacios
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'El nombre solo puede contener letras y espacios';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa un teléfono';
    }
    
    final phoneRegex = RegExp(r'^[0-9+\-\s()]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Por favor ingresa un teléfono válido';
    }
    
    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa $fieldName';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName no puede tener más de $maxLength caracteres';
    }
    return null;
  }
}