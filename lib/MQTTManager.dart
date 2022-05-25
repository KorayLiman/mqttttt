import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

import 'package:mqttttt/state/MQTTAppState.dart';

class MQTTManager {
  final MQTTAppState _currentState;
  MqttServerClient? _client;
  final String _identifier;
  final String _host;
  final String _topic;
  bool topicNotified = false;

  final client;

  MQTTManager(
      {required String host,
      required String topic,
      required String identifier,
      required MQTTAppState state})
      : _identifier = identifier,
        _host = host,
        _topic = topic,
        _currentState = state,
        client = MqttServerClient(host, "");

  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true);

    /// Add the successful connection callback
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final property = MqttUserProperty();
    property.pairName = 'Example name';
    property.pairValue = 'Example value';
    final connMess = MqttConnectMessage()
        .withClientIdentifier('MQTT5DartClient')
        .startClean()
        .withUserProperties([property]);
    print('EXAMPLE::Mqtt5 client connecting....');
    client.connectionMessage = connMess;
  }

  void connect() async {
    assert(_client != null);
    try {
      print('EXAMPLE::Mosquitto start client connecting....');
      _currentState.setAppConnectionState(MQTTAppConnectionState.Connecting);
      await _client!.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    print('Disconnected');
    _client!.disconnect();
    _currentState.setAppConnectionState(MQTTAppConnectionState.Disconnected);
  }

  void publish(String message) {
    final MqttPayloadBuilder builder = MqttPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(MqttSubscription subscription) {
    print(
        'EXAMPLE::Subscription confirmed for topic ${subscription.topic.rawTopic}');
  }

  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      if (topicNotified) {
        print(
            'EXAMPLE::OnDisconnected callback is solicited, topic has been notified - this is correct');
      } else {
        print(
            'EXAMPLE::OnDisconnected callback is solicited, topic has NOT been notified - this is an ERROR');
      }
    }
    print("Disconnected");
  }

  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.Connected);
    print('EXAMPLE::Mosquitto client connected....');
    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.updates.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      //final MqttPublishMessage recMess = c![0].payload;
      final String pt = 
      MqttUtilities.bytesToStringAsString(recMess.payload.message!);

      _currentState.setReceivedText(pt);
      print(pt);
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }
}
