import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();

  static const routeName = '/edit-product';
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocus = FocusNode();
  final _form = GlobalKey<FormState>();
  final _imageForm = GlobalKey<FormState>(); // rasm url olish va ko'rsatish
  var _product = Product(
    id: "",
    title: "",
    description: "",
    price: 0.0,
    imageUrl: "",
  );

  var _hasImage = true;
  var _init = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        // ... mahsulotni eski info sini olish
        final _editingProduct =
            Provider.of<Products>(context).findById(productId as String);
        _product = _editingProduct;
        print(_product);
      }
    }
    _init = false;
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocus.dispose();
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text("Enter URL !"),
            content: Form(
              key: _imageForm, // rasm url olish va ko'rsatish
              child: TextFormField(
                initialValue: _product.imageUrl,
                decoration: const InputDecoration(
                  labelText: "Image's URL",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please, enter image URL";
                  } else if (!value.startsWith("http")) {
                    return "Please, enter correct image URL";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  // rasm url olish va ko'rsatish
                  _product = Product(
                      id: "",
                      title: _product.title,
                      description: _product.description,
                      price: _product.price,
                      imageUrl: newValue!);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: _saveImageForm, // // rasm url olish va ko'rsatish
                child: const Text("SAVE"),
              )
            ],
          );
        });
  }

  void _saveImageForm() {
    final isValid = _imageForm.currentState!.validate();
    setState(() {
      _hasImage = true;
    });
    if (isValid && _hasImage) {
      _imageForm.currentState!.save();
      setState(() {
        Navigator.of(context).pop();
      });
    }
  }

  void _saveForm() async {
    FocusScope.of(context).unfocus();
    // validator 1
    final isValid = _form.currentState!.validate(); // validate qilsa bo'ladi
    setState(() {
      _hasImage = _product.imageUrl.isNotEmpty;
    });
    if (isValid && _hasImage) {
      setState(() {
        _isLoading = true;
      });
      _form.currentState!.save();
      if (_product.id.isEmpty) {
        try {
          await Provider.of<Products>(context, listen: false)
              .addProduct(_product);
        } catch (error) {
          await showDialog<Null>(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text("Error !"),
                  content: const Text("An error occured"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text("OK"))
                  ],
                );
              });
          // } finally {
          //   setState(() {
          //     _isLoading = false;
          //     Navigator.of(context).pop();
          //   });
          // }
        }
      } else {
        try {
          await Provider.of<Products>(context, listen: false)
              .updateProduct(_product);
        } catch (e) {
          await showDialog<Null>(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text("Error !"),
                  content: const Text("An error occured"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text("OK"))
                  ],
                );
              });
        }
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
        centerTitle: true,
        title: const Text("Add product"),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Form(
                //   autovalidateMode: AutovalidateMode tr,
                key: _form,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16), //k2
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _product.title,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        //  textInputAction: TextInputAction.next, // narxni etiborini boshqarish uchun osoni functionlari kam
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocus);
                        },
                        validator: (value) {
                          // validator 2
                          if (value == null || value.isEmpty) {
                            return 'Please, enter product\'s name';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _product = Product(
                            id: _product.id,
                            title: newValue!,
                            description: _product.description,
                            price: _product.price,
                            imageUrl: _product.imageUrl,
                            isFavorite: _product.isFavorite,
                          );
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        initialValue: _product.price == 0
                            ? ''
                            : _product.price.toStringAsFixed(2),
                        decoration: const InputDecoration(
                            labelText: 'Price', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        focusNode:
                            _priceFocus, // narxni etiborini boshqarish uchun
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          // validator 2
                          if (value == null || value.isEmpty) {
                            return 'Please, enter product\'s price';
                          } else if (double.tryParse(value) == null) {
                            return "Please, enter correct value";
                          } else if (double.parse(value) < 1) {
                            return "Product's price must be bigger than zero";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          // form ichidagi info ni saqlash uchun function
                          _product = Product(
                            id: _product.id,
                            title: _product.title,
                            description: _product.description,
                            price: double.parse(newValue!),
                            imageUrl: _product.imageUrl,
                            isFavorite: _product.isFavorite,
                          );
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        initialValue: _product.description,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint:
                              true, // labelText: yuqoriga qo'yadi
                        ),
                        maxLines:
                            5, // text qotori istalgancha katta qilish mumkun
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          // validator 2
                          if (value == null || value.isEmpty) {
                            return 'Please, enter product\'s description';
                          } else if (value.length < 10) {
                            return "Please, enter datail information";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          // form ichidagi info ni saqlash uchun function
                          _product = Product(
                            id: _product.id,
                            title: _product.title,
                            description: newValue!,
                            price: _product.price,
                            imageUrl: _product.imageUrl,
                            isFavorite: _product.isFavorite,
                          );
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Card(
                        margin: const EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                              color: _hasImage ? Colors.grey : Colors.red,
                            )),
                        child: InkWell(
                          onTap: () => _showImageDialog(context),
                          splashColor: Colors.teal.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(5),
                          highlightColor: Colors.transparent,
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: _product.imageUrl.isEmpty
                                ? Text(
                                    "Enter the main image URL",
                                    style: TextStyle(
                                        color: _hasImage
                                            ? Colors.black
                                            : Colors.red),
                                  )
                                : Image.network(
                                    _product.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
