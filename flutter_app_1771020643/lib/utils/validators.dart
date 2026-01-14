// lib/utils/validators.dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Số điện thoại không hợp lệ';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }
  
  static String? validateNumber(String? value, String fieldName, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName phải là số';
    }
    
    if (min != null && number < min) {
      return '$fieldName phải lớn hơn hoặc bằng $min';
    }
    
    if (max != null && number > max) {
      return '$fieldName phải nhỏ hơn hoặc bằng $max';
    }
    
    return null;
  }
}