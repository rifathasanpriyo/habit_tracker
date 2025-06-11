class AppExpensition implements Exception{ 
  final String message;

  AppExpensition(this.message);

  @override
  String toString() {
    return 'AppExpensition: $message';
  }
  
}
class NoInternetException extends AppExpensition {
  
  NoInternetException() : super('No internet connection available.');
}