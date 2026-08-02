/// Core failure classes for the presentation layer.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';

export 'package:melina_bakes_shared/melina_bakes_shared.dart';

class AuthFailure extends UnauthorizedFailure {
  const AuthFailure({super.message = 'Authentication failed', super.code = 'AUTH_ERROR'});
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message = 'Access forbidden', super.code = 'FORBIDDEN'});
}

class RateLimitFailure extends Failure {
  const RateLimitFailure({super.message = 'Rate limit exceeded', super.code = 'RATE_LIMIT'});
}
