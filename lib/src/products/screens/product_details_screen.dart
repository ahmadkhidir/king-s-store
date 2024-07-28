import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ai_examples/src/products/bloc/products_bloc.dart';
import 'package:sales_ai_examples/src/products/screens/checkout_screen.dart';
import 'package:sales_ai_examples/src/products/utils/models.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  static String routeName = "product_details";

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProductsBloc, ProductsState, ProductModel>(
      selector: (state) {
        return state.allProducts.firstWhere(
          (element) => element.id == widget.productId,
        );
      },
      builder: (context, product) {
        return Scaffold(
          appBar: AppBar(
            title: Text("${product.brand}"),
          ),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  product.title ?? "",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              SizedBox(
                height: 400,
                child: PageView.builder(
                  key: PageStorageKey(product.id),
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  itemCount: product.images.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Hero(
                        tag: product.id.toString(),
                        child: Image.network(
                          product.images[index],
                          height: double.infinity,
                        ),
                      );
                    } else {
                      return Image.network(
                        product.images[index],
                        height: double.infinity,
                      );
                    }
                  },
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  runSpacing: 16,
                  children: [
                    for (var index = 0; index < product.images.length; index++)
                      Radio.adaptive(
                        value: index,
                        groupValue: _selectedIndex,
                        onChanged: (value) {
                          _pageController.animateToPage(
                            value!,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${product.price.min}${product.price.max != null ? " - ${product.price.max}" : ""}',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              Visibility(
                visible: product.features.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Product Features",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Wrap(
                        runSpacing: 8,
                        children: [
                          for (var index = 0;
                              index < product.features.length;
                              index++)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.features[index].title,
                                    style:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    product.features[index].description,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: product.productDetails != null &&
                    product.productDetails!.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Product Description",
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text(
                        "${product.productDetails}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<ProductsBloc>()
                            .add(ToggleCartItem(product));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: const Color(0xFF4A4A4A),
                        minimumSize: const Size(double.infinity, 48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: BlocSelector<ProductsBloc, ProductsState, String>(
                        selector: (state) {
                          if (state.cart.indexWhere(
                                  (element) => element.id == product.id) ==
                              -1) {
                            return "Add to cart";
                          }
                          return "Remove from cart";
                        },
                        builder: (context, state) {
                          return Text(state);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.goNamed(CheckoutScreen.routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text("Buy Now"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
