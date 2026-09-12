import 'package:flutter/foundation.dart';

abstract class BaseController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  @protected
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  @protected
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  @protected
  void clearError() {
    _errorMessage = null;
  }

  Future<void> runWithLoading(Future<void> Function() action) async {
    try {
      setLoading(true);
      clearError();
      await action();
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setLoading(false);
    }
  }
}
