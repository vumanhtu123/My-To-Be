import 'package:flutter/material.dart';
import 'package:my_to_be/common/base.url.dart';
import 'package:my_to_be/utils/helper.dart';

class YouTubeVideoItem extends StatelessWidget {
  final String thumbnailUrl;
  final int duration;
  final String title;
  final String channelName;
  final String views;
  final String publishedTime;
  final String channelAvatarUrl;

  const YouTubeVideoItem({
    super.key,
    required this.thumbnailUrl,
    required this.duration,
    required this.title,
    required this.channelName,
    required this.views,
    required this.publishedTime,
    required this.channelAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail + Duration
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ApiConst.baseUrl + thumbnailUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // Ảnh đã tải xong
                    } else {
                      return SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 13,
                left: 13,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    views,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    Helper().formatDuration(duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          // Channel info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Channel Avatar
              ClipOval(
                child: Image.network(
                  channelAvatarUrl,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // Channel Name + Views + Published Time
              Expanded(
                child: Text(
                  '$channelName • $publishedTime',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}