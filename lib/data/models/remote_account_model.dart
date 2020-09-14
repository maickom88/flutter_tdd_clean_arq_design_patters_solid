import 'package:flutter_tdd_clean_arq_solid_design_patters/domain/entities/account_entity.dart';

class RemoteAccountEntity {
  final String accessToken;

  RemoteAccountEntity(this.accessToken);

  factory RemoteAccountEntity.fromJson(Map json) =>
      RemoteAccountEntity(json['accessToken']);

  AccountEntity toEntity() => AccountEntity(accessToken);
}
