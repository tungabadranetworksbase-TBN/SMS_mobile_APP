import 'package:json_annotation/json_annotation.dart';

part 'smr_dashboard_dto.g.dart';

@JsonSerializable()
class SmrDashboardDto {
  final SmrStatsDto stats;
  final List<ActiveBatchDto> activeBatches;
  final List<RecentActivityDto> recentActivities;

  SmrDashboardDto({
    required this.stats,
    required this.activeBatches,
    required this.recentActivities,
  });

  factory SmrDashboardDto.fromJson(Map<String, dynamic> json) =>
      _$SmrDashboardDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SmrDashboardDtoToJson(this);

  factory SmrDashboardDto.empty() {
    return SmrDashboardDto(
      stats: SmrStatsDto.empty(),
      activeBatches: [],
      recentActivities: [],
    );
  }
}

@JsonSerializable()
class SmrStatsDto {
  final int totalStudents;
  final int activeBatches;
  final int pendingTickets;
  final int todayAttendance;

  SmrStatsDto({
    required this.totalStudents,
    required this.activeBatches,
    required this.pendingTickets,
    required this.todayAttendance,
  });

  factory SmrStatsDto.fromJson(Map<String, dynamic> json) =>
      _$SmrStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SmrStatsDtoToJson(this);

  factory SmrStatsDto.empty() => SmrStatsDto(
    totalStudents: 0,
    activeBatches: 0,
    pendingTickets: 0,
    todayAttendance: 0,
  );
}

@JsonSerializable()
class ActiveBatchDto {
  final String id;
  final String name;
  final int studentCount;
  final String trainerName;
  final double progress;

  ActiveBatchDto({
    required this.id,
    required this.name,
    required this.studentCount,
    required this.trainerName,
    required this.progress,
  });

  factory ActiveBatchDto.fromJson(Map<String, dynamic> json) =>
      _$ActiveBatchDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveBatchDtoToJson(this);
}

@JsonSerializable()
class RecentActivityDto {
  final String id;
  final String description;
  final DateTime timestamp;
  final String type; // 'ticket', 'attendance', 'enrollment'

  RecentActivityDto({
    required this.id,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  factory RecentActivityDto.fromJson(Map<String, dynamic> json) =>
      _$RecentActivityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecentActivityDtoToJson(this);
}
