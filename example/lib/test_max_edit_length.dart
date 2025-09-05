import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

/// Test widget to demonstrate the maxVideoEditLength feature
class TestMaxEditLength extends StatefulWidget {
  final File videoFile;

  const TestMaxEditLength({super.key, required this.videoFile});

  @override
  State<TestMaxEditLength> createState() => _TestMaxEditLengthState();
}

class _TestMaxEditLengthState extends State<TestMaxEditLength> {
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  Duration? _maxEditLength = const Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _trimmer.loadVideo(videoFile: widget.videoFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Max Edit Length Test'),
      ),
      body: Column(
        children: [
          // Controls to change max edit length
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                    'Current Max Edit Length: ${_maxEditLength?.inSeconds ?? "No limit"} seconds'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(
                          () => _maxEditLength = const Duration(seconds: 15)),
                      child: const Text('15s'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(
                          () => _maxEditLength = const Duration(seconds: 30)),
                      child: const Text('30s'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(
                          () => _maxEditLength = const Duration(minutes: 1)),
                      child: const Text('1min'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => _maxEditLength = null),
                      child: const Text('No limit'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Video viewer
          Expanded(
            flex: 2,
            child: VideoViewer(trimmer: _trimmer),
          ),

          // Trim viewer with dynamic maxVideoEditLength
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TrimViewer(
              trimmer: _trimmer,
              viewerHeight: 60.0,
              viewerWidth: MediaQuery.of(context).size.width - 32,
              maxVideoLength: const Duration(minutes: 10), // Allow scrolling for center drag
              maxVideoEditLength: _maxEditLength,
              durationStyle: DurationStyle.FORMAT_MM_SS,
              editorProperties: TrimEditorProperties(
                borderPaintColor:
                    _maxEditLength != null ? Colors.red : Colors.blue,
                borderWidth: 3,
                borderRadius: 8,
                circlePaintColor: _maxEditLength != null
                    ? Colors.red.shade700
                    : Colors.blue.shade700,
                sideTapSize:
                    20, // Smaller side tap areas to increase center drag zone
              ),
              onChangeStart: (value) => setState(() => _startValue = value),
              onChangeEnd: (value) => setState(() => _endValue = value),
            ),
          ),

          // Display current selection info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                    'Selected Duration: ${((_endValue - _startValue) / 1000).toStringAsFixed(1)}s'),
                Text('Start Time: ${(_startValue / 1000).toStringAsFixed(1)}s'),
                Text('End Time: ${(_endValue / 1000).toStringAsFixed(1)}s'),
                if (_maxEditLength != null)
                  Text(
                    'Limit: ${_maxEditLength!.inSeconds}s',
                    style: TextStyle(
                      color: (_endValue - _startValue) >
                              _maxEditLength!.inMilliseconds
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 10),
                const Text(
                  'Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '• Drag left/right handles to adjust duration',
                  style: TextStyle(fontSize: 12),
                ),
                const Text(
                  '• Drag center area to move selection position',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }
}
