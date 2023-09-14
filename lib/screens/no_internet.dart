import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:nid/screens/about.dart';
import 'package:nid/screens/browser.dart';

class NoInternetConnection extends StatefulWidget {
  const NoInternetConnection({super.key});

  @override
  State<NoInternetConnection> createState() => _NoInternetConnectionState();
}

final connectivityResult = Connectivity().checkConnectivity();

class _NoInternetConnectionState extends State<NoInternetConnection> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        connectivityResult.then((value) {
          if (value == ConnectivityResult.mobile ||
              value == ConnectivityResult.wifi) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const Browser(
                          url: 'https://everify.bdris.gov.bd',
                        )));
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.verified, color: Colors.black45),
            onPressed: () async {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          title: const Text('BDRN Verification',
              style: TextStyle(color: Colors.black45, fontSize: 15)),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.info_outline_rounded,
                    color: Colors.black45),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const About()));
                }),
          ],
        ),
        body: const Center(
          child: Column(
            children: [
              Expanded(child: SizedBox()),
              Icon(
                Icons.signal_wifi_off_rounded,
                color: Colors.black12,
                size: 100,
              ),
              Center(
                  child: Text('No Internet Connection',
                      style: TextStyle(color: Colors.black26, fontSize: 15))),
              Expanded(child: SizedBox()),
              ElevatedButton(
                onPressed: null,
                child: Text('Try Again'),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
