import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MovieApp());
}

/// Class for organizing movie attributes.
class Movie {
  Movie.movie({
    required this.title,
    required this.rating,
    required this.runtime,
    required this.year,
    required this.image,
  });

  String title;
  dynamic rating;
  int runtime;
  int year;
  String image;
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        canvasColor: Colors.indigo,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
        ),
        fontFamily: 'Montserrat',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // Divide the tabs' elements in two lists.
  final List<Movie> _dramaMovies = <Movie>[];
  final List<Movie> _comedyMovies = <Movie>[];

  // Sizes for the images, divided by tabs.
  final List<double> _comedySizes = <double>[];
  final List<double> _dramaSizes = <double>[];

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  /// Parse the JSON document retrieved as Movie objects to the lists.
  void fetchMovies() {
    // Get information about the movies.
    get(Uri.parse('https://yts.torrentbay.to/api/v2/list_movies.json')).then((Response response) {
      response.body;
      setState(() {
        isLoading = false;
      });
      final Map<String, dynamic> map = jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> data = map['data'] as Map<String, dynamic>;
      final List<dynamic> movies = data['movies'] as List<dynamic>;

      // Add the information in the lists made for the two tabs divided by genre.
      for (final dynamic item in movies) {
        final List<dynamic> genres = (item as Map<String, dynamic>)['genres'] as List<dynamic>;
        if (genres.contains('Drama')) {
          _dramaMovies.add(
            Movie.movie(
              title: item['title'] as String,
              rating: item['rating'],
              runtime: item['runtime'] as int,
              year: item['year'] as int,
              image: item['large_cover_image'] as String,
            ),
          );
        } else if (genres.contains('Comedy')) {
          _comedyMovies.add(
            Movie.movie(
              title: item['title'] as String,
              rating: item['rating'],
              runtime: item['runtime'] as int,
              year: item['year'] as int,
              image: item['large_cover_image'] as String,
            ),
          );
        }
      }

      // Initialize the sizes for the images as minimum.
      for (int i = 0; i < _comedyMovies.length; i++) {
        _comedySizes.add(220);
      }
      for (int i = 0; i < _dramaMovies.length; i++) {
        _dramaSizes.add(220);
      }

      // The first images should appear bigger.
      _comedySizes[0] = 330;
      _dramaSizes[0] = 330;
    });
  }

  Widget _pageBuilder(BuildContext context, int index, Movie movie, List<double> sizes) {
    // Extract the attributes of the movie.
    final String title = movie.title;
    final String image = movie.image;
    final double size = sizes[index];
    final int runtime = movie.runtime;
    final int year = movie.year;
    final dynamic rating = movie.rating;

    // While the data is gathered, show loading animation.
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.lightBlue,
          ),
        ),
      );
    }

    // Show the movie's information.
    return Column(
      children: <Widget>[
        // The movie's poster.
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: size,
            curve: Curves.fastOutSlowIn,
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 50,
              shadowColor: Colors.black,
              child: Image.network(
                image,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        // Use box as padding.
        const SizedBox(
          height: 10,
        ),
        // Show title and about info.
        Builder(
          builder: (BuildContext context) {
            // If the movie is on the current page, show all the info.
            // Else, it shows only the image (on the sides).
            if (size != 220) {
              return Column(
                children: <Widget>[
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '$year',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white30,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 250,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '$rating',
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                              const Text(
                                'IMDB',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white60,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '$runtime',
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                              const Text(
                                'Minutes',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white60,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.white70,
                        width: 3,
                      ),
                      fixedSize: const Size(200, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Buy tickets',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  )
                ],
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xff8711c1), Color(0xff220b34)],
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Movies'),
            bottom: const TabBar(
              indicatorColor: Colors.blueAccent,
              tabs: <Tab>[
                Tab(text: 'Comedy'),
                Tab(text: 'Drama'),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              PageView.builder(
                controller: PageController(
                  viewportFraction: 0.7,
                ),
                onPageChanged: (int index) {
                  setState(() {
                    // Zoom in the current page and zoom out the side pages.
                    _comedySizes[index] = 330;
                    if (index + 1 < _comedyMovies.length) {
                      _comedySizes[index + 1] = 220;
                    }
                    if (index - 1 >= 0) {
                      _comedySizes[index - 1] = 220;
                    }
                  });
                },
                itemCount: _comedyMovies.length,
                itemBuilder: (BuildContext context, int index) {
                  return _pageBuilder(context, index, _comedyMovies[index], _comedySizes);
                },
              ),
              PageView.builder(
                controller: PageController(
                  viewportFraction: 0.67,
                ),
                onPageChanged: (int index) {
                  setState(() {
                    // Zoom in the current page and zoom out the side pages.
                    _dramaSizes[index] = 330;
                    if (index + 1 < _dramaMovies.length) {
                      _dramaSizes[index + 1] = 220;
                    }
                    if (index - 1 >= 0) {
                      _dramaSizes[index - 1] = 220;
                    }
                  });
                },
                itemCount: _dramaMovies.length,
                itemBuilder: (BuildContext context, int index) {
                  return _pageBuilder(context, index, _dramaMovies[index], _dramaSizes);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
