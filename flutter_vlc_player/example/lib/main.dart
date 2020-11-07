// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_vlc_player/vlc_player_flutter.dart';

void main() {
  runApp(
    MaterialApp(
      home: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vlc player example'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: _VlcRemoteVideo(),
      ),
    );
  }
}

class _VlcRemoteVideo extends StatefulWidget {
  @override
  _VlcRemoteVideoState createState() => _VlcRemoteVideoState();
}

class _VlcRemoteVideoState extends State<_VlcRemoteVideo> {
  VlcPlayerController _controller;
  Uint8List image;
  double sliderValue = 0.0;
  double volumeValue = 100;
  String position = "";
  String duration = "";
  bool isBuffering = true;
  bool getCastDeviceBtnEnabled = false;
  int numberOfCaptions = 0;
  int numberOfAudioTracks = 0;

  String changeUrl =
      "http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_30fps_normal.mp4";

  @override
  void initState() {
    super.initState();
    _controller = VlcPlayerController.network(
      "http://samples.mplayerhq.hu/MPEG-4/embedded_subs/1Video_2Audio_2SUBs_timed_text_streams_.mp4",
      // "http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_30fps_normal.mp4",
      // "/storage/emulated/0/Download/Test.mp4",
      // "/sdcard/Download/Test.mp4",
      autoPlay: false,
      onInit: () {
        print('onInit ${_controller.value.playingState}');
      },
      onRendererHandler: (type, id, name) {
        print('onRendererHandler $type $id $name');
      },
    );

    _controller.addListener(() {
      if (!this.mounted) return;
      if (_controller.value.initialized) {
        var oPosition = _controller.value.position;
        var oDuration = _controller.value.duration;
        if (oPosition != null && oDuration != null) {
          if (oDuration.inHours == 0) {
            var strPosition = oPosition.toString().split('.')[0];
            var strDuration = oDuration.toString().split('.')[0];
            position =
                "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
            duration =
                "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
          } else {
            position = oPosition.toString().split('.')[0];
            duration = oDuration.toString().split('.')[0];
          }
          sliderValue = _controller.value.position.inSeconds.toDouble();
        }
        numberOfCaptions = _controller.value.spuTracksCount;
        numberOfAudioTracks = _controller.value.audioTracksCount;
        //
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const Text('With remote mp4'),
          Container(
            color: Colors.black,
            height: 250,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Center(
                  child: VlcPlayer(
                    controller: _controller,
                    aspectRatio: 16 / 9,
                    placeholder: Center(child: CircularProgressIndicator()),
                  ),
                ),
                _ControlsOverlay(controller: _controller),
              ],
            ),
          ),
          RaisedButton(
            child: Text("Initialize"),
            onPressed: () async {
              await _controller.initialize();
            },
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 1,
                child: FlatButton(
                  minWidth: 20,
                  child: _controller.value.isPlaying
                      ? Icon(Icons.pause_circle_outline)
                      : Icon(Icons.play_circle_outline),
                  onPressed: () async {
                    return _controller.value.isPlaying
                        ? await _controller.pause()
                        : await _controller.play();
                  },
                ),
              ),
              Flexible(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(position),
                    Expanded(
                      child: Slider(
                        activeColor: Colors.red,
                        value: sliderValue,
                        min: 0.0,
                        max: _controller.value.duration == null
                            ? 1.0
                            : _controller.value.duration.inSeconds.toDouble(),
                        onChanged: (progress) {
                          setState(() {
                            sliderValue = progress.floor().toDouble();
                          });
                          //convert to Milliseconds since VLC requires MS to set time
                          _controller.setTime(sliderValue.toInt() * 1000);
                        },
                      ),
                    ),
                    Text(duration),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text("Volume Level"),
              Slider(
                min: 0,
                max: 100,
                value: volumeValue,
                onChanged: (value) {
                  setState(() {
                    volumeValue = value;
                  });
                  _controller.setVolume(volumeValue.toInt());
                },
              ),
            ],
          ),
          Divider(height: 1),
          Row(
            children: [
              Flexible(
                flex: 1,
                child: FlatButton(
                  child: Text("Change URL"),
                  onPressed: () => _controller.setStreamUrl(
                    changeUrl,
                    DataSourceType.network,
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: FlatButton(
                    child: Text("+speed"),
                    onPressed: () => _controller.setPlaybackSpeed(2.0)),
              ),
              Flexible(
                flex: 1,
                child: FlatButton(
                    child: Text("Normal"),
                    onPressed: () => _controller.setPlaybackSpeed(1)),
              ),
              Flexible(
                flex: 1,
                child: FlatButton(
                    child: Text("-speed"),
                    onPressed: () => _controller.setPlaybackSpeed(0.5)),
              ),
            ],
          ),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("position=" +
                    (_controller.value.position?.inSeconds ?? 0).toString() +
                    ", duration=" +
                    (_controller.value.duration?.inSeconds ?? 0).toString() +
                    ", speed=" +
                    _controller.value.playbackSpeed.toString()),
                Text("ratio=" + _controller.value.aspectRatio.toString()),
                Text("size=" +
                    (_controller.value.size?.width ?? 0).toString() +
                    "x" +
                    (_controller.value.size?.height ?? 0).toString()),
                Text("state=" + _controller.value.playingState.toString()),
              ],
            ),
          ),
          Divider(height: 1),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                child: Text('Get Subtitle Tracks'),
                onPressed: () {
                  _getSubtitleTracks();
                },
              ),
              RaisedButton(
                child: Text('Get Audio Tracks'),
                onPressed: () {
                  _getAudioTracks();
                },
              )
            ],
          ),
          Divider(height: 1),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                flex: 1,
                child: RaisedButton(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Start Renderer Scanning',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () async {
                    await _controller.startRendererScanning();
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text("Scanning for renderer...")));
                    setState(() {
                      getCastDeviceBtnEnabled = true;
                    });
                  },
                ),
              ),
              Flexible(
                flex: 1,
                child: RaisedButton(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Get Renderer Devices',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: !getCastDeviceBtnEnabled
                      ? null
                      : () {
                          _getRendererDevices();
                        },
                ),
              ),
              Flexible(
                flex: 1,
                child: RaisedButton(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Stop Scanning',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () async {
                    await _controller.stopRendererScanning();
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text("Renderer Scanning Stopped")));
                    setState(() {
                      getCastDeviceBtnEnabled = false;
                    });
                  },
                ),
              ),
            ],
          ),
          Divider(height: 1),
          RaisedButton(
            child: Icon(Icons.camera),
            onPressed: _createCameraImage,
          ),
          image == null ? Container() : Container(child: Image.memory(image)),
        ],
      ),
    );
  }

  void _getSubtitleTracks() async {
    if (!_controller.value.isPlaying) return;

    Map<int, String> subtitleTracks = await _controller.getSpuTracks();
    //
    if (subtitleTracks != null && subtitleTracks.length > 0) {
      int selectedSubId = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select Subtitle"),
            content: Container(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: subtitleTracks.keys.length + 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index < subtitleTracks.keys.length
                          ? subtitleTracks.values.elementAt(index).toString()
                          : 'Disable',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        index < subtitleTracks.keys.length
                            ? subtitleTracks.keys.elementAt(index)
                            : -1,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
      if (selectedSubId != null) await _controller.setSpuTrack(selectedSubId);
    }
  }

  void _getAudioTracks() async {
    if (!_controller.value.isPlaying) return;

    Map<int, String> audioTracks = await _controller.getAudioTracks();
    //
    if (audioTracks != null && audioTracks.length > 0) {
      int selectedAudioTrackId = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select Audio"),
            content: Container(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: audioTracks.keys.length + 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index < audioTracks.keys.length
                          ? audioTracks.values.elementAt(index).toString()
                          : 'Disable',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        index < audioTracks.keys.length
                            ? audioTracks.keys.elementAt(index)
                            : -1,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
      if (selectedAudioTrackId != null)
        await _controller.setAudioTrack(selectedAudioTrackId);
    }
  }

  void _getRendererDevices() async {
    Map<String, String> castDevices = await _controller.getRendererDevices();
    //
    if (castDevices != null && castDevices.length > 0) {
      String selectedCastDeviceName = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select Cast Device"),
            content: Container(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: castDevices.keys.length + 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index < castDevices.keys.length
                          ? castDevices.values.elementAt(index).toString()
                          : 'Disconnect',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        index < castDevices.keys.length
                            ? castDevices.keys.elementAt(index)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
      await _controller.castToRenderer(
        selectedCastDeviceName,
      );
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("No Cast Device Found!")));
    }
  }

  void _createCameraImage() async {
    Uint8List file = await _controller.takeSnapshot();
    setState(() {
      image = file;
    });
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key key, this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VlcPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black45,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
