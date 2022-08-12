import 'dart:convert';

import 'package:bytebank2/http/webclient.dart';
import 'package:http/http.dart';

const MESSAGES_URI = "https://gist.githubusercontent.com/giovaniandrade/d414d64858571c295f358322cb25d18f/raw/81260bbbb9dc1c8b46bb44c4c180a24378f72e2c/";

class I18NWebClient {
  final String _viewKey;
  ]
  I18NWebClient(this._viewKey);

  Future<Map<String, dynamic>> findAll() async {
    final Response response = await client.get(Uri.parse("$MESSAGES_URI$_viewKey.json"));
    final Map<String, dynamic> decodedJson = jsonDecode(response.body);
    return decodedJson;
  }
}
