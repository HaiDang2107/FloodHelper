class SignInService {
  Future<bool> signIn(String email, String password) async {
    // Mock API call
    await Future.delayed(const Duration(seconds: 1));
    // Return true for success
    return true;
  }
}
