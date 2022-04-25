part of 'authentication_cubit.dart';

@freezed
class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState.authenticated({required String token}) =
      AuthenticationStateAuthenticated;

  const factory AuthenticationState.unauthenticated() =
      AuthenticationStateUnauthenticated;

  const factory AuthenticationState.unknown() = AuthenticationStateUnknown;
}

extension AuthenticationHelpers on AuthenticationState {
  bool get isConnected {
    return this is AuthenticationStateAuthenticated;
  }
}
