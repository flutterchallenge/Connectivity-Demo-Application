import 'dart:io';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _connectionStatus = 'Unknown';
  Map _wifiInfo = {'name':'N/A','bssid':'N/A','ip':'N/A'};

  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;


  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  String connectionInfo(String connectivityResult){
    String connectionStatus = '';
    if(connectivityResult == 'ConnectivityResult.mobile'){
      connectionStatus = 'Data';
    }else if(connectivityResult == 'ConnectivityResult.wifi'){
      connectionStatus = 'WIFI';
    }else{
      connectionStatus = 'No Internet';
    }
    return connectionStatus;
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;
        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
            await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
              await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiName = await _connectivity.getWifiName();
            } else {
              wifiName = await _connectivity.getWifiName();
            }
          } else {
            wifiName = await _connectivity.getWifiName();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
            await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
              await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiBSSID = await _connectivity.getWifiBSSID();
            } else {
              wifiBSSID = await _connectivity.getWifiBSSID();
            }
          } else {
            wifiBSSID = await _connectivity.getWifiBSSID();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _wifiInfo['name'] = wifiName??"N/A";
          _wifiInfo['bssid'] = wifiBSSID;
          _wifiInfo['ip'] = wifiIP;
          _connectionStatus = connectionInfo(result.toString());
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = connectionInfo(result.toString()));
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connectivity Demo"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Text(
              'Welcome to flutterchallenge.com',
              style: TextStyle(
                  fontSize: 18.0
              ),
            ),
            Divider(
                color: Colors.black
            ),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(_connectionStatus == 'No Internet' ?
                    Icons.signal_wifi_off : ( _connectionStatus == 'WIFI' ? Icons.wifi : Icons.network_cell )
                        , size: 50),
                    title: Text('$_connectionStatus'),
                    subtitle: Text('Your current network information'),
                  ),
                ],
              ),
            ),
            // WIFI Information
            _connectionStatus == 'WIFI' ?  Container(
              child: Column(
                children: <Widget>[
                  Divider(
                      color: Colors.black
                  ),
                  Text(
                      "WIFI Information",
                      style: TextStyle(
                          fontSize: 18.0
                      )
                  ),
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.info, size: 25),
                          title: Text(_wifiInfo['name'].toString()),
                          subtitle: Text("WIFI Name"),
                        ),
                      ],
                    ),
                  ),Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.info, size: 25),
                          title: Text(_wifiInfo['ip'].toString()),
                          subtitle: Text('IP Address'),
                        ),
                      ],
                    ),
                  ),Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.info, size: 25),
                          title: Text(_wifiInfo['bssid'].toString()),
                          subtitle: Text('BSSID'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ): Container(),
          ],
        ),
      ),
    );
  }
}
