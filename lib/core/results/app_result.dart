/// Functional Result pattern to handle business outcomes without raw exceptions
/// Author: Nguyen Vinh Phu (QE180136)
sealed class AppResult<T> {
  const AppResult();

  const factory AppResult.success(T data) = SuccessResult<T>;
  const factory AppResult.failure(String error) = FailureResult<T>;

  bool get isSuccess => this is SuccessResult<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get dataOrNull => this is SuccessResult<T> ? (this as SuccessResult<T>).data : null;
  String? get errorOrNull => this is FailureResult<T> ? (this as FailureResult<T>).errorMessage : null;
}

final class SuccessResult<T> extends AppResult<T> {
  final T data;
  const SuccessResult(this.data);
}

final class FailureResult<T> extends AppResult<T> {
  final String errorMessage;
  const FailureResult(this.errorMessage);
}
