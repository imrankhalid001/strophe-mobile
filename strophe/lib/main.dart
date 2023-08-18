// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchRandomPoem() async {
  final response = await http.get(Uri.parse("https://poetrydb.org/random"));

  print("Grabbing new poems");
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data[0];
  } else {
    throw Exception("Failed to fetch a random poem");
  }
}

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Strophe"),
        backgroundColor: Color.fromRGBO(57, 54, 70, 1.0),
        centerTitle: true,
      ),
      body: PoemWidget(),
    );
  }
}

class PoemWidget extends StatefulWidget {
  const PoemWidget({
    super.key,
  });

  @override
  State<PoemWidget> createState() => _PoemWidgetState();
}

class _PoemWidgetState extends State<PoemWidget> {
  var poem = '';
  var title = '';
  var author = '';
  var lines = '';
  var content = '';

  Future<void> _fetchRandomPoem() async {
    final poemData = await fetchRandomPoem(); // new API call to grab new poem
    final title = poemData['title'];
    final author = poemData['author'];
    final lines = poemData['lines'];

    var content = '';

    for (int i = 0; i < lines.length; i++) {
      content += lines[i] + "\n";
    }

    setState(() {
      // updating existing/parent fields with values from new call
      this.title = title;
      this.author = author;
      this.content = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: fetchRandomPoem(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CircularProgressIndicator()); // display centered loading circle if data not ready for display
            }
            if (snapshot.hasData) {
              final poem = snapshot.data;
              final title = poem!['title'];
              final author = poem['author'];
              final lines = poem['lines'];
              var content = '';

              for (int i = 0; i < lines.length; i++) {
                content += lines[i] + "\n";
              }
              return SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: Column(children: [
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "$title",
                        style: TextStyle(fontSize: 32),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "$author",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        content,
                        style: TextStyle(fontSize: 24),
                      ),
                    ]),
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      bottomNavigationBar: Container(
          height: 50,
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FavoriteWidget(),
              IconButton(
                icon: Icon(Icons.shuffle),
                onPressed:
                    _fetchRandomPoem, // when pressed, reference function to grab from API and update UI
              ),
            ],
          )),
    );
  }
}

class FavoriteWidget extends StatefulWidget {
  const FavoriteWidget({
    super.key,
  });

  @override
  State<FavoriteWidget> createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  bool click = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(!(click) ? Icons.favorite_border_outlined : Icons.favorite),
      onPressed: () {
        setState(() {
          click = !click; // if false, set true and vice versa
        });
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    // wrapping with MaterialApp widget is crucial or else code breaks
    home: MyScaffold(),
    title: "Strophe",
    theme: ThemeData(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    ),
  ));
}
