import 'package:bytebank2/http/interceptors/logging-interceptor.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

final Client client = InterceptedClient.build(
  interceptors: [LoggingInterceptor()],
  requestTimeout: Duration(seconds: 20),
);
const String baseUrl = 'http://192.168.0.178:8080/transactions';
