// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentUser _$CurrentUserFromJson(Map<String, dynamic> json) {
  return CurrentUser()
    ..id = json['id'] as String
    ..fullName = json['fullName'] as String
    ..statusColor = json['statusColor'] as String
    ..slug = json['slug'] as String
    ..gender = json['gender'] as String
    ..placeOfBirth = json['placeOfBirth'] as String
    ..dateOfBirth = json['dateOfBirth'] as String
    ..firstName = json['firstName'] as String
    ..lastName = json['lastName'] as String
    ..codiceFiscale = json['codiceFiscale'] as String
    ..phoneNumber = json['phoneNumber'] as String
    ..email = json['email'] as String
    ..createdAt = json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String)
    ..voteRightStartingCountDate = json['voteRightStartingCountDate'] == null
        ? null
        : DateTime.parse(json['voteRightStartingCountDate'] as String)
    ..profile = json['profile'] == null
        ? null
        : Profile.fromJson(json['profile'] as Map<String, dynamic>);
}

Map<String, dynamic> _$CurrentUserToJson(CurrentUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'statusColor': instance.statusColor,
      'slug': instance.slug,
      'createdAt': instance.createdAt?.toIso8601String(),
      'voteRightStartingCountDate':
          instance.voteRightStartingCountDate?.toIso8601String(),
      'profile': instance.profile,
      'lastName': instance.lastName,
      'firstName': instance.firstName,
      'gender': instance.gender,
      'placeOfBirth': instance.placeOfBirth,
      'dateOfBirth': instance.dateOfBirth,
      'codiceFiscale': instance.codiceFiscale,
      'phoneNumber': instance.phoneNumber
    };
