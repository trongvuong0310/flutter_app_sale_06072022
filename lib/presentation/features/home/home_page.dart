import 'package:badges/badges.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_widget.dart';
import 'package:flutter_app_sale_06072022/data/model/product.dart';
import 'package:flutter_app_sale_06072022/data/repositories/cart_repository.dart';
import 'package:flutter_app_sale_06072022/data/repositories/product_repository.dart';
import 'package:flutter_app_sale_06072022/presentation/features/home/home_bloc.dart';
import 'package:flutter_app_sale_06072022/presentation/features/home/home_event.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/constants/api_constant.dart';
import '../../../common/constants/variable_constant.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../data/datasources/local/cache/app_cache.dart';
import '../../../data/datasources/remote/api_request.dart';
import '../../../data/model/cart.dart';
import '../cart/cart_bloc.dart';
import '../cart/cart_event.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void logoutUser() {
    AppCache.clear();
    Navigator.pushReplacementNamed(context, VariableConstant.SIGN_IN_ROUTE);
  }
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Home"),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: logoutUser,
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10, top: 10),
            child: IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                Navigator.pushNamed(context, VariableConstant.ORDER_HISTORY_ROUTE);
              },
            )
          ),
          Consumer<CartBloc>(
            builder: (context, bloc, child){
              return StreamBuilder<Cart>(
                  initialData: null,
                  stream: bloc.cartController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError || snapshot.data == null || snapshot.data?.products.isEmpty == true) {
                      return Container();
                    }
                    int count = snapshot.data?.products.length ?? 0;
                    return Container(
                      margin: EdgeInsets.only(right: 10, top: 10),
                      child: Badge(
                        badgeContent: Text(count.toString(), style: const TextStyle(color: Colors.white),),
                        child: IconButton(
                          icon: Icon(Icons.shopping_cart_outlined),
                          onPressed: () {
                            Navigator.pushNamed(context, VariableConstant.CART_ROUTE).then((cartUpdate){
                              if(cartUpdate != null){
                                bloc.cartController.sink.add(cartUpdate as Cart);
                              }
                            });
                          },
                        )
                      ),
                    );
                  }
              );
            },
          )
        ],
      ),
      providers: [
        Provider(create: (context) => ApiRequest()),
        ProxyProvider<ApiRequest, ProductRepository>(
          update: (context, request, repository) {
            repository?.updateRequest(request);
            return repository ?? ProductRepository()
              ..updateRequest(request);
          },
        ),
        ProxyProvider<ApiRequest, CartRepository>(
          update: (context, request, repository) {
            repository?.updateRequest(request);
            return repository ?? CartRepository()
              ..updateRequest(request);
          },
        ),
        ProxyProvider<ProductRepository, HomeBloc>(
          update: (context, repository, bloc) {
            bloc?.updateProductRepository(repository);
            return bloc ?? HomeBloc()
              ..updateProductRepository(repository);
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
      child: HomeContainer(),
    );
  }
}

class HomeContainer extends StatefulWidget {
  const HomeContainer({Key? key}) : super(key: key);

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  late HomeBloc _homeBloc;
  late CartBloc _cartBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = context.read<HomeBloc>();
    _cartBloc = context.read<CartBloc>();
    _homeBloc.eventSink.add(GetListProductEvent());
    _cartBloc.eventSink.add(GetCartEvent());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Stack(
            children: [
              StreamBuilder<List<Product>>(
                  initialData: const [],
                  stream: _homeBloc.listProductController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container(
                        child: Center(child: Text("Data error")),
                      );
                    }
                    if (snapshot.hasData && snapshot.data == []) {
                      return Container();
                    }
                    return ListView.builder(
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          return _buildItemFood(snapshot.data?[index]);
                        }
                    );
                  }
              ),
              LoadingWidget(
                bloc: _homeBloc,
                child: Container(),
              )
            ],
          ),
        )
    );
  }

  Widget _buildItemFood(Product? product) {
    if (product == null) return Container();
    return SizedBox(
      child: Container(
        margin: const EdgeInsets.only( bottom: 5),
        child: Card(
          elevation: 5,
          shadowColor: Colors.blueGrey,
          child: Container(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), topLeft: Radius.circular(5)),
                  child: Image.network(ApiConstant.BASE_URL + product.img,
                      width: 120, height: 120, fit: BoxFit.cover),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(product.name.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16)),
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Text("Price : "),
                            Text("${NumberFormat("#,###", "en_US")
                                .format(product.price)} đ",
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                            children:[
                              ElevatedButton(
                                onPressed: (){
                                  _cartBloc.eventSink.add(AddToCartEvent(id: product.id));
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                      if (states.contains(MaterialState.pressed)) {
                                        return Colors.red;
                                      } else {
                                        return const Color.fromARGB(230, 240, 102, 61);
                                      }
                                    }),
                                    shape: MaterialStateProperty.all(
                                        const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(3))))),
                                child: Row(
                                  children: [
                                    Icon(Icons.add_shopping_cart_outlined, size: 15.0),
                                    SizedBox(width: 5),
                                    Text("Add to cart", style: TextStyle(fontSize: 14))
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: ElevatedButton(
                                  onPressed: () async{
                                    await Navigator.pushNamed(context, VariableConstant.PRODUCT_DETAIL_ROUTE, arguments: product).then((result) {
                                      if(result != null && result == true){
                                        _cartBloc.eventSink.add(GetCartEvent());
                                      }
                                    });
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty.resolveWith((states) {
                                        if (states.contains(MaterialState.pressed)) {
                                          return Colors.red;
                                        } else {
                                          return Colors.blue;
                                        }
                                      }),
                                      shape: MaterialStateProperty.all(
                                          const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3)
                                              )
                                          )
                                      )
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.remove_red_eye_outlined, size: 15.0),
                                      SizedBox(width: 5),
                                      Text("View more", style: const TextStyle(fontSize: 14))
                                    ],
                                  ),
                                ),
                              ),
                            ]
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

