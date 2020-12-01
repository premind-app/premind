///
//  Generated code. Do not modify.
//  source: premind.proto
//
// @dart = 2.3
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'premind.pb.dart' as $0;
export 'premind.pb.dart';

class PremindClient extends $grpc.Client {
  static final _$createUser = $grpc.ClientMethod<$0.CreateUserRequest, $0.User>(
      '/premind.v0.Premind/CreateUser',
      ($0.CreateUserRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.User.fromBuffer(value));
  static final _$updateUser = $grpc.ClientMethod<$0.UpdateUserRequest, $0.User>(
      '/premind.v0.Premind/UpdateUser',
      ($0.UpdateUserRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.User.fromBuffer(value));
  static final _$createTimer =
      $grpc.ClientMethod<$0.CreateTimerRequest, $0.Timer>(
          '/premind.v0.Premind/CreateTimer',
          ($0.CreateTimerRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Timer.fromBuffer(value));

  PremindClient($grpc.ClientChannel channel,
      {$grpc.CallOptions options,
      $core.Iterable<$grpc.ClientInterceptor> interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.User> createUser($0.CreateUserRequest request,
      {$grpc.CallOptions options}) {
    return $createUnaryCall(_$createUser, request, options: options);
  }

  $grpc.ResponseFuture<$0.User> updateUser($0.UpdateUserRequest request,
      {$grpc.CallOptions options}) {
    return $createUnaryCall(_$updateUser, request, options: options);
  }

  $grpc.ResponseFuture<$0.Timer> createTimer($0.CreateTimerRequest request,
      {$grpc.CallOptions options}) {
    return $createUnaryCall(_$createTimer, request, options: options);
  }
}

abstract class PremindServiceBase extends $grpc.Service {
  $core.String get $name => 'premind.v0.Premind';

  PremindServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateUserRequest, $0.User>(
        'CreateUser',
        createUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateUserRequest.fromBuffer(value),
        ($0.User value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateUserRequest, $0.User>(
        'UpdateUser',
        updateUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateUserRequest.fromBuffer(value),
        ($0.User value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateTimerRequest, $0.Timer>(
        'CreateTimer',
        createTimer_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateTimerRequest.fromBuffer(value),
        ($0.Timer value) => value.writeToBuffer()));
  }

  $async.Future<$0.User> createUser_Pre($grpc.ServiceCall call,
      $async.Future<$0.CreateUserRequest> request) async {
    return createUser(call, await request);
  }

  $async.Future<$0.User> updateUser_Pre($grpc.ServiceCall call,
      $async.Future<$0.UpdateUserRequest> request) async {
    return updateUser(call, await request);
  }

  $async.Future<$0.Timer> createTimer_Pre($grpc.ServiceCall call,
      $async.Future<$0.CreateTimerRequest> request) async {
    return createTimer(call, await request);
  }

  $async.Future<$0.User> createUser(
      $grpc.ServiceCall call, $0.CreateUserRequest request);
  $async.Future<$0.User> updateUser(
      $grpc.ServiceCall call, $0.UpdateUserRequest request);
  $async.Future<$0.Timer> createTimer(
      $grpc.ServiceCall call, $0.CreateTimerRequest request);
}
