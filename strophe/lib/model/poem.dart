// ignore_for_file: prefer_const_declarations

final String tablePoems = "poems";

class PoemFields {
  static final List<String> values = [id, title, author, content];

  static final String id = "_id";
  static final String title = "title";
  static final String author = "author";
  static final String content = "content";
}

class Poem {
  final int? id;
  final String title;
  final String author;
  final String content;

  const Poem({
    this.id,
    required this.title,
    required this.author,
    required this.content,
  });

  Poem copy({
    int? id,
    String? title,
    String? author,
    String? content,
  }) =>
      Poem(
        id: id ?? this.id,
        title: title ?? this.title,
        author: author ?? this.author,
        content: content ?? this.content,
      );

  static Poem fromJson(Map<String, Object?> json) => Poem(
        id: json[PoemFields.id] as int?,
        title: json[PoemFields.title] as String,
        author: json[PoemFields.author] as String,
        content: json[PoemFields.content] as String,
      );

  Map<String, Object?> toJson() => {
        PoemFields.id: id,
        PoemFields.title: title,
        PoemFields.author: author,
        PoemFields.content: content,
      };
}
