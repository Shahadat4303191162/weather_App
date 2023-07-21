import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/utils/location_service.dart';

class WeatherPage extends StatefulWidget {
  static String routeName = '/';
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late WeatherProvider provider; //weatherProvider er object nilam provider name e
  bool isFirst = true;

  @override
  void didChangeDependencies() {
    if(isFirst){
      provider = Provider.of<WeatherProvider>(context);
      _detectLocation();
      isFirst = false;
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Weather'),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.my_location)
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded)
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings)
          ),
        ],
      ),
      body: Center(
        child: provider.hasDataLoaded ? ListView() :
        const Text('Please wait'),
      ),
    );
  }

  void _detectLocation() {
    determinePosition().then((position) {
      provider.setNewLocation(position.latitude, position.longitude);
      provider.getWeatherData();
    });
  }
}
