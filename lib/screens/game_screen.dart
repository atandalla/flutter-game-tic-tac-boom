import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/participant.dart';
import '../providers/game_provider.dart';
import 'menu_screen.dart';
import 'register_screen.dart';

    class GameScreen extends ConsumerWidget {
      @override
      Widget build(BuildContext context, ref) {
        final gameState = ref.watch(gameProvider);

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            appBar: AppBar(title: const Text('Tic Tac Boom')),
            body: Column(
              children: [
                if (gameState.participants.isNotEmpty)
                  Text('Jugador Actual: ${gameState.participants[gameState.currentPlayerIndex].name}'),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: gameState.cards.where((card) => !card.isSelected).length,
                    itemBuilder: (context, index) {
                      final card = gameState.cards.where((card) => !card.isSelected).elementAt(index);
                      return GestureDetector(
                        onTap: gameState.isCardSelected ? null : () {
                          ref.read(gameProvider.notifier).selectCard(index);
                          context.push('/confirm_card');

                        },
                        child: const Card(
                          child: Center(
                            child: Text('?'), // Carta boca abajo
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }




    class ConfirmCardScreen extends ConsumerWidget {
      @override
      Widget build(BuildContext context, ref) {
        final gameState = ref.watch(gameProvider);

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            appBar: AppBar(title: const Text('Confirmar Carta')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Estás seguro de seleccionar esta carta?'),
                const SizedBox(height: 20),
                const Card(
                  child: Center(
                    child: Text('?'), // Mantener la carta boca abajo
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.push('/reveal_card');
                  },
                  child: const Text('Revelar Carta'),
                ),
              ],
            ),
          ),
        );
      }
    }

    class RevealCardScreen extends ConsumerWidget {
      @override
      Widget build(BuildContext context, ref) {
        final gameState = ref.watch(gameProvider);

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            appBar: AppBar(title: const Text('Carta Revelada')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: Center(
                    child: Text(gameState.selectedCard?.syllable ?? ''),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.push('/dice');
                  },
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
        );
      }
    }

    class DiceScreen extends ConsumerWidget {
      @override
      Widget build(BuildContext context, ref) {
        final gameState = ref.watch(gameProvider);

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            appBar: AppBar(title: const Text('Lanzar Dado')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Jugador Actual: ${gameState.participants[gameState.currentPlayerIndex].name}'),
                if (gameState.selectedCard != null) Text('Sílaba: ${gameState.selectedCard!.syllable}'),
                ElevatedButton(
                  onPressed: gameState.isDiceRolled
                      ? null
                      : () {
                          ref.read(gameProvider.notifier).rollDice();
                        },
                  child: const Text('Lanzar Dado'),
                ),
                if (gameState.diceResult.isNotEmpty) Text('Resultado Dado: ${gameState.diceResult}'),
                if (gameState.diceResult.isNotEmpty) ...[
                  ElevatedButton(
                    onPressed: () {
                      ref.read(gameProvider.notifier).startGame();
                      context.push('/play');
                    },
                    child: const Text('Comenzar Juego'),
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }



class PlayScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    if (gameState.bombExploded && !gameState.bombDialogShown) {
      Future.microtask(() {
        final allCardsSelected = gameState.cards.every((card) => card.isSelected);
        
        showDialog(
          context: context,
          barrierDismissible: false, // Make the dialog non-dismissible
          builder: (context) => AlertDialog(
            title: const Text('BOOM !!!!'),
            content: Text('${gameState.participants[gameState.currentPlayerIndex].name} PERDISTE ESTA RONDA'),
            actions: [
              TextButton(
                onPressed: () {
                  gameNotifier.resetRound();
                  context.push('/score');
                },
                child: const Text('Terminar Juego'),
              ),
              if (!allCardsSelected)
                TextButton(
                  onPressed: () {
                    gameNotifier.resetRound();
                    context.push('/game');
                  },
                  child: const Text('Continuar'),
                ),
              TextButton(
                onPressed: () {
                  gameNotifier.resetRound();
                  context.push('/');
                },
                child: const Text('Salir al menú'),
              ),
            ],
          ),
        );

        gameNotifier.state = gameNotifier.state.copyWith(bombDialogShown: true); // Marcar el diálogo como mostrado
      });
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Play')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (gameState.participants.isNotEmpty)
              Text('Jugador Actual: ${gameState.participants[gameState.currentPlayerIndex].name}'),
            Text('Carta Seleccionada: ${gameState.selectedCard?.syllable ?? ''}'),
            Text('Resultado Dado: ${gameState.diceResult}'),
            if (gameState.isGameStarted) ...[
              TextField(
                decoration: const InputDecoration(labelText: 'Ingresar Palabra'),
                onChanged: (value) {
                  gameNotifier.state = gameState.copyWith(enteredWord: value, wordInvalid: false);
                },
              ),
              ElevatedButton(
                onPressed: gameState.enteredWord.isEmpty
                    ? null
                    : () {
                        gameNotifier.submitWord();
                      },
                child: const Text('Enviar Palabra'),
              ),
              Text('Tiempo Restante: ${gameState.remainingTime}'),
              if (gameState.wordInvalid)
                const Text('Palabra incorrecta ! Porfavor intentalo nuevamente', style: TextStyle(color: Colors.red)),
              ...gameState.participants.map((p) => Text('${p.name}: ${p.losses} Perdidas')).toList(),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.push('/score');
                  },
                  child: const Text('Terminar Juego'),
                ),
                ElevatedButton(
                  onPressed: () {
                    gameNotifier.resetGame();
                    gameNotifier.resetRound();
                    context.push('/');
                  },
                  child: const Text('Salir al menú'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                gameNotifier.togglePauseResume();
              },
              child: Text(gameState.isPaused ? 'Reanudar' : 'Pausar'),
            ),
          ],
        ),
      ),
    );
  }
}



    class ScoresScreen extends ConsumerWidget {
      @override
      Widget build(BuildContext context, ref) {
        final gameState = ref.watch(gameProvider);

        // Copia la lista de participantes y ordénala por pérdidas
        final sortedParticipants = List<Participant>.from(gameState.participants)
          ..sort((a, b) => a.losses.compareTo(b.losses));

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            appBar: AppBar(title: const Text('Scores')),
            body: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Participantes con menos puntos:'),
                      ...sortedParticipants.where((p) => p.losses < sortedParticipants.last.losses).map((p) => Text('${p.name}: ${p.losses} losses')).toList(),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Participantes con mas puntos:'),
                      ...sortedParticipants.where((p) => p.losses == sortedParticipants.last.losses).map((p) => Text('${p.name}: ${p.losses} losses')).toList(),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(gameProvider.notifier).resetGame();
                    ref.read(gameProvider.notifier).resetRound();
                    context.go('/');
                  },
                  child: const Text('Regresar al Menú'),
                ),
              ],
            ),
          ),
        );
      }
    }
