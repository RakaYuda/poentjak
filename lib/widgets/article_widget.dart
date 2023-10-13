import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/bloc/list_save_bloc.dart';
import 'package:test_app/models/articles.dart';
import '../bloc/article_bloc.dart';

import 'package:test_app/assets/style.dart';

class ArticleCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ArticleBloc _articleBloc = BlocProvider.of<ArticleBloc>(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.20,
      child: BlocBuilder<ArticleBloc, ArticleState>(
          bloc: _articleBloc,
          builder: (context, state) {
            if (state is ArticleLoading) {
              return WidgetCircularLoading();
            } else if (state is ArticleFailure) {
              return Center(
                child: Text('${state.errorMessage}'),
              );
            } else if (state is ArticleLoaded) {
              Articles articles = state.articles;
              return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: articles.listArticles.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    Article article = articles.listArticles[index];
                    // print(article);
                    return ArticleTile(article, false);
                    // return Text(article.article);
                  });
            } else {
              return Container(
                child: Text(state.toString()),
              );
            }
          }),
    );
  }
}

class ArticleTile extends StatelessWidget {
  final Article _article;
  bool isSaved = false;

  ArticleTile(this._article, this.isSaved);

  @override
  Widget build(BuildContext context) {
    ListSaveBloc _listSaveBloc = BlocProvider.of<ListSaveBloc>(context);

    void saveArticle(Operation operation) {
      Article article = _article;
      _listSaveBloc.add(ListSaveEvent(operation, article));
    }

    return Container(
      width: MediaQuery.of(context).size.width - 64,
      height: MediaQuery.of(context).size.height * 0.18 - 128,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Hero(
          tag: "article_" * _article.id,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Stack(fit: StackFit.expand, children: <Widget>[
                Image.network(_article.imgArticle, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: FractionalOffset.center,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                        Color(0x00000000),
                        darkBlue.withOpacity(1),
                      ],
                          stops: [
                        0.0,
                        1.0
                      ])),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 24, left: 24),
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            _article.titleArticle,
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                    child: new Material(
                        color: Colors.transparent,
                        child: new InkWell(onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ArticleWidgetDetail(_article)));
                        }))),
                BlocProvider<ListSaveBloc>(
                    create: (context) => _listSaveBloc,
                    child: BlocBuilder<ListSaveBloc, ListSaveState>(
                        bloc: _listSaveBloc,
                        builder: (context, state) {
                          return Positioned(
                            top: -8,
                            right: 6,
                            child: GestureDetector(
                              onTap: () {
                                saveArticle(Operation.add);
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        '"${_article.titleArticle}" added to save item')));
                                // print(state);
                              },
                              child: Icon(
                                (isSaved == true)
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          );
                        })),
              ]))),
    );
  }
}

class Carousel extends StatelessWidget {
  final List<Article> articles;

  Carousel(this.articles);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: articles.map((article) => ArticleTile(article, false)).toList(),
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.2,
        initialPage: 0,
        enlargeCenterPage: true,
        autoPlay: true,
        reverse: false,
        enableInfiniteScroll: true,
        autoPlayInterval: Duration(seconds: 2),
        autoPlayAnimationDuration: Duration(milliseconds: 2000),
        pauseAutoPlayOnTouch: false,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

class ArticleWidgetDetail extends StatefulWidget {
  final Article _article;

  ArticleWidgetDetail(this._article);

  @override
  _ArticleWidgetDetailState createState() => _ArticleWidgetDetailState();
}

class _ArticleWidgetDetailState extends State<ArticleWidgetDetail> {
  double progress = 0;

//  WebViewController _controller;

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Selected image'),
        // ),
        body: Column(
      children: <Widget>[
        Hero(
            tag: "article_" * widget._article.id,
            child: Stack(
              children: <Widget>[
                Container(
                    // height: 240,
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: MediaQuery.of(context).size.width,
                    child: FittedBox(
                      child: Image.network(
                        widget._article.imgArticle,
                      ),
                      fit: BoxFit.cover,
                    )),
                Positioned(
                    top: 200,
                    left: 48,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        widget._article.titleArticle,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none),
                      ),
                    ))
              ],
            )),
        // SizedBox(
        //   height: 32,
        // ),
//        Expanded(
//          child: WebView(
//            initialUrl: 'http://192.168.100.6:8081/articles/' +
//                widget._article.id.toString(),
//            javascriptMode: JavascriptMode.unrestricted,
//            // gestureRecognizers: Set()
//            //   ..add(
//            //     Factory<VerticalDragGestureRecognizer>(
//            //       () => VerticalDragGestureRecognizer(),
//            //     ),
//            //     // or null
//            //   ),
//          ),
//        ),
        drawerContent(removeAllHtmlTags(widget._article.article)),
//        Text(removeAllHtmlTags(widget._article.article))
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 32),
        //   child: Column(
        //     children: <Widget>[
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: <Widget>[
        //           Row(
        //             children: <Widget>[
        //               Container(
        //                 width: 36.0,
        //                 height: 36.0,
        //                 child: ClipRRect(
        //                   borderRadius: BorderRadius.circular(12),
        //                   child: Image.network(
        //                     _article.author.imgAuthor,
        //                     fit: BoxFit.cover,
        //                   ),
        //                 ),
        //               ),
        //               SizedBox(
        //                 width: 16,
        //               ),
        //               Text(
        //                 _article.author.nameAuthor,
        //                 style: TextStyle(
        //                     fontSize: 16, fontWeight: FontWeight.w500),
        //               ),
        //             ],
        //           ),
        //           Text(
        //             _article.postDate,
        //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        //           )
        //         ],
        //       ),
        //       SizedBox(
        //         height: 24,
        //       ),
        //       Text(
        //         _article.article,
        //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    ));
  }

  drawerContent(String article) {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      height: MediaQuery.of(context).size.height * 0.5,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: Text(
          article.length > 100 ? '${article.substring(0, 100)}...' : article),
    );
  }
}

//Loading Widget
class WidgetCircularLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Platform.isIOS
          ? CupertinoActivityIndicator()
          : CircularProgressIndicator(),
    );
  }
}
