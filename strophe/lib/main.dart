// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key});

  Future<Map<String, dynamic>> fetchRandomPoem() async {
    final response = await http.get(Uri.parse("https://poetrydb.org/random"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data[0];
    } else {
      throw Exception("Failed to fetch a random poem");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Strophe"),
          backgroundColor: Color.fromRGBO(57, 54, 70, 1.0),
          centerTitle: true,
        ),
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
            }));
  }
}

void main() {
  runApp(MaterialApp(
    // wrapping with MaterialApp widget is crucial or else code breaks
    home: MyScaffold(),
    title: "Strophe",
  ));
}
