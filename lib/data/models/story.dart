class Episode {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String duration;
  final String sourceType;

  Episode({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.duration,
    this.sourceType = "direct",
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id']?.toString() ?? "",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      audioUrl: json['audioUrl'] ?? "",
      duration: json['duration'] ?? "",
      sourceType: json['sourceType'] ?? "direct",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'duration': duration,
      'sourceType': sourceType,
    };
  }
}

class Podcast {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String author;
  final String category;
  final List<Episode> episodes;

  Podcast({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.category,
    required this.episodes,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    var episodesList = json['episodes'] as List? ?? [];
    return Podcast(
      id: json['id']?.toString() ?? "",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
      author: json['author'] ?? "",
      category: json['category'] ?? "",
      episodes: episodesList.map((e) => Episode.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'author': author,
      'category': category,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }
}
