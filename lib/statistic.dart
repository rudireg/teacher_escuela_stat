import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'students.dart';

class StatisticRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistic'),
      ),
      body: StatisticPage(),
    );
  }
}

class StatisticPage extends StatefulWidget {
  @override
  StatisticPageState createState() {
    return StatisticPageState();
  }
}

class StatisticPageState extends State<StatisticPage> {
  final studentsRef = Firestore.instance.collection('students');
  String _totalStudents = '...';
  String _hasMoreThanOneCount = '...';
  String _hasNewWordsLast24Hours = '...';
  String _largestSetOfWords = '...';
  String _emailLargestSetOfWords = '';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(4),
          height: 50,
          color: Colors.blue[100],
          child: ListTile(
            onTap: _getAllStudents,
            title: Text('All students:'),
            trailing: Text(this._totalStudents),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(4),
          height: 50,
          color: Colors.blue[100],
          child: ListTile(
            onTap: _getHasMoreThanOneCount,
            title: Text('Students has > 1 words:'),
            trailing: Text(this._hasMoreThanOneCount),
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.all(4),
          color: Colors.blue[100],
          child: ListTile(
            onTap: _getHasNewWordsLast24Hours,
            title: Text('Students has new words last 24 hours:'),
            trailing: Text(this._hasNewWordsLast24Hours),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(4),
          height: 50,
          color: Colors.blue[100],
          child: ListTile(
            onTap: _getLargestSetOfWords,
            title: Text('The largest set of words ($_emailLargestSetOfWords):'),
            trailing: Text(this._largestSetOfWords),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(4),
          height: 50,
          color: Colors.blue[100],
          child: ListTile(
            onTap: _shareStudentsEmail,
            title: Text('Share student\'s email'),
          ),
        ),
      ],
    );
  }

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    _getAllStudents();
    _getHasMoreThanOneCount();
    _getHasNewWordsLast24Hours();
    _getLargestSetOfWords();
  }

  // get all students
  Future _getAllStudents() async {
    setState(() {
      this._totalStudents = '...';
    });
    var query = Firestore.instance.collection('students');
    var querySnapshot = await query.getDocuments();
    int length = querySnapshot.documents.length;
    setState(() {
      this._totalStudents = length.toString();
    });
  }

  // get students who has more than one word
  Future _getHasMoreThanOneCount() async {
    int count = 0;
    setState(() {
      this._hasMoreThanOneCount = '...';
    });
    var querySnapshot = await studentsRef.getDocuments();
    querySnapshot.documents.forEach((DocumentSnapshot student) async {
      var wordsSnapshot =
          await student.reference.collection('words').getDocuments();
      if (wordsSnapshot.documents.length > 1) {
        count++;
        setState(() {
          this._hasMoreThanOneCount = count.toString();
        });
      }
    });
  }

  // Get how many students has new words last 24 hours
  Future _getHasNewWordsLast24Hours() async {
    int count = 0;
    DateTime today = new DateTime.now();
    DateTime oneDayAgo = today.subtract(new Duration(days: 1));
    setState(() {
      this._hasNewWordsLast24Hours = '...';
    });
    var querySnapshot = await studentsRef.getDocuments();
    querySnapshot.documents.forEach((DocumentSnapshot student) async {
      var wordsSnapshot = await student.reference
          .collection('words')
          .where('start', isGreaterThan: oneDayAgo)
          .getDocuments();
      if (wordsSnapshot.documents.length > 0) {
        count++;
      }
      setState(() {
        this._hasNewWordsLast24Hours = count.toString();
      });
    });
  }

  // The largest set of words
  Future _getLargestSetOfWords() async {
    int maxCount = 0;
    setState(() {
      this._largestSetOfWords = '...';
      this._emailLargestSetOfWords = '';
    });
    var querySnapshot = await studentsRef.getDocuments();
    querySnapshot.documents.forEach((DocumentSnapshot student) async {
      var wordsSnapshot =
          await student.reference.collection('words').getDocuments();
      var len = wordsSnapshot.documents.length;
      if (len > maxCount) {
        maxCount = len;
        setState(() {
          this._emailLargestSetOfWords = student.data['email'] ?? '';
          this._largestSetOfWords = maxCount.toString();
        });
      }
    });
  }

  // Share student's emails
  Future _shareStudentsEmail() async {
    List<Record> students = [];
    var querySnapshot = await studentsRef.getDocuments();
    querySnapshot.documents.forEach((DocumentSnapshot student) {
      students.add(Record.fromSnapshot(student));
    });
    // save emails to local file
    File file = await saveEmails(students);
    await _shareFile(file.path);
  }

  // Get local path of App
  Future<String> get _localPath async {
//    final directory = await getApplicationDocumentsDirectory();
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  // Create a reference to the file location
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/student_emails.txt');
  }

  // Write data to the file
  Future<File> saveEmails(List<Record> students) async {
    final file = await _localFile;
    List<String> emails = [];
    students.forEach((Record record) {
      if (record.email.isNotEmpty) {
        emails.add(record.email);
      }
    });
    file.writeAsString(emails.join('\r\n'));
    return file;
  }

  // share files
  Future<void> _shareFile(String filePath) async {
    await FlutterShare.shareFile(
      title: 'Students Email share',
      text: 'Shared Students Email list',
      filePath: filePath,
    );
  }
}
