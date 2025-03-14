import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class PrayerTimesWidget extends StatefulWidget {
  final String? locationName; // Optional: If null, fetch from GPS
  final Madhab madhab; // Either Hanafi or Shafi

  const PrayerTimesWidget({super.key, this.locationName, required this.madhab});

  @override
  _PrayerTimesWidgetState createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<PrayerTimesWidget> {
  String _displayLocation = "Fetching location...";
  PrayerTimes? _prayerTimes;

  @override
  void initState() {
    super.initState();
    _getPrayerTimes();
  }

  Future<void> _getPrayerTimes() async {
    try {
      double latitude, longitude;

      if (widget.locationName != null) {
        // Convert location name to coordinates
        List<Location> locations = await locationFromAddress(
          widget.locationName!,
        );
        if (locations.isEmpty) {
          setState(() => _displayLocation = "Location not found");
          return;
        }
        latitude = locations.first.latitude;
        longitude = locations.first.longitude;
        setState(() => _displayLocation = widget.locationName!);
      } else {
        // Get current GPS location
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        latitude = position.latitude;
        longitude = position.longitude;

        // Get location name from coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude,
        );
        setState(
          () =>
              _displayLocation =
                  "${placemarks.first.locality}, ${placemarks.first.country}",
        );
      }

      // Calculate prayer times
      final myCoordinates = Coordinates(latitude, longitude);
      final params = CalculationMethod.karachi.getParameters();
      params.madhab = widget.madhab;

      setState(() {
        _prayerTimes = PrayerTimes.today(myCoordinates, params);
      });
    } catch (e) {
      setState(() => _displayLocation = "Error fetching location");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _prayerTimes == null
        ? const Center(child: CircularProgressIndicator())
        : Card(
          elevation: 5,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Location: $_displayLocation",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                _buildPrayerTime("Fajr", _prayerTimes!.fajr),
                _buildPrayerTime("Sunrise", _prayerTimes!.sunrise),
                _buildPrayerTime("Dhuhr", _prayerTimes!.dhuhr),
                _buildPrayerTime("Asr", _prayerTimes!.asr),
                _buildPrayerTime("Maghrib", _prayerTimes!.maghrib),
                _buildPrayerTime("Isha", _prayerTimes!.isha),
              ],
            ),
          ),
        );
  }

  Widget _buildPrayerTime(String name, DateTime time) {
    return Text(
      "$name: ${DateFormat.jm().format(time)}",
      style: const TextStyle(fontSize: 16),
    );
  }
}
