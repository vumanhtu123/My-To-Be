class Thumbnail {
  final String url;
  final int width;
  final int height;
  final String? quality; // Có thể có hoặc không

  Thumbnail({
    required this.url,
    required this.width,
    required this.height,
    this.quality,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      url: json['url'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      quality: json['quality'], // có thể null
    );
  }
}

class VideoItem {
  final String type;
  final String title;
  final String videoId;
  final String author;
  final String authorId;
  final String authorUrl;
  final bool authorVerified;
  final List<Thumbnail> authorThumbnails;
  final List<Thumbnail> videoThumbnails;
  final String description;
  final String descriptionHtml;
  final int viewCount;
  final String viewCountText;
  final int published;         // timestamp unix
  final String publishedText;  // text dạng "2 weeks ago"
  final int lengthSeconds;
  final bool liveNow;
  final bool premium;
  final bool isUpcoming;
  final bool isNew;
  final bool is4k;
  final bool is8k;
  final bool isVr180;
  final bool isVr360;
  final bool is3d;
  final bool hasCaptions;

  VideoItem({
    required this.type,
    required this.title,
    required this.videoId,
    required this.author,
    required this.authorId,
    required this.authorUrl,
    required this.authorVerified,
    required this.authorThumbnails,
    required this.videoThumbnails,
    required this.description,
    required this.descriptionHtml,
    required this.viewCount,
    required this.viewCountText,
    required this.published,
    required this.publishedText,
    required this.lengthSeconds,
    required this.liveNow,
    required this.premium,
    required this.isUpcoming,
    required this.isNew,
    required this.is4k,
    required this.is8k,
    required this.isVr180,
    required this.isVr360,
    required this.is3d,
    required this.hasCaptions,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    var authorThumbsJson = json['authorThumbnails'] as List<dynamic>? ?? [];
    var videoThumbsJson = json['videoThumbnails'] as List<dynamic>? ?? [];

    List<Thumbnail> authorThumbs =
    authorThumbsJson.map((e) => Thumbnail.fromJson(e)).toList();
    List<Thumbnail> videoThumbs =
    videoThumbsJson.map((e) => Thumbnail.fromJson(e)).toList();

    return VideoItem(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      videoId: json['videoId'] ?? '',
      author: json['author'] ?? '',
      authorId: json['authorId'] ?? '',
      authorUrl: json['authorUrl'] ?? '',
      authorVerified: json['authorVerified'] ?? false,
      authorThumbnails: authorThumbs,
      videoThumbnails: videoThumbs,
      description: json['description'] ?? '',
      descriptionHtml: json['descriptionHtml'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      viewCountText: json['viewCountText'] ?? '',
      published: json['published'] ?? 0,
      publishedText: json['publishedText'] ?? '',
      lengthSeconds: json['lengthSeconds'] ?? 0,
      liveNow: json['liveNow'] ?? false,
      premium: json['premium'] ?? false,
      isUpcoming: json['isUpcoming'] ?? false,
      isNew: json['isNew'] ?? false,
      is4k: json['is4k'] ?? false,
      is8k: json['is8k'] ?? false,
      isVr180: json['isVr180'] ?? false,
      isVr360: json['isVr360'] ?? false,
      is3d: json['is3d'] ?? false,
      hasCaptions: json['hasCaptions'] ?? false,
    );
  }
}
