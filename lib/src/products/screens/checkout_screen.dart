import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ai_examples/src/paystack/screens/payment_screen.dart';

import '../bloc/products_bloc.dart';
import '../utils/models.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  static const routeName = "checkout_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                BlocSelector<ProductsBloc, ProductsState, List<ProductModel>>(
              selector: (state) {
                return state.cart;
              },
              builder: (context, carts) {
                return ListView(
                  children: [
                    for (var index = 0; index < carts.length; index++)
                      Builder(
                        builder: (context) {
                          final cart = carts[index];
                          return ListTile(
                            title: Text(
                              "${cart.title}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              "${cart.price.min}",
                            ),
                            shape: const Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ListTile(
                      title: const Text(
                        "Total",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: BlocBuilder<ProductsBloc, ProductsState>(
                        builder: (context, state) {
                          return Text(
                            "${state.currency}${state.cartTotal}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      shape: const Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {},
                    child: const Text("Save / Pay later"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      context.goNamed(PaystackScreen.routeName);
                    },
                    child: const Text("Pay now"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
