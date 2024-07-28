import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ai_examples/src/components/modals.dart';
import 'package:sales_ai_examples/src/paystack/bloc/paystack_bloc.dart';
import 'package:sales_ai_examples/src/paystack/screens/verify_screen.dart';
import 'package:sales_ai_examples/src/paystack/utils/helpers.dart';
import 'package:sales_ai_examples/src/paystack/utils/models.dart';
import 'package:sales_ai_examples/src/products/bloc/products_bloc.dart'
    hide Status;
import 'package:sales_ai_examples/src/utils/helpers.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaystackScreen extends StatefulWidget {
  const PaystackScreen({super.key});

  static const routeName = "paystack_screen";

  @override
  State<PaystackScreen> createState() => _PaystackScreenState();
}

class _PaystackScreenState extends State<PaystackScreen> {
  late WebViewController _webViewController;

  @override
  void initState() {
    _webViewController = WebViewController();
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController.setNavigationDelegate(NavigationDelegate(
      onUrlChange: (change) {
        debugPrint("Change ${change.url}");
        if (change.url!.startsWith(TransactionURLs.callbackURL)) {
          context.pushReplacementNamed(VerifyScreen.routeName);
        }
      },
    ));

    final cartTotal = context.read<ProductsBloc>().state.cartTotal;
    context.read<PaystackBloc>().add(
          PaymentDataEvent(
            email: FirebaseAuth.instance.currentUser?.email ?? "",
            amount: (cartTotal * 100 * 1700).round().toString(),
          ),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaystackBloc, PaystackState>(
      listenWhen: (previous, current) => isRouteOnTop(context),
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
                    context.pop(); // go back
                    context.read<PaystackBloc>().add(ClearStatus());
                  },
                );
              },
            );
          case Status.loaded:
            context.pop();
            debugPrint(state.transaction!.url);
            _webViewController.loadRequest(Uri.parse(state.transaction!.url));
          default:
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog.adaptive(
                title: const Text("Alert!"),
                content: const Text(
                    "Are you sure you want to terminate this transaction?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                      context.pop();
                    },
                    child: const Text("Yes"),
                  ),
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text("No"),
                  )
                ],
              );
            },
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Paystack"),
          ),
          body: WebViewWidget(controller: _webViewController),
        ),
      ),
    );
  }
}
