
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // You'll need to add this package to pubspec.yaml
import 'package:audio_session/audio_session.dart'; // For managing audio session

// Define an Audio model class to represent audio tracks
class AudioTrack {
  final String id;
  final String name;
  final String artist;
  final String source;
  final bool isPremium;
  final String language;

  AudioTrack({
    required this.id,
    required this.name,
    required this.artist,
    required this.source,
    required this.isPremium,
    this.language = 'English',
  });
}

// Audio selection screen
class AudioSelectionScreen extends StatefulWidget {
  final Function(AudioTrack?) onAudioSelected;
  final AudioTrack? currentAudio;

  const AudioSelectionScreen({
    Key? key,
    required this.onAudioSelected,
    this.currentAudio,
  }) : super(key: key);

  @override
  _AudioSelectionScreenState createState() => _AudioSelectionScreenState();
}

class _AudioSelectionScreenState extends State<AudioSelectionScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioTrack? _previewingAudio;
  List<String> _languages = ['English', 'Hindi', 'Spanish', 'French'];
  String _selectedLanguage = 'English';
  bool _isPlaying = false;
  int? _playingIndex;
  
  // Sample audio tracks - in a real app, these would come from an API
  List<AudioTrack> _audioTracks = [
    AudioTrack(
      id: '1',
      name: 'Happy Summer',
      artist: 'Audio Library',
      source: 'assets/audio/track_filename.mp3',
      isPremium: false,
    ),
    AudioTrack(
      id: '2',
      name: 'Peaceful Morning',
      artist: 'Music Collection',
      source: 'assets/audio/track_filename.mp3',
      isPremium: false,
    ),
    AudioTrack(
      id: '3',
      name: 'Epic Adventure',
      artist: 'Sound Studio',
      source: 'assets/audio/track_filename.mp3',
      isPremium: true,
    ),
    AudioTrack(
      id: '4',
      name: 'Romantic Moments',
      artist: 'Audio Collection',
      source: 'assets/audio/track_filename.mp3',
      isPremium: true,
    ),
    AudioTrack(
      id: '5',
      name: 'Energetic Party',
      artist: 'Music Masters',
      source: 'assets/audio/track_filename.mp3',
      isPremium: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initAudioSession();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _playAudio(AudioTrack audio, int index) async {
    // Stop current audio if playing
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    // Set as previewing audio
    setState(() {
      _previewingAudio = audio;
      _playingIndex = index;
      _isPlaying = true;
    });

    try {
      // Load and play the audio
      await _audioPlayer.setAsset(audio.source);
      await _audioPlayer.play();
      
      // Set up listener for completion
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
            _playingIndex = null;
          });
        }
      });
    } catch (e) {
      print('Error playing audio: $e');
      setState(() {
        _isPlaying = false;
        _playingIndex = null;
      });
    }
  }

  Future<void> _stopAudio() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _playingIndex = null;
      });
    }
  }

  void _selectAudio(AudioTrack audio) {
    widget.onAudioSelected(audio);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Audio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _stopAudio();
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _stopAudio();
              widget.onAudioSelected(null); // Remove audio
              Navigator.pop(context);
            },
            child: const Text('No Audio', style: TextStyle(color: Colors.white)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Preset Audio'),
            Tab(text: 'Custom Audio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Preset Audio Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedLanguage,
                  items: _languages.map((language) {
                    return DropdownMenuItem(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _audioTracks.length,
                  itemBuilder: (context, index) {
                    final audio = _audioTracks[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _playingIndex == index ? Icons.pause : Icons.music_note,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(audio.name),
                      subtitle: Text(audio.artist),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (audio.isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Premium',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(_playingIndex == index ? Icons.stop : Icons.play_arrow),
                            onPressed: () {
                              if (_playingIndex == index) {
                                _stopAudio();
                              } else {
                                _playAudio(audio, index);
                              }
                            },
                          ),
                          Radio<AudioTrack>(
                            value: audio,
                            groupValue: widget.currentAudio,
                            onChanged: (value) {
                              _selectAudio(audio);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        if (_playingIndex == index) {
                          _stopAudio();
                        } else {
                          _playAudio(audio, index);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          
          // Custom Audio Tab (Upload from device)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.upload_file,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20),
                const Text('Upload your own audio file'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // You would implement file picking here
                    // For example, using file_picker package
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upload functionality coming soon')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 51, 68, 196),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Upload Audio File'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _tabController?.index == 0 
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_previewingAudio != null) {
                    _selectAudio(_previewingAudio!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 51, 68, 196),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply Selected Audio',style: TextStyle(color: Colors.white),),
              ),
            )
          : null,
    );
  }
}