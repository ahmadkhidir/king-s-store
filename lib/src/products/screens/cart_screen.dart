import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ai_examples/src/products/bloc/products_bloc.dart';
import 'package:sales_ai_examples/src/products/screens/checkout_screen.dart';
import 'package:sales_ai_examples/src/products/screens/product_details_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const routeName = "cart_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Cart"),
            BlocSelector<ProductsBloc, ProductsState, int>(
              selector: (state) {
                return state.cart.length;
              },
              builder: (context, cartSize) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    shape: BoxShape.circle,
                  ),
                  child: Text(cartSize.toString()),
                );
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          final products = state.cart;
          if (products.isEmpty) {
            return const Center(child: Text("Cart is empty"));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      title: Text(
                        "${product.title}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("${product.brand}"),
                          Text("${product.price.min}"),
                        ],
                      ),
                      trailing: IconButton.filledTonal(
                        onPressed: () {
                          context
                              .read<ProductsBloc>()
                              .add(ToggleCartItem(product));
                        },
                        icon: const Icon(Icons.delete),
                      ),
                      leading: Image.network(
                        product.images.first,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      onTap: () => context.pushNamed(
                        ProductDetailsScreen.routeName,
                        pathParameters: {"id": product.id!},
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 70,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Total: ${state.currency}${state.cartTotal}",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: ElevatedButton(
                        onPressed: () {
                          context.goNamed(CheckoutScreen.routeName);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, double.infinity),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text("Buy Now"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
