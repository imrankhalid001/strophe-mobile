// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import, avoid_print, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:strophe/db/fav_poems_database.dart';
import 'package:strophe/model/poem.dart';

var currentPoem;
var id;

Future<Map<String, dynamic>> fetchRandomPoem() async {
  final response = await http.get(Uri.parse("https://poetrydb.org/random"));
  id = DateTime.now()
      .millisecondsSinceEpoch; // set id to unique value every time new poem is fetched

  if (response.statusCode == 200) {
    final utfData = utf8.decode(response.bodyBytes);
    final data = json.decode(utfData);
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

    currentPoem = Poem(
        // create Poem object with these values
        id: id,
        title: title,
        author: author,
        content: content,
        isFavorite:
            false); // figure out way to change this value (probably need setter in db module)

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
              currentPoem = Poem(
                  // make sure to do it here too!
                  id: id,
                  title: title,
                  author: author,
                  content: content,
                  isFavorite: false);

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
                        "By: $author",
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
              MenuWidget()
            ],
          )),
    );
  }
}

class MenuWidget extends StatelessWidget {
  const MenuWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.collections_bookmark_outlined),
      onPressed: () {
        // changes screen to something else
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SavedPoems()),
        );
      }, // placeholder method being used
    );
  }
}

class SavedPoems extends StatefulWidget {
  const SavedPoems({
    super.key,
  });

  @override
  State<SavedPoems> createState() => _SavedPoemsState();
}

class _SavedPoemsState extends State<SavedPoems> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Favorited Poems'),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(57, 54, 70, 1.0),
        ),
        body: Center(
          child: FutureBuilder(
              future: PoemsDatabase.instance.readAllPoems(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Poem>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return displaySavedPoems(snapshot.data![index]);
                      });
                } else {
                  return Center(
                    child: Text(
                      "No Data Found",
                    ),
                  );
                }
              }),
        ));
  }

  Widget displaySavedPoems(Poem data) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "${data.title}",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "By: ${data.author}",
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              )
            ])));
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
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border_outlined),
      color: Colors.red,
      onPressed: () async {
        print(await PoemsDatabase.instance
            .readAllPoems()); // find way to iterate through list of poems to check if current poem exists in db already
        if (isFavorite) {
          await PoemsDatabase.instance.delete(currentPoem.id);
          print(
              "DELETED"); // BUG: if you favorite poem and then shuffle, heart will remain, and if you unfavorite, it will delete poem even though it hasn't been inserted yet
        } else {
          await PoemsDatabase.instance.create(currentPoem);
          print("ADDED");
        }
        setState(() {
          isFavorite = !isFavorite;
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
