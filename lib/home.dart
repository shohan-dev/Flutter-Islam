import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:islam/prayerTime.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times App')),
      body: Column(
        children: [
          PrayerTimesWidget(madhab: Madhab.hanafi), // GPS-based
          PrayerTimesWidget(
            locationName: "Mecca, Saudi Arabia",
            madhab: Madhab.shafi,
          ),
          PrayerTimesWidget(
            locationName: "New York, USA",
            madhab: Madhab.hanafi,
          ),
        ],
      ),
    );
  }
}
