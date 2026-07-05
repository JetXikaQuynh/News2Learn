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

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();

  Hive.registerAdapter(BookmarkModelAdapter());

  Hive.registerAdapter(VocabModelAdapter());

  Hive.registerAdapter(UserModelAdapter());

  Hive.registerAdapter(UserVocabModelAdapter());

  Hive.registerAdapter(QuizResultModelAdapter());

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D28D9)),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}
