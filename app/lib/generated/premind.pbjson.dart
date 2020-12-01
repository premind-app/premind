///
//  Generated code. Do not modify.
//  source: premind.proto
//
// @dart = 2.3
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

const User$json = const {
  '1': 'User',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'fcm_token', '3': 2, '4': 1, '5': 9, '10': 'fcmToken'},
  ],
};

const Timer$json = const {
  '1': 'Timer',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'creator_id', '3': 2, '4': 1, '5': 9, '10': 'creatorId'},
    const {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    const {'1': 'deadline', '3': 4, '4': 1, '5': 4, '10': 'deadline'},
    const {'1': 'recipient_ids', '3': 5, '4': 3, '5': 9, '10': 'recipientIds'},
  ],
};

const CreateUserRequest$json = const {
  '1': 'CreateUserRequest',
  '2': const [
    const {'1': 'user', '3': 1, '4': 1, '5': 11, '6': '.premind.v0.User', '10': 'user'},
  ],
};

const UpdateUserRequest$json = const {
  '1': 'UpdateUserRequest',
  '2': const [
    const {'1': 'user', '3': 1, '4': 1, '5': 11, '6': '.premind.v0.User', '10': 'user'},
  ],
};

const CreateTimerRequest$json = const {
  '1': 'CreateTimerRequest',
  '2': const [
    const {'1': 'timer', '3': 1, '4': 1, '5': 11, '6': '.premind.v0.Timer', '10': 'timer'},
  ],
};

