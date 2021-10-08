import 'package:http_interceptor/http_interceptor.dart';

class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    print('REQUEST');
    print('url     : ${data.url}');
    print('headers : ${data.headers}');
    print('body    : ${data.body}');
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    print('RESPONSE');
    print('headers : ${data.headers}');
    print('status  : ${data.statusCode}');
    print('body    : ${data.body}');

    return data;
  }
}