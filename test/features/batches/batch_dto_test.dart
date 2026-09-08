import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/features/batches/data/models/batch_dto.dart';

void main() {
  // Shape mirrors what StaffBatchRowDto already parses from /batches.
  const row = {
    'id': 'b1',
    'name': 'Flutter Evening Batch',
    'status': 'ACTIVE',
    'course': {'title': 'Flutter Fundamentals'},
    'createdBy': {'name': 'Asha Rao'},
    '_count': {'members': 24},
  };

  test('reads nested course, trainer and member count', () {
    final batch = BatchDto.fromJson(row);
    expect(batch.id, 'b1');
    expect(batch.name, 'Flutter Evening Batch');
    expect(batch.courseTitle, 'Flutter Fundamentals');
    expect(batch.trainerName, 'Asha Rao');
    expect(batch.memberCount, 24);
    expect(batch.status, 'ACTIVE');
  });

  test('a batch missing its nested objects still parses', () {
    // The list endpoints do not guarantee course/createdBy/_count are present.
    final batch = BatchDto.fromJson({'id': 'b2', 'name': 'Unassigned'});
    expect(batch.courseTitle, '');
    expect(batch.memberCount, 0);
    expect(batch.trainerName, 'Staff');
  });

  test('listFrom accepts a {batches: [...]} envelope', () {
    final list = BatchDto.listFrom({
      'batches': [row],
    });
    expect(list, hasLength(1));
    expect(list.single.id, 'b1');
  });

  test('listFrom accepts a bare array', () {
    expect(BatchDto.listFrom([row]).single.name, 'Flutter Evening Batch');
  });

  test('listFrom degrades to empty rather than throwing', () {
    expect(BatchDto.listFrom(null), isEmpty);
    expect(BatchDto.listFrom({'unexpected': 1}), isEmpty);
  });
}
