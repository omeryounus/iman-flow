import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// App theme mode
enum AppThemeMode {
  system,
  light,
  dark,
}

/// Location mode
enum LocationMode {
  automatic,
  manual,
}

/// User settings data
class UserSettings {
  final AppThemeMode themeMode;
  final LocationMode locationMode;
  final double? latitude;
  final double? longitude;
  final String? cityName;
  final String? timezone;
  final bool autoTimezone;

  const UserSettings({
    this.themeMode = AppThemeMode.system,
    this.locationMode = LocationMode.automatic,
    this.latitude,
    this.longitude,
    this.cityName,
    this.timezone,
    this.autoTimezone = true,
  });

  UserSettings copyWith({
    AppThemeMode? themeMode,
    LocationMode? locationMode,
    double? latitude,
    double? longitude,
    String? cityName,
    String? timezone,
    bool? autoTimezone,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      locationMode: locationMode ?? this.locationMode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      timezone: timezone ?? this.timezone,
      autoTimezone: autoTimezone ?? this.autoTimezone,
    );
  }
}

/// Settings Service - Manages user preferences
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;
  
  final _settingsController = StreamController<UserSettings>.broadcast();
  Stream<UserSettings> get settingsStream => _settingsController.stream;
  
  UserSettings _settings = const UserSettings();
  UserSettings get settings => _settings;

  /// Initialize settings from storage
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (_prefs == null) return;

    final themeModeIndex = _prefs!.getInt('themeMode') ?? 0;
    final locationModeIndex = _prefs!.getInt('locationMode') ?? 0;
    
    _settings = UserSettings(
      themeMode: AppThemeMode.values[themeModeIndex],
      locationMode: LocationMode.values[locationModeIndex],
      latitude: _prefs!.getDouble('latitude'),
      longitude: _prefs!.getDouble('longitude'),
      cityName: _prefs!.getString('cityName'),
      timezone: _prefs!.getString('timezone'),
      autoTimezone: _prefs!.getBool('autoTimezone') ?? true,
    );

    _settingsController.add(_settings);
  }

  /// Update theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _prefs?.setInt('themeMode', mode.index);
    _settingsController.add(_settings);
  }

  /// Update location mode
  Future<void> setLocationMode(LocationMode mode) async {
    _settings = _settings.copyWith(locationMode: mode);
    await _prefs?.setInt('locationMode', mode.index);
    _settingsController.add(_settings);
    
    if (mode == LocationMode.automatic) {
      await updateLocationAutomatically();
    }
  }

  /// Set manual location
  Future<void> setManualLocation(double lat, double lng, String city) async {
    _settings = _settings.copyWith(
      latitude: lat,
      longitude: lng,
      cityName: city,
    );
    await _prefs?.setDouble('latitude', lat);
    await _prefs?.setDouble('longitude', lng);
    await _prefs?.setString('cityName', city);
    _settingsController.add(_settings);
  }

  /// Update location automatically
  Future<bool> updateLocationAutomatically() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Get city name
      String cityName = 'Unknown';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          cityName = place.locality ?? place.subAdministrativeArea ?? 'Unknown';
        }
      } catch (_) {}

      _settings = _settings.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
      );
      
      await _prefs?.setDouble('latitude', position.latitude);
      await _prefs?.setDouble('longitude', position.longitude);
      await _prefs?.setString('cityName', cityName);
      _settingsController.add(_settings);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Set timezone
  Future<void> setTimezone(String timezone, {bool auto = false}) async {
    _settings = _settings.copyWith(timezone: timezone, autoTimezone: auto);
    await _prefs?.setString('timezone', timezone);
    await _prefs?.setBool('autoTimezone', auto);
    _settingsController.add(_settings);
  }

  /// Get ThemeMode for MaterialApp
  ThemeMode getThemeMode() {
    switch (_settings.themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  void dispose() {
    _settingsController.close();
  }
}
