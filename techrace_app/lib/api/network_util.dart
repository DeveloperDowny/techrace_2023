import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techrace/utils/MLocalStorage.dart';

class NetworkUtil {
  // next three lines makes this class a Singleton
  static NetworkUtil _instance = new NetworkUtil.internal();

  NetworkUtil.internal();

  factory NetworkUtil() => _instance;
  var dio = Dio();
  late Response response;
  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url) async {
    response = await dio.get(url);
    final int statusCode = response.statusCode!;
    print(statusCode.toString()+"get");
    print(response.toString());

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return _decoder.convert(response.toString());
  }

  Future<dynamic> post(String url, formData) async {
    try {
      response = await dio.post(url, data: formData);
      final int statusCode = response.statusCode!;
      print(statusCode.toString());
      print(response.toString());

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(response.toString());
    } catch(e) {
      return HashMap.from({
        "status": "0",
        "message": "Error occurred.\nPlease close the app, remove it from recent tabs and try again.\nIf issue persists, call +91 897 580 3664"
      });
    }
  }
  Future<dynamic> postf(String url, formData) async {
    try {
      // var jwtToken = MLocalStorage().getToken();
      var jwtToken = GetStorage().read("token");
      // GetStorage().write("token", res["token"]);
      // print(jwtToken);
      // print("jwtds");
      response = await dio.post(url, data: formData, options: Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer $jwtToken"
        // HttpHeaders.authorizationHeader:"Bearer ghfghfg.eyJ0aWQiOiI2NzgiLCJpYXQiOjE2NzMzMzU0ODUsImV4cCI6MTY3NzMzNTA4NX0.UiO7hUJbhe1FV5k-HGqNptfPNn8UYjKoZpgPipeNUrw"
      }));
      final int statusCode = response.statusCode!;
      print(statusCode.toString());
      print(response.toString());

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(response.toString());
    } catch(e) {
      print(e);
      return HashMap.from({
        "status": "0",
        "message": "Error occurred.\nPlease Log Out and Log In again.\nIf issue persists, call +91 897 580 3664"
      });
    }
  }

  Future<dynamic> post1(String url, formData) async {
    response = await dio.post(url, data: formData);
    final int statusCode = response.statusCode!;
    print(statusCode.toString());
    print(response.toString());

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return _decoder.convert(response.toString());
  }

  Future<dynamic> postnew(String url, formData) async {
    response = await dio.post(url,   options: Options(headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    }), data:  jsonEncode(formData));
    final int statusCode = response.statusCode!;
    print(statusCode.toString());
    print(response.toString());

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return _decoder.convert(response.toString());
  }
}
