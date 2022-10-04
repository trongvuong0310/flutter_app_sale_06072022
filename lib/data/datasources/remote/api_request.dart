import 'package:dio/dio.dart';
import 'package:flutter_app_sale_06072022/common/constants/api_constant.dart';
import 'package:flutter_app_sale_06072022/data/datasources/remote/dio_client.dart';

class ApiRequest {
  late Dio _dio;
  
  ApiRequest(){
    _dio = DioClient.instance.dio;
  }
  
  Future signIn(String email, String password) {
    return _dio.post(ApiConstant.SIGN_IN_URL, data: {
      "email": email,
      "password": password
    });
  }

  Future signUp(String email, String name, String phone, String password, String address) {
    return _dio.post(ApiConstant.SIGN_UP_URL, data: {
      "email": email,
      "password": password,
      "phone": phone,
      "name": name,
      "address": address
    });
  }

  Future getProducts() {
    return _dio.get(ApiConstant.LIST_PRODUCT_URL);
  }

  Future getCart() {
    return _dio.get(ApiConstant.CART_URL);
  }

  Future addToCart(String id) {
    return _dio.post(ApiConstant.ADD_TO_CART_URL, data: {
      "id_product": id,
    });
  }

  Future updateCart(String idCart, num quantity, String idProduct) {
    return _dio.post(ApiConstant.UPDATE_CART_URL, data: {
      "id_cart": idCart,
      "quantity": quantity,
      "id_product": idProduct
    });
  }

  Future conformCart(String idCart) {
    return _dio.post(ApiConstant.CONFORM_CART_URL, data: {
      "id_cart": idCart
    });
  }

  Future getOrders() {
    return _dio.post(ApiConstant.ORDER_HISTORY_URL);
  }
}