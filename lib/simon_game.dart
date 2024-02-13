import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

enum ColorType { red, green, blue, yellow }

class SimonGame extends StatefulWidget {
  @override
  _SimonGameState createState() => _SimonGameState();
}

class _SimonGameState extends State<SimonGame> {
  List<ColorType> _sequence = [];
  List<ColorType> _playerSequence = [];
  bool _isUserTurn = false;
  int _score = 0;
  int _bestScore = 0;
  final _audioPlayer = AudioCache(prefix: 'assets/note/');
  final Map<ColorType, String> _sounds = {
    ColorType.red: 'note1.wav',
    ColorType.green: 'note2.wav',
    ColorType.blue: 'note3.wav',
    ColorType.yellow: 'note4.wav',
  };
  ColorType? _activeColor;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _sequence.clear();
    _playerSequence.clear();
    _score = 0;
    _addColorToSequence();
  }

  void _addColorToSequence() {
    _sequence.add(ColorType.values[Random().nextInt(ColorType.values.length)]);
    _playSequence();
  }

  Future<void> _playSequence() async {
    _isUserTurn = false;
    for (var color in _sequence) {
      setState(() => _activeColor = color);
      _playSound(color);
      await _animateColor(color);
      await Future.delayed(Duration(milliseconds: 200));
      setState(() => _activeColor = null);
      await Future.delayed(Duration(milliseconds: 200));
    }
    _isUserTurn = true;
  }

  Future<void> _animateColor(ColorType color) async {
    await Future.delayed(Duration(milliseconds: 300));
    _playSound(color);
    await Future.delayed(Duration(milliseconds: 300));
  }

  void _playSound(ColorType color) {
    _audioPlayer.play(_sounds[color]!);
  }

  void _handleColorTap(ColorType color) {
    if (!_isUserTurn) {
      return;
    }

    _playerSequence.add(color);
    _playSound(color);
    _checkPlayerInput();
    _animateButtonTap(color);
  }

  void _checkPlayerInput() {
    for (int i = 0; i < _playerSequence.length; i++) {
      if (_playerSequence[i] != _sequence[i]) {
        _endGame();
        return;
      }
    }

    if (_playerSequence.length == _sequence.length) {
      setState(() {
        _score++;
        if (_score > _bestScore) {
          _bestScore = _score;
        }
        _isUserTurn = false;
        _playerSequence.clear();
      });
      _addColorToSequence();
    }
  }

  void _endGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text('Votre score est $_score.\nMeilleur score: $_bestScore'),
        actions: [
          TextButton(
            child: Text('Recommencer'),
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(ColorType color, Color btnColor) {
    bool isActive = _activeColor == color;
    return GestureDetector(
      onTap: () {
        _handleColorTap(color);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive ? btnColor.withOpacity(0.5) : btnColor,
          shape: BoxShape.circle,
        ),
        width: isActive ? 120.0 : 100.0,
        height: isActive ? 120.0 : 100.0,
        margin: EdgeInsets.all(10),
      ),
    );
  }

  Future<void> _animateButtonTap(ColorType color) async {
    setState(() {
      _activeColor = color;
    });
    await Future.delayed(Duration(milliseconds: 200));
    setState(() {
      _activeColor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jeu Simon'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Score: $_score', style: Theme.of(context).textTheme.headline4),
          Text('Meilleur score: $_bestScore', style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <ColorType>[ColorType.red, ColorType.green].map((color) => _buildColorButton(color, _getColor(color))).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <ColorType>[ColorType.blue, ColorType.yellow].map((color) => _buildColorButton(color, _getColor(color))).toList(),
          ),
        ],
      ),
    );
  }

  Color _getColor(ColorType type) {
    switch (type) {
      case ColorType.red:
        return Colors.red;
      case ColorType.green:
        return Colors.green;
      case ColorType.blue:
        return Colors.blue;
      case ColorType.yellow:
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
