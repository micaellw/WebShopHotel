class Failure {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => message;
}

class BookingConflictFailure extends Failure {
  const BookingConflictFailure(super.message) : super(code: 409);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message) : super(code: 400);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message) : super(code: 404);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message) : super(code: 401);
}
