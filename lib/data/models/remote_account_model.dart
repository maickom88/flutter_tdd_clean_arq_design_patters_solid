import '../../domain/entities/account_entity.dart';

import '../http/http.dart';

class RemoteAccountEntity {
  final String accessToken;

  RemoteAccountEntity(this.accessToken);

  factory RemoteAccountEntity.fromJson(Map json) {
    if (!json.containsKey('accessToken')) {
      throw HttpError.invalidData;
    }
    return RemoteAccountEntity(json['accessToken']);
  }

  AccountEntity toEntity() => AccountEntity(accessToken);
}
