; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "FluentGPT"
#define MyAppVersion "1.0.70"
#define MyAppPublisher "realkalash"
#define MyAppURL "https://github.com/realkalash/fluent_gpt_app"
#define MyAppExeName "fluent_gpt.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{C27B7438-3670-45C6-9435-EF1852976684}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
; "ArchitecturesAllowed=x64compatible" specifies that Setup cannot run
; on anything but x64 and Windows 11 on Arm.
ArchitecturesAllowed=x64compatible
; "ArchitecturesInstallIn64BitMode=x64compatible" requests that the
; install be done in "64-bit mode" on x64 or Windows 11 on Arm,
; meaning it should use the native 64-bit Program Files directory and
; the 64-bit view of the registry.
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
LicenseFile=C:\Users\alex\repos\fluent_gpt_app\LICENSE.md
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=C:\Users\alex\repos\fluent_gpt_app\installers
OutputBaseFilename=FluentGPT-{#MyAppVersion}
SetupIconFile="C:\Users\alex\repos\fluent_gpt_app\assets\app_icon.ico"
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\file_selector_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\flutter_acrylic_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\gpt_tokenizer.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\hotkey_manager_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\irondash_engine_context_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\pasteboard_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\audioplayers_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\record_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\permission_handler_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\protocol_handler_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\screen_retriever_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
; Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\super_native_extensions.dll"; DestDir: "{app}"; Flags: ignoreversion
; Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\super_native_extensions_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\system_theme_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\tray_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\keypress_simulator_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\windows_single_instance_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\windows_notification_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\capture_screenshot.py"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\alex\repos\fluent_gpt_app\build\windows\x64\runner\Release\drag_and_drop_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

