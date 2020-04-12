import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WordRoute extends StatelessWidget {
  final WordModel record;
  WordRoute({Key key, @required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word: ${record.learnWord}'),
      ),
      body: WordPage(record: record),
    );
  }
}

class WordPage extends StatefulWidget {
  final WordModel record;
  WordPage({Key key, @required this.record}) : super(key: key);

  @override
  WordPageState createState() {
    return WordPageState(record);
  }
}

class WordPageState extends State<WordPage> {
  var record;
  WordPageState(record) {
    this.record = record;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey(record.learnWord),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListView(
          padding: const EdgeInsets.only(top: 20.0),
          children:
            ListTile.divideTiles(
              context: context,
              tiles: [
                ListTile(
                  title: Text('Word ID'),
                  trailing: Text(record.wordId.toString()),
                ),
                ListTile(
                  title: Text('Learn Word'),
                  trailing: Text(record.learnWord.toString()),
                ),
                ListTile(
                  title: Text('Native Word'),
                  trailing: Text(record.nativeWord.toString()),
                ),
                ListTile(
                  title: Text('Progress'),
                  trailing: Text(record.progress.toString()),
                ),
                ListTile(
                  title: Text('Start'),
                  trailing: Text(timeago.format(record.start.toDate())),
                ),
              ],
              color: Colors.black12,
            ).toList(),
        ),
      ),
    );
  }
}

class WordModel {
  String learnWord;
  String nativeWord;
  int progress;
  Timestamp start;
  String wordId;

  WordModel(
      {this.learnWord,
        this.nativeWord,
        this.progress,
        this.start,
        this.wordId});

  factory WordModel.fromFireStore(DocumentSnapshot doc) {
    Map data = doc.data;
    return WordModel(
      learnWord: data['learnword'],
      nativeWord: data['nativeword'],
      progress: data['progress'],
      start: data['start'],
      wordId: doc.documentID,
    );
  }
}