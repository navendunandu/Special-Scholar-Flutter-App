import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:special_scholar/video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

bool check = false;

class HowToVideos extends StatelessWidget {
  final String id;
  const HowToVideos({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Screen'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> videos = snapshot.data!;
            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenVideoPlayer(
                          videoUrl: videos[index]['videoUrl'],
                        ),
                      ),
                    );
                  },
                  child: VideoPlayerWidget(
                    videoUrl: videos[index]['videoUrl'],
                    videoTitle: videos[index]['videoTitle'],
                    videoThumb: videos[index]['imgUrl'],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchVideos() async {
  final QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance
          .collection('tbl_course')
          .where('trainer_id', isEqualTo: id)
          .get();

  return snapshot.docs.map((DocumentSnapshot<Map<String, dynamic>> doc) {
    return doc.data()!;
  }).toList();
}
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  final String videoThumb;

  VideoPlayerWidget({
    required this.videoUrl,
    required this.videoTitle,
    required this.videoThumb,
  });

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  String? thumbnailUrl;

  @override
  void initState() {
    super.initState();

    // Generate a thumbnail from the video URL
    generateThumbnail();

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      })
      ..addListener(() {
        if (_controller.value.hasError) {
          // Handle video playback error
          print('Video playback error: ${_controller.value.errorDescription}');
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Dispose of the controller when navigating back
        _controller.dispose();
        return true;
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenVideoPlayer(
                videoUrl: widget.videoUrl,
              ),
            ),
          );
        },
        child: Column(
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: widget.videoThumb != null
                        ? Image.network(
                            widget.videoThumb,
                            fit: BoxFit.cover,
                          )
                        : Center(child: CircularProgressIndicator()),
                  )
                : CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.videoTitle),
            ),
          ],
        ),
      ),
    );
  }

  // Function to generate a thumbnail from the video URL
  void generateThumbnail() async {
    thumbnailUrl = await VideoThumbnail.thumbnailFile(
      video: widget.videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 100,
      quality: 25,
    );

    if (mounted) {
      setState(() {});
    }
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}