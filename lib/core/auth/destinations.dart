import 'package:flutter/material.dart';

import '../router/route_names.dart';
import 'capabilities.dart';

class Destination {
  final String route;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String module;
  final List<String> anyOf;

  const Destination({
    required this.route,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.module,
    required this.anyOf,
  });
}

/// v1 staff tabs. Keys are from the backend registry — do not invent new ones.
const kStaffDestinations = <Destination>[
  Destination(
    route: RoutePaths.staffStudents,
    label: 'Students',
    icon: Icons.people_outline_rounded,
    activeIcon: Icons.people_rounded,
    module: 'students',
    anyOf: ['students.account.view'],
  ),
  Destination(
    route: RoutePaths.staffBatches,
    label: 'Batches',
    icon: Icons.class_outlined,
    activeIcon: Icons.class_rounded,
    module: 'batches',
    anyOf: ['batches.batch.view'],
  ),
  Destination(
    route: RoutePaths.staffInsights,
    label: 'Analytics',
    icon: Icons.analytics_outlined,
    activeIcon: Icons.analytics_rounded,
    module: 'insights',
    anyOf: ['insights.dashboard.view'],
  ),
];

List<Destination> visibleStaffDestinations(Capabilities caps) {
  return kStaffDestinations.where((d) => d.anyOf.any(caps.can)).toList();
}

String homeRouteFor(Capabilities caps) {
  if (caps.tier == UserTier.student) {
    return RoutePaths.studentDashboard;
  }
  final dests = visibleStaffDestinations(caps);
  if (dests.isEmpty) return RoutePaths.staffUnavailable;
  return dests.first.route;
}
