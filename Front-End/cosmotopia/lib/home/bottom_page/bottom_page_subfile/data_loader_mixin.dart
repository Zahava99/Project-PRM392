import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cosmotopia/backend/api_service.dart';
import 'package:cosmotopia/backend/schema/structs/category_struct.dart';
import 'package:cosmotopia/backend/schema/structs/product_struct.dart';
import 'package:cosmotopia/backend/schema/structs/order_struct.dart';
import '/flutter_flow/flutter_flow_util.dart';

mixin DataLoaderMixin<T extends StatefulWidget> on State<T> {
  // Categories data
  List<dynamic> _categories = [];
  bool _isLoadingCategory = true;
  String? _categoryError;
  
  // Products data
  List<ProductStruct> _allProducts = [];
  List<ProductStruct> _justForYouProducts = [];
  List<ProductStruct> _newArrivalProducts = [];
  List<ProductStruct> _favoriteProducts = [];
  bool _isLoadingProducts = true;
  bool _isLoadingFavorites = true;
  String? _productsError;
  String? _favoritesError;
  
  // User data
  String _userName = 'User';
  bool _isLoadingUser = true;
  
  // Orders data
  List<OrderStruct> _allOrders = [];
  List<OrderStruct> _activeOrders = [];
  List<OrderStruct> _completedOrders = [];
  List<OrderStruct> _cancelledOrders = [];
  bool _isLoadingOrders = true;
  String? _ordersError;

  // Getters
  List<dynamic> get categories => _categories;
  bool get isLoadingCategory => _isLoadingCategory;
  String? get categoryError => _categoryError;
  
  List<ProductStruct> get allProducts => _allProducts;
  List<ProductStruct> get justForYouProducts => _justForYouProducts;
  List<ProductStruct> get newArrivalProducts => _newArrivalProducts;
  List<ProductStruct> get favoriteProducts => _favoriteProducts;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingFavorites => _isLoadingFavorites;
  String? get productsError => _productsError;
  String? get favoritesError => _favoritesError;
  
  String get userName => _userName;
  bool get isLoadingUser => _isLoadingUser;
  
  List<OrderStruct> get allOrders => _allOrders;
  List<OrderStruct> get activeOrders => _activeOrders;
  List<OrderStruct> get completedOrders => _completedOrders;
  List<OrderStruct> get cancelledOrders => _cancelledOrders;
  bool get isLoadingOrders => _isLoadingOrders;
  String? get ordersError => _ordersError;

  Future<void> loadCurrentUser() async {
    setState(() {
      _isLoadingUser = true;
    });

    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        setState(() {
          _userName = FFAppState().firstname.isNotEmpty ? FFAppState().firstname : 'Guest';
          _isLoadingUser = false;
        });
        return;
      }

      final response = await ApiService.getCurrentUser(token: token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['data'];
        
        setState(() {
          _userName = userData['firstName'] ?? 'User';
          _isLoadingUser = false;
        });
        
        FFAppState().firstname = userData['firstName'] ?? '';
        FFAppState().emailaddress = userData['email'] ?? '';
        FFAppState().phonenumber = userData['phone'] ?? '';
      } else {
        setState(() {
          _userName = FFAppState().firstname.isNotEmpty ? FFAppState().firstname : 'User';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        _userName = FFAppState().firstname.isNotEmpty ? FFAppState().firstname : 'User';
        _isLoadingUser = false;
      });
      print('Error loading current user: $e');
    }
  }

  Future<void> loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });

    try {
      final response = await ApiService.getAllProducts(page: 1, pageSize: 50);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] != null) {
          final List<ProductStruct> products = [];
          for (var e in data['products']) {
            try {
              final product = ProductStruct.fromMap(e);
              products.add(product);
            } catch (err) {
              print('Error mapping product: $err');
            }
          }
          
          setState(() {
            _allProducts = products;
            _justForYouProducts = _getRandomProducts(products, 4);
            final remainingProducts = products.where((p) => !_justForYouProducts.any((jp) => jp.productId == p.productId)).toList();
            _newArrivalProducts = _getRandomProducts(remainingProducts, 6);
            _isLoadingProducts = false;
          });
        } else {
          setState(() {
            _productsError = data['message'] ?? 'Không có dữ liệu sản phẩm';
            _isLoadingProducts = false;
          });
        }
      } else {
        setState(() {
          _productsError = 'Lỗi API: ${response.statusCode}';
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      print('ERROR in loadProducts: $e');
      setState(() {
        _productsError = 'Lỗi kết nối: $e';
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> loadFavoriteProducts() async {
    setState(() {
      _isLoadingFavorites = true;
      _favoritesError = null;
    });

    try {
      final favoriteIds = FFAppState().favoriteProductIds;
      if (favoriteIds.isEmpty) {
        setState(() {
          _favoriteProducts = [];
          _isLoadingFavorites = false;
        });
        return;
      }

      final response = await ApiService.getAllProducts(page: 1, pageSize: 100);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] != null) {
          final List<ProductStruct> allProducts = [];
          for (var e in data['products']) {
            try {
              final product = ProductStruct.fromMap(e);
              allProducts.add(product);
            } catch (err) {
              print('Error mapping product: $err');
            }
          }
          
          final favoriteProducts = allProducts
              .where((product) => favoriteIds.contains(product.productId))
              .toList();
          
          setState(() {
            _favoriteProducts = favoriteProducts;
            _isLoadingFavorites = false;
          });
        } else {
          setState(() {
            _favoritesError = data['message'] ?? 'Không có dữ liệu sản phẩm';
            _isLoadingFavorites = false;
          });
        }
      } else {
        setState(() {
          _favoritesError = 'Lỗi API: ${response.statusCode}';
          _isLoadingFavorites = false;
        });
      }
    } catch (e) {
      print('ERROR in loadFavoriteProducts: $e');
      setState(() {
        _favoritesError = 'Lỗi kết nối: $e';
        _isLoadingFavorites = false;
      });
    }
  }

  Future<void> loadCategories() async {
    setState(() {
      _isLoadingCategory = true;
      _categoryError = null;
    });
    try {
      final response = await ApiService.getAllCategory(page: 1, pageSize: 10);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['categories'] != null) {
          setState(() {
            _categories = List.from(data['categories']);
            FFAppState().categorylist = _categories
                .map((e) => CategoryStruct.fromMap(e as Map<String, dynamic>))
                .toList();
            print('API categories: $_categories');
            print('FFAppState categories: ${FFAppState().categorylist}');
            _isLoadingCategory = false;
          });
        } else {
          setState(() {
            _categoryError = data['message'] ?? 'Unknown error';
            _isLoadingCategory = false;
          });
        }
      } else {
        setState(() {
          _categoryError = 'Failed to load categories';
          _isLoadingCategory = false;
        });
      }
    } catch (e) {
      setState(() {
        _categoryError = e.toString();
        _isLoadingCategory = false;
      });
    }
  }

  Future<void> loadUserOrders() async {
    setState(() {
      _isLoadingOrders = true;
      _ordersError = null;
    });

    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        setState(() {
          _allOrders = [];
          _activeOrders = [];
          _completedOrders = [];
          _cancelledOrders = [];
          _isLoadingOrders = false;
        });
        return;
      }

      final response = await ApiService.getUserOrders(token: token, page: 1, pageSize: 100);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['orders'] != null) {
          final List<OrderStruct> orders = [];
          
          for (var orderData in data['orders']) {
            try {
              final order = OrderStruct.fromMap(orderData);
              orders.add(order);
            } catch (err) {
              print('Error mapping order: $err');
            }
          }
          
          setState(() {
            _allOrders = orders;
            _activeOrders = orders.where((order) => order.isActive).toList();
            _completedOrders = orders.where((order) => order.isCompleted).toList();
            _cancelledOrders = orders.where((order) => order.isCancelled).toList();
            _isLoadingOrders = false;
          });
          
          print('Loaded ${orders.length} orders: ${_activeOrders.length} active, ${_completedOrders.length} completed, ${_cancelledOrders.length} cancelled');
        } else {
          setState(() {
            _ordersError = data['message'] ?? 'No orders found';
            _isLoadingOrders = false;
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _allOrders = [];
          _activeOrders = [];
          _completedOrders = [];
          _cancelledOrders = [];
          _isLoadingOrders = false;
        });
      } else {
        setState(() {
          _ordersError = 'API Error: ${response.statusCode}';
          _isLoadingOrders = false;
        });
      }
    } catch (e) {
      print('ERROR in loadUserOrders: $e');
      setState(() {
        _ordersError = 'Connection Error: $e';
        _isLoadingOrders = false;
      });
    }
  }

  List<ProductStruct> _getRandomProducts(List<ProductStruct> products, int count) {
    if (products.isEmpty) return [];
    final random = Random();
    final shuffled = List<ProductStruct>.from(products);
    shuffled.shuffle(random);
    return shuffled.take(count).toList();
  }

  void onAppStateChange() {
    if (mounted) {
      // Check if general data refresh is needed
      if (FFAppState().needsDataRefresh) {
        print('🔄 DataLoaderMixin: General data refresh detected');
        loadCategories();
        loadProducts();
        loadFavoriteProducts();
        loadCurrentUser();
        loadUserOrders();
        FFAppState().clearDataRefreshFlag();
      }
      
      // Check if specific product refresh is needed
      if (FFAppState().needsProductRefresh) {
        print('🔄 DataLoaderMixin: Product refresh detected');
        loadProducts();
        loadFavoriteProducts();
        FFAppState().clearProductRefreshFlag();
      } else {
        // Default behavior for favorite changes
        loadFavoriteProducts();
        loadCurrentUser();
        loadUserOrders();
      }
    }
  }
} 