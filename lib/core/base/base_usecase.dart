abstract class BaseUseCase<T, Params> {
  Future<T> execute(Params params);
}

class NoParams {}
