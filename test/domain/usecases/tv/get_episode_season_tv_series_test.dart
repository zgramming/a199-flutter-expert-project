import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:ditonton/domain/entities/tv/tv_episode.dart';
import 'package:ditonton/domain/usecases/tv/get_episode_season_tv_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/test_helper.mocks.dart';

void main() {
  late MockTVRepository repository;
  late GetEpisodeSeasonTVSeries usecase;

  setUp(() {
    repository = MockTVRepository();
    usecase = GetEpisodeSeasonTVSeries(repository: repository);
  });

  final id = 1;
  final seasonNumber = 1;

  final list = <Episode>[];
  test(
    'should get list episode of season tv series from the repository',
    () async {
      ///arrange
      when(repository.getEpisodeSeasonTVSeries(id: id, seasonNumber: seasonNumber))
          .thenAnswer((_) async => Right(list));

      ///act
      final result = await usecase.execute(id: id, seasonNumber: seasonNumber);

      ///assert
      expect(result, Right(list));
    },
  );
}
