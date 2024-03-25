import 'dart:async';
import 'dart:developer';
import 'package:uni_links/uni_links.dart';

class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._();

  DeepLinkHandler._();

  factory DeepLinkHandler() => _instance;

  final _linkStreamController = StreamController<String?>.broadcast();

  Stream<String?> get linkStream => _linkStreamController.stream;

  Future<void> init() async {
    try {
      final initialLink = await getInitialUri();
      if (initialLink != null) {
        _linkStreamController.add(initialLink.toString());
      }
    } on Exception catch (e) {
      log('Error initializing deep link handler: $e');
    }

    uriLinkStream.listen((Uri? link) {
      _linkStreamController.add(link?.toString());
    });
  }
}
