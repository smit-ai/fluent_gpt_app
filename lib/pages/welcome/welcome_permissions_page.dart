import 'dart:io';

import 'package:fluent_gpt/common/prefs/app_cache.dart';
import 'package:fluent_gpt/features/screenshot_tool.dart';
import 'package:fluent_gpt/file_utils.dart';
import 'package:fluent_gpt/log.dart';
import 'package:fluent_gpt/native_channels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'package:window_manager/window_manager.dart';

import 'welcome_screen.dart';

class WelcomePermissionsPage extends StatefulWidget {
  const WelcomePermissionsPage({super.key});

  @override
  State<WelcomePermissionsPage> createState() => _WelcomePermissionsPageState();
}

class _WelcomePermissionsPageState extends State<WelcomePermissionsPage> with WidgetsBindingObserver {
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log('App resumed. Rechecking permissions');
      setState(() {});
    }
  }

  bool isAccessibilityGranted = false;
  bool isNotificationsGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        AppCache.isMicAccessGranted.value = await Permission.microphone.isGranted;
      } catch (e) {
        logError('Error checking microphone permission: $e');
      }
      if (mounted) setState(() {});
      try {
        isAccessibilityGranted = await NativeChannelUtils.isAccessibilityGranted();
      } catch (e) {
        logError('Error checking accessibility permission: $e');
      }
      if (mounted) setState(() {});
      try {
        final notificationsState = await IOSFlutterLocalNotificationsPlugin().checkPermissions();
        if (notificationsState?.isEnabled == true) {
          isNotificationsGranted = true;
        }
      } catch (e) {
        logError('Error checking notifications permission: $e');
      }
      if (mounted) setState(() {});
    });

    if (Platform.isMacOS) {
      Future.delayed(const Duration(milliseconds: 1000)).then((_) async {
        Size windowSize = await windowManager.getSize();
        Offset position = await calcWindowPosition(windowSize, Alignment.center);
        await windowManager.setBounds(
          null,
          size: const Size(800 * 1.5, 500 * 1.5),
          position: position.translate(-200, -200),
          animate: true,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[900],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const TextAnimator(
                        'Permissions',
                        initialDelay: Duration(milliseconds: 500),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const TextAnimator(
                      'Unlock the full potential',
                      initialDelay: Duration(milliseconds: 1000),
                      characterDelay: Duration(milliseconds: 15),
                      style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextAnimator(
                      'Granting these permissions ensures all features work seamlessly from the get-go.',
                      initialDelay: const Duration(milliseconds: 1500),
                      characterDelay: const Duration(milliseconds: 5),
                      style: TextStyle(color: Colors.white.withAlpha(178), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(
                color: Colors.white,
                thickness: 1,
              ),
              // Right side
              Expanded(
                flex: 3,
                child: Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          // const PermissionItem(
                          //   icon: Icons.calendar_today,
                          //   title: 'Calendar and Contacts',
                          //   description:
                          //       'Allows you to check upcoming meetings and join calls.',
                          //   isGranted: true,
                          // ),
                          // const SizedBox(height: 24),
                          PermissionItem(
                            icon: Icons.folder_outlined,
                            title: 'Files and Folders',
                            description:
                                'Allows you to save chats history and temprorarily python files generated by LLM',
                            isGranted: AppCache.isStorageAccessGranted.value!,
                            onGrantAccessTap: () async {
                              final res = await FileUtils.touchAccessAllFolders();
                              if (res == true) {
                                AppCache.isStorageAccessGranted.value = true;
                                await FileUtils.init();
                                ScreenshotTool.init(isStorageAccessGranted: true);

                                setState(() {});
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          PermissionItem(
                            icon: Icons.mic,
                            title: 'Microphone',
                            description: 'Allows you to record your voice and send it to LLM',
                            isGranted: AppCache.isMicAccessGranted.value!,
                            onGrantAccessTap: () async {
                              final result = await AudioRecorder().hasPermission();
                              if (result == false) return;
                              AppCache.isMicAccessGranted.value = true;
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 24),
                          if (Platform.isMacOS)
                            PermissionItem(
                              icon: Icons.accessibility_new,
                              title: 'Accessibility',
                              description: 'Allows you to use overlay, resize windows and more.',
                              isGranted: isAccessibilityGranted,
                              onGrantAccessTap: () async {
                                await NativeChannelUtils.initAccessibility();
                                await Future.delayed(Durations.extralong4);
                                setState(() {});
                              },
                            ),
                          const SizedBox(height: 24),
                          if (Platform.isMacOS)
                            PermissionItem(
                              icon: Icons.notifications,
                              title: 'Notifications',
                              description: 'Allows you to receive notifications from the app.',
                              isGranted: isNotificationsGranted,
                              onGrantAccessTap: () async {
                                await MacOSFlutterLocalNotificationsPlugin().requestPermissions(
                                  alert: true,
                                  sound: true,
                                  badge: true,
                                );
                                await Future.delayed(Durations.extralong4);
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
