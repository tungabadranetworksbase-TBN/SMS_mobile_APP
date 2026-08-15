// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smr_dashboard_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmrDashboardDto _$SmrDashboardDtoFromJson(Map<String, dynamic> json) =>
    SmrDashboardDto(
      stats: SmrStatsDto.fromJson(json['stats'] as Map<String, dynamic>),
      activeBatches: (json['activeBatches'] as List<dynamic>)
          .map((e) => ActiveBatchDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentActivities: (json['recentActivities'] as List<dynamic>)
          .map((e) => RecentActivityDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SmrDashboardDtoToJson(SmrDashboardDto instance) =>
    <String, dynamic>{
      'stats': instance.stats,
      'activeBatches': instance.activeBatches,
      'recentActivities': instance.recentActivities,
    };

SmrStatsDto _$SmrStatsDtoFromJson(Map<String, dynamic> json) => SmrStatsDto(
  totalStudents: (json['totalStudents'] as num).toInt(),
  activeBatches: (json['activeBatches'] as num).toInt(),
  pendingTickets: (json['pendingTickets'] as num).toInt(),
  todayAttendance: (json['todayAttendance'] as num).toInt(),
);

Map<String, dynamic> _$SmrStatsDtoToJson(SmrStatsDto instance) =>
    <String, dynamic>{
      'totalStudents': instance.totalStudents,
      'activeBatches': instance.activeBatches,
      'pendingTickets': instance.pendingTickets,
      'todayAttendance': instance.todayAttendance,
    };

ActiveBatchDto _$ActiveBatchDtoFromJson(Map<String, dynamic> json) =>
    ActiveBatchDto(
      id: json['id'] as String,
      name: json['name'] as String,
      studentCount: (json['studentCount'] as num).toInt(),
      trainerName: json['trainerName'] as String,
      progress: (json['progress'] as num).toDouble(),
    );

Map<String, dynamic> _$ActiveBatchDtoToJson(ActiveBatchDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'studentCount': instance.studentCount,
      'trainerName': instance.trainerName,
      'progress': instance.progress,
    };

RecentActivityDto _$RecentActivityDtoFromJson(Map<String, dynamic> json) =>
    RecentActivityDto(
      id: json['id'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
    );

Map<String, dynamic> _$RecentActivityDtoToJson(RecentActivityDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': instance.type,
    };
