abstract class BaseService {
  Future<T> execute<T>(Future<T> Function() request) async {
    try {
      return await request();
    } catch (e) {
      throw handleError(e);
    }
  }

  Exception handleError(Object error) {
    if (error is Exception) return error;
    return Exception(error.toString());
  }
}
