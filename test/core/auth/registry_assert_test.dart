import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/auth/destinations.dart';
import 'package:tbn_lms/core/auth/registry_assert.dart';

void main() {
  // Fixture mirrors registryForClient() module keys used by v1 destinations.
  final modules = [
    {
      'key': 'students',
      'label': 'Students',
      'permissions': ['students.account.view', 'students.account.create'],
    },
    {
      'key': 'batches',
      'label': 'Batches',
      'permissions': ['batches.batch.view', 'batches.batch.create'],
    },
    {
      'key': 'insights',
      'label': 'Insights',
      'permissions': ['insights.dashboard.view'],
    },
  ];

  test('every kStaffDestinations anyOf key exists in the registry fixture', () {
    expect(() => assertDestinationsInRegistry(modules), returnsNormally);
  });

  test('invented permission key fails loudly', () {
    expect(
      () => assertDestinationsInRegistry(
        modules,
        destinations: const [
          Destination(
            route: '/x',
            label: 'Broken',
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            module: 'students',
            anyOf: ['students.record.view'],
          ),
        ],
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('v1 destinations only use the three known view keys', () {
    final keys = kStaffDestinations.expand((d) => d.anyOf).toSet();
    expect(keys, {
      'students.account.view',
      'batches.batch.view',
      'insights.dashboard.view',
    });
  });
}
