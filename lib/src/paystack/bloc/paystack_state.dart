part of 'paystack_bloc.dart';

class PaystackState {
  bool paymentIsVerified;
  TransactionModel? transaction;
  Status status;
  String statusMessage;

  PaystackState({
    this.transaction,
    this.paymentIsVerified = false,
    this.status = Status.initial,
    this.statusMessage = "",
  });

  copyWith({
    TransactionModel? transaction,
    bool? paymentIsVerified,
    Status? status,
    String? statusMessage,
  }) {
    return PaystackState(
      transaction: transaction ?? this.transaction,
      paymentIsVerified: paymentIsVerified ?? this.paymentIsVerified,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  reset() {
    return PaystackState();
  }
}
