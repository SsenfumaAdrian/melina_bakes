/// Melina Bakes Server Entry Point
///
/// Bootstraps the Serverpod server with all endpoints and services.
/// Uses the Serverpod 2.9.3 API — endpoints are registered through
/// a custom EndpointDispatch that initializes each endpoint manually.
///
/// NOTE: This file requires `serverpod generate` to be run to produce
/// the `Protocol` class (a concrete `SerializationManagerServer`) in
/// `lib/src/generated/protocol.dart`. Until then, the placeholder
/// `NullSerializationManager` below is used. Replace with `Protocol()`
/// once `serverpod generate` has been executed against the protocol YAMLs.
library;

import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart' as internal;
import 'package:melina_bakes_server/src/endpoints/health/health_endpoint.dart';
import 'package:melina_bakes_server/src/endpoints/auth/auth_endpoint.dart';
import 'package:melina_bakes_server/src/endpoints/bakery/bakery_endpoint.dart';
import 'package:melina_bakes_server/src/endpoints/cart/cart_endpoint.dart';
import 'package:melina_bakes_server/src/endpoints/orders/orders_endpoint.dart';
import 'package:melina_bakes_server/src/endpoints/customer/customer_endpoint.dart';
import 'package:melina_bakes_server/src/endpoints/admin/admin_endpoint.dart';
import 'package:melina_bakes_server/src/endpoints/payments/payments_endpoint.dart';

class MelinaEndpoints extends EndpointDispatch {
  @override
  void initializeEndpoints(Server server) {
    final endpoints = <String, Endpoint>{
      'health': HealthEndpoint()
        ..initialize(server, 'health', null),
      'auth': AuthEndpoint()
        ..initialize(server, 'auth', null),
      'bakery': BakeryEndpoint()
        ..initialize(server, 'bakery', null),
      'cart': CartEndpoint()
        ..initialize(server, 'cart', null),
      'orders': OrdersEndpoint()
        ..initialize(server, 'orders', null),
      'customer': CustomerEndpoint()
        ..initialize(server, 'customer', null),
      'admin': AdminEndpoint()
        ..initialize(server, 'admin', null),
      'payments': PaymentsEndpoint()
        ..initialize(server, 'payments', null),
    };

    for (final entry in endpoints.entries) {
      connectors[entry.key] = EndpointConnector(
        name: entry.key,
        endpoint: entry.value,
        methodConnectors: {},
      );
    }
  }
}

void main(List<String> args) {
  final pod = Serverpod(
    args,
    internal.Protocol(),
    MelinaEndpoints(),
  );

  pod.start();
}