import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movies_app/Core/theme/my_theme.dart';
import 'package:movies_app/Model/api/api_manager.dart';
import 'package:movies_app/Model/movie_details/MoviesDetails.dart';
import 'package:movies_app/Model/movie_popular/Result.dart';
import 'package:movies_app/Providers/app_provider.dart';
import 'package:movies_app/View/home/details/similar/similar_widget.dart';
import 'package:provider/provider.dart';

import '../../../Model/movie_similar/MoviesSimilar.dart';
import 'details_widget.dart';

class DetailsView extends StatefulWidget {
  static const String routeName = 'details';

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)?.settings.arguments as Result;
    var provider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.secondaryColor,
        title: Text(args.title!),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.20,
                  child: CachedNetworkImage(
                    imageUrl:
                    'https://image.tmdb.org/t/p/w500${args.backdropPath}',
                    fit: BoxFit.fill,
                    placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error)),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.07,
                  left: MediaQuery.of(context).size.width * 0.4,
                  child: const Icon(
                    Icons.play_circle,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    args.title!,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    args.releaseDate!,
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 225,
                        width: 120,
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              fit: BoxFit.fill,
                              height: 225,
                              imageUrl:
                              'https://image.tmdb.org/t/p/w500${args.posterPath}',
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                              const Center(child: Icon(Icons.error)),
                            ),
                            InkWell(
                              onTap: () {
                                provider.selectMovie(args);
                              },
                              child: provider.idList.contains(args.id)
                                  ? Image.asset(
                                  'assets/images/bookmark_done.png')
                                  : Image.asset('assets/images/bookmark.png'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 225,
                        width: 248,
                        child: FutureBuilder<MoviesDetails>(
                          future: ApiManager.getMovieDetails(args.id!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            }
                            if (snapshot.data?.statusCode == 7) {
                              return Center(
                                child: Text(snapshot.data?.statusMessage ?? ''),
                              );
                            }
                            return DetailsWidget(snapshot.data);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder<MoviesSimilar>(
                    future: ApiManager.getMoviesSimilar(args.id!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      }
                      if (snapshot.data?.statusCode == 7) {
                        return Center(
                          child: Text(snapshot.data?.statusMessage ?? ''),
                        );
                      }
                      return SimilarWidget(snapshot.data);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
