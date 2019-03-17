import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:crypto/crypto.dart';

String API_KEY = 'V37UcPDfsVDiaYgs';
String API_SECRET = 'yOjBov7vc-0op26qkHmaLOL4abzb34oK';
String BASE_URL = 'https://api.edinburghfestivalcity.com';

class Event {
  String title;
  String venue;
  String image_src;
  String description;
  double lat;
  double long;
  double euclid_dist;
}

dynamic Search() async {
  String queryWithKey = '/events?' +
      'distance=1kilometer&latitude=55.9431985&longitude=-3.2003548&pretty=1' +
      '&key=' +
      API_KEY;
  String signature = CreateSignature(queryWithKey, API_SECRET);

  Uri authenticatedUri =
      Uri.parse(BASE_URL + queryWithKey + "&signature=" + signature);

  HttpClient client = new HttpClient();

  var request = await client.getUrl(authenticatedUri);
  var response = await request.close();

  if (response.statusCode == HttpStatus.OK) {
    var result = await response.transform(Utf8Decoder()).join();
    try {
      var data = jsonDecode(result);
      return data;
    } catch (exception) {
      throw ('Failed parsing');
    }
  } else {
    var result = await response.transform(Utf8Decoder()).join();
    print(result.toString());
    throw ('Error in request');
  }
}

String CreateSignature(String query, String secret) {
  var encoding = new AsciiCodec();
  var keyBytes = encoding.encode(secret);
  var messageBytes = encoding.encode(query);

  var hmacsha1 = new Hmac(sha1, keyBytes);
  return hmacsha1.convert(messageBytes).toString();
}

// void orderEvents(String event) {
//   HTTPClient client = new HTTPClient();
//   client.getURL(BASE_URL + 'api/FestivalData/Search?query=' + event);
//   results =
// }
