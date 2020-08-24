import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_user/models/posts.dart';

class CreatItem extends StatefulWidget {
  @override
  _CreatItemState createState() => _CreatItemState();
}

class _CreatItemState extends State<CreatItem> {
  Posts posts;
  String images;
  String userName;

  File _image;
  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future uploadImage() async {
    FirebaseStorage storage =
        FirebaseStorage(storageBucket: 'gs://responsive-user.appspot.com');
    StorageReference ref = storage.ref().child(p.basename(_image.path));
    StorageUploadTask storageUploadTask = ref.putFile(_image);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    String url = await storageTaskSnapshot.ref.getDownloadURL(); //very good

    return url;
  }

  @override
  Widget build(BuildContext context) {
    String newPhotoUrl;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 3,
              child: _image == null
                  ? Center(child: Text('No image selected.'))
                  : Image.file(_image),
            ),
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: TextField(
                onChanged: (value) => userName = value,
                decoration: InputDecoration(
                  hintText: 'interyourName',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Row(
                  children: <Widget>[
                    RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Pick your image'),
                      ),
                      onPressed: getImage,
                    ),
                    RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Puplish'),
                      ),
                      onPressed: () async {
                        newPhotoUrl = await uploadImage();
                        await FirebaseFirestore.instance
                            .collection('posts')
                            .add(
                          {
                            'userName':
                                userName, //new item is created with TestUser userName
                            'image': newPhotoUrl,
                          },
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
            ),
          ],
        ),
      ),
    );
  }
}
