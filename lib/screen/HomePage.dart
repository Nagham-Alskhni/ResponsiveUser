import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_user/screen/CreatItem.dart';
import 'package:responsive_user/models/posts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Posts> posts;

  @override
  void initState() {
    Firebase.initializeApp().whenComplete(() => setState(() {}));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,

            // we need to send the user position when creating new item
            // because we need the item to have a location
            MaterialPageRoute(builder: (context) => CreatItem()),
          );
        },
      ),
      body: Firebase.apps?.length == 0
          ? CircularProgressIndicator()
          : Container(
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null)
                      return CircularProgressIndicator();
                    else {
                      posts = snapshot.data.docs.map((doc) {
                        final data = doc.data();
                        return Posts(
                            documentId: doc.reference.id,
                            userName: data['userName'],
                            like: data['like'] ??
                                false, //if like is null, make it false by default
                            image: data['image'],
                            likesCount: data['likeCount'],
                            userComment: data['comments']?.map((commentDoc) {
                              return Comments(
                                  userName: commentDoc['userName'],
                                  body: commentDoc['body'],
                                  timestamp: commentDoc['timestamp']?.toDate());
                            })?.toList());
                      }).toList();
                    }
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          String commentText;

                          return Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            child: Image(
                                              image: NetworkImage(
                                                  posts[index].image),
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(posts[index].userName)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Image(image: NetworkImage(posts[index].image)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        posts[index].like == true
                                            ? Icons.thumb_up
                                            : Icons.thumb_down,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(posts[index].documentId)
                                            .update(
                                                {'like': !posts[index].like});
                                      },
                                    ),
                                  ],
                                ),
                                if (posts[index].userComment != null)
                                  ListView.builder(
                                      itemCount:
                                          posts[index].userComment.length,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, i) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: <Widget>[
                                              CircleAvatar(
                                                child: Text(
                                                  posts[index]
                                                      .userComment[i]
                                                      .userName
                                                      .toString()
                                                      .substring(0, 1),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(posts[index]
                                                    .userComment[i]
                                                    .body),
                                              )
                                            ],
                                          ),
                                        );
                                      }),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.comment),
                                        onPressed: () {},
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          onChanged: (value) =>
                                              commentText = value,
                                          decoration: InputDecoration(
                                              hintText: 'write a comment',
                                              suffixIcon: IconButton(
                                                icon: Icon(Icons.send),
                                                onPressed: () {
                                                  print('send');

                                                  FirebaseFirestore.instance
                                                      .collection('posts')
                                                      .doc(posts[index]
                                                          .documentId)
                                                      .update({
                                                    'comments':
                                                        FieldValue.arrayUnion([
                                                      {
                                                        'userName': 'Test User',
                                                        'body': commentText,
                                                        'timestamp':
                                                            DateTime.now()
                                                      }
                                                    ])
                                                  });
                                                },
                                              )),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 14),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: RichText(
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Liked By :',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: 'nagham',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        });
                  }),
            ),
    );
  }
}
