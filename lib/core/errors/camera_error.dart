import 'package:securecapture/core/errors/domain_error.dart';

class CameraError implements DomainError {
  const CameraError();
  // TODO: Add a message to the error

  @override
  final String declaration = 'Camera error';
}
