import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_ai_examples/src/products/utils/data_provider.dart';
import 'package:sales_ai_examples/src/products/utils/models.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final DBRepository _dbRepository;
  ProductsBloc({required DBRepository dbRepository})
      : _dbRepository = dbRepository,
        super(ProductsState()) {
    on<FetchProducts>(_onFetchProducts);
    on<FetchSearchedProducts>(_onSearchedProducts);
    on<EventCompleted>(_onEventCompleted);
    on<ToggleCartItem>(_onToggleCartItem);
    on<AddCartItemByID>(_onAddCartItemByID);
    on<RemoveCartItemByID>(_onRemoveCartItemByID);
    on<ClearCart>(_onClearCart);
  }

  FutureOr<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final products = List<ProductModel>.from(
        (await _dbRepository.fetchProducts()).map(
          (x) => ProductModel.fromMap(x),
        ),
      );
      emit(state.copyWith(
          status: Status.loaded, products: state.products + products));
    } catch (e) {
      emit(state.copyWith(status: Status.error, statusMessage: e.toString()));
    }
  }

  FutureOr<void> _onSearchedProducts(
    FetchSearchedProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final searchedProducts = List<ProductModel>.from(
        (await _dbRepository.searchProducts(event.query)).map(
          (x) => ProductModel.fromMap(x),
        ),
      );
      emit(state.copyWith(
        status: Status.loaded,
        searchedProducts: searchedProducts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        statusMessage: e.toString(),
      ));
    }
  }

  FutureOr<void> _onEventCompleted(
    EventCompleted event,
    Emitter<ProductsState> emit,
  ) {
    emit(state.copyWith(status: Status.initial));
  }

  FutureOr<void> _onToggleCartItem(
    ToggleCartItem event,
    Emitter<ProductsState> emit,
  ) {
    List<ProductModel> cart = List.from(state.cart);
    int index = cart.indexWhere((element) => element.id == event.product.id);
    if (index == -1) {
      cart.add(event.product);
    } else {
      cart.removeAt(index);
    }
    emit(state.copyWith(cart: cart));
  }

  FutureOr<void> _onAddCartItemByID(
    AddCartItemByID event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      final product = ProductModel.fromMap(
          (await _dbRepository.getProduct(event.productId)));
      List<ProductModel> cart = List.from(state.cart);
      int index = cart.indexWhere((element) => element.id == product.id);
      if (index == -1) {
        cart.add(product);
      }
      emit(state.copyWith(cart: cart));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        statusMessage: e.toString(),
      ));
    }
  }

  FutureOr<void> _onRemoveCartItemByID(
    RemoveCartItemByID event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      List<ProductModel> cart = List.from(state.cart);
      int index = cart.indexWhere((element) => element.id == event.productId);
      if (index != -1) {
        cart.removeAt(index);
      }
      emit(state.copyWith(cart: cart));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        statusMessage: e.toString(),
      ));
    }
  }

  FutureOr<void> _onClearCart(ClearCart event, Emitter<ProductsState> emit) {
    emit(state.copyWith(cart: []));
  }
}
