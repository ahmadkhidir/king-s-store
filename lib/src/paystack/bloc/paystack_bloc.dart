import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_ai_examples/src/paystack/utils/models.dart';
import 'package:sales_ai_examples/src/paystack/utils/repository.dart';

part 'paystack_event.dart';
part 'paystack_state.dart';

class PaystackBloc extends Bloc<PaystackEvent, PaystackState> {
  final PaystackRepository _paystackRepository;
  PaystackBloc({required PaystackRepository paystackRepository})
      : _paystackRepository = paystackRepository,
        super(PaystackState()) {
    on<ClearStatus>(_onClearStatus);
    on<PaymentDataEvent>(_onPaymentData);
    on<VerifyPaymentEvent>(_onVerifyPayment);
    on<ResetPayment>(_onResetPayment);
  }

  FutureOr<void> _onClearStatus(event, emit) {
    emit(state.copyWith(status: Status.initial, statusMessage: ""));
  }

  FutureOr<void> _onPaymentData(event, emit) async {
    try {
      emit(state.copyWith(status: Status.loading));
      final transaction = await _paystackRepository.initializeTransaction(
          event.email, event.amount);
      emit(state.copyWith(
        transaction: transaction,
        status: Status.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        statusMessage: e.toString(),
      ));
    }
  }

  FutureOr<void> _onVerifyPayment(
    VerifyPaymentEvent event,
    Emitter<PaystackState> emit,
  ) async {
    try {
      emit(state.copyWith(status: Status.loading));
      await Future.delayed(const Duration(seconds: 10));
      final isVerified =
          await _paystackRepository.verifyPayment(state.transaction!.reference);
      emit(state.copyWith(
        paymentIsVerified: isVerified,
        status: Status.loaded,
      ));
    } catch (e) {
      emit(
        state.copyWith(
          status: Status.error,
          statusMessage: e.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onResetPayment(
    ResetPayment event,
    Emitter<PaystackState> emit,
  ) {
    emit(state.reset());
  }
}
