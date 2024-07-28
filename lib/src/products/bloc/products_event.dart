part of 'products_bloc.dart';

sealed class ProductsEvent {}


class FetchProducts extends ProductsEvent {
  FetchProducts();
}

class FetchSearchedProducts extends ProductsEvent {
  final String query;
  FetchSearchedProducts(this.query);
}

class EventCompleted extends ProductsEvent {
  /// update the state to initial status
  EventCompleted();
}

class ToggleCartItem extends ProductsEvent {
  final ProductModel product;
  ToggleCartItem(this.product);
}

class AddCartItemByID extends ProductsEvent {
  final String productId;
  AddCartItemByID(this.productId);
}

class RemoveCartItemByID extends ProductsEvent {
  final String productId;
  RemoveCartItemByID(this.productId);
}

class ClearCart extends ProductsEvent {}