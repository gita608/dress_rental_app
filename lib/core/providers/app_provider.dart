import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppProvider with ChangeNotifier {
  static const String _dressesKey = 'dresses';
  static const String _bookingsKey = 'bookings';
  static const String _categoriesKey = 'categories';
  static const String _userKey = 'currentUser';

  static const String _themeModeKey = 'themeMode';
  static const String _viewModeKey = 'viewMode';

  final List<Dress> _dresses = [];
  final List<Booking> _bookings = [];
  final List<Category> _categories = [];
  User? _currentUser;
  
  ThemeMode _themeMode = ThemeMode.system;
  ViewMode? _viewModeVal;

  AppProvider() {
    _loadData();
  }

  // Getters
  List<Dress> get dresses => _dresses;
  List<Booking> get bookings => _bookings;
  List<Category> get categories => _categories;
  User? get currentUser => _currentUser;
  ThemeMode get themeMode => _themeMode;
  ViewMode get viewMode => _viewModeVal ?? ViewMode.list;

  // Dashboard Stats
  int get totalDresses => _dresses.length;
  int get availableDresses => _dresses.where((d) => d.status == DressStatus.available && d.stock > 0).length;
  int get outOfStockDresses => _dresses.where((d) => d.stock == 0).length;
  int get pendingBookings => _bookings.where((b) => b.status == BookingStatus.pending).length;
  double get totalRevenue => _bookings.length * 1500.0; // Mock revenue

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load User
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _currentUser = User.fromMap(jsonDecode(userJson));
    } else {
      _currentUser = User(email: 'admin@evoca.com', name: 'Evoca Admin');
    }

    // Load Categories
    final categoriesJson = prefs.getString(_categoriesKey);
    if (categoriesJson != null) {
      final List<dynamic> decoded = jsonDecode(categoriesJson);
      _categories.clear();
      _categories.addAll(decoded.map((m) => Category.fromMap(m)).toList());
    } else {
      _categories.addAll([
        Category(id: '1', title: 'Wedding', description: 'Bridal and bridesmaid dresses'),
        Category(id: '2', title: 'Party', description: 'Cocktail and evening wear'),
        Category(id: '3', title: 'Formal', description: 'Gowns for gala and formal events'),
      ]);
    }

    // Load Dresses
    final dressesJson = prefs.getString(_dressesKey);
    if (dressesJson != null) {
      final List<dynamic> decoded = jsonDecode(dressesJson);
      _dresses.clear();
      _dresses.addAll(decoded.map((m) => Dress.fromMap(m)).toList());
    } else {
      _dresses.addAll([
        Dress(
          id: '1',
          name: 'Elegant Evening Dress',
          price: 1200.0,
          description: 'A stunning, floor-length gown featuring intricate lacework and a flowing silhouette.',
          sizes: ['S', 'M', 'L'],
          stock: 5,
          categoryId: '2',
        ),
        Dress(
          id: '2',
          name: 'Red Velvet Gown',
          price: 1500.0,
          description: 'Luxurious red velvet with gold embroidery.',
          sizes: ['M', 'L'],
          stock: 3,
          categoryId: '3',
        ),
        Dress(
          id: '3',
          name: 'Royal Bridal Lehenga',
          price: 5000.0,
          description: 'Traditional handcrafted bridal wear with heavy zari work.',
          sizes: ['M', 'L', 'XL'],
          stock: 2,
          categoryId: '1',
        ),
      ]);
    }

    // Load Bookings
    final bookingsJson = prefs.getString(_bookingsKey);
    if (bookingsJson != null) {
      final List<dynamic> decoded = jsonDecode(bookingsJson);
      _bookings.clear();
      _bookings.addAll(decoded.map((m) => Booking.fromMap(m)).toList());
    } else {
      // Add static bookings for testing
      _bookings.addAll([
        Booking(
          id: 'b1',
          dressId: '1',
          clientName: 'Sarah Johnson',
          clientPhone: '9876543210',
          startDate: DateTime.now().add(const Duration(days: 2)),
          endDate: DateTime.now().add(const Duration(days: 5)),
          measurements: {'Bust': 34, 'Waist': 28, 'Hips': 36},
          status: BookingStatus.pending,
        ),
        Booking(
          id: 'b2',
          dressId: '2',
          clientName: 'Emily Davis',
          clientPhone: '9123456780',
          startDate: DateTime.now().subtract(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 2)),
          measurements: {'Bust': 36, 'Waist': 30, 'Hips': 40},
          status: BookingStatus.active,
        ),
      ]);
    }

    final themeModeIndex = prefs.getInt(_themeModeKey);
    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }

    final viewModeIndex = prefs.getInt(_viewModeKey);
    if (viewModeIndex != null) {
      _viewModeVal = ViewMode.values[viewModeIndex];
    }

    notifyListeners();
  }

  // Auth Methods (Mocking API)
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1200)); // Simulate API delay
    _currentUser = User(email: email, name: email.split('@')[0].toUpperCase());
    await _saveData();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    notifyListeners();
  }

  Future<void> updateProfile(User user) async {
    await Future.delayed(const Duration(milliseconds: 800)); // API delay
    _currentUser = user;
    await _saveData();
    notifyListeners();
  }

  // Settings Methods
  Future<void> setViewMode(ViewMode mode) async {
    _viewModeVal = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_viewModeKey, mode.index);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dressesKey, jsonEncode(_dresses.map((d) => d.toMap()).toList()));
    await prefs.setString(_bookingsKey, jsonEncode(_bookings.map((b) => b.toMap()).toList()));
    await prefs.setString(_categoriesKey, jsonEncode(_categories.map((c) => c.toMap()).toList()));
    if (_currentUser != null) {
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toMap()));
    }
  }

  // Dress Methods
  void addDress(Dress dress) {
    _dresses.add(dress);
    _saveData();
    notifyListeners();
  }

  void updateDress(Dress dress) {
    final index = _dresses.indexWhere((d) => d.id == dress.id);
    if (index != -1) {
      _dresses[index] = dress;
      _saveData();
      notifyListeners();
    }
  }

  void refillStock(String dressId, int amount) {
    final index = _dresses.indexWhere((d) => d.id == dressId);
    if (index != -1) {
      _dresses[index].stock += amount;
      if (_dresses[index].stock > 0 && (_dresses[index].status == DressStatus.outOfStock || _dresses[index].status == DressStatus.rented)) {
        _dresses[index].status = DressStatus.available;
      }
      _saveData();
      notifyListeners();
    }
  }

  void deleteDress(String id) {
    _dresses.removeWhere((d) => d.id == id);
    _saveData();
    notifyListeners();
  }

  void updateDressStatus(String id, DressStatus status) {
    final index = _dresses.indexWhere((d) => d.id == id);
    if (index != -1) {
      _dresses[index].status = status;
      _saveData();
      notifyListeners();
    }
  }

  // Booking Methods
  void addBooking(Booking booking) {
    _bookings.add(booking);
    
    // Manage stock
    final dressIndex = _dresses.indexWhere((d) => d.id == booking.dressId);
    if (dressIndex != -1) {
      if (_dresses[dressIndex].stock > 0) {
        _dresses[dressIndex].stock -= 1;
        if (_dresses[dressIndex].stock == 0) {
          _dresses[dressIndex].status = DressStatus.outOfStock;
        }
      }
    }

    _saveData();
    notifyListeners();
  }

  void updateBookingStatus(String id, BookingStatus status) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings[index].status = status;
      _saveData();
      notifyListeners();
    }
  }

  // Category Methods
  void addCategory(Category category) {
    _categories.add(category);
    _saveData();
    notifyListeners();
  }

  void updateCategory(Category category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      _saveData();
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    _saveData();
    notifyListeners();
  }
}
