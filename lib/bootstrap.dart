import 'package:dio/dio.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/bootstrap.config.dart';
import 'package:pokefinder/src/4_repository/interceptors/logging_interceptor.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies(String environment) =>
    getIt.init(environment: environment);

@module
abstract class RegisterModule {
  @lazySingleton
  EnLogger get logger {
    final printer = PrinterHandler()
      ..configure({
        Severity.notice: const PrinterColor.green(),
      });

    return EnLogger(
      defaultPrefixFormat: const PrefixFormat(
        startFormat: '[',
        endFormat: ']',
      ),
    )..addHandler(printer);
  }

  @lazySingleton
  Dio dio(EnLogger logger) {
    final dio = Dio();
    dio.interceptors.add(LoggingInterceptor(
      logger: logger,
      verbose: kDebugMode,
    ));
    return dio;
  }
}
