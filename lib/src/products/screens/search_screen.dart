import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ai_examples/src/products/bloc/products_bloc.dart';

import 'product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.query});
  final String query;

  static const routeName = "search";

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    _searchController = TextEditingController(text: widget.query);
    context.read<ProductsBloc>().add(FetchSearchedProducts(widget.query));
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Form(
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    hintText: 'Search products',
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: () {
                  context
                      .read<ProductsBloc>()
                      .add(FetchSearchedProducts(_searchController.text));
                },
                style: ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.onPrimary),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  iconSize: const MaterialStatePropertyAll(30),
                  fixedSize: const MaterialStatePropertyAll(Size(50, 50)),
                ),
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if (state.status == Status.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = state.searchedProducts;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(
                  "${product.title}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text("${product.brand}"),
                leading: Hero(
                  tag: product.id.toString(),
                  child: Image.network(
                    product.images.first,
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                onTap: () => context.pushNamed(
                  ProductDetailsScreen.routeName,
                  pathParameters: {"id": product.id!},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
