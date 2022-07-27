import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/edit_products.dart';

import 'package:shop_app/screens/products_overview_screen.dart';

import './screens/orders_screen.dart';
import './screens/user_products.dart';
import './screens/cart_screen.dart';
import './providers/cart.dart';
import './providers/products.dart';
import './providers/orders.dart';
import 'Screens/Product_detail_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Products(),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProvider.value(
          value: Orders(),
        ),
        // ChangeNotifierProvider(create: (_) => Products()),
        // ChangeNotifierProvider(create: (_) => Cart()),
        // ChangeNotifierProvider(create: (_) => Orders()),
        //ChangeNotifier(create: (_)=> Product());
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'State Management',
        theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.orange,
            fontFamily: 'Lato'),
        home: ProductsOverview(),
        routes: {
          ProductDetails.routeName: (ctx) => ProductDetails(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen(),
          UserProducts.routeName: (ctx) => UserProducts(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
        },
      ),
    );
  }
}
