import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'student_words.dart';

class StudentsRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Students List'),
        ),
        body: StudentPage());
  }
}

class StudentPage extends StatefulWidget {
  @override
  StudentPageState createState() {
    return StudentPageState();
  }
}

class StudentPageState extends State<StudentPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('students').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
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
    final record = Record.fromSnapshot(data);
    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
          trailing: Text(record.email.toString()),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => StudentWordsRoute(name: record.name, documentID: data.documentID)
                )
            );
          },
        ),
      ),
    );
  }
}

class Record {
  final String id;
  final String email;
  final String name;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'] ?? '',
        email = map['email'] ?? '',
        name = map['name'] ?? '';

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$email>";
}
