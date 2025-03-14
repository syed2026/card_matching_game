import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() {
  runApp(const CardMatchingGame());
}

class CardMatchingGame extends StatelessWidget {
  const CardMatchingGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GameScreen(),
      ),
    );
  }
}

class GameProvider extends ChangeNotifier {
  List<CardModel> cards = [];
  CardModel? firstFlippedCard;
  bool isChecking = false;
  int score = 0;
  int timeElapsed = 0;
  Timer? timer;

  GameProvider() {
    _initializeGame();
  }

  void _initializeGame() {
    List<String> images = ["🍎", "🍌", "🍇", "🍉", "🍊", "🍓", "🥭", "🍍"];
    images = [...images, ...images];
    images.shuffle();

    cards = List.generate(images.length, (index) => CardModel(id: index, image: images[index]));
    score = 0;
    timeElapsed = 0;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeElapsed++;
      notifyListeners();
    });
  }

  void flipCard(CardModel card) async {
    if (isChecking || card.isMatched || card.isFaceUp) return;

    card.isFaceUp = true;
    notifyListeners();

    if (firstFlippedCard == null) {
      firstFlippedCard = card;
    } else {
      isChecking = true;
      await Future.delayed(const Duration(seconds: 1));

      if (firstFlippedCard!.image == card.image) {
        firstFlippedCard!.isMatched = true;
        card.isMatched = true;
        score += 10;
      } else {
        firstFlippedCard!.isFaceUp = false;
        card.isFaceUp = false;
        score -= 2;
      }

      firstFlippedCard = null;
      isChecking = false;
      notifyListeners();
    }

    if (cards.every((card) => card.isMatched)) {
      timer?.cancel();
    }
  }

  void restartGame() {
    _initializeGame();
  }
}

class CardModel {
  final int id;
  final String image;
  bool isFaceUp;
  bool isMatched;

  CardModel({required this.id, required this.image, this.isFaceUp = false, this.isMatched = false});
}

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key); // Add this constructor

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => gameProvider.restartGame(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: ${gameProvider.score}', style: const TextStyle(fontSize: 18)),
                Text('Time: ${gameProvider.timeElapsed}s', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: gameProvider.cards.length,
              itemBuilder: (context, index) {
                final card = gameProvider.cards[index];
                return GestureDetector(
                  onTap: () => gameProvider.flipCard(card),
                  child: Container(
                    decoration: BoxDecoration(
                      color: card.isFaceUp ? Colors.white : Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 2),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        card.isFaceUp ? card.image : "❓",
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
