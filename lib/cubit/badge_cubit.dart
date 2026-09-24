import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rburger/screens/cart_screen.dart';

class CartCountCubit extends Cubit<int> {
  CartCountCubit._() : super(CartController.instance.itemCount) {
    CartController.instance.addListener(_onCartChanged);
  }

  static final CartCountCubit instance = CartCountCubit._();

  void _onCartChanged() {
    emit(CartController.instance.itemCount);
  }

  @override
  Future<void> close() {
    CartController.instance.removeListener(_onCartChanged);
    return super.close();
  }
}
