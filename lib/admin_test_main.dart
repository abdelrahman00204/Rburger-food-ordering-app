import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

// Standalone entry point: Run this file independently without touching main.dart using:
// flutter run -t lib/admin_test_main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const AdminTestApp());
}

class AdminTestApp extends StatelessWidget {
  const AdminTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Tool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const AdminStandaloneScreen(),
    );
  }
}

class AdminStandaloneScreen extends StatefulWidget {
  const AdminStandaloneScreen({super.key});

  @override
  State<AdminStandaloneScreen> createState() => _AdminStandaloneScreenState();
}

class _AdminStandaloneScreenState extends State<AdminStandaloneScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Driver controllers
  final _nameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _driverPasswordController = TextEditingController();
  final _branchIdController = TextEditingController();
  final _vehicleController =
      TextEditingController(); // Added vehicle controller

  // Menu Item controllers
  final _menuNameArController = TextEditingController();
  final _menuNameEnController = TextEditingController();
  final _menuDescArController = TextEditingController();
  final _menuDescEnController = TextEditingController();
  final _menuPriceController = TextEditingController();
  final _menuCategoryIdController = TextEditingController();

  bool _isAdminLoggedIn = false;
  bool _isLoading = false;
  String? _adminToken;

  int _selectedTab = 0; // 0: Drivers, 1: Menu Items, 2: View Orders
  List<dynamic> _fetchedOrders = [];

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.get('API_URL'),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<void> _loginAdmin() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.post(
        '/v1/auth/admin/login',
        data: {
          'username': _phoneController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      setState(() {
        _adminToken = data['accessToken'];
        _isAdminLoggedIn = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin Login Failed. Check credentials.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createDriver() async {
    setState(() => _isLoading = true);
    try {
      await _dio.post(
        '/v1/admin/drivers',
        data: {
          'fullName': _nameController.text.trim(),
          'phone': _driverPhoneController.text.trim(),
          'password': _driverPasswordController.text.trim(),
          'vehicle': _vehicleController.text.trim(),
          'branchId': int.parse(_branchIdController.text.trim()),
        },
        options: Options(headers: {'Authorization': 'Bearer $_adminToken'}),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver Added Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _nameController.clear();
      _driverPhoneController.clear();
      _driverPasswordController.clear();
      _branchIdController.clear();
      _vehicleController.clear();
    } catch (e) {
      if (e is DioException) {
        debugPrint('❌ Dio Error Status: ${e.response?.statusCode}');
        debugPrint('❌ Dio Error Data: ${e.response?.data}');
        debugPrint('❌ Dio Error Headers: ${e.response?.headers}');
      } else {
        debugPrint('❌ General Error: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add driver.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createMenuItem() async {
    setState(() => _isLoading = true);
    try {
      await _dio.post(
        '/v1/admin/menu-items',
        data: {
          'name': {
            'ar': _menuNameArController.text.trim(),
            'en': _menuNameEnController.text.trim(),
          },
          'description': {
            'ar': _menuDescArController.text.trim(),
            'en': _menuDescEnController.text.trim(),
          },
          'price': double.parse(_menuPriceController.text.trim()),
          'categoryId': int.parse(_menuCategoryIdController.text.trim()),
        },
        options: Options(headers: {'Authorization': 'Bearer $_adminToken'}),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menu Item Added Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _menuNameArController.clear();
      _menuNameEnController.clear();
      _menuDescArController.clear();
      _menuDescEnController.clear();
      _menuPriceController.clear();
      _menuCategoryIdController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add menu item.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get(
        '/v1/admin/orders',
        options: Options(headers: {'Authorization': 'Bearer $_adminToken'}),
      );
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      setState(() {
        _fetchedOrders = data['items'] ?? data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load orders.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Standalone Tool'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : !_isAdminLoggedIn
            ? ListView(
                children: [
                  const Text(
                    'Admin Login',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Admin Phone'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loginAdmin,
                    child: const Text('Login as Admin'),
                  ),
                ],
              )
            : Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ChoiceChip(
                          label: const Text('Add Driver'),
                          selected: _selectedTab == 0,
                          onSelected: (val) => setState(() => _selectedTab = 0),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Add Menu Item'),
                          selected: _selectedTab == 1,
                          onSelected: (val) => setState(() => _selectedTab = 1),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('View Orders'),
                          selected: _selectedTab == 2,
                          onSelected: (val) {
                            setState(() => _selectedTab = 2);
                            _fetchOrders();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                  Expanded(
                    child: _selectedTab == 0
                        ? ListView(
                            children: [
                              const Text(
                                'Add New Driver',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Driver Full Name',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _driverPhoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Driver Phone',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _driverPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Driver Password',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _branchIdController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Branch ID (Number)',
                                ),
                              ),
                              const SizedBox(height: 24),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _vehicleController,
                                decoration: const InputDecoration(
                                  labelText: 'Vehicle (e.g., Motorcycle / Car)',
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _createDriver,
                                child: const Text('Submit Driver'),
                              ),
                            ],
                          )
                        : _selectedTab == 1
                        ? ListView(
                            children: [
                              const Text(
                                'Add New Menu Item',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _menuNameArController,
                                decoration: const InputDecoration(
                                  labelText: 'Name (Arabic)',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _menuNameEnController,
                                decoration: const InputDecoration(
                                  labelText: 'Name (English)',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _menuDescArController,
                                decoration: const InputDecoration(
                                  labelText: 'Description (Arabic)',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _menuDescEnController,
                                decoration: const InputDecoration(
                                  labelText: 'Description (English)',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _menuPriceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _menuCategoryIdController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Category ID',
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _createMenuItem,
                                child: const Text('Submit Menu Item'),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'System Orders',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: _fetchOrders,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _fetchedOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = _fetchedOrders[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        title: Text(
                                          'Order #${order['orderNumber'] ?? order['id']}',
                                        ),
                                        subtitle: Text(
                                          'Total: ${order['total']} EGP\nStage: ${order['stage']}',
                                        ),
                                        trailing: Text(
                                          order['branchNameAr'] ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
