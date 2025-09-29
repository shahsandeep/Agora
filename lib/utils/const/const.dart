import 'package:flutter/material.dart';

class AgoraConstants {
  // static const appId = "ecb97c1a789742da81e7d71682481cd4";

  static const appId = "75aabc070b24486b9eb7d0df8d554ef4";
  static const loginEmail = 'eve.holt@reqres.in';
  static const loginPassword = 'cityslicka';

  // static const token =
  // '007eJxSYNB4YZHL7XH+4vMnp42EPu49d0+yd+rq92kKW7it2UvzFe4qMKQmJ1maJxsmmltYmpsYpSRaGKaap5gbmlkYmVgYJqeYSHYdTndYo85gpZnJysjAyMDCwMgA4jOBSWYwyQImORkS0/OLEktSi0sYGAABAAD//3xlJNw=';

  static const token = '007eJxTYFgddyD48IcLr+Qqpi4WLb306e/s+Os+sVZ2ay7khUxq2PFMgcHcNDExKdnA3CDJyMTEwizJMjXJPMUgJc0ixdTUJDXNxHrxrYyGQEaGfJctrIwMEAjiczIkpucXJZakFpcwMAAADMkk7g==';
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static const String baseUrl = "https://reqres.in/api";

  static const String login = "$baseUrl/login";

  static const String fetchUsers = "$baseUrl/users";
}
