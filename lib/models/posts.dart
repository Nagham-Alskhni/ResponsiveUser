class Posts {
  Posts(
      {this.userName,
      this.image,
      this.like,
      this.likesCount,
      this.userComment,
      this.documentId});
  String documentId;
  String image;
  String userName;
  int likesCount;
  bool like;
  List<dynamic> userComment;
}

class Comments {
  Comments({this.userName, this.body, this.timestamp});
  String userName;
  String body;
  DateTime timestamp;
}
