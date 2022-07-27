import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Providers/product.dart';
import 'package:shop_app/Providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit_products";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  Product _product = Product(
      id: "",
      title: '',
      description: '',
      price: 0,
      imageUrl: '',
      isFavorite: false);

  var _isinit = true;

  bool _isLoading = false;

  var _initValues = {
    "title": "",
    "price": "",
    "description": "",
    "imageUrl": "",
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isinit) {
      final productId = ModalRoute.of(context)?.settings.arguments;
      if (productId != null) {
        _product = Provider.of<Products>(context, listen: false)
            .findbyId(productId.toString());
        _initValues = {
          "title": _product.title,
          "price": _product.price.toString(),
          "description": _product.description,
          // "imageUrl": _product.imageUrl Not allowed when you have controller set
        };
        _imageUrlController.text = _product.imageUrl;
      }
    }
    _isinit = false;
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith("http") &&
              !_imageUrlController.text.startsWith("https")) ||
          (!_imageUrlController.text.endsWith(".png") &&
              !_imageUrlController.text.endsWith(".jpg") &&
              !_imageUrlController.text.endsWith(".jpeg") &&
              !_imageUrlController.text.endsWith(".webp"))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveFrom() async {
    final isvalid = _formKey.currentState?.validate();
    if (isvalid != null && !isvalid) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _formKey.currentState?.save();
    print(_product.id);
    if (_product.id != "") {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_product.id, _product);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_product);
      } catch (e) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("An Error Occurred"),
                  content: Text("Something Went Wrong"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text("Okay"))
                  ],
                ));
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [IconButton(onPressed: _saveFrom, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues["title"],
                      decoration: InputDecoration(labelText: "Title"),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return "Please provide a value";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _product = Product(
                          id: _product.id,
                          isFavorite: _product.isFavorite,
                          title: value ?? "",
                          price: _product.price,
                          description: _product.description,
                          imageUrl: _product.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["price"],
                      decoration: InputDecoration(labelText: "Price"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_descFocusNode);
                      },
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return "Please Provide a price.";
                        }
                        if (value != null && double.tryParse(value) == null) {
                          return "Please enter a valid number.";
                        }
                        if (value != null && double.parse(value) <= 0) {
                          return "Plase enter a greater than zero number";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _product = Product(
                          id: _product.id,
                          isFavorite: _product.isFavorite,
                          title: _product.title,
                          price: double.parse(value ?? "0"),
                          description: _product.description,
                          imageUrl: _product.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["description"],
                      decoration: InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descFocusNode,
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return "Please Provide a value.";
                        }

                        if (value != null && value.length < 10) {
                          return "Should be at least 10 characters long.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _product = Product(
                          id: _product.id,
                          isFavorite: _product.isFavorite,
                          title: _product.title,
                          price: _product.price,
                          description: value ?? "",
                          imageUrl: _product.imageUrl,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text("Enter a URL")
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                              // initialValue: _initValues["imageUrl"],
                              decoration:
                                  InputDecoration(labelText: "Image Url"),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.url,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) {
                                _saveFrom();
                              },
                              onSaved: (value) {
                                _product = Product(
                                  id: _product.id,
                                  isFavorite: _product.isFavorite,
                                  title: _product.title,
                                  price: _product.price,
                                  description: _product.description,
                                  imageUrl: value ?? "",
                                );
                              }),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
