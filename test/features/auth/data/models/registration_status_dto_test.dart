import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/features/auth/data/models/registration_status_dto.dart';

void main() {
  test('paid true when paid flag is set', () {
    expect(
      RegistrationStatusDto.fromJson({'paid': true}).paid,
      isTrue,
    );
  });

  test('paid true when status is PAID', () {
    expect(
      RegistrationStatusDto.fromJson({'status': 'PAID'}).paid,
      isTrue,
    );
  });

  test('paid true when regFeeStatus is VERIFIED', () {
    expect(
      RegistrationStatusDto.fromJson({'regFeeStatus': 'VERIFIED'}).paid,
      isTrue,
    );
  });

  test('reads fee amount and onlinePayment', () {
    final dto = RegistrationStatusDto.fromJson({
      'regFeeStatus': 'PENDING',
      'fee': {'amount': 708, 'currency': 'INR'},
      'onlinePayment': true,
    });
    expect(dto.paid, isFalse);
    expect(dto.feeAmount, 708);
    expect(dto.onlinePayment, isTrue);
  });

  test('paid false otherwise', () {
    expect(RegistrationStatusDto.fromJson({}).paid, isFalse);
  });
}
