
/// Domain entity representing the delivery address snapshot of an order.
///
/// Frozen at order time so historical orders always display the address
/// used at the moment of purchase, even if the customer later edits or
/// deletes it from their address book.
library;

import 'package:equatable/equatable.dart';

class OrderAddressEntity extends Equatable {
  final String streetAddress;
  final String city;
  final String? state;
  final String? postalCode;
  final String? country;

  const OrderAddressEntity({
    required this.streetAddress,
    required this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  /// Returns a single-line, comma-separated display string.
  String get displayLine => [
        streetAddress,
        city,
        state,
        postalCode,
        country,
      ].whereType<String>().where((s) => s.trim().isNotEmpty).join(', ');

  @override
  List<Object?> get props => [streetAddress, city, state, postalCode, country];
}
