import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/Model/product.dart';
import 'package:shop_app/Controller/auth.dart';
import 'package:shop_app/Controller/product_controller.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  Product _newProduct() {
    return Product(
      id: "",
      title: "",
      price: 0,
      description: "",
      imageUrl: "",
      userId: context.read<User>().userId!,
      // token: context.read<User>().token,
    );
  }

  Product? _editedProduct;
  var _initValues = {
    'title': "",
    'description': "",
    'price': "",
    'imageUrl': "",
  };
  var _isInit = true;

  bool _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        _editedProduct = context.read<ProductController>().findById(productId);
        _initValues = {
          'title': _editedProduct!.title,
          'description': _editedProduct!.description,
          'price': _editedProduct!.price.toString(),
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
          "userId": _editedProduct!.userId
        };
        _imageUrlController.text = _editedProduct!.imageUrl;
      } else {
        _editedProduct = _newProduct();
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _form.currentState!.save();
    //_______________________________________ edit product
    if (_editedProduct!.id != "") {
      try {
        await context
            .read<ProductController>()
            .updateProduct(_editedProduct!.id, _editedProduct!)
            .then(
          (_) {
            setState(
              () {
                _isLoading = false;
              },
            );
          },
        );
      } catch (error) {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text("Error"),
            content: Text("Something went wrong"),
          ),
        );
      } finally {
        Navigator.of(context).pop();
      }
    }
    //_______________________________________ new product
    else {
      try {
        await context
            .read<ProductController>()
            .addProduct(_editedProduct!)
            .then(
          (_) {
            setState(
              () {
                _isLoading = false;
              },
            );
          },
        );
      } catch (error) {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text("Error"),
            content: Text("Something went wrong"),
          ),
        );
      } finally {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _form,
                  child: ListView(
                    children: <Widget>[
                      //______________________________________ title
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a value.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: value!,
                            price: _editedProduct!.price,
                            description: _editedProduct!.description,
                            imageUrl: _editedProduct!.imageUrl,
                            id: _editedProduct!.id,
                            userId: _editedProduct!.userId,
                          );
                        },
                      ),
                      //______________________________________ price
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: const InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a price.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number.';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a number greater than zero.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: _editedProduct!.title,
                            price: double.parse(value!),
                            description: _editedProduct!.description,
                            imageUrl: _editedProduct!.imageUrl,
                            id: _editedProduct!.id,
                            userId: _editedProduct!.userId,
                          );
                        },
                      ),
                      //______________________________________ desc
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a description.';
                          }
                          if (value.length < 10) {
                            return 'Should be at least 10 characters long.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: _editedProduct!.title,
                            price: _editedProduct!.price,
                            description: value!,
                            imageUrl: _editedProduct!.imageUrl,
                            id: _editedProduct!.id,
                            userId: _editedProduct!.userId,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(
                              top: 8,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? const Text('Enter a URL')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          //______________________________________ image url
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter an image URL.';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please enter a valid URL.';
                                }
                                if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'Please enter a valid image URL.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _editedProduct = Product(
                                  title: _editedProduct!.title,
                                  price: _editedProduct!.price,
                                  description: _editedProduct!.description,
                                  imageUrl: value!,
                                  id: _editedProduct!.id,
                                  userId: _editedProduct!.userId,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
