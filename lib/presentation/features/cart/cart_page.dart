import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_widget.dart';
import 'package:flutter_app_sale_06072022/data/model/product.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../common/constants/api_constant.dart';
import '../../../common/constants/variable_constant.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../data/datasources/remote/api_request.dart';
import '../../../data/model/cart.dart';
import '../../../data/repositories/cart_repository.dart';
import 'cart_bloc.dart';
import 'cart_event.dart';
class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      appBar: AppBar(
        title: const Text("My Shopping Cart"),
        actions: [
          Container(
              margin: EdgeInsets.only(right: 10, top: 10),
              child: IconButton(
                icon: Icon(Icons.history),
                onPressed: () {
                  Navigator.pushNamed(context, VariableConstant.ORDER_HISTORY_ROUTE);
                },
              )
          )
        ],
      ),
      providers: [
        Provider(create: (context) => ApiRequest()),
        ProxyProvider<ApiRequest, CartRepository>(
          update: (context, request, repository) {
            repository?.updateRequest(request);
            return repository ?? CartRepository()
              ..updateRequest(request);
          },
        ),
        ProxyProvider<CartRepository, CartBloc>(
          update: (context, repository, bloc) {
            bloc?.updateCartRepository(repository);
            return bloc ?? CartBloc()
              ..updateCartRepository(repository);
          },
        ),
      ],
      child: CartContainer(),
    );
  }
}

class CartContainer extends StatefulWidget {
  const CartContainer({Key? key}) : super(key: key);

  @override
  State<CartContainer> createState() => _CartContainerState();
}

class _CartContainerState extends State<CartContainer> {
  Cart? _cart;
  late CartBloc _cartBloc;

  @override
  void initState() {
    super.initState();
    _cartBloc = context.read<CartBloc>();
    _cartBloc.eventSink.add(GetCartEvent());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context, _cart);
        return true;
      },
      child: SafeArea(
          child: Container(
            child: Stack(
              children: [
                StreamBuilder<Cart>(
                    initialData: null,
                    stream: _cartBloc.cartController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text(
                              'Your Cart is Empty',
                              style:
                              TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            )
                        );
                      }
                      if (snapshot.hasData) {
                        _cart = snapshot.data;
                        if (snapshot.data!.products.isEmpty) {
                          return const Center(
                              child: Text(
                                'Your Cart is Empty',
                                style:
                                TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18.0),
                              )
                          );
                        }
                        return Column(
                          children: [
                            Expanded(
                                child: ListView.builder(
                                    itemCount: snapshot.data?.products?.length ??
                                        0,
                                    itemBuilder: (context, index) {
                                      return _buildItemCart(
                                          snapshot.data?.products?[index]);
                                    }
                                )
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 1,
                                      color: Colors.grey[300],
                                      margin: EdgeInsets.only(top: 10, bottom: 10),
                                    ),
                                    Text('Order summary' ,style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total: '),
                                        Text(NumberFormat("#,###", "en_US")
                                            .format(_cart?.price) +
                                            " đ",
                                            style: TextStyle(fontSize: 20,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_cart != null) {
                                      String? cartId = _cart!.id;
                                      _cartBloc.eventSink.add(
                                          CartConformEvent(idCart: cartId));
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Payment".toUpperCase(),
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 18)),
                                      Icon(Icons.arrow_right_alt, ),
                                    ],
                                  ),
                                  style: ButtonStyle(
                                    // backgroundColor: MaterialStateProperty<Color>(Colors.red),
                                    // padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(vertical: 10))
                                  ),
                                ),
                            ),
                          ],
                        );
                      }
                      return Container();
                    }
                ),
                LoadingWidget(
                  bloc: _cartBloc,
                  child: Container(),
                )
              ],
            ),

          )
      ),
    );
  }

  Widget _buildItemCart(Product? product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Card(
        elevation: 2,
        shadowColor: Colors.blueGrey,
        child: Container(

          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(0),
                child:ClipRRect(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), topLeft: Radius.circular(5)),
                  child: Image.network(ApiConstant.BASE_URL + product!.img,
                      width: 120, height: 120, fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text((product.name).toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(height: 5,),
                      Row(
                        children: [
                          Text("Price : "),
                          Text("${NumberFormat("#,###", "en_US")
                              .format(product?.price)} đ",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if(product != null && _cart != null) {
                                String? cartId = _cart!.id;
                                if(cartId.isNotEmpty) {
                                  _cartBloc.eventSink.add(UpdateCartEvent(
                                      idCart: cartId,
                                      idProduct: product.id,
                                      quantity: product.quantity - 1));
                                }
                              }
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(35)
                              ),
                              child: Center(child: Text("-", style: TextStyle(color: Colors.white),),),
                            ),

                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text((product.quantity).toString(),
                                style: TextStyle(fontSize: 16)),
                          ),
                          InkWell(
                            onTap: () {
                              if(product != null && _cart != null) {
                                String? cartId = _cart!.id;
                                if(cartId.isNotEmpty) {
                                  _cartBloc.eventSink.add(UpdateCartEvent(
                                      idCart: cartId,
                                      idProduct: product.id,
                                      quantity: product.quantity + 1));
                                }
                              }
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(35)
                              ),
                              child: Center(child: Text("+", style: TextStyle(color: Colors.white),),),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}