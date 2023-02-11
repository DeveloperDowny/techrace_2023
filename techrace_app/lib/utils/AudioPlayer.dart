import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
  }) : super(key: key);
  final String audioUrl;
  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with SingleTickerProviderStateMixin {
  final audioPlayer = AudioPlayer();
  var isPlaying = ValueNotifier(false);
  Rx<Duration> duration = Duration.zero.obs;
  Rx<Duration> position = Duration.zero.obs;
  late AnimationController iconController;

  @override
  void initState() {
    super.initState();
    iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    setAudio();
    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      duration.value = newDuration;
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      position.value = newPosition;
    });
  }

  Future setAudio() async {
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.setSourceUrl(widget.audioUrl);
    // await audioPlayer.play(UrlSource(widget.audioUrl), mode: PlayerMode.lowLatency);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        children: [
          Obx(
            () => Theme(
              data: ThemeData(
                sliderTheme: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white.withOpacity(0.8),
                    inactiveTrackColor: Colors.black.withOpacity(0.2),
                    trackShape: const RoundedRectSliderTrackShape(),
                    trackHeight: 4.0,
                    thumbColor: Colors.white,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                    overlayColor: Colors.white.withAlpha(32),
                    overlayShape: SliderComponentShape.noOverlay),
              ),
              child: Slider(
                  value: position.value.inSeconds.toDouble(),
                  min: 0,
                  max: duration.value.inSeconds.toDouble(),
                  onChanged: (value) async {
                    // await audioPlayer.seek(Duration(seconds: value.toInt()));
                    final position = Duration(seconds: value.toInt());
                    await audioPlayer.seek(position);
                    await audioPlayer.resume();
                    iconController.forward();
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    formatTime(position.value),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Obx(
                  () => Text(
                    formatTime(duration.value),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder(
              valueListenable: isPlaying,
              builder: (context, value, child) {
                return InkWell(
                  child: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: iconController,
                    color: Colors.white,
                  ),
                  onTap: () async {
                    if (isPlaying.value) {
                      await audioPlayer.pause();
                      iconController.reverse();
                    } else {
                      await audioPlayer.resume();
                      iconController.forward();
                    }
                  },
                );
              }),
          // IconButton(
          //     onPressed: () async {
          //       if (isPlaying.value) {
          //         await audioPlayer.pause();
          //       } else {
          //         await audioPlayer.resume();
          //       }
          //     },
          //     icon: ValueListenableBuilder(
          //         valueListenable: isPlaying,
          //         builder: (context, value, child) {
          //           return Icon(isPlaying.value ? Icons.pause : Icons.play_arrow);
          //         })),
        ],
      ),
    );
  }
}

String formatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return [
    if (duration.inHours > 0) hours,
    minutes,
    seconds,
  ].join(":");
}
