import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://www.offroad.ist/api';

  static Dio get _dio {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService.getToken();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ));
    return dio;
  }

  // Home
  static Future<Map<String, dynamic>> getHome() async {
    final res = await _dio.get('/home');
    return res.data;
  }

  // Products
  static Future<Map<String, dynamic>> getProducts({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    String sort = 'newest',
    int page = 1,
  }) async {
    final res = await _dio.get('/products', queryParameters: {
      if (category != null) 'category': category,
      if (brand != null) 'brand': brand,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      'sort': sort,
      'page': page,
    });
    return res.data;
  }

  static Future<Map<String, dynamic>> getProduct(String slug) async {
    final res = await _dio.get('/products/$slug');
    return res.data;
  }

  static Future<Map<String, dynamic>> searchProducts(String q, {int page = 1}) async {
    final res = await _dio.get('/products', queryParameters: {'search': q, 'page': page});
    return res.data;
  }

  static Future<Map<String, dynamic>> getProductReviews(String slug, {int page = 1}) async {
    final res = await _dio.get('/products/$slug/reviews', queryParameters: {'page': page});
    return res.data;
  }

  // Categories
  static Future<List<dynamic>> getCategories() async {
    final res = await _dio.get('/categories');
    return res.data['data'];
  }

  static Future<Map<String, dynamic>> getCategory(String slug) async {
    final res = await _dio.get('/categories/$slug');
    return res.data;
  }

  // Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/login', data: {'email': email, 'password': password});
    return res.data;
  }

  static Future<Map<String, dynamic>> register(String firstName, String lastName, String email, String password) async {
    final res = await _dio.post('/register', data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    return res.data;
  }

  static Future<void> logout() async {
    await _dio.post('/logout');
  }

  static Future<Map<String, dynamic>> getUser() async {
    final res = await _dio.get('/user');
    return res.data;
  }

  // Cart
  static Future<Map<String, dynamic>> getCart() async {
    final res = await _dio.get('/cart');
    return res.data;
  }

  static Future<void> addToCart(int productId, {int quantity = 1, int? variantId}) async {
    await _dio.post('/cart/add', data: {
      'product_id': productId,
      'quantity': quantity,
      if (variantId != null) 'variant_id': variantId,
    });
  }

  static Future<void> updateCart(int productId, int quantity) async {
    await _dio.put('/cart/update/$productId', data: {'quantity': quantity});
  }

  static Future<void> removeFromCart(int productId) async {
    await _dio.delete('/cart/remove/$productId');
  }

  static Future<void> clearCart() async {
    await _dio.post('/cart/clear');
  }

  // Checkout
  static Future<Map<String, dynamic>> getCheckout() async {
    final res = await _dio.get('/checkout');
    return res.data;
  }

  static Future<Map<String, dynamic>> processCheckout(Map<String, dynamic> data) async {
    final res = await _dio.post('/checkout/process', data: data);
    return res.data;
  }

  // Orders
  static Future<Map<String, dynamic>> getOrders({int page = 1}) async {
    final res = await _dio.get('/account/orders', queryParameters: {'page': page});
    return res.data;
  }

  static Future<Map<String, dynamic>> getOrderDetail(int id) async {
    final res = await _dio.get('/account/orders/$id');
    return res.data;
  }

  // Addresses
  static Future<List<dynamic>> getAddresses() async {
    final res = await _dio.get('/account/addresses');
    return res.data['data'];
  }

  static Future<void> storeAddress(Map<String, dynamic> data) async {
    await _dio.post('/account/addresses', data: data);
  }

  static Future<void> setDefaultAddress(int id) async {
    await _dio.patch('/account/addresses/$id/default');
  }

  static Future<void> deleteAddress(int id) async {
    await _dio.delete('/account/addresses/$id');
  }
}
