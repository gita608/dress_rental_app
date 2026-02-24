import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppProvider with ChangeNotifier {
  static const String _dressesKey = 'dresses';
  static const String _bookingsKey = 'bookings';

  static const String _themeModeKey = 'themeMode';

  final List<Dress> _dresses = [];
  final List<Booking> _bookings = [];
  ThemeMode _themeMode = ThemeMode.system;

  AppProvider() {
    _loadData();
  }

  List<Dress> get dresses => _dresses;
  List<Booking> get bookings => _bookings;
  ThemeMode get themeMode => _themeMode;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final dressesJson = prefs.getString(_dressesKey);
    if (dressesJson != null) {
      final List<dynamic> decoded = jsonDecode(dressesJson);
      _dresses.clear();
      _dresses.addAll(decoded.map((m) => Dress.fromMap(m)).toList());
    } else {
      // Default sample data if nothing is saved
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

    final themeModeIndex = prefs.getInt(_themeModeKey);
    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }

    notifyListeners();
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
  }

  void addDress(Dress dress) {
    _dresses.add(dress);
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
}
