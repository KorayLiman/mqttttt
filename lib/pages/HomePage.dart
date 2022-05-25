import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mqttttt/MQTTManager.dart';
import 'package:mqttttt/state/MQTTAppState.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? host;
  String? topic;
  String? message;
  late MQTTManager manager;
  late MQTTAppState currentAppState;
  TextEditingController _messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "MQTT",
          style: TextStyle(color: Colors.black),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: LogoWidget(),
            flex: 2,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 500,
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade400,
                    elevation: 20,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(0),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 1,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(currentAppState.getHistoryText),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _configureAndConnect() {
    // ignore: flutter_style_todos
    // TODO: Use UUID
    String osPrefix = 'IOS Dahi Bilişim';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    manager = MQTTManager(
        host: host!,
        topic: topic!,
        identifier: osPrefix,
        state: currentAppState);
    try {
      manager.initializeMQTTClient();
    } catch (error) {
      print(error);
    }
    try {
      manager.connect();
    } catch (error) {
      print(error);
    }

    print("Connected");
  }

  void _disconnect() {
    manager.disconnect();
  }

  Widget LogoWidget() {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: Image.asset("assets/images/dahilogo.png")),
        SizedBox(
          height: 20,
        ),
        Container(
          child: TextFormField(
              onChanged: (value) {
                host = value;
              },
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  hintText: "Host",
                  contentPadding: const EdgeInsets.all(0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)))),
          height: 50,
          width: 200,
        ),
        SizedBox(
          height: 20,
        ),
        Container(
            child: TextFormField(
              onChanged: (value) {
                topic = value;
              },
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  hintText: "Topic",
                  contentPadding: const EdgeInsets.all(0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
            height: 50,
            width: 200),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _configureAndConnect();
              },
              child: const Text("Connect"),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                  textStyle: MaterialStateProperty.all(
                      TextStyle(color: Colors.white))),
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () {
                _disconnect();
              },
              child: const Text("Disonnect"),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  textStyle: MaterialStateProperty.all(
                      TextStyle(color: Colors.white))),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                child: TextFormField(
                  controller: _messageTextController,
                  onChanged: (value) {
                    message = value;
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: "Message",
                      enabled: appState.getAppConnectionState ==
                              MQTTAppConnectionState.Connected
                          ? true
                          : false,
                      contentPadding: const EdgeInsets.all(0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                height: 50,
                width: 200),
          ],
        ),
        ElevatedButton(
            onPressed: () {
              _publishMessage(message!);
            },
            child: const Text("Send")),
      ],
    );
  }

  void _publishMessage(String text) {
    String osPrefix = 'IOS Dahi Bilisim';
    if (Platform.isAndroid) {
      osPrefix = 'Android Dahi Bilisim';
    }
    final String message = osPrefix + ' : ' + text;
    manager.publish(message);
    _messageTextController.clear();
  }
}
