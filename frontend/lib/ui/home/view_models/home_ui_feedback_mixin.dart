part of 'home_view_model.dart';

mixin HomeUiFeedbackMixin on _HomeViewModelBase {
  void showInfoMessage(String message) {
    _emitUiEvent(message, HomeUiEventType.info);
  }

  void clearUiEvent() {
    state = state.copyWith(clearUiEvent: true);
  }

  @override
  void _emitUiEvent(String message, HomeUiEventType type) {
    state = state.copyWith(
      uiEvent: HomeUiEvent(type: type, message: message),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
