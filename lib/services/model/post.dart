class Post {
  final String id;
  final String title;
  final String author;
  final List<Content> content;

  Post({required this.id, required this.title, required this.author, required this.content});

  factory Post.fromJson(Map<String, dynamic> json) {
    var contentList = json['content'] as List;
    List<Content> contentObjects = contentList.map((i) => Content.fromJson(i)).toList();

    return Post(
      id: json['_id'],
      title: json['title'],
      author: json['author'],
      content: contentObjects,
    );
  }
}

class Content {
  final String headline;
  final String text;

  Content({required this.headline, required this.text});

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      headline: json['headline'] ?? "",
      text: json['text'] ?? "",
    );
  }
}
