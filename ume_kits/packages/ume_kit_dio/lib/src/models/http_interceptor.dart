///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/13/21 1:58 PM
///
import 'package:dio/dio.dart';

import '../constants/constants.dart';
import '../instances.dart';

int get _timestamp => DateTime.now().millisecondsSinceEpoch;

/// Implement a [Interceptor] to handle dio methods.
///
/// Main idea about this interceptor:
///  - Use [RequestOptions.extra] to store our timestamps.
///  - Add [DIO_EXTRA_START_TIME] when a request was requested.
///  - Add [DIO_EXTRA_END_TIME] when a response is respond or thrown an error.
///  - Deliver the [Response] to the container.
class UMEDioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[DIO_EXTRA_START_TIME] = _timestamp;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    response.requestOptions.extra[DIO_EXTRA_END_TIME] = _timestamp;
    InspectorInstance.httpContainer.addRequest(response);
    handler.next(response);
  }

  @override
  void onError(DioException exception, ErrorInterceptorHandler handler) {
    // Create an empty response with the [RequestOptions] for delivery.
    // exception.response ??= Response<dynamic>(requestOptions: exception.requestOptions);
    exception.response!.requestOptions.extra[DIO_EXTRA_END_TIME] = _timestamp;
    InspectorInstance.httpContainer.addRequest(exception.response!);
    handler.next(exception);
  }
}