import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/database/database.dart';
import 'package:todo_list/models/note_model.dart';
import 'package:todo_list/screens/add_note_screen.dart';

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

   late Future<List<Note>> _noteList;

  final DateFormat _dateFormatter = DateFormat('MM dd, yyyy');

  DatabaseHelper _databaseHelper = DatabaseHelper.instance;


  void initState(){
     super.initState();
     _updateNoteList();
   }

  _updateNoteList(){
    _noteList = DatabaseHelper.instance.getNoteList();
  }

  Widget buildNote(Note note){
    return Padding(
        padding:EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          ListTile(
            title: Text(note.title!, style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              decoration: note.status == 0
                ? TextDecoration.none
                  : TextDecoration.lineThrough

            ),
            ),
            subtitle: Text('${_dateFormatter.format(note.date!)} - ${note.priority}', style: TextStyle(
              fontSize: 15.0,
              color: Colors.white,
                decoration: note.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough

            ),
            ),
            trailing: Checkbox(
              onChanged: (value){
                note.status = value! ? 1 : 0;
                DatabaseHelper.instance.updateNote(note);
                _updateNoteList();

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
              },
              activeColor: Theme.of(context).primaryColor,
              value: note.status == 1 ? true : false
            ),
            onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => AddNoteScreen(
              updateNoteList: _updateNoteList(),
              note: note
            ),
            ),
            ),
          ),
          Divider(height: 5.0, color: Colors.deepPurple, thickness: 2.0,)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(builder: (_) => AddNoteScreen(
            updateNoteList: _updateNoteList,
          ) ));
        },
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _noteList,
        builder: (context, AsyncSnapshot<List<Note>> snapshot ) {
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final int completeNoteCount = snapshot.data!.where((Note note) => note.status ==1).toList().length;


        return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 80.0),
              itemCount: int.parse(snapshot.data!.length.toString()) +1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Notes',
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10.0,),
                        Text(
                          '$completeNoteCount of ${snapshot.data!.length}',
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }
                return buildNote(snapshot.data![index - 1]);
              }
          );

        }
      ),
    );
  }
}
