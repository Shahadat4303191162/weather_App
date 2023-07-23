import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/pages/settings_page.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/utils/constants.dart';
import 'package:weather_app/utils/helper_functions.dart';
import 'package:weather_app/utils/location_service.dart';
import 'package:weather_app/utils/text_style.dart';

class WeatherPage extends StatefulWidget {
  static String routeName = '/';

  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
 with WidgetsBindingObserver {
  late WeatherProvider
      provider; //weatherProvider er object nilam provider name e
  bool isFirst = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isFirst) {
      provider = Provider.of<WeatherProvider>(context);
      _detectLocation();
      isFirst = false;
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state) {
      case AppLifecycleState.resumed :
        _detectLocation();
        break;
      case AppLifecycleState.inactive:
      // Handle inactive state here
        break;
      case AppLifecycleState.paused:
      // Handle paused state here
        break;
      case AppLifecycleState.detached:
      // Handle detached state here
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Weather', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              _detectLocation();
            },
            icon: const Icon(Icons.my_location),
            color: Colors.white,
          ),
          IconButton(
            onPressed: () async {
              final result = await showSearch(
                  context: context, delegate: _CitySearchDelegate());
              if (result != null && result.isNotEmpty) {
                provider.convertCityToLatLng(
                    result: result,
                    onError: (msg) {
                      showMsg(context, msg);
                    });
              }
            },
            icon: const Icon(Icons.search_rounded),
            color: Colors.white,
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, SettingsPage.routeName),
            icon: const Icon(Icons.settings),
            color: Colors.white,
          ),
        ],
      ),
      body: Center(
        child: provider.hasDataLoaded
            ? ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                children: [
                  _currentWeatherSection(),
                  _forecastWeatherSection(),
                ],
              )
            :  Text('Please wait',style: txtNormal16,),
      ),
    );
  }

  void _detectLocation() async {
    final isLocationEnabled = await isLocationServiceEnabled;
    if (isLocationEnabled) {
      try {
        final position = await determinePosition();
        provider.setNewLocation(position.latitude, position.longitude);
        provider.setTempUnit(await provider.getTempUnitPreferenceValue());
        provider.getWeatherData();
      } catch (error) {
        showMsg(context, 'error');
      }
    } else{
      // ignore: use_build_context_synchronously
      showMsgWithAction(
          context: context,
          msg: 'Please turn on your Location',
          actionButtonTitle: 'Go to Settings',
          onPressedSettings: () async{
            await openLocationSettings;
          },
      );
    }
  }

  Widget _currentWeatherSection() {
    final current = provider.currentResponseModel;
    return Column(
      children: [
        Text(
          getFormattedDateTime(current!.dt!, 'MMM dd,yyyy'),
          style: txtDateBig18,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          '${current.name},${current.sys!.country}',
          style: txtAddress25,
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                '$iconPrefix${current.weather![0].icon}$iconSuffix',
                fit: BoxFit.cover,
              ),
              Text(
                '${current.main!.temp!.round()}$degree${provider.unitSymbol}',
                style: txtTempBig80,
              ),
            ],
          ),
        ),
        Text(
          'feels like ${current.main!.feelsLike}$degree${provider.unitSymbol}',
          style: txtNormal16,
        ),
        Text(
          '${current.weather![0].main} ${current.weather![0].description}',
          style: txtNormal16,
        ),
        const SizedBox(
          height: 5,
        ),
        Wrap(
          children: [
            Text(
              'Humidity ${current.main!.humidity}% ',
              style: txtNormal16,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              'pressure ${current.main!.pressure}hPa ',
              style: txtNormal16,
            ),
            Text(
              'Visibility ${current.visibility}m',
              style: txtNormal16,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              'Degree ${current.wind!.deg}$degree',
              style: txtNormal16,
            ),
            Text(
              'Wind Speed ${current.wind!.speed}m/s',
              style: txtNormal16,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Wrap(
          children: [
            Text(
              'Sunrise: ${getFormattedDateTime(current.sys!.sunrise!, 'hh:mm a')}',
              style: txtNormal16White54,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              'Sunset: ${getFormattedDateTime(current.sys!.sunset!, 'hh:mm a')}',
              style: txtNormal16White54,
            ),
          ],
        )
      ],
    );
  }

  Widget _forecastWeatherSection() {
    return Column();
  }
}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.search),
      title: Text(query),
      onTap: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty
        ? cities
        : cities
            .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(filteredList[index]),
        onTap: () {
          query = filteredList[index];
          close(context, query);
        },
      ),
    );
  }
}
