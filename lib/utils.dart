import 'dart:io';

import 'package:fluent_gpt/common/custom_messages/image_custom_message.dart';
import 'package:fluent_gpt/common/custom_messages_src.dart';
import 'package:fluent_gpt/common/prefs/app_cache.dart';
import 'package:fluent_gpt/main.dart';
import 'package:fluent_gpt/providers/chat_globals.dart';
import 'package:fluent_gpt/providers/weather_provider.dart';
import 'package:fluent_gpt/system_messages.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:intl/intl.dart';
import 'package:langchain/langchain.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:system_info2/system_info2.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

/// Generates a random 16 character ID for chats
String generateChatID() => nanoid(length: 16);

/// Generates a random 16 character ID
String generate16ID() => nanoid(length: 16, alphabet: Alphabet.alphanumeric);

extension ThemeExtension on BuildContext {
  FluentThemeData get theme => FluentTheme.of(this);
}

extension ChatMessageExtension on ChatMessage {
  Map<String, dynamic> toJson() {
    if (this is HumanChatMessage && (this as HumanChatMessage).content is ChatMessageContentText) {
      final message = this as HumanChatMessage;
      return {
        'prefix': HumanChatMessage.defaultPrefix,
        'content': (message.content as ChatMessageContentText).text,
      };
    }
    if (this is HumanChatMessage && (this as HumanChatMessage).content is ChatMessageContentImage) {
      final message = this as HumanChatMessage;
      return {
        'prefix': HumanChatMessage.defaultPrefix,
        'base64': (message.content as ChatMessageContentImage).data,
      };
    }
    // AI
    if (this is AIChatMessage) {
      final message = this as AIChatMessage;
      return {
        'prefix': AIChatMessage.defaultPrefix,
        'content': message.content,
      };
    }
    // Extended custom messages should be checked before CustomChatMessage
    // because they are extended from CustomChatMessage
    if (this is WebResultCustomMessage) {
      return (this as WebResultCustomMessage).toJson();
    }
    if (this is TextFileCustomMessage) {
      return (this as TextFileCustomMessage).toJson();
    }
    if (this is ImageCustomMessage) {
      return (this as ImageCustomMessage).toJson();
    }

    if (this is CustomChatMessage) {
      final message = this as CustomChatMessage;
      return {
        'prefix': message.role,
        'content': message.content,
      };
    }
    if (this is SystemChatMessage) {
      final message = this as SystemChatMessage;
      return {
        'prefix': SystemChatMessage.defaultPrefix,
        'content': message.content,
      };
    }

    throw Exception('Invalid content');
  }
}

/// hotkey extension to get string
extension HotKeyExtension on HotKey {
  String get hotkeyString {
    final key = logicalKey;
    final modifiers = <String>[];
    this.modifiers?.forEach((modifier) {
      modifiers.add(modifier.name);
    });
    return '${modifiers.join('+')}+${key.keyLabel}';
  }

  String get hotkeyShortString {
    final key = logicalKey;
    final modifiers = <String>[];
    this.modifiers?.forEach((modifier) {
      if (modifier == HotKeyModifier.control) {
        modifiers.add('Ctr');
      } else if (modifier == HotKeyModifier.shift) {
        modifiers.add('⇧');
      } else if (modifier == HotKeyModifier.meta) {
        modifiers.add('⌘');
      } else if (modifier == HotKeyModifier.alt) {
        modifiers.add(Platform.isMacOS ? '⌥' : 'Alt');
      } else {
        modifiers.add(modifier.name.substring(0, 1).toUpperCase());
      }
    });
    return '${modifiers.join('+')}+${key.keyLabel}';
  }
}

/// String extensions
extension StringExtension on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';

  /// If the string contains is wrapped with " it will remove them
  String get removeWrappedQuotes {
    if (startsWith('"') && endsWith('"')) {
      return substring(1, length - 1);
    }
    return this;
  }
}

String getSystemInfoString() {
  final dateTime = DateTime.now();
  final formatter = DateFormat('yyyy-MM-dd HH:mm E');
  final formattedDate = formatter.format(dateTime);
  return '''OS: ${SysInfo.operatingSystemName}
Cores: ${SysInfo.cores.length}
kernel: ${SysInfo.rawKernelArchitecture}
KernelName: ${SysInfo.kernelName}
OS version: ${SysInfo.kernelVersion}
User directory: ${SysInfo.userDirectory}
User system id: ${SysInfo.userId}
User name in OS: ${SysInfo.userName}
Current date: $formattedDate
''';
}

String contextualInfoDelimeter = '\n\nContextual information about the user. Dont use it until it is necessary!';

Future<String> getFormattedSystemPrompt({required String basicPrompt, String? appendText}) async {
  /// we append them line by line
  final userName = AppCache.userName.value;
  final systemInfo = getSystemInfoString();
  infoAboutUser = await AppCache.userInfo.value();
  final userInfo = infoAboutUser.replaceAll('{user_name}', userName ?? '{user}');
  String prompt = basicPrompt;
  bool isIncludeAdditionalEnabled = AppCache.includeSysInfoToSysPrompt.value! ||
      AppCache.includeUserNameToSysPrompt.value! ||
      AppCache.includeWeatherPrompt.value! ||
      AppCache.includeUserCityNamePrompt.value! ||
      AppCache.includeTimeToSystemPrompt.value! ||
      AppCache.includeKnowledgeAboutUserToSysPrompt.value!;

  if (isIncludeAdditionalEnabled) {
    prompt += contextualInfoDelimeter;
  }
  if (AppCache.includeTimeToSystemPrompt.value!) {
    final dateTime = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm a E');
    final formattedDate = formatter.format(dateTime);
    prompt += '\n\nCurrent date and time: $formattedDate';
  }

  if (AppCache.includeSysInfoToSysPrompt.value!) {
    prompt += '\nSystem info: $systemInfo';
  }
  if (AppCache.includeUserNameToSysPrompt.value!) {
    prompt += '\nUser name: $userName';
  }
  if (AppCache.includeWeatherPrompt.value!) {
    final todayMax = weatherTodayMax;
    final todayMin = weatherTodayMin;
    final tomorrowAvg = weatherTomorrowMax;
    prompt +=
        "\nCurrent weather in ${todayMax?.units ?? 'Celsius'} (DONT EXPOSE IT UNTIL IT IS NECESSARY): max: ${todayMax?.temperature} min: ${todayMin?.temperature} status: ${todayMax?.weatherStatus.name}"
        "\nTomorrow weather max: ${tomorrowAvg?.temperature} ${tomorrowAvg?.units} status: ${tomorrowAvg?.weatherStatus.name}";
  }
  if (AppCache.includeUserCityNamePrompt.value!) {
    prompt += '\nUser located in: ${AppCache.userCityName.value}';
  }

  if (AppCache.includeKnowledgeAboutUserToSysPrompt.value!) {
    prompt += '\n\nThings you remembered from previous dialogs: """$userInfo"""';
  }
  if (isIncludeAdditionalEnabled) {
    prompt += '\n';
  }
  if (appendText != null) {
    prompt += '\n\n$appendText';
  }
  return prompt;
}

String formatArgsInSystemPrompt(String prompt) {
  /// TODO: implement this function to format the args in the system prompt
  // final userName = AppCache.userName.value;
  // final systemInfo = getSystemInfoString();
  // infoAboutUser = await AppCache.userInfo.value();
  // final userInfo = infoAboutUser;
  // String formattedPrompt = prompt;
  // formattedPrompt = formattedPrompt.replaceAll('{user_name}', userName);
  // formattedPrompt = formattedPrompt.replaceAll('{system_info}', systemInfo);
  // formattedPrompt =
  //     formattedPrompt.replaceAll('{user_info}', infoAboutUser ?? '');
  // return formattedPrompt;
  // {{pinnedMessages}}

  StringBuffer sb = StringBuffer();
  // Split by any whitespace (space, tab, newline, etc.)
  final words = prompt.split(RegExp(r'\s+'));
  for (final word in words) {
    if (word.isNotEmpty && word[0] == '{') {
      if (word.contains('{{pinnedMessages}}')) {
        _addPinnedMessages(sb, word);
      }
    } else if (word.isNotEmpty) {
      sb.write('$word ');
    }
  }
  return sb.toString();
}

void _addPinnedMessages(StringBuffer sb, String word) {
  /// Indexes from [reversedMessagesList] list where 0 is the oldest one and 999 is the newest
  final pinnedMessages = pinnedMessagesIndexes;
  sb.writeln('\nPinned:');
  int i = 0;
  for (final index in pinnedMessages) {
    final message = messagesReversedList[index];
    sb.writeln('$i: ${message.content}. By: ${message.creator}');
    i++;
  }
}

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

Future<void> displayCopiedToClipboard() {
  return displayInfoBar(
    appContext!,
    alignment: Alignment(0.0, 0.9),
    builder: (context, close) => InfoBar(
      title: const Text('Copied'),
      severity: InfoBarSeverity.info,
      style: InfoBarThemeData(icon: (_) => FluentIcons.clipboard_24_filled),
    ),
  );
}

Future<void> displaySuccessInfoBar({String? title}) {
  return displayInfoBar(
    appContext!,
    alignment: Alignment(0.0, 0.9),
    builder: (context, close) => InfoBar(
      title: Text(title ?? 'Success'),
      severity: InfoBarSeverity.success,
    ),
  );
}

Future<void> displayTextInfoBar(
  String title, {
  Alignment alignment = const Alignment(0.0, 0.9),
  Widget Function(ui.VoidCallback close)? action,
}) {
  return displayInfoBar(
    appContext!,
    alignment: alignment,
    builder: (context, close) => InfoBar(
      title: Text(title),
      severity: InfoBarSeverity.info,
      action: action?.call(close),
    ),
  );
}

Future<void> displayErrorInfoBar({String? title, String? message, Widget? action}) {
  return displayInfoBar(
    appContext!,
    alignment: Alignment(0.0, 0.9),
    builder: (context, close) => InfoBar(
      title: Text(title ?? 'Error'),
      content: message != null ? Text(message) : null,
      severity: InfoBarSeverity.error,
      action: action,
    ),
  );
}

class ImageDimensions {
  final double width;
  final double height;

  const ImageDimensions({
    required this.width,
    required this.height,
  });

  @override
  String toString() => '(width: $width, height: $height)';

  static Future<ImageDimensions> fromBytes(Uint8List bytes) async {
    return getImageDimensionsFromBytes(bytes);
  }
}

/// Gets the dimensions of an image from its bytes
///
/// Returns [ImageDimensions] containing width and height
/// Throws [Exception] if image cannot be decoded
Future<ImageDimensions> getImageDimensionsFromBytes(Uint8List bytes) async {
  try {
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;

    return ImageDimensions(
      width: image.width.toDouble(),
      height: image.height.toDouble(),
    );
  } catch (e) {
    throw Exception('Failed to decode image: $e');
  } finally {
    // Clean up resources
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
