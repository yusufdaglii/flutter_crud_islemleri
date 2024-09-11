import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/api/products'));

      if (response.statusCode == 200) {
        setState(() {
          _products = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load products: ${response.reasonPhrase}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addProduct(String name, String price) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'price': price,
        }),
      );

      if (response.statusCode == 201) {
        _fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün başarıyla eklendi!')),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to add product: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProduct(int productId, String name, String price) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/products/$productId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'price': price,
        }),
      );

      if (response.statusCode == 200) {
        _fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün başarıyla güncellendi!')),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to update product: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(int productId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/products/$productId'),
      );

      if (response.statusCode == 200) {
        _fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün başarıyla silindi!')),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to delete product: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünler'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ProductForm(
                        nameController: _nameController,
                        priceController: _priceController,
                        onAddProduct: () {
                          if (_nameController.text.isNotEmpty &&
                              _priceController.text.isNotEmpty) {
                            _addProduct(
                              _nameController.text,
                              _priceController.text,
                            );
                            _nameController.clear();
                            _priceController.clear();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ProductList(
                          products: _products,
                          onDeleteProduct: _deleteProduct,
                          onUpdateProduct: (int id) {
                            _nameController.text = _products.firstWhere(
                                (product) => product['id'] == id)['name'];
                            _priceController.text = _products
                                .firstWhere(
                                    (product) => product['id'] == id)['price']
                                .toString();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Ürünü Güncelle'),
                                content: ProductForm(
                                  nameController: _nameController,
                                  priceController: _priceController,
                                  onAddProduct: () {
                                    _updateProduct(
                                      id,
                                      _nameController.text,
                                      _priceController.text,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class ProductForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final VoidCallback onAddProduct;

  const ProductForm({
    required this.nameController,
    required this.priceController,
    required this.onAddProduct,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Ürün Adı',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Ürün Fiyatı',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onAddProduct,
          icon: const Icon(Icons.add),
          label: const Text('Ürün Ekle'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ],
    );
  }
}

class ProductList extends StatelessWidget {
  final List<dynamic> products;
  final Function(int) onDeleteProduct;
  final Function(int) onUpdateProduct;

  const ProductList({
    required this.products,
    required this.onDeleteProduct,
    required this.onUpdateProduct,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              product['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Fiyat: ₺${product['price']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => onUpdateProduct(product['id']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDeleteProduct(product['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
