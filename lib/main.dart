import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twilio_whatsapp/config/config.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //For the message
  String strPhoneNumber = "", strMessage = "";

  //For loading
  bool blLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Flutter Whatsapp message Demo")),
      body: ListView(
        children: <Widget>[
          //To phone number
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(labelText: "Enter the receiver's phone number"),
              onChanged: (val) {
                setState(() {
                  strPhoneNumber = val;
                });
              },
            ),
          ),

          //Message
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Enter the Message you want to send",
              ),
              minLines: 5,
              maxLines: 10,
              onChanged: (val) {
                setState(() {
                  strMessage = val;
                });
              },
            ),
          ),

          //Message
        ],
      ),
      floatingActionButton: blLoading

          //When loading
          ? FloatingActionButton.extended(
              icon: Icon(Icons.sync_problem),
              label: Text("Loading"),
            )

          //When Loaded
          : FloatingActionButton.extended(
              onPressed: () => sendWhatsAppMessage(),
              icon: Icon(Icons.send),
              label: Text("Send Message"),
            ),
    );
  }

  sendWhatsAppMessage() async {
    //Send the message on whatsapp
    if (strMessage != null && strMessage != "" && strPhoneNumber != null && strPhoneNumber != "") {
      //Start loading
      setState(() => blLoading = true);

      APIKeys apiKeys = new APIKeys();

      //Send the message
      // try{
      //   BaseOptions options = BaseOptions(
      //     baseUrl: "https://api.twilio.com",
      //     connectTimeout: 5000,
      //     receiveTimeout: 3000,
      //   );
      //   Dio dio = Dio(options);
      //   var response = await dio.post(
      //     "/2010-04-01/Accounts/" + apiKeys.accountId + "/Messages.json",
      //     data: FormData.fromMap({"Username": apiKeys.accountId, "Password": apiKeys.authToken}),
      //   );
      // }catch(e){}

      var response = await http.post(
        //url
        "https://api.twilio.com/2010-04-01/Accounts/" + apiKeys.accountId + "/Messages.json",

        //headers
        headers: {
          'Authorization': 'Basic ' + base64Encode(utf8.encode(apiKeys.accountId + ':' + apiKeys.authToken)),
          "Content-Type": "application/x-www-form-urlencoded"
        },

        //body
        body: <String, String>{
          "To": "whatsapp:" + strPhoneNumber,
          "From": "whatsapp:+14155238886",
          "Body": strMessage,
        },
        encoding: Encoding.getByName("utf-8"),
      );

      if (response.statusCode == 200) {
        print(response.body);
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Message sent!")));
      } else {
        print(response.body);
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Error sending the message")));
      }

      //Stop loading
      setState(() => blLoading = false);
    } else {
      //Show the error message
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please enter all the fields")));
    }
  }
}
