import '../../../../core/network/json_value.dart';

class CrmInsightsDto {
  final int totalLeads;
  final int convertedLeads;
  final int conversionRatePct;
  final Map<String, int> pipeline;
  final int stuckRecords;
  final int pendingFollowUps;
  final int overdueFollowUps;

  const CrmInsightsDto({
    required this.totalLeads,
    required this.convertedLeads,
    required this.conversionRatePct,
    required this.pipeline,
    required this.stuckRecords,
    required this.pendingFollowUps,
    required this.overdueFollowUps,
  });

  factory CrmInsightsDto.fromJson(Map<String, dynamic> json) {
    final leads = jsonMap(json['leads']);
    final records = jsonMap(json['records']);
    final followUps = jsonMap(json['followUps']);
    final pipeline = jsonMap(json['pipeline']);
    return CrmInsightsDto(
      totalLeads: jsonInt(leads['total']),
      convertedLeads: jsonInt(leads['converted']),
      conversionRatePct: jsonInt(leads['conversionRatePct']),
      pipeline: {
        for (final e in pipeline.entries) e.key.toString(): jsonInt(e.value),
      },
      stuckRecords: jsonInt(records['stuck']),
      pendingFollowUps: jsonInt(followUps['pending']),
      overdueFollowUps: jsonInt(followUps['overdue']),
    );
  }

  int pipelineCount(String stage) => pipeline[stage] ?? 0;
}
