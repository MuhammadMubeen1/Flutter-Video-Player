import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:floating/floating.dart';

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  late Floating floating;
  double brightness = 1.0;

  @override
  void initState() {
    super.initState();

    // Video URL
    String videoUrl =
        'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4';

    // Initialize video controller
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        if (_controller.value.hasError) {
          print(
              'Error initializing video: ${_controller.value.errorDescription}');
        } else {
          _controller.setLooping(true);
          _controller.play();
          _controller.setVolume(brightness); // Set initial brightness
          setState(() {});
        }
      }).catchError((error) {
        print('Error during video initialization: $error');
      });

    // Initialize Chewie controller
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: false,
      // You can customize other Chewie options here
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.blue,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.lightGreen,
      ),
      allowPlaybackSpeedChanging: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(errorMessage),
        );
      },
    );

    // Initialize the 'floating' variable
    floating = Floating();
  }

  @override
  Widget build(BuildContext context) {
    return PiPSwitcher(
      childWhenEnabled: Chewie(
        controller: _chewieController,
      ),
      childWhenDisabled: Scaffold(
        appBar: AppBar(
          title: Text('Floating example app'),
        ),
        body: Center(
          child: justVideo(),
        ),
        floatingActionButton: PiPSwitcher(
          childWhenDisabled: FloatingActionButton(
            onPressed: () async {
              await floating.enable(aspectRatio: Rational.landscape());
            },
          ),
          childWhenEnabled: Container(
            color: Colors.amber,
          ),
        ),
      ),
    );
  }

  Widget justVideo() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VideoPlayer(_controller),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    floating.dispose(); // Don't forget to dispose of the floating controller
    super.dispose();
  }
}
