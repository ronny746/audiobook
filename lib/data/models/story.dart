class Episode {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String duration;
  final String sourceType;
  final String playType;
  final bool downloadable;

  Episode({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.duration,
    this.sourceType = "direct",
    this.playType = "youtube",
    this.downloadable = false,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id']?.toString() ?? "",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      audioUrl: json['audioUrl'] ?? "",
      duration: json['duration'] ?? "",
      sourceType: json['sourceType'] ?? "direct",
      playType: json['playType'] ?? "youtube",
      downloadable: json['downloadable'] ?? false,
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
      'playType': playType,
      'downloadable': downloadable,
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
  final String playType;
  final String actionLabel;
  final String? youtubePlaylist;
  final int totalEpisodes;
  final String? mp3Url;
  final List<Episode> episodes;

  Podcast({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.category,
    this.playType = "detail",
    this.actionLabel = "Play",
    this.youtubePlaylist,
    this.totalEpisodes = 0,
    this.mp3Url,
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
      playType: json['playType'] ?? "detail",
      actionLabel: json['actionLabel'] ?? "Play",
      youtubePlaylist: json['youtubePlaylist'],
      totalEpisodes: json['totalEpisodes'] ?? 0,
      mp3Url: json['mp3Url'],
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
      'playType': playType,
      'actionLabel': actionLabel,
      'youtubePlaylist': youtubePlaylist,
      'totalEpisodes': totalEpisodes,
      'mp3Url': mp3Url,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }
}
