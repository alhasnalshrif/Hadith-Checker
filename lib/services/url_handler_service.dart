import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadith_cheker/blocs/hadith_bloc.dart';

class UrlHandlerService {
  static const MethodChannel _channel = MethodChannel(
    'app.hadith_checker/url_handler',
  );
  static final StreamController<String> _textStreamController =
      StreamController<String>.broadcast();

  static Stream<String> get textStream => _textStreamController.stream;

  static Future<void> initialize() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'handleSharedText' ||
          call.method == 'handleCheckHadith') {
        final String sharedText = call.arguments as String;
        _textStreamController.add(sharedText);
      }
      return null;
    });

    // Check if app was opened with shared text or context menu
    try {
      final String? initialText = await _channel.invokeMethod(
        'getInitialSharedText',
      );
      if (initialText != null && initialText.isNotEmpty) {
        _textStreamController.add(initialText);
      }
    } catch (e) {
      print('Error getting initial shared text: $e');
    }
  }

  static void dispose() {
    _textStreamController.close();
  }

  static void processSharedText(context, text) {
    if (text.isNotEmpty) {
      BlocProvider.of<HadithBloc>(context).add(SearchHadithEvent(text));
    }
  }
}
