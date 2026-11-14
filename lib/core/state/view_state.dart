/// الحالة الموحدة للعمليات غير المتزامنة في الـ ViewModels.
///
/// بدل ما كل ViewModel يشيل متغيرات متفرقة زي `_isLoading` و `_hasError`
/// و `_isEmpty`، كل شاشة بتشوف حالة واحدة واضحة: initial / loading /
/// success / empty / error.
class ViewState<T> {
  const ViewState._(this.status, this.data, this.message);

  const ViewState.initial() : this._(ViewStateStatus.initial, null, null);

  const ViewState.loading() : this._(ViewStateStatus.loading, null, null);

  const ViewState.success(T data) : this._(ViewStateStatus.success, data, null);

  const ViewState.empty() : this._(ViewStateStatus.empty, null, null);

  const ViewState.error(String message) : this._(ViewStateStatus.error, null, message);

  final ViewStateStatus status;
  final T? data;
  final String? message;

  bool get isInitial => status == ViewStateStatus.initial;
  bool get isLoading => status == ViewStateStatus.loading;
  bool get isSuccess => status == ViewStateStatus.success;
  bool get isEmpty => status == ViewStateStatus.empty;
  bool get isError => status == ViewStateStatus.error;
}

enum ViewStateStatus { initial, loading, success, empty, error }
