; Inno Setup Script for GHEtool GUI - CI/Windows Build
; Use with: iscc /DLinkToGHEtool="C:\path\to\repo" installer.iss

#ifndef LinkToGHEtool
#define LinkToGHEtool "."
#endif

#define MyAppName "GHEtool OS"
#define MyAppVersion "2.2.0"
#define MyAppPublisher "GHEtool Team"
#define MyAppURL "https://github.com/wouterpeere/GHEtool-GUI"
#define MyAppExeName "GHEtoolGUI.exe"
#define MyAppAssocName MyAppName + " File"
#define MyAppAssocExt ".GHEtool"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
AppId={{12C84980-AE15-4A64-BFFA-3EF61A56D3B8}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir={#LinkToGHEtool}\Output
OutputBaseFilename=GHEtoolOS_setup_{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ChangesAssociations=yes
DisableProgramGroupPage=yes

; License - LICENSE or LICENSE.txt in project root
LicenseFile={#LinkToGHEtool}\LICENSE.txt

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#LinkToGHEtool}\dist\GHEtoolGUI\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#LinkToGHEtool}\dist\GHEtoolGUI\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

; Fonts - uncomment if GHEtoolGUI/font/ exists with Lexend TTF files
; Source: "{#LinkToGHEtool}\GHEtoolGUI\font\Lexend-Regular.TTF"; DestDir: "{autofonts}"; FontInstall: "Lexend"; Flags: onlyifdoesntexist uninsneveruninstall

[Registry]
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: {#MyAppAssocExt}; ValueData: ""

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
