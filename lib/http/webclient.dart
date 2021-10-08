import 'dart:convert';

import 'package:bytebank2/http/interceptors/logging-interceptor.dart';
import 'package:bytebank2/models/contact.dart';
import 'package:bytebank2/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

final Client client =
    InterceptedClient.build(interceptors: [LoggingInterceptor()]);
const String baseUrl = 'http://192.168.0.178:8080/transactions';


