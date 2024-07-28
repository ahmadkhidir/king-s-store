part of 'paystack_bloc.dart';

sealed class PaystackEvent {}

class ClearStatus extends PaystackEvent {}

class ResetPayment extends PaystackEvent {}

class PaymentDataEvent extends PaystackEvent {
  final String email, amount;

  PaymentDataEvent({required this.email, required this.amount});
}


class VerifyPaymentEvent extends PaystackEvent {}