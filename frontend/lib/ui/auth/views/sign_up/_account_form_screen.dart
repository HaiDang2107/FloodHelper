import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Account form screen with additional fields
class AccountFormScreen extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController dateOfBirthController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final VoidCallback? onDatePickerTap;

  const AccountFormScreen({
    super.key,
    required this.fullNameController,
    required this.phoneNumberController,
    required this.dateOfBirthController,
    required this.usernameController,
    required this.passwordController,
    required this.onSubmit,
    required this.onBack,
    this.onDatePickerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDF71), // Yellow background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Complete Your Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F62FE), // Blue text
                ),
              ),
              const SizedBox(height: 16),

              // Full Name Field
              CustomTextField(
                controller: fullNameController,
                hintText: 'Full Name',
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              CustomTextField(
                controller: phoneNumberController,
                hintText: 'Phone Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Date of Birth Field
              GestureDetector(
                onTap: () {
                  // We'll need to pass the viewModel callback
                  if (onDatePickerTap != null) {
                    onDatePickerTap!();
                  }
                },
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: dateOfBirthController,
                    hintText: 'Date of Birth (Optional)',
                    suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF0F62FE)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Username Field
              CustomTextField(
                controller: usernameController,
                hintText: 'Username',
              ),
              const SizedBox(height: 16),

              // Password Field
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Submit Button
              CustomButton(
                text: 'Submit',
                backgroundColor: const Color(0xFF0F62FE), // Blue button
                textColor: Colors.white,
                onPressed: onSubmit,
              ),
              const SizedBox(height: 16),

              // Back Button
              GestureDetector(
                onTap: onBack,
                child: Text(
                  'Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF0F62FE), // Blue text
                    fontSize: 12,
                    fontFamily: 'Anonymous Pro',
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
