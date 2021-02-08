import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(Weather());
}

class Weather extends StatefulWidget {
  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  int temperature;
  String location = "Mumbai";
  int woeid = 12586539;
  String weather = 'clear';
  String abbreviation = '';
  String errorMessage = '';

  String locationDetails;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;

  var minTemperatureForecast = new List(7);
  var maxTemperatureForecast = new List(7);
  var abbreviationForecast = new List(7);

  //searchLocation
  String searchApiUrl =
      "https://www.metaweather.com/api/location/search/?query=";
  //searchWeatherByLocationId(woeid)
  String locationApiUrl = "https://www.metaweather.com/api/location/";

  void fetchSearch(String input) async {
    try {
      var searchResult = await http.get(searchApiUrl + input);
      var result = json.decode(searchResult.body)[0];
      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage = '';
      });
    } catch (error) {
      errorMessage =
          "Sorry, We Don't Have Data About This City Or Check The City Name";
    }
  }

  void fetchLocation() async {
    var locationResult = await http.get(locationApiUrl + woeid.toString());
    var result = json.decode(locationResult.body);
    var consolidatedWeather = result["consolidated_weather"];
    var data = consolidatedWeather[0];
    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });
  }

  void fetchLocationDay() async {
    var today = new DateTime.now();
    for (var i = 0; i < 7; i++) {
      var locationDayResult = await http.get(locationApiUrl +
          woeid.toString() +
          '/' +
          new DateFormat('y/M/d')
              .format(today.add(new Duration(days: i + 1)))
              .toString());
      var result = json.decode(locationDayResult.body);
      var data = result[0];
      setState(() {
        minTemperatureForecast[i] = data["min_temp"].round();
        maxTemperatureForecast[i] = data["max_temp"].round();
        abbreviationForecast[i] = data["weather_state_abbr"];
      });
    }
  }

  void onTextFieldSubmitted(String input) async {
    setState(() {
      temperature = null;
    });
    fetchSearch(input);
    fetchLocation();
    fetchLocationDay();
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
      onTextFieldSubmitted(place.locality);
      locationDetails = "Location is " +
          place.locality +
          ", PostalCode is " +
          place.postalCode +
          " Country is " +
          place.country;
      print(place.locality);
      print(place.postalCode);
      print(place.country);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLocation();
    fetchLocationDay();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/$weather.png'),
            fit: BoxFit.cover,
            // colorFilter: ColorFilter.mode(
            //     Colors.black.withOpacity(0.6), BlendMode.dstATop),
          ),
        ),
        child: temperature == null
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          _getCurrentLocation();
                        },
                        child: Icon(
                          Icons.location_city,
                          size: 35.0,
                        ),
                      ),
                    )
                  ],
                ),
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Image.network(
                              'http://www.metaweather.com/static/img/weather/png/$abbreviation.png',
                              width: 100),
                          Text(
                            temperature.toString() + ' °C',
                            style:
                                TextStyle(color: Colors.white, fontSize: 50.0),
                          ),
                          Text(
                            location.toUpperCase(),
                            style:
                                TextStyle(color: Colors.white, fontSize: 50.0),
                          )
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        for (var i = 0; i < 7; i++)
                          forecastElement(
                              i + 1,
                              abbreviationForecast[i],
                              maxTemperatureForecast[i],
                              minTemperatureForecast[i])
                      ]),
                    ),
                    Column(
                      children: [
                        Container(
                          width: 300,
                          child: TextField(
                            onSubmitted: (String input) {
                              onTextFieldSubmitted(input);
                            },
                            cursorColor: Colors.white,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                            decoration: InputDecoration(
                              hintText: "Search Another Location",
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 20),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 300,
                          child: Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}

Widget forecastElement(
    dateFromNow, abbrevation, maxTemperatureForecast, minTemperatureForecast) {
  var now = new DateTime.now();
  var oneDayFromNow = now.add(new Duration(days: dateFromNow));

  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(205, 212, 228, 0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              new DateFormat.E().format(oneDayFromNow),
              style: TextStyle(color: Colors.white, fontSize: 25.0),
            ),
            Text(
              new DateFormat.MMMd().format(oneDayFromNow),
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            Image.network(
                'http://www.metaweather.com/static/img/weather/png/$abbrevation.png',
                width: 50),
            Text(
              'HIGH:' + maxTemperatureForecast.toString() + ' ' '°C',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            Text(
              'LOW:' + minTemperatureForecast.toString() + ' ' '°C',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ],
        ),
      ),
    ),
  );
}
