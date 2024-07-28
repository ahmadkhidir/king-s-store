import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ai_examples/src/components/modals.dart';
import 'package:sales_ai_examples/src/paystack/bloc/paystack_bloc.dart';
import 'package:sales_ai_examples/src/paystack/utils/models.dart';
import 'package:sales_ai_examples/src/products/bloc/products_bloc.dart' hide Status;
import 'package:sales_ai_examples/src/products/screens/home_screen.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  static const routeName = "verify_screen";

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {

  @override
  void initState() {
    context.read<PaystackBloc>().add(VerifyPaymentEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PaystackBloc, PaystackState>(
        listener: (context, state) {
          switch (state.status) {
            case Status.loading:
              showDialog(
                context: context,
                builder: (context) {
                  return const LoadingCard();
                },
              );
              break;
            case Status.error:
              context.pop(); // pop the loading modal
              showDialog(
                context: context,
                builder: (context) {
                  return ErrorDialog(
                    statusMessage: state.statusMessage,
                    onPressed: () {
                      context.pop(); // pop the loading screen
                    },
                  );
                },
              );
            case Status.loaded:
              context.pop();
            default:
          }
        },
        child: BlocSelector<PaystackBloc, PaystackState, bool>(
          selector: (state) {
            return state.paymentIsVerified;
          },
          builder: (context, isVerified) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isVerified ? Icons.check_circle_outline : Icons.error_outline,
                    size: 65,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      isVerified
                          ? "Thank you for your patronage. See you soon."
                          : "Ops, your payment couldn't be verified yet!",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PaystackBloc>().add(ResetPayment());
                      context.read<ProductsBloc>().add(ClearCart());
                      context.goNamed(HomeScreen.routeName);
                    },
                    child: const Text("Shop more!"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
