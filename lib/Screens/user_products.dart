import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Screens/edit_products.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import '../providers/products.dart';
import '../widgets/user_product.dart';


class UserProducts extends StatelessWidget {
  static const routeName = '/user_products';

  const UserProducts({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProductions();
  }

  @override
  Widget build(BuildContext context) {
    final productsdata = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Products"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) => Column(
              children: [
                UserProductItem(
                  imageUrl: productsdata.items[index].imageUrl,
                  title: productsdata.items[index].title,
                  id: productsdata.items[index].id,
                ),
                Divider()
              ],
            ),
            itemCount: productsdata.items.length,
          ),
        ),
      ),
    );
  }
}