import '../../../data/models/models.dart';
import '../../../core/state/disposable_change_notifier.dart';
import '../repositories/curriculum_repository.dart';

class CurriculumViewModel extends DisposableChangeNotifier {
  CurriculumViewModel(this._repository);

  final CurriculumRepository _repository;

  List<Level> get levels => _repository.levels;

  List<Term> get terms => _repository.terms();

  List<YearLevel> yearsOf(Level level) => _repository.yearsOf(level);

  List<Subject> subjectsFor(Level level) => _repository.subjectsFor(level);
}
