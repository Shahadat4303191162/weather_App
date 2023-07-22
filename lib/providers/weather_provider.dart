import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/current_response_model.dart';
import 'package:weather_app/models/forecast_response_model.dart';
import 'package:weather_app/utils/constants.dart';

class WeatherProvider extends ChangeNotifier{
  CurrentResponseModel? currentResponseModel;
  ForecastResponseModel? forecastResponseModel;

  double latitude = 0.0, longitude = 0.0;
  String unit =metric; //imperial
  String unitSymbol = celsius;

  bool get isFahrenheit => unit == imperial;

  bool get hasDataLoaded => currentResponseModel != null &&
      forecastResponseModel != null;

  setNewLocation(double lat,double lng){
    latitude = lat;
    longitude = lng;
  }

  Future<bool> setTempUnitPreferenceValue(bool value) async{
    final pref = await SharedPreferences.getInstance();
    return pref.setBool('unit', value);
  }

  Future<bool> getTempUnitPreferenceValue() async{
    final pref = await SharedPreferences.getInstance();
    return pref.getBool('unit') ?? false;
  }

  getWeatherData(){
    _getCurrentData();
    _getForecastData();

  }

  void _getCurrentData() async{
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$unit&appid=$weatherApiKey');
    try{
      final response = await get(uri);
      final map = jsonDecode(response.body) ;
      if(response.statusCode == 200){
        currentResponseModel = CurrentResponseModel.fromJson(map);
        print(currentResponseModel!.main!.temp!.round());
        notifyListeners();
      } else{
        print(map['message']);
      }
    }catch(error){
      rethrow;
    }

  }

  void _getForecastData() async {
    final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$unit&appid=$weatherApiKey');
    try {
      final response = await get(uri);
      final map = jsonDecode(response.body);
      if (response.statusCode == 200) {
        forecastResponseModel = ForecastResponseModel.fromJson(map);
        print(forecastResponseModel!.list!.length);
        notifyListeners();
      } else {
        print(map['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  void setTempUnit(bool value) {
    unit = value ? imperial : metric;
    unitSymbol = value ? fahrenheit : celsius;
    notifyListeners();
  }
}