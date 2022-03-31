import 'package:json_annotation/json_annotation.dart';

part 'AuthenticateHD.g.dart';

@JsonSerializable()
class AuthenticateHD {
  @JsonKey(name: 'access_token')
  String accessToken;

  @JsonKey(name: 'expires_in')
  int expired;

  @JsonKey(name: 'token_type')
  String tokenType;

  @JsonKey(name: 'scope')
  String scope;

  AuthenticateHD._();

  AuthenticateHD(this.accessToken, this.expired, this.tokenType, this.scope);

  factory AuthenticateHD.fromJson(Map<String, dynamic> json) => _$AuthenticateHDFromJson(json);

  Map<String, dynamic> toJson() => _$AuthenticateHDToJson(this);
}
