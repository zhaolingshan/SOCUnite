import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:SoCUniteTwo/widgets/provider_widget.dart';
//import 'package:intl/intl.dart';
import 'package:SoCUniteTwo/screens/forum_screens/experiences/experience_details.dart';
import 'package:SoCUniteTwo/screens/forum_screens/experiences/experience.dart';

class MyPostsExperiences extends StatefulWidget {
  @override
  _MyPostsExperiencesState createState() => _MyPostsExperiencesState();
}

class _MyPostsExperiencesState extends State<MyPostsExperiences> {

  void _showDialog() { //to appear on owner's screen when report hits 5 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
   padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 20, bottom: 20),
   child:
        AlertDialog(
          backgroundColor: Colors.grey[850],
          title: new Text(
            "This post has been reported.",
            style: TextStyle(color: Colors.blue[300]),
            ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              Text(
                "Your post has been reported by several users for not abiding by the guidelines and has been deleted from public view. ",
                style: TextStyle(color: Colors.grey[100]),
              ),
              SizedBox(height:10,),
               Text(
                "Please take note of the guidelines before making a post.  ",
                style: TextStyle(color: Colors.grey[100]),
              )
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              color: Colors.blue[300],
              child: new Text(
                "Close",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          },
        ),
        backgroundColor: Colors.grey[850],
        title: Text("My posts: Internship Experiences"),
      ),
      body: Container(
        child: StreamBuilder(
          stream: getUserPrivateExperiencesStreamSnapshot(context),
          builder: (context, snapshot) {
            if(!snapshot.hasData) return 
            Center(child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
              CircularProgressIndicator()
            ],)); 
            return new ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (BuildContext context, int index) 
          => buildPrivateExperiences(context, 
          snapshot.data.documents[index])
          );
          } 
        )
        ),
    );
  }

  Stream<QuerySnapshot> getUserPrivateExperiencesStreamSnapshot(BuildContext context) async* {
    final uid = await Provider.of(context).auth.getCurrentUID();
    yield* Firestore.instance.collection('users').document(uid).collection('private_experiences').snapshots();
  }

  Widget buildPrivateExperiences(BuildContext context, DocumentSnapshot post) {
    final experience = Experience.fromSnapshot(post);
   return Container(
      child: Card(
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18.0)),
        child: InkWell(
          onTap: () {
            if (post['reported'].length >= 5) {
              _showDialog();
            } else {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => ExperienceDetails(experience: experience) //with this particular forum 
            ));
            }
          },
      child: Padding(
        padding: EdgeInsets.only(top: 4, bottom: 4),
                child: Column(
                  children: <Widget>[
                    Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 8),
                    child:
                    Row(children: <Widget>[
                      SizedBox(width: 10,),
                      Text('Uploaded on ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: Colors.grey[400]),),
                      Text(post['timestamp'], 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: Colors.grey[400]),),
                      Spacer(), 
                      IconButton(
                      iconSize: 30,
                      color: Colors.lightGreenAccent,
                      icon: Icon(Icons.delete_forever),
                      onPressed: () async {

                        final uid = await Provider.of(context).auth.getCurrentUID();
                        
                        //need to loop and delete from saved 

                        await Firestore.instance.collection('users').document(uid)
                        .collection('private_experiences').document(post.documentID).delete();

                        await Firestore.instance.collection('public').document('internship_experiences')
                        .collection('Offers').document(post.documentID).delete();

                      },)   
                    ],),
                    ),
                    SizedBox(height: 10),
                    Row(children: <Widget>[
                      SizedBox(width: 10,),
                      CircleAvatar(
                      backgroundImage: post['profilePicture'] != null ?
                      NetworkImage(post['profilePicture']) : 
                      NetworkImage('https://genslerzudansdentistry.com/wp-content/uploads/2015/11/anonymous-user.png'),
                      backgroundColor: Colors.grey,
                      radius: 20,),
                      SizedBox(width: 10,),
                      Text(post['username'], style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 16, decoration: TextDecoration.underline, color: Colors.grey[100]),
                    )],),
                    SizedBox(height: 10),
                    Padding( 
                    padding: EdgeInsets.only(top: 4, bottom: 8),
                    child:
                    Row(children: <Widget>[
                      SizedBox(width: 10,), 
                      Expanded(child:
                      Text(post['title'], style: TextStyle(fontSize: 18,
                      fontWeight:FontWeight.bold,  color: Colors.grey[100]))),
                    ],)),
                    Padding( 
                    padding: EdgeInsets.only(top: 4, bottom: 8),
                    child:
                    Row(children: <Widget>[
                      SizedBox(width: 10,), 
                      Text("Time period of internship: ", style: TextStyle(fontSize: 17,
                      fontWeight:FontWeight.bold,color: Colors.grey[100])),
                      SizedBox(width: 10,), 
                      Expanded(child:
                      Text(post['timePeriod'], style: TextStyle(fontSize: 17, color: Colors.grey[100]
                      ))),
                    ],)),
                    Padding( 
                    padding: EdgeInsets.only(top: 4, bottom: 8),
                    child:
                    Row(children: <Widget>[
                      SizedBox(width: 10,), 
                      Text("Company:", style: TextStyle(fontSize: 17,fontWeight:FontWeight.bold, color: Colors.grey[100]),),
                      SizedBox(width: 10,), 
                      Text(post['company'], style: TextStyle(fontSize: 17, color: Colors.grey[100]
                      )),
                    ],)),
                    Padding( 
                    padding: EdgeInsets.only(top: 4, bottom: 8),
                    child:
                    Row(children: <Widget>[
                      SizedBox(width: 10,), 
                      Text('Role:', style: TextStyle(fontSize: 17,fontWeight:FontWeight.bold, color: Colors.grey[100])),
                      SizedBox(width: 10,), 
                      Expanded(child: 
                      Text(post['role'], style: TextStyle(fontSize: 18,  color: Colors.grey[100])),)
                    ],)),
                    Padding( 
                    padding: EdgeInsets.only(top: 4, bottom: 8),
                    child:
                    Row(children: <Widget>[
                      SizedBox(width: 10,), 
                      Text("Details ", style: TextStyle(fontSize: 18,
                      fontWeight:FontWeight.bold,  color: Colors.grey[100])),
                    ],)),
                
                    Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 8),
                    child:
                    Row(children: <Widget>[
                      SizedBox(width: 10,),
                      Expanded(child:
                      Text(post['content'], style: TextStyle(fontSize: 17,  color: Colors.grey[100]),
                      overflow: TextOverflow.ellipsis, maxLines: 1,),),
                    ],)),
                    SizedBox(height: 20),
                    Row(children: <Widget>[
                      // SizedBox(width: 10,),
                      // Icon(Icons.comment, size: 26,
                      // color: Colors.tealAccent), 
                      // SizedBox(width: 6,),Text('0', style: TextStyle(color: Colors.grey[100]),), //change to icons
                      Spacer(),
                      Icon(Icons.thumb_up, size: 26, color: Colors.tealAccent),
                      SizedBox(width: 6,),
                      Text(post['upvotes'].values.where((e)=> e as bool).length.toString(), style: TextStyle(color: Colors.grey[100])),
                    SizedBox(width: 10,),],)
                ],)
      ),),)
            );
    }
}