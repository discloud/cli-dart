[Setup]
AppCopyright=Copyright (C) 2026 Discloud, Inc.
AppName=Discloud CLI
AppPublisher=Discloud, Inc.
AppPublisherURL=https://discloud.com
AppReadmeFile=https://github.com/discloud/cli-dart#readme
AppUpdatesURL=https://github.com/discloud/cli-dart/releases
; update with inno_setup script
AppVersion={{version}}
ArchitecturesAllowed=x64os
ArchitecturesInstallIn64BitMode=x64os
ChangesEnvironment=yes
Compression=lzma2/max
DefaultDirName={autopf}\Discloud\cli
DefaultGroupName=Discloud CLI
LicenseFile=LICENSE
OutputBaseFilename=discloud-cli-x64-setup
OutputDir=.
PrivilegesRequired=admin
SetupIconFile=assets\icons\favicon.ico
SolidCompression=yes
; update with inno_setup script
VersionInfoVersion={{version}}.0
WizardStyle=modern dark polar

[Files]
Source: discloud-cli-x64.exe; DestName: discloud.exe; DestDir: {app}; Flags: ignoreversion
Source: assets\icons\favicon.ico; DestDir: {app}; Flags: ignoreversion
Source: LICENSE; DestDir: {app}; Flags: ignoreversion
Source: docs\*.html; DestDir: {app}\docs; Flags: ignoreversion

[Icons]
Name: {app}\CLI Documentation; Filename: {app}\docs\index.html;
Name: {group}\CLI Documentation; Filename: {app}\docs\index.html;
Name: {group}\Uninstall; Filename: {uninstallexe};

[Code]
const
  EnvironmentKey = 'System\CurrentControlSet\Control\Session Manager\Environment';

// Function to add the path to the PATH environment variable
procedure AddPath(Path: string);
var
  Paths: string;
begin
  // Try to read the current system PATH
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths) then
    Paths := '';

  // Check if the path is already there (we use ';' at the ends to avoid false positives with similar paths)
  if Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';') = 0 then
  begin
    // Add the new path
    if Paths = '' then
      Paths := Path
    else if Copy(Paths, Length(Paths), 1) = ';' then
      Paths := Paths + Path
    else
      Paths := Paths + ';' + Path;

    // Save the new PATH to the registry
    RegWriteStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths);
  end;
end;

// Function to remove the path from the PATH environment variable during uninstallation
procedure RemovePath(Path: string);
var
  Paths: string;
  P: Integer;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths) then
    Exit;

  // Prepare strings with ';' to search for the exact block
  Paths := ';' + Paths + ';';
  Path := ';' + Path + ';';

  P := Pos(Uppercase(Path), Uppercase(Paths));
  if P > 0 then
  begin
    // Remove the found segment
    Delete(Paths, P, Length(Path) - 1);
    
    // Clean up the extra ';' we put at the ends
    if Copy(Paths, 1, 1) = ';' then Delete(Paths, 1, 1);
    if Copy(Paths, Length(Paths), 1) = ';' then Delete(Paths, Length(Paths), 1);

    // Save the cleaned PATH to the registry
    RegWriteStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths);
  end;
end;

// Standard Inno Setup event called during Installation
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Add the application directory ({app}) to the PATH
    AddPath(ExpandConstant('{app}'));
  end;
end;

// Standard Inno Setup event called during Uninstallation
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Remove the application directory ({app}) from the PATH
    RemovePath(ExpandConstant('{app}'));
  end;
end;