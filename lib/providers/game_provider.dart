

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/participant.dart';
import '../models/game_card.dart';
import '../utils/constants.dart';
import 'dart:math';

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier()
      : super(GameState(
          participants: [],
          cards: List.generate(
            Constants.syllables.length,
            (index) => GameCard(
              syllable: Constants.syllables[index],
              isSelected: false,
            ),
          ),
          selectedCard: null,
          currentPlayerIndex: 0,
          remainingTime: 0,
          enteredWord: '',
          diceResult: '',
          isDiceRolled: false,
          isGameStarted: false,
          rounds: 0,
          bombExploded: false,
          wordInvalid: false,
          usedWords: [],
          isCardSelected: false,
          isPaused: false,
          bombDialogShown: false, // Inicializar la nueva bandera
        ));

  final Random random = Random();
  Timer? _timer;

  void addParticipant() {
    final newParticipants = [...state.participants, Participant(name: '')];
    state = state.copyWith(participants: newParticipants);
  }

  void updateParticipantName(int index, String name) {
    final updatedParticipants = state.participants.map((p) {
      if (state.participants.indexOf(p) == index) {
        return Participant(name: name, losses: p.losses);
      }
      return p;
    }).toList();
    state = state.copyWith(participants: updatedParticipants);
  }

  void selectCard(int index) {
    final selectableCards = state.cards.where((card) => !card.isSelected).toList();
    if (index >= 0 && index < selectableCards.length) {
      final cardToSelect = selectableCards[index];
      final updatedCards = state.cards.map((card) {
        if (card.syllable == cardToSelect.syllable) {
          return card.copyWith(isSelected: true);
        }
        return card;
      }).toList();
      state = state.copyWith(
        selectedCard: cardToSelect,
        cards: updatedCards,
        isCardSelected: true, // Actualizar la bandera
      );
    }
  }

  void rollDice() {
    if (!state.isDiceRolled) {
      List<String> diceOptions = ['TIC', 'TAC', 'BOOM'];
      state = state.copyWith(
        diceResult: diceOptions[random.nextInt(3)],
        isDiceRolled: true,
      );
    }
  }

  void startGame() {
    if (state.isDiceRolled) {
      state = state.copyWith(
        isGameStarted: true,
        remainingTime: random.nextInt(40) + 10, // Random time between 10 and 50 seconds
      );
      startTimer();
    }
  }

  void startTimer() {
    _timer?.cancel();  // Cancelar cualquier temporizador anterior
    if (state.remainingTime > 0) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (state.isPaused) {
          timer.cancel();
        } else if (state.remainingTime > 1) {
          state = state.copyWith(remainingTime: state.remainingTime - 1);
        } else {
          bombExploded();
          timer.cancel();
        }
      });
    }
  }

  void togglePauseResume() {
    if (state.isPaused) {
      state = state.copyWith(isPaused: false);
      startTimer();
    } else {
      _timer?.cancel();
      state = state.copyWith(isPaused: true);
    }
  }

  void submitWord() {
    if (state.enteredWord.isNotEmpty &&
        isValidWord(state.enteredWord, state.diceResult, state.selectedCard!.syllable) &&
        !state.usedWords.contains(state.enteredWord.toLowerCase())) {
      state = state.copyWith(
        usedWords: [...state.usedWords, state.enteredWord.toLowerCase()],
      );
      passToNextPlayer();
    } else {
      state = state.copyWith(wordInvalid: true);
    }
  }

  bool isValidWord(String word, String diceResult, String syllable) {
    if (diceResult == 'TIC') {
      return word.toLowerCase().startsWith(syllable.toLowerCase());
    } else if (diceResult == 'TAC') {
      return word.toLowerCase().endsWith(syllable.toLowerCase());
    } else {
      return word.toLowerCase().contains(syllable.toLowerCase());
    }
  }

  void passToNextPlayer() {
    int newIndex = (state.currentPlayerIndex + 1) % state.participants.length;
    state = state.copyWith(
      currentPlayerIndex: newIndex,
      enteredWord: '',
      wordInvalid: false,
    );
  }

  void bombExploded() {
    final updatedParticipants = state.participants.map((p) {
      if (state.participants.indexOf(p) == state.currentPlayerIndex) {
        return Participant(name: p.name, losses: p.losses + 1);
      }
      return p;
    }).toList();
    state = state.copyWith(
      participants: updatedParticipants,
      bombExploded: true,
      bombDialogShown: false, // Asegurarse de que la bandera esté en falso al explotar la bomba
      isGameStarted: false,
      isCardSelected: false, // Resetear la bandera
      isDiceRolled: false,
      diceResult: '',
      remainingTime: 0,
    );
  }

  void selectRandomParticipant() {
    final randomIndex = random.nextInt(state.participants.length);
    state = state.copyWith(currentPlayerIndex: randomIndex);
  }

  void resetRound() {
    state = state.copyWith(
      selectedCard: null,
      enteredWord: '',
      diceResult: '',
      isDiceRolled: false,
      isGameStarted: false,
      remainingTime: 0,
      bombExploded: false,
      bombDialogShown: false, // Reiniciar la bandera
      wordInvalid: false,
      usedWords: [], // Reiniciar la lista de palabras usadas
      isCardSelected: false, // Resetear la bandera
      isPaused: false,
    );
    _timer?.cancel();
  }

  void resetGame() {
    state = GameState(
      participants: [],
      cards: List.generate(
        Constants.syllables.length,
        (index) => GameCard(
          syllable: Constants.syllables[index],
          isSelected: false,
        ),
      ),
      selectedCard: null,
      currentPlayerIndex: 0,
      remainingTime: 0,
      enteredWord: '',
      diceResult: '',
      isDiceRolled: false,
      isGameStarted: false,
      rounds: 0,
      bombExploded: false,
      wordInvalid: false,
      usedWords: [],
      isCardSelected: false,
      isPaused: false,
      bombDialogShown: false, // Inicializar la bandera
    );
    _timer?.cancel();
  }
}

class GameState {
  final List<Participant> participants;
  final List<GameCard> cards;
  final GameCard? selectedCard;
  final int currentPlayerIndex;
  final int remainingTime;
  final String enteredWord;
  final String diceResult;
  final bool isDiceRolled;
  final bool isGameStarted;
  final int rounds;
  final bool bombExploded;
  final bool wordInvalid;
  final List<String> usedWords;
  final bool isCardSelected; // Nueva bandera
  final bool isPaused;
  final bool bombDialogShown; // Nueva bandera para mostrar el diálogo una vez

  GameState({
    required this.participants,
    required this.cards,
    required this.selectedCard,
    required this.currentPlayerIndex,
    required this.remainingTime,
    required this.enteredWord,
    required this.diceResult,
    required this.isDiceRolled,
    required this.isGameStarted,
    required this.rounds,
    required this.bombExploded,
    required this.wordInvalid,
    required this.usedWords,
    required this.isCardSelected, // Inicializar la bandera
    this.isPaused = false,
    this.bombDialogShown = false, // Inicializar la nueva bandera
  });

  GameState copyWith({
    List<Participant>? participants,
    List<GameCard>? cards,
    GameCard? selectedCard,
    int? currentPlayerIndex,
    int? remainingTime,
    String? enteredWord,
    String? diceResult,
    bool? isDiceRolled,
    bool? isGameStarted,
    int? rounds,
    bool? bombExploded,
    bool? wordInvalid,
    List<String>? usedWords,
    bool? isCardSelected, // Agregar esta propiedad en copyWith
    bool? isPaused,
    bool? bombDialogShown, // Agregar esta propiedad en copyWith
  }) {
    return GameState(
      participants: participants ?? this.participants,
      cards: cards ?? this.cards,
      selectedCard: selectedCard ?? this.selectedCard,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      remainingTime: remainingTime ?? this.remainingTime,
      enteredWord: enteredWord ?? this.enteredWord,
      diceResult: diceResult ?? this.diceResult,
      isDiceRolled: isDiceRolled ?? this.isDiceRolled,
      isGameStarted: isGameStarted ?? this.isGameStarted,
      rounds: rounds ?? this.rounds,
      bombExploded: bombExploded ?? this.bombExploded,
      wordInvalid: wordInvalid ?? this.wordInvalid,
      usedWords: usedWords ?? this.usedWords,
      isCardSelected: isCardSelected ?? this.isCardSelected, // Copiar la bandera
      isPaused: isPaused ?? this.isPaused,
      bombDialogShown: bombDialogShown ?? this.bombDialogShown, // Copiar la nueva bandera
    );
  }
}
