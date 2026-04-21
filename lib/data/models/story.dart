class Episode {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String duration;
  final String sourceType;
  final String playType;
  final bool downloadable;
  final String? lyrics;

  Episode({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.duration,
    this.sourceType = "direct",
    this.playType = "youtube",
    this.downloadable = false,
    this.lyrics,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? "",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      audioUrl: json['youtubeId'] ?? json['audioUrl'] ?? "", // Map youtubeId to audioUrl for extraction
      duration: json['duration'] ?? "",
      sourceType: json['sourceType'] ?? (json['youtubeId'] != null ? "youtube" : "direct"),
      playType: json['playType'] ?? "youtube",
      downloadable: json['downloadable'] ?? false,
      lyrics: json['lyrics'],
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
      'lyrics': lyrics,
    };
  }
}

class Podcast {
  final String id;
  final String title;
  final String? subtitle;
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
  final String contentType; // 'music', 'playlist', 'show', 'story', 'movie'
  final String? youtubeId;

  Podcast({
    required this.id,
    required this.title,
    this.subtitle,
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
    this.contentType = 'music',
    this.youtubeId,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    var episodesList = json['episodes'] as List? ?? [];
    String type = json['type'] ?? 'music';
    
    // If it's single music or movie, create a default episode from the youtubeId
    List<Episode> mappedEpisodes = episodesList.map((e) => Episode.fromJson(e)).toList();
    if ((type == 'music' || type == 'movie') && mappedEpisodes.isEmpty && json['youtubeId'] != null) {
      mappedEpisodes = [
        Episode(
          id: json['_id'] ?? "",
          title: json['title'] ?? "",
          description: json['description'] ?? "",
          audioUrl: json['youtubeId'] ?? "",
          duration: "04:00",
          sourceType: "youtube",
          playType: "youtube",
        )
      ];
    }

    return Podcast(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? "",
      title: json['title'] ?? "",
      subtitle: json['subtitle'],
      description: json['description'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
      author: json['author'] ?? "",
      category: json['category'] ?? "",
      playType: (type == 'music' || type == 'movie') ? 'direct' : 'detail', // Dynamic routing decision
      actionLabel: json['actionLabel'] ?? "Play",
      youtubePlaylist: json['youtubePlaylist'],
      totalEpisodes: json['totalEpisodes'] ?? mappedEpisodes.length,
      mp3Url: json['mp3Url'],
      episodes: mappedEpisodes,
      contentType: type,
      youtubeId: json['youtubeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
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
      'type': contentType,
      'youtubeId': youtubeId,
    };
  }
}

class HistoryItem {
  final Podcast podcast;
  final Episode episode;
  final DateTime playedAt;
  final Duration position;
  final Duration totalDuration;

  HistoryItem({
    required this.podcast,
    required this.episode,
    required this.playedAt,
    this.position = Duration.zero,
    this.totalDuration = Duration.zero,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      podcast: Podcast.fromJson(json['podcast']),
      episode: Episode.fromJson(json['episode']),
      playedAt: DateTime.parse(json['playedAt']),
      position: Duration(milliseconds: json['positionMs'] ?? 0),
      totalDuration: Duration(milliseconds: json['totalDurationMs'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'podcast': podcast.toJson(),
      'episode': episode.toJson(),
      'playedAt': playedAt.toIso8601String(),
      'positionMs': position.inMilliseconds,
      'totalDurationMs': totalDuration.inMilliseconds,
    };
  }
}

class FavoriteItem {
  final Podcast podcast;
  final Episode episode;

  FavoriteItem({required this.podcast, required this.episode});

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      podcast: Podcast.fromJson(json['podcast']),
      episode: Episode.fromJson(json['episode']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'podcast': podcast.toJson(),
      'episode': episode.toJson(),
    };
  }
}
