/// Health Check Endpoint
///
/// Reports the operational state of the server, database, and
/// dependent services. Used by Docker HEALTHCHECK, Kubernetes
/// liveness/readiness probes, and monitoring dashboards.
library;

import 'package:serverpod/serverpod.dart';

class HealthEndpoint extends Endpoint {
  /// GET /health
  ///
  /// Returns server health status with component-level details.
  /// Non-authenticated — accessible to load balancers and monitoring.
  Future<Map<String, dynamic>> check(Session session) async {
    final status = <String, dynamic>{
      'status': 'healthy',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'services': <String, dynamic>{
        'api': 'healthy',
      },
    };

    try {
      await session.db.unsafeQuery('SELECT 1');
      status['services']['database'] = 'connected';
    } on Exception {
      status['services']['database'] = 'disconnected';
    }

    return status;
  }
}