
/// Data model for serializing the delivery address snapshot of an order.
library;

import '../../domain/entities/order_address_entity.dart';

class OrderAddressModel {
  final String streetAddress;
  final String city;
  final String? state;
  final String? postalCode;
  final String? country;

  OrderAddressModel({
    required this.streetAddress,
    required this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  factory OrderAddressModel.fromJson(Map<String, dynamic> json) {
    return OrderAddressModel(
      streetAddress: json['streetAddress'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
    );
  }

  OrderAddressEntity toEntity() => OrderAddressEntity(
        streetAddress: streetAddress,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
      );
}
