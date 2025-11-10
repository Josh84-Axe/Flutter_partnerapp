//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'admin_activate_or_deactivate_user.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminActivateOrDeactivateUser {
  /// Returns a new [AdminActivateOrDeactivateUser] instance.
  AdminActivateOrDeactivateUser({

     this.isActive,
  });

  @JsonKey(
    
    name: r'is_active',
    required: false,
    includeIfNull: false
  )


  final bool? isActive;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminActivateOrDeactivateUser &&
      other.isActive == isActive;

    @override
    int get hashCode =>
        isActive.hashCode;

  factory AdminActivateOrDeactivateUser.fromJson(Map<String, dynamic> json) => _$AdminActivateOrDeactivateUserFromJson(json);

  Map<String, dynamic> toJson() => _$AdminActivateOrDeactivateUserToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

