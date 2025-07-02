import 'package:securecapture/core/errors/domain_error.dart';

// TODO: Consider creating a separate error class like [StorageError] for database and file system operations.
class CommonError implements DomainError {
  const CommonError(this.message);

  @override
  final String message;

  @override
  String toString() => message;
}
