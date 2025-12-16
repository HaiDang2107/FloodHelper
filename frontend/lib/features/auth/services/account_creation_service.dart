class AccountCreationService {
  String? validateForm({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String village,
    required String district,
    required String province,
    required String nation,
    required String email,
    required String password,
  }) {
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        dateOfBirth.isEmpty ||
        village.isEmpty ||
        district.isEmpty ||
        province.isEmpty ||
        nation.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      return 'Please fill in all fields';
    }
    return null;
  }

  Future<void> submitAccountDetails({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String village,
    required String district,
    required String province,
    required String email,
    required String password,
  }) async {
    // Mock API call
    await Future.delayed(const Duration(seconds: 1));
    print('First Name: $firstName');
    print('Last Name: $lastName');
    print('Date of Birth: $dateOfBirth');
    print('Village: $village');
    print('District: $district');
    print('Province: $province');
    print('Email: $email');
    print('Password: $password');
  }

  String? validateCode(String code) {
    if (code.isEmpty) {
      return 'Please enter the verification code';
    }
    return null;
  }
}
