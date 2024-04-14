import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:special_scholar/video_player.dart';

class VideoListPage extends StatefulWidget {
  final String trainerId;

  VideoListPage({required this.trainerId});

  @override
  _VideoListPageState createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  List<Map<String, dynamic>> videos = [];

  Future<List<Map<String, dynamic>>> getVideosByTrainerId(String trainerId) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('tbl_course')
      .where('trainer_id', isEqualTo: trainerId)
      .get();
  return querySnapshot.docs.map((doc) => doc.data()).toList();
}

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  void _loadVideos() async {
    final fetchedVideos = await getVideosByTrainerId(widget.trainerId);
    setState(() {
      videos = fetchedVideos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video List'),
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return ListTile(
            title: Text(video['description']),
            onTap: () {
              _playVideo(video['content']);
            },
          );
        },
      ),
    );
  }

  void _playVideo(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(videoUrl: videoUrl),
      ),
    );
  }
}