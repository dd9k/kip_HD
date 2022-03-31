import 'dart:io';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/services/MobileDataInterceptor.dart';
import 'package:chopper/chopper.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' show MultipartFile;

part 'ApiServiceHD.chopper.dart';

//final $url = '${Constants.URL_LIST[Constants().indexURL]}${path}';
@ChopperApi(baseUrl: "")
abstract class ApiServiceHD extends ChopperService {

  @Post(path: '{path}', headers: {'Content-Type': 'multipart/form-data'})
  @multipart
  Future<dynamic> postApiOCR(
  @Header('Authorization') String authorization,
    @Path('path') String path,
    @Part('requestId') String requestId,
    @Part('partner') String partner,
    @Part('channel') String channel,
    @PartFile() MultipartFile image,
  );

  @Post(path: '{path}', headers: {'Content-Type': 'application/json'})
  Future<dynamic> postApiNoAuthenticate(@Path('path') String path, @Body() Map<String, dynamic> body);

  static ApiServiceHD create() {
    HttpClient httpclient = new HttpClient()
      ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    httpclient.connectionTimeout = Constants.CONNECTION_TIME_OUT;
    var ioClient = new IOClient(httpclient);
    final client = ChopperClient(
      baseUrl: '',
      services: [
        _$ApiServiceHD(),
      ],
      client: ioClient,
      converter: JsonConverter(),
      interceptors: [
        MobileDataInterceptor()
        ,HttpLoggingInterceptor()
      ],
    );
    return _$ApiServiceHD(client);
  }
}
