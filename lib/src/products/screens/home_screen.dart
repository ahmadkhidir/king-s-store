import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ai_examples/src/auth/screens/profile_screen.dart';
import 'package:sales_ai_examples/src/components/modals.dart';
import 'package:sales_ai_examples/src/products/screens/cart_screen.dart';
import 'package:sales_ai_examples/src/products/screens/search_screen.dart';
import 'package:sales_ai_examples/src/products/utils/helper.dart';
import 'package:sales_ai_examples/src/sales_ai/bloc/sales_ai_bloc.dart';
import 'package:sales_ai_examples/src/utils/helpers.dart';
import '../bloc/products_bloc.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String routeName = "home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _searchFormKey = GlobalKey();
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  @override
  void initState() {
    setSystemUIOverlayColor(Colors.white);

    // Fetch initial products to display
    context.read<ProductsBloc>().add(FetchProducts());
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    super.initState();

    // Fetch more products when the user scrolls to the bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        context.read<ProductsBloc>().add(FetchProducts());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback(_fetchProductsToMemory);
  }

  void _fetchProductsToMemory(timeStamp) async {
        final data = await db.collection("products").limit(2000).get();
        // Load the data to memory
        // use callback to avoid use of context in async block
        (() => context.read<SalesAiBloc>().add(
              LoadToMemory(
                data.docs.map<Map<String, dynamic>>((e) {
                  final data = e.data();
                  return {
                    "title": data["title"],
                    "id": e.id,
                    "brand": data["brand"],
                    "price": data["price"],
                    "breadcrumbs": data["breadcrumbs"],
                    "features": data["features"],
                  };
                }).toList(),
              ),
            ))();
      }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        title: const Text('King\'s Store'),
        actions: [
          IconButton(
            icon: Row(
              children: [
                StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.userChanges(),
                    builder: (context, user) {
                      if (user.hasData) {
                        return Text(user.data?.displayName ?? "User");
                      } else {
                        return const SizedBox();
                      }
                    }),
                const Icon(Icons.person),
              ],
            ),
            onPressed: () {
              context.goNamed(ProfileScreen.routeName);
            },
          ),
          IconButton(
            onPressed: () {
              context.goNamed(CartScreen.routeName);
            },
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                BlocSelector<ProductsBloc, ProductsState, bool>(
                  selector: (state) {
                    return state.cart.isNotEmpty;
                  },
                  builder: (context, isCart) {
                    return Visibility(
                      visible: isCart,
                      child: Positioned(
                        top: 0,
                        left: 7,
                        child: SizedBox(
                          height: 10,
                          width: 10,
                          child: Material(
                            shape: const CircleBorder(
                                side: BorderSide(
                              color: Colors.white,
                            )),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _searchFormKey,
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
                        if (_searchFormKey.currentState!.validate()) {
                          context.goNamed(
                            SearchScreen.routeName,
                            pathParameters: {'query': _searchController.text},
                          );
                        }
                      },
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        iconSize: const WidgetStatePropertyAll(30),
                        fixedSize: const WidgetStatePropertyAll(Size(50, 50)),
                      ),
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
              BlocSelector<ProductsBloc, ProductsState, Status>(
                selector: (state) {
                  return state.status;
                },
                builder: (context, status) {
                  return Visibility(
                    visible: status == Status.loading,
                    child: const LinearProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: BlocListener<ProductsBloc, ProductsState>(
        listenWhen: (previous, current) {
          // Only listen when the status is not loading
          // This makes only the linear loading dialog to be shown
          return current.status != Status.loading;
        },
        listener: (context, state) {
          if (state.status == Status.error) {
            showDialog(
              context: context,
              builder: (context) => ErrorDialog(
                statusMessage: state.statusMessage,
                onPressed: () {
                  context.read<ProductsBloc>().add(EventCompleted());
                  Navigator.of(context).pop();
                },
              ),
            );
          }
          if (state.status == Status.loaded) {
            // Event completed
            context.read<ProductsBloc>().add(EventCompleted());
          }
        },
        child: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductsBloc>().add(FetchProducts());
              },
              child: GridView.builder(
                //controller
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 400,
                  // childAspectRatio: 3 / 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 5,
                ),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 1,
                    child: GestureDetector(
                      onTap: () {
                        context.goNamed(
                          ProductDetailsScreen.routeName,
                          pathParameters: {'id': product.id!},
                        );
                      },
                      child: Column(
                        children: [
                          Hero(
                            tag: product.id.toString(),
                            child: Image.network(
                              product.images.first,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                product.title ?? 'Title',
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                                '${product.price.min}${product.price.max != null ? " - ${product.price.max}" : ""}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.green,
                                    )),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<ProductsBloc>()
                                  .add(ToggleCartItem(product));
                            },
                            style: const ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              minimumSize: WidgetStatePropertyAll(
                                Size(double.infinity, 50),
                              ),
                            ),
                            child: BlocSelector<ProductsBloc, ProductsState,
                                String>(
                              selector: (state) {
                                if (state.cart.indexWhere((element) =>
                                        element.id == product.id) ==
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: BlocSelector<SalesAiBloc, SalesAiState, SalesAIStatus>(
          selector: (state) => state.status,
          builder: (context, status) {
            return FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  enableDrag: true,
                  showDragHandle: true,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (context) {
                    return const PromptModal();
                  },
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              child: status == SalesAIStatus.loading
                  ? const CircularProgressIndicator()
                  : const Icon(
                      Icons.support_agent_rounded,
                      size: 40,
                    ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      drawer: Drawer(
        child: Stack(
          children: [
            ListView(
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  color: Theme.of(context).colorScheme.secondary,
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  child: Builder(builder: (context) {
                    return StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.userChanges(),
                        builder: (context, user) {
                          if (user.hasData) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  user.data?.displayName ?? "User",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                ),
                                Text(
                                  user.data?.email ?? "...@...",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                ),
                              ],
                            );
                          } else {
                            return const SizedBox();
                          }
                        });
                  }),
                ),
                ListTile(
                  title: const Text('King\'s Store'),
                  trailing: const Icon(Icons.home_outlined),
                  onTap: () {
                    context.pop();
                  },
                ),
                ListTile(
                  title: const Text('Profile'),
                  trailing: const Icon(Icons.person_outline),
                  onTap: () {
                    context.goNamed(ProfileScreen.routeName);
                  },
                ),
                ListTile(
                  title: const Text('Licenses'),
                  trailing: const Icon(Icons.book_outlined),
                  onTap: () {
                    showLicensePage(context: context);
                  },
                ),
              ],
            ),
            Align(
              alignment: const Alignment(0, 0.95),
              child: Text(
                "Powered by Gemini",
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
