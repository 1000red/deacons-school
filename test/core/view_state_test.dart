import 'package:deacons_school_mobile/core/state/view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ViewState', () {
    test('initial/loading/empty have no data and no message', () {
      const initial = ViewState<int>.initial();
      expect(initial.isInitial, isTrue);
      expect(initial.data, isNull);
      expect(initial.message, isNull);

      const loading = ViewState<int>.loading();
      expect(loading.isLoading, isTrue);
      expect(loading.data, isNull);

      const empty = ViewState<int>.empty();
      expect(empty.isEmpty, isTrue);
      expect(empty.data, isNull);
    });

    test('success carries the data and only success is successful', () {
      const state = ViewState<String>.success('محتوى');

      expect(state.isSuccess, isTrue);
      expect(state.data, 'محتوى');
      expect(state.isLoading, isFalse);
      expect(state.isError, isFalse);
      expect(state.isEmpty, isFalse);
    });

    test('error carries the message only', () {
      const state = ViewState<int>.error('تعذر تحميل المحتوى.');

      expect(state.isError, isTrue);
      expect(state.message, 'تعذر تحميل المحتوى.');
      expect(state.data, isNull);
    });
  });
}
