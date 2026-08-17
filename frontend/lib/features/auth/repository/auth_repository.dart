import 'package:frontend/features/auth/models/auth_response.dart';
import 'package:frontend/features/auth/models/user.dart';
import 'package:frontend/shared/services/auth_service.dart';

class AuthRepository {
  final AuthService authService;

  AuthRepository(this.authService);

  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final json = await authService.login(
      username: username,
      password: password,
    );
    return AuthResponse.fromJson(json);
  }

  Future<AuthResponse> register({
    required String username,
    required String email,
    required String gender,
    required String phone,
    required String password,
  }) async {
    final json = await authService.register(
      username: username,
      email: email,
      gender: gender,
      phone: phone,
      password: password,
    );
    return AuthResponse.fromJson(json);
  }

  Future<String?> getToken() => authService.getToken();

  Future<void> saveSession({
    required AuthResponse auth,
  }) {
    return authService.saveSession(token: auth.token, user: auth.user.toJson());
  }

  Future<AuthResponse?> getSavedSession() async {
    final userJson = await authService.getSavedUser();
    final token = await authService.getToken();
    if (userJson == null || token == null) return null;
    return AuthResponse(token: token, tokenType: 'Bearer', expiresIn: 0, user: User.fromJson(userJson));
  }

  Future<void> clearSession() => authService.clearSession();
}
