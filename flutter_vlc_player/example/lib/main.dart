import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'video_data.dart';
import 'package:flutter_vlc_player/vlc_player_flutter.dart';
import 'vlc_player_with_controls.dart';

void main() {
  runApp(
    MaterialApp(
      home: App(),
    ),
  );
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  VlcPlayerController _controller;

  //
  List<VideoData> listVideos;
  int selectedVideoIndex;

  void fillVideos() {
    listVideos = List<VideoData>();
    //
    listVideos.add(VideoData(
      name: 'Network Video 1',
      path:
          'http://samples.mplayerhq.hu/MPEG-4/embedded_subs/1Video_2Audio_2SUBs_timed_text_streams_.mp4',
      type: VideoType.network,
    ));
    //
    listVideos.add(VideoData(
      name: 'Network Video 2',
      path:
          'http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_30fps_normal.mp4',
      type: VideoType.network,
    ));
    //
    listVideos.add(VideoData(
      name: 'File Video 1',
      path: '/sdcard/test.mp4', // or '/storage/emulated/0/test.mp4'
      type: VideoType.file,
    ));
    //
    listVideos.add(VideoData(
      name: 'Asset Video 1',
      path: 'assets/sample.mp4',
      type: VideoType.asset,
    ));
  }

  @override
  void initState() {
    super.initState();
    //
    fillVideos();
    selectedVideoIndex = 0;
    //
    VideoData initVideo = listVideos[selectedVideoIndex];
    switch (initVideo.type) {
      case VideoType.network:
        _controller = VlcPlayerController.network(
          initVideo.path,
          hwAcc: HwAcc.FULL,
          onInit: () async {
            await _controller.startRendererScanning();
          },
          onRendererHandler: (type, id, name) {
            print('onRendererHandler $type $id $name');
          },
          options: VlcPlayerOptions(
            
            advanced: VlcAdvancedOptions([
              VlcAdvancedOptions.networkCaching(2000),

            ]),
            rtp: VlcRtpOptions([
              VlcRtpOptions.rtpOverRtsp(true),
            ]),
            
          ),
        );
        break;
      case VideoType.file:
        File file = File(initVideo.path);
        _controller = VlcPlayerController.file(
          file,
          onInit: () async {
            await _controller.startRendererScanning();
          },
          onRendererHandler: (type, id, name) {
            print('onRendererHandler $type $id $name');
          },
        );
        break;
      case VideoType.asset:
        _controller = VlcPlayerController.asset(
          initVideo.path,
          onInit: () async {
            await _controller.startRendererScanning();
          },
          onRendererHandler: (type, id, name) {
            print('onRendererHandler $type $id $name');
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Vlc Player Example'),
      ),
      body: ListView(
        children: [
          Container(
            height: 400,
            child: VlcPlayerWithControls(controller: _controller),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: listVideos.length,
            itemBuilder: (BuildContext context, int index) {
              VideoData video = listVideos[index];
              IconData iconData;
              switch (video.type) {
                case VideoType.network:
                  iconData = Icons.cloud;
                  break;
                case VideoType.file:
                  iconData = Icons.insert_drive_file;
                  break;
                case VideoType.asset:
                  iconData = Icons.all_inbox;
                  break;
              }
              return ListTile(
                selected: selectedVideoIndex == index,
                selectedTileColor: Colors.black54,
                leading: Icon(
                  iconData,
                  color:
                      selectedVideoIndex == index ? Colors.white : Colors.black,
                ),
                title: Text(
                  video.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selectedVideoIndex == index
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                subtitle: Text(
                  video.path,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selectedVideoIndex == index
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                onTap: () async {
                  switch (video.type) {
                    case VideoType.network:
                      await _controller.setMediaFromNetwork(video.path, hwAcc: HwAcc.FULL);
                      break;
                    case VideoType.file:
                      File file = File(video.path);
                      if (await file.exists())
                        await _controller.setMediaFromFile(file);
                      break;
                    case VideoType.asset:
                      await _controller.setMediaFromAsset(video.path);
                      break;
                  }
                  selectedVideoIndex = index;
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.stopRendererScanning();
    _controller.removeListener(() {});
    super.dispose();
  }
}
