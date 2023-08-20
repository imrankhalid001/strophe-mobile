// ignore_for_file: prefer_const_declarations

final String tablePoems = "poems";

class PoemFields {
  static final List<String> values = [id, isFavorite, title, author, content];

  static final String id = "_id";
  static final String isFavorite = 'isFavorite';
  static final String title = "title";
  static final String author = "author";
  static final String content = "content";
}

class Poem {
  final int? id;
  final bool isFavorite;
  final String title;
  final String author;
  final String content;

  const Poem({
    this.id,
    required this.isFavorite,
    required this.title,
    required this.author,
    required this.content,
  });

  Poem copy({
    int? id,
    bool? isFavorite,
    String? title,
    String? author,
    String? content,
  }) =>
      Poem(
        id: id ?? this.id,
        isFavorite: isFavorite ?? this.isFavorite,
        title: title ?? this.title,
        author: author ?? this.author,
        content: content ?? this.content,
      );

  static Poem fromJson(Map<String, Object?> json) => Poem(
        id: json[PoemFields.id] as int?,
        isFavorite: json[PoemFields.isFavorite] == 1,
        title: json[PoemFields.title] as String,
        author: json[PoemFields.author] as String,
        content: json[PoemFields.content] as String,
      );

  Map<String, Object?> toJson() => {
        PoemFields.id: id,
        PoemFields.isFavorite: isFavorite ? 1 : 0,
        PoemFields.title: title,
        PoemFields.author: author,
        PoemFields.content: content,
      };
}
