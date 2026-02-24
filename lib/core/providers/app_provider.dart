import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppProvider with ChangeNotifier {
  static const String _dressesKey = 'dresses';
  static const String _bookingsKey = 'bookings';
  static const String _categoriesKey = 'categories';

  static const String _themeModeKey = 'themeMode';
  static const String _viewModeKey = 'viewMode';

  final List<Dress> _dresses = [];
  final List<Booking> _bookings = [];
  final List<Category> _categories = [];
  ThemeMode _themeMode = ThemeMode.system;
  ViewMode? _viewModeVal;

  AppProvider() {
    _loadData();
  }

  List<Dress> get dresses => _dresses;
  List<Booking> get bookings => _bookings;
  List<Category> get categories => _categories;
  ThemeMode get themeMode => _themeMode;
  ViewMode get viewMode => _viewModeVal ?? ViewMode.list;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

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
          price: 120.0,
          description: 'A stunning, floor-length gown featuring intricate lacework and a flowing silhouette.',
          sizes: ['S', 'M', 'L'],
        ),
        Dress(
          id: '2',
          name: 'Red Velvet Gown',
          price: 150.0,
          description: 'Luxurious red velvet with gold embroidery.',
          sizes: ['M', 'L'],
        ),
      ]);
    }

    final bookingsJson = prefs.getString(_bookingsKey);
    if (bookingsJson != null) {
      final List<dynamic> decoded = jsonDecode(bookingsJson);
      _bookings.clear();
      _bookings.addAll(decoded.map((m) => Booking.fromMap(m)).toList());
    }

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
  }

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

  void addBooking(Booking booking) {
    _bookings.add(booking);
    updateDressStatus(booking.dressId, DressStatus.rented);
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
