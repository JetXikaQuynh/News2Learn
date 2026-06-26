import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/bookmark_model.dart';
import 'models/vocab_model.dart';
import 'models/user_model.dart';
import 'models/user_vocab_model.dart';
import 'models/quiz_result_model.dart';

import 'features/articles/providers/article_provider.dart';
import 'features/splash/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔧 LOAD ENV VARIABLES
  await dotenv.load(fileName: ".env");

  // 🔥 FIREBASE
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔥 HIVE
  await Hive.initFlutter();

  Hive.registerAdapter(BookmarkModelAdapter());
  await Hive.openBox<BookmarkModel>('bookmarkBox');

  Hive.registerAdapter(VocabModelAdapter());
  await Hive.openBox<VocabModel>('vocabBox');

  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('userBox');

  Hive.registerAdapter(UserVocabModelAdapter());
  await Hive.openBox<UserVocabModel>('userVocabBox');

  Hive.registerAdapter(QuizResultModelAdapter());
  await Hive.openBox<QuizResultModel>('quizResultBox');

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ArticleProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News2Learn',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D28D9),
        ), // Violet seed
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}
