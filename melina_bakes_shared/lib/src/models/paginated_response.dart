/// Generic paginated response model used across API endpoints.
class PaginatedResponse<T> {
  /// List of items for the current page.
  final List<T> items;

  /// Current page number (1-based).
  final int page;

  /// Number of items per page.
  final int pageSize;

  /// Total number of items across all pages.
  final int totalItems;

  /// Total number of pages.
  final int totalPages;

  /// True if there is a next page.
  final bool hasNextPage;

  /// True if there is a previous page.
  final bool hasPreviousPage;

  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Creates an empty paginated response.
  factory PaginatedResponse.empty({int pageSize = 20}) =>
      PaginatedResponse<T>(
        items: const [],
        page: 1,
        pageSize: pageSize,
        totalItems: 0,
        totalPages: 0,
        hasNextPage: false,
        hasPreviousPage: false,
      );

  /// Maps the items to a different type.
  PaginatedResponse<R> map<R>(R Function(T item) mapper) {
    return PaginatedResponse<R>(
      items: items.map(mapper).toList(),
      page: page,
      pageSize: pageSize,
      totalItems: totalItems,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }
}
