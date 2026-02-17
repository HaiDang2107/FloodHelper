import 'package:flutter/material.dart';
import '../../../data/data.dart';

/// Callback type for successful code verification
/// [resetToken] is provided for forgot password flow, null for signup flow
typedef OnCodeVerifySuccess = void Function(String? resetToken);

/// Mixin for common authentication methods
mixin AuthCodeVerificationMixin {
  /// Set loading state
  void setLoading(bool value);

  /// Set error message
  void setError(String? message);

  /// Clear error message
  void clearError();

  /// Get the authentication repository
  AuthRepository getAuthRepository();

  /// Handle code submission with verification
  Future<void> handleCodeSubmit({
    required BuildContext context,
    required String code,
    required String username,
    required VerificationType verificationType,
    required OnCodeVerifySuccess onSuccess,
  }) async {
    clearError();

    // Validate code
    if (code.isEmpty) {
      setError('Please enter the verification code');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the verification code')),
        );
      }
      return;
    }

    setLoading(true);

    try {
      final authRepository = getAuthRepository();
      
      final response = await authRepository.verifyCode(
        username: username,
        code: code,
        type: verificationType,
      );

      // Call success callback with resetToken (if available)
      onSuccess(response.resetToken);
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      setError(errorMessage);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  /// Handle resend verification code
  Future<void> handleResendCode({
    required BuildContext context,
    required String username,
    required VerificationType verificationType,
    String? successMessage,
  }) async {
    setLoading(true);
    
    try {
      final authRepository = getAuthRepository();
      
      await authRepository.resendCode(
        username: username,
        type: verificationType,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage ?? 'Verification code sent again')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      setLoading(false);
    }
  }
}
