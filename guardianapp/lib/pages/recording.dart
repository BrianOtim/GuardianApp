import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guardianapp/helpers/colors.dart';
import 'package:guardianapp/helpers/sending.dart';
import 'package:guardianapp/helpers/storage.dart';
import 'package:guardianapp/helpers/urls.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:http/http.dart' as http;

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final RecordMp3 audioRecorder = RecordMp3.instance;
  final AudioPlayer audioPlayer = AudioPlayer();
  List<dynamic> alertList = [];
  String? recordingPath;
  bool isRecording = false;
  bool isPlaying = false;
  bool isPaused = false;
  String? current;

  @override
  void initState() {
    super.initState();
    loadAlert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        title: const Text('My Recordings',
            style: TextStyle(fontSize: 16.0, color: themeColor)),
        centerTitle: true,
      ),
      //floatingActionButton: _recordingButton(),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
            itemCount: alertList.length,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, int index) {
              var alert = alertList[index];
              String message = alert['message'];
              List<String> sentence = message.split(" at ");
              String one = sentence[1];
              String two = sentence[2];
              String fileName = "$one at $two";
              String audioName = convertName(fileName);

              return Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 5.0),
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      if (!isPlaying)
                        IconButton(
                          onPressed: () async {
                            if (!isPaused) {
                              recordingPath = await getFilePath(audioName);
                              await audioPlayer.setFilePath(recordingPath!);
                            }
                            audioPlayer.play();
                            setState(() {
                              isPlaying = true;
                              isPaused = false;
                              current = fileName;
                            });
                          },
                          icon: const Icon(
                            CupertinoIcons.play_fill,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      if (isPlaying && fileName == current)
                        IconButton(
                          onPressed: () {
                            audioPlayer.pause();
                            setState(() {
                              isPlaying = false;
                              isPaused = true;
                            });
                          },
                          icon: const Icon(
                            CupertinoIcons.pause_fill,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      if ((isPlaying || isPaused) && fileName == current)
                        IconButton(
                          onPressed: () async {
                            isPlaying = false;
                            if (audioPlayer.playing || isPaused) {
                              audioPlayer.stop();
                              setState(() {
                                isPlaying = false;
                                isPaused = false;
                              });
                            }
                          },
                          icon: const Icon(
                            CupertinoIcons.stop_circle_fill,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _recordingButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (isRecording) {
          isRecording = !audioRecorder.stop();
          setState(() {
            isRecording = false;
          });
        } else {
          String filePath = await getFilePath("");
          audioRecorder.start(filePath, (type) {});
          setState(() {
            isRecording = true;
            recordingPath = filePath;
          });
        }
      },
      child: Icon(
        isRecording ? Icons.stop : Icons.mic,
      ),
    );
  }

  Future<Map<String, dynamic>> loadAlert() async {
    var apiUrl =
        Uri.parse('$baseUrl/alerts/${await pickIntegerValue(name: "userId")}');
    final response = await http.get(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
    );
    // print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('alerts')) {
        setState(() {
          alertList = responseData['alerts'];
        });
      }
      return responseData;
    } else if (response.statusCode == 400) {
    } else {
      return {};
    }

    return {};
  }
}
