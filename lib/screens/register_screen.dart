import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final gameState = ref.watch(gameProvider);
     int index = 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Participantes')),
      body: Column(
        children: [
          ...gameState.participants.map((participant) {
            index++;
            return TextField(
              decoration: InputDecoration(labelText: 'Participante N°${index}'),
              onChanged: (value) {
                ref.read(gameProvider.notifier).updateParticipantName(gameState.participants.indexOf(participant), value);
              },
            );
            
          }).toList(),

          if (gameState.participants.length < 5)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                ref.read(gameProvider.notifier).addParticipant();
              },
            ),
          ElevatedButton(
            onPressed: gameState.participants.length >= 2 ? () {
              ref.read(gameProvider.notifier).selectRandomParticipant();
              context.push('/game');
    
            } : null,
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
