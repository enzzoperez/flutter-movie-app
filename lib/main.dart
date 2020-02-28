import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movieapp/models/movieModel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'detailMovieScreen.dart';

const baseUrl = 'https://api.themoviedb.org/3/movie';
const baseImagesUrl = 'https://image.tmdb.org/t/p';
const apiKey = '5e108caa732260241966f5fc85fb7b0f';
const nowPlayingURL = '$baseUrl/now_playing?api_key=$apiKey';
const incomingMoviesUrl = '$baseUrl/upcoming?api_key=$apiKey';
const popularMoviesUrl = '$baseUrl/popular?api_key=$apiKey';
const topRatedMoviesUrl = '$baseUrl/top_rated?api_key=$apiKey';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie App',
      theme: ThemeData.dark(),
      home: MyMovieApp(),
    ));

class MyMovieApp extends StatefulWidget {
  @override
  _MyMovieApp createState() => new _MyMovieApp();
}

class _MyMovieApp extends State<MyMovieApp> {
  Movie nowPlayingMovie;
  Movie incomingMovies;
  Movie popularMovies;
  Movie topRatedMovies;

  var heroTag = 0;
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPlayingMovies();
    _fetchIncomingMovies();
  }

  void _fetchPlayingMovies() async {
    var response = await http.get(nowPlayingURL);
    var decodeJSON = jsonDecode(response.body);
    setState(() {
      nowPlayingMovie = Movie.fromJson(decodeJSON);
    });
  }

  void _fetchIncomingMovies() async {
    var response = await http.get(incomingMoviesUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      incomingMovies = Movie.fromJson(decodeJson);
    });
  }

  Widget _buildCarrousel() => CarouselSlider(
        items: nowPlayingMovie == null
            ? <Widget>[
                Center(
                  child: CircularProgressIndicator(),
                )
              ]
            : nowPlayingMovie.results
                .map((movie) => _buildMovieItem(movie)).toList(),
        viewportFraction: 0.4,
        height: 250,
        autoPlay: false,
        enlargeCenterPage: true,
      );

  Widget _buildListItem(Results movieItem) => Material(
        child: Container(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(5),
                  child: _buildMovieItem(movieItem)),
              Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Text(
                  movieItem.title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 6, top: 3),
                child: Text(
                  DateFormat('yyyy').format(DateTime.parse(movieItem.releaseDate))
                )
              )
            ],
          ),
        ),
      );

  Widget _buildMovieItem(Results movieItem){
    heroTag += 1;
    movieItem.heroTag = heroTag ;
    return Material(
          elevation: 15,
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context)=> MovieDetail(movie: movieItem,)
              ));
            },
            child: Hero(
              tag: heroTag,
              child: Image.network(
                '$baseImagesUrl/w342${movieItem.posterPath}',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
  } 

  Widget _buildMovieList(Movie movie, String header) => Container(
        height: 300,
        padding: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text(header, style: TextStyle(color: Colors.red)),
            ),
            Flexible(
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: movie == null
                      ? <Widget>[
                          Center(
                            child: CircularProgressIndicator(),
                          )
                        ]
                      : movie.results.map((movie) => Padding(
                          padding: EdgeInsets.only(left: 7, right: 2),
                          child: _buildListItem(movie))).toList()
                          ),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          'My Movie App',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        leading: IconButton(icon: Icon(Icons.menu), onPressed: () => {}),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () => {}),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'NOW PLAYING',
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              expandedHeight: 350,
              floating: false,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: <Widget>[
                    Container(
                      child: Image.network(
                        '$baseImagesUrl/w500/h4VB6m0RwcicVEZvzftYZyKXs6K.jpg',
                        width: 1500.0,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.5),
                        colorBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: _buildCarrousel())
                  ],
                ),
              ),
            )
          ];
        },
        body: ListView(
          children: <Widget>[
            _buildMovieList(incomingMovies, 'COMING MOVISSSS')
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        currentIndex: _currentIndex,
        onTap: (int index){
          setState(()=>_currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_movies),
            title: Text('TODAS')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tag_faces),
            title: Text('TICKETS')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('PERFIL')
          ),
        ]
      ),
    );
  }
}
