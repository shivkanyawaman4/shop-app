import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/Providers/product.dart';
import 'package:shop_app/models/http_exceptions.dart';


class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  Product findbyId(String id) =>
      _items.firstWhere((element) => element.id == id);

  List<Product> get favoriteItem {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }


 Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          "https://shopapp-e0fa1-default-rtdb.firebaseio.com/$id.json";
      http.patch(Uri.parse(url),
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }
  
  Future<void> fetchAndSetProductions() async {
    const url =
        "https://shopapp-e0fa1-default-rtdb.firebaseio.com/products.json";

    try {
      final response = await http.get(Uri.parse(url));

      final List<Product> loadedProducts = [];
      final extractedData = json.decode(response.body) == null
          ? {}
          : json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.length <= 0) {
        return;
      }
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            description: prodData["description"],
            id: prodId,
            imageUrl: prodData["imageUrl"],
            price: prodData["price"],
            title: prodData["title"]));
      });
      _items = loadedProducts;
      notifyListeners();
      // print(json.decode(response.body));
    } catch (error) {
      // print("Error: $error");
      throw (error);
    }
  }

   
  Future addProduct(Product product) async {
    const url =
        "https://shopapp-e0fa1-default-rtdb.firebaseio.com/products.json";
  return await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          })).then((value)      
     {
        Product newProduct = Product(
          id: json.decode(value.body)["name"],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
     }).catchError((onError){
  print(onError);
      throw onError;
     });
    }
  


  Future<void> deleteProducts(String id) async {
    final url =
        "https://shopapp-e0fa1-default-rtdb.firebaseio.com//products/$id.json";

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingproduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    // _items.removeWhere((element) => element.id == id);
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingproduct);
      notifyListeners();
      throw HttpException("Could not delete product.");
    }
    existingproduct = null;
  }
}
