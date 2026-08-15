// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminDashboardDto _$AdminDashboardDtoFromJson(Map<String, dynamic> json) =>
    AdminDashboardDto(
      stats: AdminStatsDto.fromJson(json['stats'] as Map<String, dynamic>),
      revenueData: (json['revenueData'] as List<dynamic>)
          .map((e) => RevenueDataDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      systemAlerts: (json['systemAlerts'] as List<dynamic>)
          .map((e) => SystemAlertDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AdminDashboardDtoToJson(AdminDashboardDto instance) =>
    <String, dynamic>{
      'stats': instance.stats,
      'revenueData': instance.revenueData,
      'systemAlerts': instance.systemAlerts,
    };

AdminStatsDto _$AdminStatsDtoFromJson(Map<String, dynamic> json) =>
    AdminStatsDto(
      totalUsers: (json['totalUsers'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toInt(),
      activeCourses: (json['activeCourses'] as num).toInt(),
      pendingApprovals: (json['pendingApprovals'] as num).toInt(),
      serverUptime: (json['serverUptime'] as num).toDouble(),
    );

Map<String, dynamic> _$AdminStatsDtoToJson(AdminStatsDto instance) =>
    <String, dynamic>{
      'totalUsers': instance.totalUsers,
      'totalRevenue': instance.totalRevenue,
      'activeCourses': instance.activeCourses,
      'pendingApprovals': instance.pendingApprovals,
      'serverUptime': instance.serverUptime,
    };

RevenueDataDto _$RevenueDataDtoFromJson(Map<String, dynamic> json) =>
    RevenueDataDto(
      month: json['month'] as String,
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$RevenueDataDtoToJson(RevenueDataDto instance) =>
    <String, dynamic>{'month': instance.month, 'amount': instance.amount};

SystemAlertDto _$SystemAlertDtoFromJson(Map<String, dynamic> json) =>
    SystemAlertDto(
      id: json['id'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$SystemAlertDtoToJson(SystemAlertDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'severity': instance.severity,
      'timestamp': instance.timestamp.toIso8601String(),
    };
