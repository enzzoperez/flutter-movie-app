import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './models/detailMovieModel.dart';
import './models/movieModel.dart';
import 'package:intl/intl.dart';

const baseUrl = 'https://api.themoviedb.org/3/movie';
const baseImagesUrl = 'https://image.tmdb.org/t/p';
const apiKey = '5e108caa732260241966f5fc85fb7b0f';

class MovieDetail extends StatefulWidget {
  final Results movie;

  MovieDetail({this.movie});

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  String movieDetailUrl;
  DetailMovieModel movieDetail;

  @override
  void initState() {
    super.initState();
    movieDetailUrl = '$baseUrl/${widget.movie.id}?api_key=$apiKey';
    _fetchMovieDetail();
  }

  _fetchMovieDetail() async {
    var response = await http.get(movieDetailUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      movieDetail = DetailMovieModel.fromJson(decodeJson);
    });
  }

  @override
  Widget build(BuildContext context) {
    final moviePoster = Container(
      height: 350,
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: Hero(
        tag: widget.movie.heroTag,
        child: Image.network(
          '$baseImagesUrl/w342${widget.movie.posterPath}',
          fit: BoxFit.contain,
        ),
      ),
    );
    return Scaffold(
        appBar: AppBar(
          elevation: 20,
          centerTitle: true,
          title: Text('MOVIE APP'),
        ),
        body: ListView(
          children: <Widget>[
            moviePoster,
          ],
        ));
  }
}
