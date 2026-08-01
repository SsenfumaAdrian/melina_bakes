
/// Core failure classes for the presentation layer.
///
/// Failures are domain-level representations of errors that
/// occurred in the data layer. They are returned via [Result]
/// from the shared package.
///
/// This file re-exports the shared failures and adds any
/// client-specific failure types.
library;

export 'package:melina_bakes_shared/melina_bakes_shared.dart'
    show
        Failure,
        ServerFailure,
        NetworkFailure,
        AuthFailure,
        NotFoundFailure,
        ValidationFailure,
        ConflictFailure,
        ForbiddenFailure,
        RateLimitFailure;
