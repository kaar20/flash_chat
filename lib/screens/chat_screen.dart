import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;
var loggedIn;

class ChatScreen extends StatefulWidget {
  static const String id = "chat_Screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgClear = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? mesg;

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedIn = user;
      print(loggedIn);
    }
  }

  // void getMesseges() async {
  //   final messeges = await _fireStore.collection('userInfo').get();
  //   for (var msg in messeges.docs) {
  //     print(msg.data());
  //   }
  // }
  void getMesseges() async {
    await for (var snap in _fireStore.collection('userInfo').snapshots()) {
      for (var msg in snap.docs) {
        print(msg.data());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                getMesseges();
                //Implement logout functionality
                // _auth.signOut();
                // Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            msgStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: msgClear,
                      // controller: _clear,
                      onChanged: (value) {
                        mesg = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      msgClear.clear();
                      // _clear.clear();
                      _fireStore.collection('userInfo').add({
                        'sender': loggedIn.email,
                        'text': mesg,
                      });

                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class msgStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('userInfo').snapshots(),
      builder: (context, snapshot) {
        final msg = snapshot.data!.docs;
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent),
          );
        }
        List<bubble> msgWidgets = [];
        for (var messages in msg) {
          // final info = messages.data('text');
          final msgText = messages.get('text');
          final msgSender = messages.get('sender');
          //  msgSender ==loggedIn.email
          final currentUser = loggedIn.email;

          final msgwidget = bubble(
            text: msgText,
            sender: msgSender,
            isMe: currentUser == msgSender,
          );

          // final msgwidget =
          msgWidgets.add(msgwidget);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: msgWidgets,
          ),
        );
      },
    );
  }
}

class bubble extends StatelessWidget {
  bubble({required this.text, required this.sender, required this.isMe});
  final String sender;
  final String text;
  final bool? isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          Material(
            elevation: 5,
            borderRadius: isMe!
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
            color: isMe! ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 15, color: isMe! ? Colors.white : Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
