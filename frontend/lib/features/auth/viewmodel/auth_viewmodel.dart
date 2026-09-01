import 'package:frontend/features/auth/model/auth_response.dart';
import 'package:frontend/features/auth/model/user.dart';
import 'package:frontend/features/auth/repository/auth_repository.dart';
import 'package:get/get.dart';

class AuthViewmodel extends GetxController {
  final AuthRepository authRepository;
  AuthViewmodel(this.authRepository);

  final RxBool isCheckingSession = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = "".obs;
  final Rx<AuthResponse?> auth = Rx<AuthResponse?>(null);

  bool get isLoggedIn => auth.value != null;
  User? get currentUser => auth.value?.user;
  String? get token => auth.value?.token;

  @override
  void onInit() {
    super.onInit();
    checkSession();
  }

  Future<void> checkSession() async {
    isCheckingSession.value = true;
    final saved = await authRepository.getSavedSession();
    auth.value = saved;
    isCheckingSession.value = false;
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      final result = await authRepository.login(
        username: username,
        password: password,
      );
      await authRepository.saveSession(auth: result);
      auth.value = result;
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String gender,
    required String phone,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      final result = await authRepository.register(
        username: username,
        email: email,
        gender: gender,
        phone: phone,
        password: password,
      );
      await authRepository.saveSession(auth: result);
      auth.value = result;
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await authRepository.clearSession();
    auth.value = null;
  }
}
