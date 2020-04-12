import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'word.dart';

class StudentWordsRoute extends StatelessWidget {
  final name;
  final String documentID;
  StudentWordsRoute({Key key, @required this.name, @required this.documentID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$name')
        ),
        body: StudentWordsPage(documentID: this.documentID),
    );
  }
}

class StudentWordsPage extends StatefulWidget {
  final String documentID;
  StudentWordsPage({Key key, @required this.documentID}) : super(key: key);

  @override
  StudentWordsPageState createState() {
    return StudentWordsPageState(this.documentID);
  }
}

class StudentWordsPageState extends State<StudentWordsPage> {
  String documentID;
  final List<WordModel> finalWordsList = [];
  StudentWordsPageState(String documentID) {
    this.documentID = documentID;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:  Firestore.instance.collection('students')
          .document(this.documentID)
          .collection("words").orderBy('start', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        //snapshot.data.documents.length.toString();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = WordModel.fromFireStore(data);
    return Padding(
      key: ValueKey(record.learnWord),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.learnWord.toString()),
          trailing: Text(record.nativeWord.toString()),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WordRoute(record: record)
                )
            );
          },
        ),
      ),
    );
  }
}
