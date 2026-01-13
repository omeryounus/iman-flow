import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/service_locator.dart';

/// Settings Screen - Theme, Location, Timezone options
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = getIt<SettingsService>();
  bool _isUpdatingLocation = false;

  // Common timezones
  final List<String> _timezones = [
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'America/Vancouver',
    'Europe/London',
    'Europe/Paris',
    'Europe/Istanbul',
    'Asia/Dubai',
    'Asia/Karachi',
    'Asia/Kolkata',
    'Asia/Dhaka',
    'Asia/Jakarta',
    'Asia/Kuala_Lumpur',
    'Asia/Singapore',
    'Asia/Tokyo',
    'Asia/Riyadh',
    'Africa/Cairo',
    'Australia/Sydney',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: StreamBuilder<UserSettings>(
        stream: _settingsService.settingsStream,
        initialData: _settingsService.settings,
        builder: (context, snapshot) {
          final settings = snapshot.data ?? const UserSettings();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Section
              _buildSectionHeader('Appearance'),
              _buildThemeSelector(settings),
              const SizedBox(height: 24),

              // Location Section
              _buildSectionHeader('Location'),
              _buildLocationSettings(settings),
              const SizedBox(height: 24),

              // Timezone Section
              _buildSectionHeader('Timezone'),
              _buildTimezoneSettings(settings),
              const SizedBox(height: 24),

              // Current Location Info
              if (settings.latitude != null) _buildLocationInfo(settings),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: ImanFlowTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(UserSettings settings) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildThemeOption(
            'System Default',
            'Follow device settings',
            Icons.settings_suggest,
            AppThemeMode.system,
            settings.themeMode,
          ),
          const Divider(height: 1),
          _buildThemeOption(
            'Light Mode',
            'Always use light theme',
            Icons.light_mode,
            AppThemeMode.light,
            settings.themeMode,
          ),
          const Divider(height: 1),
          _buildThemeOption(
            'Dark Mode',
            'Always use dark theme',
            Icons.dark_mode,
            AppThemeMode.dark,
            settings.themeMode,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String title,
    String subtitle,
    IconData icon,
    AppThemeMode mode,
    AppThemeMode currentMode,
  ) {
    final isSelected = mode == currentMode;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? ImanFlowTheme.primaryGreen.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? ImanFlowTheme.primaryGreen : Colors.grey,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: ImanFlowTheme.primaryGreen)
          : null,
      onTap: () => _settingsService.setThemeMode(mode),
    );
  }

  Widget _buildLocationSettings(UserSettings settings) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Automatic Location'),
            subtitle: const Text('Use GPS for accurate prayer times'),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ImanFlowTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.gps_fixed, color: ImanFlowTheme.primaryGreen),
            ),
            value: settings.locationMode == LocationMode.automatic,
            activeColor: ImanFlowTheme.primaryGreen,
            onChanged: (value) {
              _settingsService.setLocationMode(
                value ? LocationMode.automatic : LocationMode.manual,
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ImanFlowTheme.accentTurquoise.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.refresh, color: ImanFlowTheme.accentTurquoise),
            ),
            title: const Text('Update Location Now'),
            subtitle: Text(
              _isUpdatingLocation ? 'Updating...' : 'Tap to refresh your location',
            ),
            trailing: _isUpdatingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _isUpdatingLocation ? null : _updateLocation,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ImanFlowTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_location, color: ImanFlowTheme.accentGold),
            ),
            title: const Text('Set Manual Location'),
            subtitle: const Text('Enter coordinates manually'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showManualLocationDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimezoneSettings(UserSettings settings) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Automatic Timezone'),
            subtitle: const Text('Use device timezone'),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ImanFlowTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.schedule, color: ImanFlowTheme.primaryGreen),
            ),
            value: settings.autoTimezone,
            activeColor: ImanFlowTheme.primaryGreen,
            onChanged: (value) {
              if (value) {
                _settingsService.setTimezone(
                  DateTime.now().timeZoneName,
                  auto: true,
                );
              }
            },
          ),
          if (!settings.autoTimezone) ...[
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ImanFlowTheme.accentTurquoise.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.public, color: ImanFlowTheme.accentTurquoise),
              ),
              title: const Text('Select Timezone'),
              subtitle: Text(settings.timezone ?? 'Not set'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTimezoneSelector(settings),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationInfo(UserSettings settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ImanFlowTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ImanFlowTheme.primaryGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: ImanFlowTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Current Location',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('City: ${settings.cityName ?? "Unknown"}'),
          const SizedBox(height: 4),
          Text(
            'Coordinates: ${settings.latitude?.toStringAsFixed(4)}, ${settings.longitude?.toStringAsFixed(4)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _updateLocation() async {
    setState(() => _isUpdatingLocation = true);

    final success = await _settingsService.updateLocationAutomatically();

    setState(() => _isUpdatingLocation = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Location updated successfully!'
              : 'Failed to update location. Please check permissions.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showManualLocationDialog() {
    final latController = TextEditingController(
      text: _settingsService.settings.latitude?.toString() ?? '',
    );
    final lngController = TextEditingController(
      text: _settingsService.settings.longitude?.toString() ?? '',
    );
    final cityController = TextEditingController(
      text: _settingsService.settings.cityName ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Manual Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'City Name',
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: latController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(
                labelText: 'Latitude',
                prefixIcon: Icon(Icons.north),
                hintText: 'e.g. 40.7128',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lngController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(
                labelText: 'Longitude',
                prefixIcon: Icon(Icons.east),
                hintText: 'e.g. -74.0060',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(latController.text);
              final lng = double.tryParse(lngController.text);
              final city = cityController.text.trim();

              if (lat != null && lng != null && city.isNotEmpty) {
                _settingsService.setManualLocation(lat, lng, city);
                _settingsService.setLocationMode(LocationMode.manual);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Location saved!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTimezoneSelector(UserSettings settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Timezone',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _timezones.length,
                itemBuilder: (context, index) {
                  final tz = _timezones[index];
                  final isSelected = tz == settings.timezone;

                  return ListTile(
                    title: Text(tz.replaceAll('_', ' ')),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: ImanFlowTheme.primaryGreen)
                        : null,
                    onTap: () {
                      _settingsService.setTimezone(tz, auto: false);
                      Navigator.pop(context);
                    },
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
