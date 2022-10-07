import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_bloc.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_event.dart';
import 'package:flutter_app_sale_06072022/data/datasources/remote/dto/order_dto.dart';
import '../../../data/datasources/remote/app_response.dart';
import '../../../data/model/order.dart';
import '../../../data/model/product.dart';
import '../../../data/repositories/order_repository.dart';
import 'order_event.dart';

class OrderBloc extends BaseBloc{
  StreamController<List<Order>> orderController = StreamController();
  late OrderRepository _orderRepository;

  void updateOrderRepository(OrderRepository orderRepository) {
    _orderRepository = orderRepository;
  }

  @override
  void dispatch(BaseEvent event) {
    switch(event.runtimeType) {
      case GetOrderEvent:
        _getOrder();
        break;

    }
  }

  void _getOrder() async {
    loadingSink.add(true);
    try {
      Response response = await _orderRepository.getOrders();
      AppResponse<List<OrderDto>> orderResponse = AppResponse.fromJson(response.data, OrderDto.convertJson);

      List<Order> orders = [];
      orderResponse.data?.forEach((item) {
        Order order = Order(
          item?.id,
          item?.products?.map((dto){
            return Product(dto.id, dto.name, dto.address, dto.price, dto.img, dto.quantity, dto.gallery);
          }).toList(),
          item?.idUser,
          item?.price,
          item?.status,
          item?.dateCreated,
        );
        orders.add(order);
      });

      orderController.sink.add(orders);
    } on DioError catch (e) {
      orderController.sink.addError(e.response?.data["message"]);
      messageSink.add(e.response?.data["message"]);
    } catch (e) {
      messageSink.add(e.toString());
    }
    loadingSink.add(false);
  }

}