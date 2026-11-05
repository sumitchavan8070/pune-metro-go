import 'package:dio/dio.dart';

class DioService {
  DioService() {
    client = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 25),
        headers: const {
          'User-Agent': 'PuneMetroGuide/1.0 (reference-data check)',
        },
        responseType: ResponseType.plain,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  late final Dio client;
}
