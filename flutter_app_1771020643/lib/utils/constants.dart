// lib/utils/constants.dart
class AppConstants {
  static const String appName = 'Restaurant App - 1771020643';
  static const String firebaseProjectId = 'hoang-thi-9f055';
  
  // Collections
  static const String customersCollection = 'customers';
  static const String menuItemsCollection = 'menu_items';
  static const String reservationsCollection = 'reservations';
  
  // Preferences keys
  static const String prefCustomerId = 'customerId';
  static const String prefEmail = 'email';
  static const String prefFullName = 'fullName';
  
  // Status values
  static const List<String> reservationStatuses = [
    'pending',
    'confirmed',
    'seated',
    'completed',
    'cancelled',
    'no_show',
  ];
  
  static const List<String> paymentStatuses = [
    'pending',
    'paid',
    'refunded',
  ];
  
  static const List<String> paymentMethods = [
    'cash',
    'card',
    'online',
  ];
  
  static const List<String> categories = [
    'Appetizer',
    'Main Course',
    'Dessert',
    'Beverage',
    'Soup',
  ];
  
  static const List<String> preferences = [
    'vegetarian',
    'spicy',
    'seafood',
  ];
}