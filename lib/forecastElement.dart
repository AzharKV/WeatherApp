
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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