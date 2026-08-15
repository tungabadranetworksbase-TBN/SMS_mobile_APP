/// Tungabadra Networks LMS — Generic API Response Wrapper
///
/// Wraps all API responses into a consistent envelope.
/// Controllers and repositories always work with this type.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final PaginationMeta? pagination;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.pagination,
  });

  factory ApiResponse.success(
    T data, {
    String? message,
    int? statusCode,
    PaginationMeta? pagination,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
      pagination: pagination,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

/// Pagination metadata for list endpoints.
class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasNextPage;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasNextPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      totalItems: json['totalItems'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 20,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }
}
