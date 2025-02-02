import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:global_template/global_template.dart';
import 'package:provider/provider.dart';

import 'package:ditonton/common/constants.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv/tv_crew.dart';
import 'package:ditonton/domain/entities/tv/tv_detail.dart';
import 'package:ditonton/domain/entities/tv/tv_season.dart';
import 'package:ditonton/presentation/provider/tv/tv_series_episode_season_notifier.dart';

class TVEpisodeSeasonPage extends StatefulWidget {
  static const ROUTE_NAME = '/episode-season-tv';

  /// [tv, season]
  final Map<String, dynamic> param;

  const TVEpisodeSeasonPage({
    Key? key,
    required this.param,
  }) : super(key: key);

  @override
  State<TVEpisodeSeasonPage> createState() => _TVEpisodeSeasonPageState();
}

class _TVEpisodeSeasonPageState extends State<TVEpisodeSeasonPage> {
  late final TVDetail tv;
  late final Season season;
  @override
  void initState() {
    super.initState();
    tv = widget.param['tv'];
    season = widget.param['season'];

    Future.microtask(() {
      Provider.of<TVSeriesEpisodeSeasonNotifier>(context, listen: false)
        ..get(
          id: tv.id,
          seasonNumber: season.seasonNumber,
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('${tv.name} | ${season.name}'),
      ),
      body: SizedBox.expand(
        child: Consumer<TVSeriesEpisodeSeasonNotifier>(
          builder: (context, data, child) {
            final state = data.state;
            if (state == RequestState.Loading) {
              return Center(child: CircularProgressIndicator());
            } else if (state == RequestState.Loaded) {
              if (data.items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('Episode untuk ${tv.name} ${season.name} tidak ditemukan'),
                  ),
                );
              }
              return ListView.builder(
                itemCount: data.items.length,
                shrinkWrap: true,
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, index) {
                  final episode = data.items[index];
                  return ListTile(
                    leading: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: '$BASE_IMAGE_URL/${episode.stillPath}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80.0,
                            height: 80.0,
                            decoration: BoxDecoration(color: kMikadoYellow),
                            child: FittedBox(
                              child: Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),
                    title: Text('${episode.name}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 10),
                        Builder(builder: (_) {
                          DateTime? date;
                          if (episode.airDate != null) {
                            date = episode.airDate;
                          }
                          if (date == null) {
                            return SizedBox();
                          }

                          return Text(
                            GlobalFunction.formatYMDS(date),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12.0,
                            ),
                          );
                        }),
                        SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RatingBarIndicator(
                              rating: (episode.voteAverage ?? 0) / 2,
                              itemCount: 5,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: kMikadoYellow,
                              ),
                              itemSize: 24,
                            ),
                            SizedBox(width: 5),
                            Text('${(episode.voteAverage ?? 0).toStringAsFixed(1)}'),
                          ],
                        )
                      ],
                    ),
                    trailing: InkWell(
                      onTap: () async {
                        await showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15.0),
                            ),
                          ),
                          context: context,
                          builder: (context) => Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Crew',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 20),
                                ShowCrew(crews: episode.crew),
                                SizedBox(height: 20),
                                Text(
                                  'Guest Start',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 20),
                                ShowCrew(crews: episode.guestStars),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: kMikadoYellow,
                        foregroundColor: Colors.white,
                        child: Icon(Icons.person),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text(data.message));
            }
          },
        ),
      ),
    );
  }
}

class ShowCrew extends StatelessWidget {
  const ShowCrew({
    Key? key,
    required this.crews,
  }) : super(key: key);

  final List<Crew> crews;
  @override
  Widget build(BuildContext context) {
    if (crews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('People not found')),
      );
    }
    return SizedBox(
      height: 100,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemExtent: 100,
        itemCount: crews.length,
        itemBuilder: (context, index) {
          final crew = crews[index];
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: '$BASE_IMAGE_URL/${crew.profilePath}',
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          color: kMikadoYellow,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${crew.name}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
