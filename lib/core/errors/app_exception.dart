/// الأخطاء الموحدة التي بتنتقل من طبقة البيانات إلى الـ ViewModels.
///
/// كل خطأ بيحمل [message] تقني (بيتسجل في الـ logs)، والـ ViewModel هو
/// اللي بيحوّله لرسالة عربية مناسبة للمستخدم حسب سياق الشاشة.
class AppException implements Exception {
  const AppException(this.message, {this.assetPath, this.cause});

  /// رسالة تقنية بتوصف سبب الفشل.
  final String message;

  /// مسار الـ asset الملوّق فيه لو الفشل قراءة ملف من الـ bundle.
  final String? assetPath;

  /// السبب الأصلي اللي تسبب في الخطأ (للـ debugging).
  final Object? cause;

  @override
  String toString() => message;
}
