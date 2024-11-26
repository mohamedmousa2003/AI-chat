import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? file;
  List messege = [];
  openGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      file = File(photo.path);
    }
  }

  TextEditingController textEditingController = TextEditingController();
  add() {
    if (file != null) {
      if (textEditingController.text.isNotEmpty) {
        setState(() {
          messege.add({
            "text": textEditingController.text,
            "sender": true,
            "image": file,
            "hasImage": true,
          });
        });
        Gemini gemini = Gemini.instance;
        gemini.textAndImage(
            text: textEditingController.text,

            /// text
            images: [file!.readAsBytesSync()]

            /// list of images
            ).then((value) {
          setState(() {
            messege.add({
              "text": value?.content?.parts?.last.text,
              "sender": false,
              "image": null,
              "hasImage": false,
            });
          });
        });
        file = null;
      }
    } else {
      if (textEditingController.text.isNotEmpty) {
        setState(() {
          messege.add({
            "text": textEditingController.text,
            "sender": true,
            "image": null,
            "hasImage": false, 
          });
        });
        Gemini gemini = Gemini.instance;
        gemini.text(textEditingController.text).then(
          (value) {
            setState(() {
              messege.add({
                "text": value?.output,
                "sender": false,
                "image": null,
                "hasImage": false,
              });
            });
          },
        );
      }
    }
    setState(() {
       textEditingController.text = "";
    });
   
  }

  String keyapi = "AIzaSyB4tvYYNGtoywJfLaKpNOUs1VpoK1BfFGA";
  @override
  void initState() {
    Gemini.init(apiKey: keyapi);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Shimmer.fromColors(
    baseColor: Colors.blue,
    highlightColor: Colors.red,
          child: const Text(
            "AI ",
            style: TextStyle(
              fontWeight: FontWeight.bold,color: Colors.white
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: ListView.builder(
              itemBuilder: (context, index) => Messege(
                  sender: messege[index]["sender"],
                  text: messege[index]["text"],
                  hasImage: messege[index]["hasImage"],
                  image: messege[index]["image"]),
              itemCount: messege.length,
            ),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12 , horizontal: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width *0.7,
                    height: 40,
                    child: TextFormField(
                      controller: textEditingController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300],
                          contentPadding: EdgeInsets.all(8.0),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(50))),
                      style: TextStyle(color: Colors.black),
                    )),
                SizedBox(
                  width: 8,
                ),
                GestureDetector(
                  onTap: () {
                    add();
                  },
                  child: Icon(
                    Icons.send,
                    color: Colors.blue,
                    size: 38,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                GestureDetector(
                  onTap: () {
                    openGallery();
                  },
                  child: Icon(
                    Icons.add_photo_alternate,
                    color: Colors.blue,
                    size: 35,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Messege extends StatelessWidget {
  final bool sender;
  final bool hasImage;
  final String text;
  final File? image;
  const Messege(
      {super.key,
      required this.sender,
      required this.text,
      required this.hasImage,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: (sender) ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          width: 300,
          child: Column(
            crossAxisAlignment:
                (sender) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (sender && hasImage)
                Container(
                    height: 200,
                    width: 300,   
                    decoration: BoxDecoration(
                        image:(image!=null)? DecorationImage(image: FileImage(image! ),fit: BoxFit.fill):null,
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15))),
              Container(
                constraints: BoxConstraints(maxWidth: (sender) ? 250 : 300),
                decoration: BoxDecoration(
                  color: (sender) ? Color.fromARGB(255, 0, 0, 0) : Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}