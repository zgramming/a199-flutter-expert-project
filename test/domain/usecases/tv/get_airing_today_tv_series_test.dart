import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:ditonton/domain/entities/tv/tv.dart';
import 'package:ditonton/domain/usecases/tv/get_airing_today_tv_series.dart';

import '../../../helpers/test_helper.mocks.dart';

void main() {
  late GetAiringTodayTVSeries usecase;
  late MockTVRepository repository;

  setUp(() {
    repository = MockTVRepository();
    usecase = GetAiringTodayTVSeries(repository: repository);
  });

  final list = <TV>[];
  test(
    'should get List TV Series from the repository',
    () async {
      ///arrange
      when(repository.getAiringTodayTVSeries()).thenAnswer((_) async => Right(list));

      ///act
      final result = await usecase.execute();

      ///asser
      expect(result, Right(list));
    },
  );
}
