import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_view/pagination_view.dart';

class FlickrPhoto {
  final String id;
  final String owner;
  final String title;
  final String imageUrl;

  FlickrPhoto({
    required this.id,
    required this.owner,
    required this.title,
    required this.imageUrl,
  });

  factory FlickrPhoto.fromJson(Map<String, dynamic> json) {
    return FlickrPhoto(
      id: json['id'] ?? '',
      owner: json['owner'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['url_s'] ?? '',
    );
  }
}

abstract class FlickrEvent {}

class FetchPhotosEvent extends FlickrEvent {
  final int page;

  FetchPhotosEvent({required this.page});
}

abstract class FlickrState {}

class FlickrInitialState extends FlickrState {}

class FlickrLoadedState extends FlickrState {
  final List<FlickrPhoto> photos;
  final bool hasReachedMax;

  FlickrLoadedState({required this.photos, required this.hasReachedMax});
}

class FlickrErrorState extends FlickrState {
  final String error;

  FlickrErrorState({required this.error});
}

class FlickrBloc extends Bloc<FlickrEvent, FlickrState> {
  final http.Client httpClient;

  FlickrBloc({required this.httpClient}) : super(FlickrInitialState());

  @override
  Stream<FlickrState> mapEventToState(FlickrEvent event) async* {
    if (event is FetchPhotosEvent) {
      yield* _mapFetchPhotosEventToState(event.page);
    }
  }

  Stream<FlickrState> _mapFetchPhotosEventToState(int page) async* {
    try {
      final Uri url = Uri.parse(
        'https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6f102c62f41998d151e5a1b48713cf13&format=json&nojsoncallback=1&extras=url_s&text=cat&page=$page',
      );

      final response = await httpClient.get(url);

      if (response.statusCode == 200) {
        final jsonString = response.body.replaceFirst('jsonFlickrApi(', '').replaceAll(')', '');
        final Map<String, dynamic> data = json.decode(jsonString);
        final List<dynamic> photoList = data['photos']['photo'];

        final isLastPage = data['photos']['page'] == data['photos']['pages'];

        if (isLastPage) {
          yield FlickrLoadedState(
            photos: photoList.map((json) => FlickrPhoto.fromJson(json)).toList(),
            hasReachedMax: true,
          );
        } else {
          yield FlickrLoadedState(
            photos: photoList.map((json) => FlickrPhoto.fromJson(json)).toList(),
            hasReachedMax: false,
          );
        }
      } else {
        throw Exception('Failed to load photos');
      }
    } catch (error) {
      yield FlickrErrorState(error: error.toString());
    }
  }
}

class Flicker extends StatefulWidget {
  const Flicker({Key? key}) : super(key: key);

  @override
  State<Flicker> createState() => _FlickerState();
}

class _FlickerState extends State<Flicker> {
  final _scrollController = ScrollController();
  late FlickrBloc _flickrBloc;

  @override
  void initState() {
    super.initState();
    _flickrBloc = FlickrBloc(httpClient: http.Client())..add(FetchPhotosEvent(page: 1));

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _flickrBloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _flickrBloc.add(FetchPhotosEvent(page: _flickrBloc.state is FlickrLoadedState
          ? (_flickrBloc.state as FlickrLoadedState).photos.length ~/ 10 + 1
          : 1));
    }
  }

  bool get _isBottom {
    return _scrollController.position.pixels == _scrollController.position.maxScrollExtent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flickr Assignment 2'),
      ),
      body: BlocBuilder<FlickrBloc, FlickrState>(
        bloc: _flickrBloc,
        builder: (context, state) {
          if (state is FlickrInitialState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is FlickrLoadedState) {
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax
                  ? state.photos.length
                  : state.photos.length + 1,
              itemBuilder: (context, index) {
                return index >= state.photos.length
                    ? BottomLoader()
                    : Card(
                        margin: EdgeInsets.all(10.0),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                state.photos[index].imageUrl,
                                height: 200.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                state.photos[index].title,
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
              },
            );
          } else if (state is FlickrErrorState) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
