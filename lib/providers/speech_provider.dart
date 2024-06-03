
// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_recognition_error.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// import 'game_provider.dart';

// class SpeechState {
//   final bool isListening;
//   final bool isVerifying;
//   final bool wordVerified;
//   final bool speechEnabled;
//   final String lastWords;
//   final String lastError;
//   final String lastStatus;
//   final List<String> spokenWords;
//   final List<LocaleName> localeNames;
//   final String currentLocaleId;
//   final int currentPlayerIndex;
//   final List<String> players;
//   final bool ttsAnnounced;

//   SpeechState({
//     this.isListening = false,
//     this.isVerifying = false,
//     this.wordVerified = false,
//     this.speechEnabled = false,
//     this.lastWords = '',
//     this.lastError = '',
//     this.lastStatus = '',
//     this.spokenWords = const [],
//     this.localeNames = const [],
//     this.currentLocaleId = '',
//     this.currentPlayerIndex = 0,
//     this.players = const [],
//     this.ttsAnnounced = false,
//   });

//   SpeechState copyWith({
//     bool? isListening,
//     bool? isVerifying,
//     bool? wordVerified,
//     bool? speechEnabled,
//     String? lastWords,
//     String? lastError,
//     String? lastStatus,
//     List<String>? spokenWords,
//     List<LocaleName>? localeNames,
//     String? currentLocaleId,
//     int? currentPlayerIndex,
//     List<String>? players,
//     bool? ttsAnnounced,
//   }) {
//     return SpeechState(
//       isListening: isListening ?? this.isListening,
//       isVerifying: isVerifying ?? this.isVerifying,
//       wordVerified: wordVerified ?? this.wordVerified,
//       speechEnabled: speechEnabled ?? this.speechEnabled,
//       lastWords: lastWords ?? this.lastWords,
//       lastError: lastError ?? this.lastError,
//       lastStatus: lastStatus ?? this.lastStatus,
//       spokenWords: spokenWords ?? this.spokenWords,
//       localeNames: localeNames ?? this.localeNames,
//       currentLocaleId: currentLocaleId ?? this.currentLocaleId,
//       currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
//       players: players ?? this.players,
//       ttsAnnounced: ttsAnnounced ?? this.ttsAnnounced,
//     );
//   }
// }




// class SpeechNotifier extends StateNotifier<SpeechState> {
//   final SpeechToText _speechToText = SpeechToText();
//   final FlutterTts _flutterTts = FlutterTts();
//   final Ref ref;
//   Timer? _listeningTimer;

//   SpeechNotifier(this.ref) : super(SpeechState()) {
//     _initSpeech();
//     _flutterTts.setLanguage("es-ES");
//   }

//   Future<void> _initSpeech() async {
//     bool speechEnabled = await _speechToText.initialize(
//       onError: errorListener,
//       onStatus: statusListener,
//     );
//     if (speechEnabled) {
//       List<LocaleName> localeNames = await _speechToText.locales();
//       var systemLocale = await _speechToText.systemLocale();
//       String currentLocaleId = systemLocale?.localeId ?? '';
//       state = state.copyWith(
//         speechEnabled: speechEnabled,
//         localeNames: localeNames,
//         currentLocaleId: currentLocaleId,
//       );
//     }
//   }

//   void resetState() {
//     state = state.copyWith(
//       lastWords: '',
//       lastError: '',
//       isListening: false,
//       wordVerified: false,
//       isVerifying: false,
//     );
//   }

//   void startListening() async {
//     state = state.copyWith(lastWords: '', lastError: '', isListening: true, wordVerified: false);
//     await _speechToText.listen(
//       onResult: _onSpeechResult,
//       listenFor: Duration(seconds: 30),
//       pauseFor: Duration(seconds: 3),
//       localeId: state.currentLocaleId,
//       onSoundLevelChange: soundLevelListener,
//       cancelOnError: true,
//       partialResults: true,
//     );
//     _startListeningTimer();
//   }

//   void stopListening() async {
//     await _speechToText.stop();
//     _listeningTimer?.cancel();
//     state = state.copyWith(isListening: false);
//   }

//   void cancelListening() async {
//     await _speechToText.cancel();
//     _listeningTimer?.cancel();
//     state = state.copyWith(isListening: false);
//   }

//   void _startListeningTimer() {
//     _listeningTimer?.cancel();
//     _listeningTimer = Timer(Duration(seconds: 3), () {
//       if (state.isListening && !state.wordVerified) {
//         stopListening();
//       }
//     });
//   }

//   void _onSpeechResult(SpeechRecognitionResult result) {
//     state = state.copyWith(lastWords: result.recognizedWords, wordVerified: true);
//     stopListening();
//   }

//   void soundLevelListener(double level) {
//     // Implement sound level handling if needed
//   }

//   void errorListener(SpeechRecognitionError error) {
//     state = state.copyWith(lastError: '${error.errorMsg} - ${error.permanent}');
//   }

//   void statusListener(String status) {
//     state = state.copyWith(lastStatus: status);
//   }

//   Future<bool> verifyWord() async {
//     if (state.lastWords.isNotEmpty && !state.spokenWords.contains(state.lastWords)) {
//       state = state.copyWith(isVerifying: true);
//       try {
//         final url = Uri.parse('https://us-central1-cafealpaso-a253c.cloudfunctions.net/app/validate-word');
//         final response = await http.post(
//           url,
//           headers: {
//             'Content-Type': 'application/json',
//           },
//           body: jsonEncode({'palabra': state.lastWords}),
//         ).timeout(Duration(seconds: 10)); // Timeout after 10 seconds

//         if (response.statusCode == 200) {
//           final responseBody = jsonDecode(response.body);
//           if (responseBody['existe']) {
//             state = state.copyWith(
//               spokenWords: [...state.spokenWords, state.lastWords],
//               lastWords: '',
//               currentPlayerIndex: (state.currentPlayerIndex + 1) % state.players.length,
//               ttsAnnounced: false,
//               isVerifying: false,
//               wordVerified: false, // Reset word verification
//             );
//             ref.read(gameProvider.notifier).setEnteredWord(state.lastWords);
//             return true;
//           } else {
//             await speak('La palabra no existe, di otra palabra');
//             state = state.copyWith(isVerifying: false);
//             return false;
//           }
//         } else {
//           await speak('Hubo un error con la validación, intenta de nuevo');
//           state = state.copyWith(isVerifying: false);
//           return false;
//         }
//       } catch (e) {
//         await speak('Hubo un error con la validación, intenta de nuevo');
//         state = state.copyWith(isVerifying: false);
//         return false;
//       }
//     } else {
//       await speak('Sorry, di otra palabra');
//       return false;
//     }
//   }

//   void switchLang(String selectedVal) {
//     state = state.copyWith(currentLocaleId: selectedVal);
//   }

//   Future<void> speak(String text) async {
//     await _flutterTts.speak(text);
//   }

//   Future<void> announcePlayer() async {
//     if (!state.ttsAnnounced && state.players.isNotEmpty) {
//       await speak('${state.players[state.currentPlayerIndex]} toca el micrófono para comenzar a escuchar...');
//       state = state.copyWith(ttsAnnounced: true);
//     }
//   }

//   void setPlayers(List<String> players) {
//     state = state.copyWith(players: players, currentPlayerIndex: 0);
//   }
// }

// final speechProvider = StateNotifierProvider<SpeechNotifier, SpeechState>((ref) => SpeechNotifier(ref));
