import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_photos/blocs/blocs.dart';
import 'package:flutter_photos/widgets/widgets.dart';

class PhotosScreen extends StatefulWidget {
  @override
  _PhotosScreenState createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset ==
                _scrollController.position.maxScrollExtent &&
            context.read<PhotosBloc>().state.status !=
                PhotosStatus.paginating) {
          context.read<PhotosBloc>().add(
                PhotosPaginate(),
              );
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: const Text('Photos Screen'),
          ),
        ),
        body: BlocConsumer<PhotosBloc, PhotosState>(
          listener: (context, state) {
            if (state.status == PhotosStatus.paginating) {
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(const SnackBar(
                backgroundColor: Colors.green,
                content: Text('Loading More Photos...'),
                duration: Duration(seconds: 1),
              ));
            } else if (state.status == PhotosStatus.noMorePhotos) {
              Scaffold.of(context).showSnackBar(const SnackBar(
                backgroundColor: Colors.red,
                content: Text('No More Photos.'),
                duration: Duration(milliseconds: 1500),
              ));
            } else if (state.status == PhotosStatus.error) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Search Error'),
                  content: Text(state.failure.message),
                  actions: [
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4.0,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                              // suffixIcon: Icon(Icons.search),
                              hintStyle: TextStyle(fontSize: 17),
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                context
                                    .read<PhotosBloc>()
                                    .add(PhotosSearchPhotos(query: val.trim()));
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: state.photos.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: GridView.builder(
                                controller: _scrollController,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  mainAxisSpacing: 15.0,
                                  crossAxisSpacing: 15.0,
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                ),
                                itemBuilder: (context, index) {
                                  final photo = state.photos[index];
                                  return PhotoCard(
                                    photo: photo,
                                    photos: state.photos,
                                    index: index,
                                  );
                                },
                                itemCount: state.photos.length,
                              ),
                            )
                          : Center(
                              child: Text('No Reslut'),
                            ),
                    )
                  ],
                ),
                if (state.status == PhotosStatus.loading)
                  CircularProgressIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }
}
