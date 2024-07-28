part of 'products_bloc.dart';

enum Status { initial, loading, loaded, error }

class ProductsState {
  ProductsState({
    this.products = const [],
    this.searchedProducts = const [],
    this.cart = const [],
    this.status = Status.initial,
    this.statusMessage = '',
  });
  final List<ProductModel> products, searchedProducts, cart;
  final Status status;
  final String statusMessage;

  ProductsState copyWith({
    List<ProductModel>? products,
    List<ProductModel>? searchedProducts,
    List<ProductModel>? cart,
    Status? status,
    String? statusMessage,
  }) {
    return ProductsState(
      products: products ?? this.products,
      searchedProducts: searchedProducts ?? this.searchedProducts,
      cart: cart ?? this.cart,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  List<ProductModel> get allProducts => products + searchedProducts + cart; 

  double get cartTotal {
    return double.parse(
      cart
          .fold(
              0.0,
              (previousValue, element) =>
                  previousValue +
                  (double.tryParse(element.price.min!.substring(1)) ?? 0))
          .toStringAsFixed(2),
    );
  }

  String get currency => "£";
}
