import 'package:json_annotation/json_annotation.dart';

part 'admin_dashboard_dto.g.dart';

@JsonSerializable()
class AdminDashboardDto {
  final AdminStatsDto stats;
  final List<RevenueDataDto> revenueData;
  final List<SystemAlertDto> systemAlerts;

  AdminDashboardDto({
    required this.stats,
    required this.revenueData,
    required this.systemAlerts,
  });

  factory AdminDashboardDto.fromJson(Map<String, dynamic> json) =>
      _$AdminDashboardDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDashboardDtoToJson(this);

  factory AdminDashboardDto.empty() {
    return AdminDashboardDto(
      stats: AdminStatsDto.empty(),
      revenueData: [],
      systemAlerts: [],
    );
  }
}

@JsonSerializable()
class AdminStatsDto {
  final int totalUsers;
  final int totalRevenue;
  final int activeCourses;
  final int pendingApprovals;
  final double serverUptime;

  AdminStatsDto({
    required this.totalUsers,
    required this.totalRevenue,
    required this.activeCourses,
    required this.pendingApprovals,
    required this.serverUptime,
  });

  factory AdminStatsDto.fromJson(Map<String, dynamic> json) =>
      _$AdminStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AdminStatsDtoToJson(this);

  factory AdminStatsDto.empty() => AdminStatsDto(
    totalUsers: 0,
    totalRevenue: 0,
    activeCourses: 0,
    pendingApprovals: 0,
    serverUptime: 0.0,
  );
}

@JsonSerializable()
class RevenueDataDto {
  final String month;
  final int amount;

  RevenueDataDto({required this.month, required this.amount});

  factory RevenueDataDto.fromJson(Map<String, dynamic> json) =>
      _$RevenueDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueDataDtoToJson(this);
}

@JsonSerializable()
class SystemAlertDto {
  final String id;
  final String message;
  final String severity; // 'low', 'medium', 'high', 'critical'
  final DateTime timestamp;

  SystemAlertDto({
    required this.id,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  factory SystemAlertDto.fromJson(Map<String, dynamic> json) =>
      _$SystemAlertDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SystemAlertDtoToJson(this);
}
