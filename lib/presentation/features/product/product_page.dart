import 'package:badges/badges.dart';
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
import '../cart/cart_bloc.dart';
import '../cart/cart_event.dart';
class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      appBar: AppBar(
        title: const Text("Product detail"),
        actions: [
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
                      margin: EdgeInsets.only(right: 20, top: 10),
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
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: (){Navigator.pop(context, true);}
        )
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
      child: ProductContainer(),
    );
  }
}

class ProductContainer extends StatefulWidget {
  const ProductContainer({Key? key}) : super(key: key);

  @override
  State<ProductContainer> createState() => _ProductContainerState();
}

class _ProductContainerState extends State<ProductContainer> {
  Product? product;
  late CartBloc _cartBloc;
  String selectedImage = "";
  String image = "";

  @override
  void initState() {
    super.initState();
    _cartBloc = context.read<CartBloc>();
    _cartBloc.eventSink.add(GetCartEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    product = ModalRoute.of(context)?.settings.arguments as Product;
    selectedImage = image = ApiConstant.BASE_URL + product!.img;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Image.network(selectedImage,width: double.maxFinite, height: 250, fit: BoxFit.contain,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildImages(image),
                ...List.generate(product!.gallery.length,
                        (index) => buildImages(ApiConstant.BASE_URL + product!.gallery[index])),
              ],
            )
          ],
        ),
        TopRoundedContainer(
          color: Colors.white,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20, context)),
                    child: Text(
                      product!.name,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(20, context),
                      vertical: 5,
                    ),
                    child: Row(
                      children: [
                        Text(
                            "Price : "
                        ),
                        Text("${NumberFormat("#,###", "en_US")
                            .format(product!.price)} ??",
                            style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(20, context),
                      vertical: 5,
                    ),
                    child: Text(
                      product!.address,
                      maxLines: 4,
                    ),
                  )
                ],
              ),
              Stack(
                children: [
                  LoadingWidget(
                    bloc: _cartBloc,
                    child: Container(),
                  )
                ],
              ),
              TopRoundedContainer(
                color: Color(0xFFF2F2F2),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: getProportionateScreenWidth(40, context),
                    top: getProportionateScreenWidth(15, context),
                  ),
                  child: DefaultButton(
                    text: "Add to cart",
                    press: () {
                      _cartBloc.eventSink.add(AddToCartEvent(id: product!.id));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  GestureDetector buildImages(String url) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedImage = url;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.all(5),
        height: getProportionateScreenHeight(80, context),
        width: getProportionateScreenWidth(60, context),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: Color(0xFFFF7643).withOpacity(selectedImage == url ? 1 : 0)),
        ),
        child: Image.network(url),
      ),
    );
  }

}

class TopRoundedContainer extends StatelessWidget {
  const TopRoundedContainer({
    Key? key,
    required this.color,
    required this.child,
  }) : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: getProportionateScreenWidth(20, context)),
      padding: EdgeInsets.only(top: getProportionateScreenWidth(20, context)),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: child,
    );
  }
}

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key? key,
    this.text,
    this.press,
  }) : super(key: key);
  final String? text;
  final Function? press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: getProportionateScreenHeight(56, context),
      child: TextButton(
        style: TextButton.styleFrom(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.red,
        ),
        onPressed: press as void Function()?,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_shopping_cart_outlined, size: 20.0, color: Colors.white,),
            SizedBox(width: 5),
            Text(
              text!,
              style: TextStyle(
                fontSize: getProportionateScreenWidth(18, context),
                color: Colors.white,
              ),
            ),
          ],
        )
      ),
    );
  }
}

double getProportionateScreenHeight(double inputHeight, BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  return (inputHeight / 812.0) * screenHeight;
}

double getProportionateScreenWidth(double inputWidth, BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  return (inputWidth / 375.0) * screenWidth;
}

