import '../../common/bases/base_repository.dart';

class CartRepository extends BaseRepository{
  Future getCart() {
    return apiRequest.getCart();
  }

  Future addToCart(String id) {
    return apiRequest.addToCart(id);
  }

  Future updateCart(String idCart, num quantity, String idProduct) {
    return apiRequest.updateCart(idCart, quantity, idProduct);
  }

  Future conformCart(String idCart) {
    return apiRequest.conformCart(idCart);
  }
}