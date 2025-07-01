import 'package:securecapture/core/errors/domain_error.dart';

class CommonError implements DomainError {
  const CommonError(this.message);
  final String message;

  @override
  final String declaration = 'Common error';
}
