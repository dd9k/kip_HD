// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ApiServiceHD.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$ApiServiceHD extends ApiServiceHD {
  _$ApiServiceHD([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  final definitionType = ApiServiceHD;

  Future postApiOCR(String authorization, String path, String requestId,
      String partner, String channel, MultipartFile image) {
    final $url = '${path}';
    final $headers = {
      'Authorization': authorization,
      'Content-Type': 'multipart/form-data'
    };
    final $parts = <PartValue>[
      PartValue<String>('requestId', requestId),
      PartValue<String>('partner', partner),
      PartValue<String>('channel', channel),
      PartValueFile<MultipartFile>('image', image)
    ];
    final $request = Request('POST', $url, client.baseUrl,
        parts: $parts, multipart: true, headers: $headers);
    return client.send($request);
  }

  Future postApiNoAuthenticate(String path, Map<String, dynamic> body) {
    final $url = '${path}';
    final $headers = {'Content-Type': 'application/json'};
    final $body = body;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, headers: $headers);
    return client.send($request);
  }
}
