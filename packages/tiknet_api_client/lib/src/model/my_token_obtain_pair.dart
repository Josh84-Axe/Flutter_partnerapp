//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'my_token_obtain_pair.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MyTokenObtainPair {
  /// Returns a new [MyTokenObtainPair] instance.
  MyTokenObtainPair({

    required  this.email,

    required  this.password,
  });

  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false
  )


  final String email;



  @JsonKey(
    
    name: r'password',
    required: true,
    includeIfNull: false
  )


  final String password;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MyTokenObtainPair &&
      other.email == email &&
      other.password == password;

    @override
    int get hashCode =>
        email.hashCode +
        password.hashCode;

  factory MyTokenObtainPair.fromJson(Map<String, dynamic> json) => _$MyTokenObtainPairFromJson(json);

  Map<String, dynamic> toJson() => _$MyTokenObtainPairToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

