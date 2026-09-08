import '../../../../core/network/json_value.dart';

class AdminDashboardDto {
  final AdminStatsDto stats;
  final List<RevenueDataDto> revenueData;
  final List<SystemAlertDto> systemAlerts;

  AdminDashboardDto({
    required this.stats,
    required this.revenueData,
    required this.systemAlerts,
  });

  factory AdminDashboardDto.fromJson(Map<String, dynamic> json) {
    if (json['people'] is Map || json['commerce'] is Map) {
      return AdminDashboardDto.fromInsights(json);
    }
    return AdminDashboardDto(
      stats: AdminStatsDto.fromJson(jsonMap(json['stats'])),
      revenueData: jsonList(json['revenueData'])
          .map((e) => RevenueDataDto.fromJson(jsonMap(e)))
          .toList(),
      systemAlerts: jsonList(json['systemAlerts'])
          .map((e) => SystemAlertDto.fromJson(jsonMap(e)))
          .toList(),
    );
  }

  factory AdminDashboardDto.fromInsights(Map<String, dynamic> json) {
    final people = jsonMap(json['people']);
    final catalogue = jsonMap(json['catalogue']);
    final commerce = jsonMap(json['commerce']);
    final crm = jsonMap(json['crm']);
    final revenue = jsonList(commerce['revenueCollected']);
    var collected = 0.0;
    if (revenue.isNotEmpty) {
      collected = jsonDouble(jsonMap(revenue.first)['collected']);
    }
    return AdminDashboardDto(
      stats: AdminStatsDto(
        totalUsers: jsonInt(people['students']) + jsonInt(people['staff']),
        totalRevenue: collected.round(),
        activeCourses: jsonInt(catalogue['publishedCourses']),
        pendingApprovals: jsonInt(crm['openAlerts']),
        serverUptime: jsonDouble(crm['conversionRatePct']),
      ),
      revenueData: [
        RevenueDataDto(
          month: '30d',
          amount: jsonInt(commerce['ordersLast30']),
        ),
      ],
      systemAlerts: jsonList(json['recentActivity'])
          .map((e) {
            final row = jsonMap(e);
            return SystemAlertDto(
              id: jsonStr(row['at'] ?? row['action']),
              message: '${jsonStr(row['action'])} · ${jsonStr(row['by'])}',
              severity: 'low',
              timestamp: jsonDate(row['at']) ?? DateTime.now(),
            );
          })
          .toList(),
    );
  }

  factory AdminDashboardDto.empty() {
    return AdminDashboardDto(
      stats: AdminStatsDto.empty(),
      revenueData: const [],
      systemAlerts: const [],
    );
  }
}

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

  factory AdminStatsDto.fromJson(Map<String, dynamic> json) {
    return AdminStatsDto(
      totalUsers: jsonInt(json['totalUsers']),
      totalRevenue: jsonInt(json['totalRevenue']),
      activeCourses: jsonInt(json['activeCourses']),
      pendingApprovals: jsonInt(json['pendingApprovals']),
      serverUptime: jsonDouble(json['serverUptime']),
    );
  }

  factory AdminStatsDto.empty() => AdminStatsDto(
    totalUsers: 0,
    totalRevenue: 0,
    activeCourses: 0,
    pendingApprovals: 0,
    serverUptime: 0,
  );
}

class RevenueDataDto {
  final String month;
  final int amount;

  RevenueDataDto({required this.month, required this.amount});

  factory RevenueDataDto.fromJson(Map<String, dynamic> json) {
    return RevenueDataDto(
      month: jsonStr(json['month']),
      amount: jsonInt(json['amount']),
    );
  }
}

class SystemAlertDto {
  final String id;
  final String message;
  final String severity;
  final DateTime timestamp;

  SystemAlertDto({
    required this.id,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  factory SystemAlertDto.fromJson(Map<String, dynamic> json) {
    return SystemAlertDto(
      id: jsonStr(json['id']),
      message: jsonStr(json['message']),
      severity: jsonStr(json['severity'], 'low'),
      timestamp: jsonDate(json['timestamp']) ?? DateTime.now(),
    );
  }
}
