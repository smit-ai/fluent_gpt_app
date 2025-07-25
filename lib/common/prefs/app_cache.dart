import 'package:fluent_gpt/common/prefs/prefs_types.dart';
import 'package:fluent_gpt/system_messages.dart';
import 'package:flutter/gestures.dart';

class AppCache {
  /* Main settings */
  static const currentFileIndex = IntPref("currentFileIndex");
  // ${resolution.width}x${resolution.height}
  static const resolution = StringPref("resolution", '500x700');
  static const preventClose = BoolPref("preventClose");
  static const showAppInDock = BoolPref("showAppInDock", false);
  static const enableOverlay = BoolPref("enableOverlay", false);
  static const alwaysOnTop = BoolPref("alwaysOnTop", false);
  static const hideTitleBar = BoolPref("hideTitleBar", false);
  static const isMarkdownViewEnabled = BoolPref("isMarkdownView", true);
  static const overlayVisibleElements = IntPref("overlayVisibleElements", -1);
  static const messageTextSize = IntPref("messageTextSize", 14);
  static const compactMessageTextSize = IntPref("compactMessageTextSize", 10);
  static const showSettingsInOverlay = BoolPref("showSettingsInOverlay", true);
  static const frameless = BoolPref("frameless", false);
  static const StringPref backgroundEffect =
      StringPref("backgroundEffect", 'disabled');
  static const speechLanguage = StringPref("speechLanguage", 'en');
  static const appThemeStyle = StringPref("appThemeStyle", 'dark');
  static const textToSpeechService =
      StringPref("textToSpeechService", 'deepgram');
  static const deepgramVoiceModel =
      StringPref("deepgramVoiceModel", 'aura-asteria-en');
  static const azureVoiceModel =
      StringPref("azureVoiceModel", 'en-US-AvaMultilingualNeural');
  static const elevenlabsVoiceModelName =
      StringPref("elevenlabsVoiceModel", 'Aria');
  static const elevenlabsModel = StringPref("elevenlabsModel", '');
  static const elevenlabsVoiceModelId =
      StringPref("elevenlabsVoiceModelId", '9BWtsMINqrJLrRacOk9x');
  static const autoScrollSpeed = DoublePref("autoScrollSpeed", 0.1);
  static const selectedChatRoomId = StringPref("selectedChatRoomName");
  static const micrpohoneDeviceId = StringPref("micrpohoneDeviceId");
  static const micrpohoneDeviceName = StringPref("micrpohoneDeviceName");
  static const scrapOnlyDecription = BoolPref("scrapOnlyDecription", true);
  static const fetchChatsPeriodically =
      BoolPref("fetchChatsPeriodically", false);
  static const fetchChatsPeriodMin = IntPref("fetchChatsPeriodMin", 10);
  static const pricePer1MSent = StringPref("pricePer1MSent", '1.0');
  static const pricePer1MReceived = StringPref("pricePer1MReceived", '1.0');
  static const costCalcNotes = StringPref("costCalcNotes", '');
  static const locale = StringPref("locale", 'en');
  static const archiveOldChatsAfter = IntPref("deleteOldChatsAfter", 45);
  static const deleteOldArchivedChatsAfter =
      IntPref("deleteOldArchivedChatsAfter", 60);
  static const imageGenerator = IntPref("imageGenerator", 0);
  static const imageGeneratorApiKey = StringPref("imageGeneratorApiKey", null);
  static const imageGeneratorSize =
      StringPref("imageGeneratorSize", '1024x1024');
  static const imageGeneratorQuality =
      StringPref("imageGeneratorQuality", "hd");
  static const imageGeneratorStyle =
      StringPref("imageGeneratorStyle", "natural");
  static const imageGeneratorModel = StringPref("imageGeneratorModel", null);
  static const useRAG = BoolPref("useRag", false);
  static const ragThreshold = DoublePref("ragThreshold", 0.5);
  static const enableReasoning = BoolPref("enableReasoning", false);

  /// Contains Strings that we can't migrate because they are used by StringPref, IntPref etc.
  /// the format is:
  ///
  /// ```json
  /// {
  ///  "key": "value"
  /// }
  /// ```
  static const exportedGlobalSettings =
      FileStringPref("fluent_gpt/exportedGlobalSettings.json");

  /* Directories */
  static const appDocumentsDirectory = StringPref("appDocumentsDirectory", '');

  /* One time banners/tutors */
  /// related to the very first welcome screen
  static const isWelcomeShown = BoolPref("isWelcomeShown", false);

  /* Permissions */
  static const isStorageAccessGranted =
      BoolPref("isFoldersAccessGranted", false);
  static const isMicAccessGranted = BoolPref("isMicAccessGranted", false);

  /* Global Hotkeys */
  static const openWindowKey = StringPref("openWindowKey");
  static const takeScreenshotKey = StringPref("takeScreenshotKey");
  static const pttKey = StringPref("pttKey");
  static const pttScreenshotKey = StringPref("pttScreenshotKey");

  /* Window pos */
  static const windowX = IntPref("windowX");
  static const windowY = IntPref("windowY");
  static const previousCompactOffset =
      OffsetPref("previousCompactOffset", Offset.zero);
  static const windowWidth = IntPref("windowWidth");
  static const windowHeight = IntPref("windowHeight");

  static const globalSystemPrompt = StringPref("globalSystemPrompt", '');
  static const hideEditSystemPromptInHomePage = BoolPref("hideEditSystemPromptInHomePage", true);
  static const tokensUsedTotal = IntPref("tokensUsedTotal");
  static const costTotal = DoublePref("costTotal");

  /// Contains quick prompts for the buttons in the chat
  static const quickPrompts = FileStringPref("fluent_gpt/customPrompts.json");

  /// Contains all the prompts from the library like system messages, helpers etc.
  static const promptsLibrary =
      FileStringPref("fluent_gpt/promptsLibrary.json");
  static const customActions = FileStringPref("fluent_gpt/customActions.json");
  static const savedModels = FileStringPref("fluent_gpt/savedModels.json");
  static const userInfo = UserInfoFilePref("fluent_gpt/userInfo.json");
  static const maxTokensUserInfo = IntPref("maxTokensUserInfo", 1024);
  static const userName = StringPref("userName", 'User');
  static const userCityName = StringPref("userCityName", '');
  static const showWeatherWidget = BoolPref("showWeatherWidget", true);
  static const weatherData = StringPref("weatherData");

  /// DateTime in milliseconds since epoch. default is 0
  static const lastTimeWeatherFetched = IntPref("lastTimeWeatherFetched", 0);
  static const archivedPrompts = StringPref("archivedPrompts");

  /* APIs/Keys */
  static const localApiModelPath = StringPref("localApiModels", '');
  static const braveSearchApiKey = StringPref("braveSearchApiKey", '');
  static const imgurClientId = StringPref("imgurClientId", '');
  static const deepgramApiKey = StringPref("deepgramApiKey", '');
  static const azureSpeechApiKey = StringPref("azureSpeechApiKey", '');
  static const azureSpeechRegion = StringPref("azureSpeechRegion", 'eastus2');
  static const elevenLabsApiKey = StringPref("elevenLabsApiKey", '');

  /* Tools enabled/disabled */
  static const gptToolCopyToClipboardEnabled =
      BoolPref("copyToClipboardEnabled", true);
  static const gptToolAutoOpenUrls = BoolPref("gptToolAutoOpenUrls", true);
  static const gptToolGenerateImage = BoolPref("gptToolGenerateImage", true);
  static const gptToolRememberInfo = BoolPref("rememberInfo", true);
  static const useAiToNameChat =
      BoolPref("useSecondRequestForNamingChats", false);
  static const enableAutonomousMode = BoolPref("enableAutonomousMode", false);
  static const annoyModeTimerMinMinutes =
      IntPref("annoyModeTimerMinMinutes", 100);
  static const annoyModeTimerMaxMinutes =
      IntPref("annoyModeTimerMaxMinutes", 120);
  static const includeUserNameToSysPrompt =
      BoolPref("includeUserNameToSysPrompt", true);
  static const includeUserCityNamePrompt =
      BoolPref("includeUserCityNamePrompt", false);
  static const includeWeatherPrompt = BoolPref("includeWeatherPrompt", false);
  static const includeSysInfoToSysPrompt =
      BoolPref("includeSysInfoToSysPrompt", false);
  static const includeKnowledgeAboutUserToSysPrompt =
      BoolPref("includeKnowledgeAboutUserToSysPrompt", false);
  static const includeTimeToSystemPrompt =
      BoolPref("includeTimeToSystemPrompt", true);
  @Deprecated('Use gptToolRememberInfo')
  static const learnAboutUserAfterCreateNewChat =
      BoolPref("learnAboutUserAfterCreateNewChat", false);
  static const autoPlayMessagesFromAi = BoolPref("autoPlayMessagesFromAi", false);
  static const speedIntIncreasePerc = IntPref("ttsSpeed", 0);
  static const enableQuestionHelpers = BoolPref("enableQuestionHelpers");
  static const nerdySelectorType = IntPref("nerdySelectorType", 0);

  /* Use API */
  static const useGoogleApi = BoolPref("useGoogleApi", false);
  static const useImgurApi = BoolPref("useImgurApi", false);
  static const useSouceNao = BoolPref("useSouceNao", false);
  static const useYandexImageSearch = BoolPref("useYandexImageSearch", false);

  static const List<Pref> settingsToExportList = [
    azureSpeechApiKey,
    azureSpeechRegion,
    useGoogleApi,
    useImgurApi,
    useSouceNao,
    useYandexImageSearch,
    braveSearchApiKey,
    imgurClientId,
    deepgramApiKey,
    elevenLabsApiKey,
    userCityName,
    userName,
    maxTokensUserInfo,
    globalSystemPrompt,
    scrapOnlyDecription,
    autoScrollSpeed,
    elevenlabsVoiceModelId,
    elevenlabsModel,
    elevenlabsVoiceModelName,
    deepgramVoiceModel,
    backgroundEffect,
    compactMessageTextSize,
    messageTextSize,
    overlayVisibleElements,
    isMarkdownViewEnabled,
    enableOverlay,
    showSettingsInOverlay,
    speechLanguage,
    textToSpeechService,
  ];
}
