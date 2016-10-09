; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "My Awesome Package"
#define MyAppVersion "1.0"
#define MyAppPublisher "MyCompany"
#define MyAppURL "http://www.mycompany.com/"

#define DelphiRootDirectory='C:\Program Files (x86)\Embarcadero\Studio\'
#define Delphi101BaseVersion = '18.0'
#define Delphi101Directory=DelphiRootDirectory+'\'+Delphi101BaseVersion
#define Delphi101BerlinPath =Delphi101Directory+'\bin\'
#define Delphi101BerlinRsvars = Delphi101BerlinPath+'rsvars.bat'
#define Delphi101BerlinDCC32 = Delphi101BerlinPath+'dcc32.exe'
#define Delphi101BerlinBuildDirectory= 'D101Berlin'
#define Delphi101BerlinBaseRegistryPath ='Software\Embarcadero\BDS\18.0\'
#define Delphi101BPLPath = Delphi101Directory+'\Bpl'

#define MyPackageName "myAwesomePackage.bpl"
#define MyPackageDescription "My Awesome Package"
#define MyPackageProjectName "myAwesomePackage.dproj"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{A2A9C2E1-B323-4CEB-AD90-5FC8054C3C23}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={commondocs}\MyCompany\myAwesomePackage
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputBaseFilename=myAwesomePackage-setup-1.0
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: "..\myAwesomePackage.dpk"; DestDir: "{app}\SourceCode\Package"; Flags: ignoreversion
Source: "..\myAwesomeUnit.pas"; DestDir: "{app}\SourceCode\Package"; Flags: ignoreversion
Source: "..\myAwesomePackage.dproj"; DestDir: "{app}\SourceCode\Package"; Flags: ignoreversion
Source: "CompileSource.bat"; DestDir: "{app}"; Flags: dontcopy

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Dirs]
Name: "{app}\BPL"

[Code]
type
  TAvailableDelphi = (availD101Berlin);

var
  IsAvailableDelphi101Berlin: boolean;

  ChooseDelphiInstallationPage: TInputOptionWizardPage;
  availableDelphiInstallations: integer;

  ChooseDelphiTargetsPage: TInputOptionWizardPage;
  availableDelphiTargets: integer;

function InitializeSetup(): Boolean;
begin
  if DirExists(ExpandConstant('{#Delphi101BerlinPath}')) then 
  begin
   IsAvailableDelphi101Berlin:=true;
   result:=true;
  end
  else
  begin
    IsAvailableDelphi101Berlin:=false;
    If MsgBox('Delphi 10.1 Berlin has not been detected in your system.'+#10+#13+
      'If you continue, only the code will be installed.'+#13+#10+
      'If you have another Delphi installation, you need to install the IDE package manually.'+#13+#10+
      'Would you like to continue?', mbConfirmation, mb_YESNO)=IDNO then
      result:=false
    else
      result:=true;
  end;
end;

procedure InitializeWizard;
var
  i: integer;
begin
  { Create the pages }
  ChooseDelphiInstallationPage := CreateInputOptionPage(wpWelcome,
    'Choose Delphi Installation', '',
    'Check the Delphi versions you want to install the component for and then click Next.',
    false, False);

  availableDelphiInstallations:=0;
  if IsAvailableDelphi101Berlin then
  begin
    ChooseDelphiInstallationPage.Add('Delphi 10.1 Berlin');
    inc(availableDelphiInstallations);
  end;

  if availableDelphiInstallations=0 then
    Exit;

  for i:=0 to availableDelphiInstallations-1 do
   ChooseDelphiInstallationPage.Values[i]:=true;

  ChooseDelphiTargetsPage := CreateInputOptionPage(ChooseDelphiInstallationPage.ID,
    'Choose Targets', '',
    'Check the targets you want to install the component for and then click Next.',
    false, False);

  availableDelphiTargets:=0;
  ChooseDelphiTargetsPage.Add('Win32');
  inc(availableDelphiTargets);
  ChooseDelphiTargetsPage.Add('Win64');
  inc(availableDelphiTargets);      
  ChooseDelphiTargetsPage.Add('OSX32');
  inc(availableDelphiTargets);


  for i:=0 to availableDelphiTargets-1 do
   ChooseDelphiTargetsPage.Values[i]:=true;

end;

procedure InstallForPlatform(const basicParams: string; const BuildFolderID:
  string; const runDir: string; const currPlatform: string;
  const delphiRegistryPath: string); 

var
  Params,
  BPLDir,
  DCUDir,
  cmdLine,
  includeDir,
  fullRegistryLibraryPath: string;
  ResultCode: integer;
begin
  Params:='';
  Params:=basicParams+currPlatform+' ';
  BPLDir:=ExpandConstant('{app}')+'\Bpl\'+BuildFolderID+'\'+currPlatform;
  Params:=Params+'"'+BPLDir+'"';
  DCUDir:=runDir+'\'+BuildFolderID;
  Params:=Params+' "'+DCUDir+'"';
  includeDir:=''; //Here include any folder you need
  Params:=Params +' "'+includeDir+'"';

  Exec(ExpandConstant('{tmp}')+'\CompileSource.bat', 
     Params,
     '',
     SW_HIDE, ewWaitUntilTerminated, ResultCode);
  if ResultCode<>0 then 
   MsgBox('Error while compiling for '+currPlatform, mbInformation, mb_OK)
  else
  begin
  //Folders
   fullRegistryLibraryPath:=delphiRegistryPath+'Library\'+currPlatform;

   if RegQueryStringValue(HKEY_CURRENT_USER,fullRegistryLibraryPath,'Search Path', cmdLine) then
   begin
     if Pos(ExpandConstant('{app}')+'\SourceCode\Package\'+BuildFolderID+'\'+currPlatform+'\Release', cmdLine)=0 then
       cmdLine:=cmdLine+';'+ExpandConstant('{app}')+'\SourceCode\Package\'+BuildFolderID+'\'+currPlatform+'\Release'; 
     RegWriteStringValue(HKEY_CURRENT_USER,fullRegistryLibraryPath,'Search Path', cmdLine); 
   end;

   if RegQueryStringValue(HKEY_CURRENT_USER,fullRegistryLibraryPath,'Browsing Path', cmdLine) then
   begin
     if Pos(ExpandConstant('{app}')+'\SourceCode\Package', cmdLine)=0 then
       cmdLine:=cmdLine+';'+ExpandConstant('{app}')+'\SourceCode\Package'; 
     RegWriteStringValue(HKEY_CURRENT_USER,fullRegistryLibraryPath,'Browsing Path', cmdLine); 
   end;

  if RegQueryStringValue(HKEY_CURRENT_USER,fullRegistryLibraryPath,'Debug DCU Path', cmdLine) then
   begin
     if Pos(ExpandConstant('{app}')+'\SourceCode\Package\'+BuildFolderID+'\'+currPlatform+'\Debug', cmdLine)=0 then 
       RegWriteStringValue(HKEY_CURRENT_USER,fullRegistryLibraryPath,'Debug DCU Path',
        cmdLine+';'+ExpandConstant('{app}')+'\SourceCode\Package\'+BuildFolderID+'\'+currPlatform+'\Debug');
   end;
  end;
end;

procedure InstallIDEPackageProcedure(const delphiRegistryPath: string;
           const BuildFolderID: string);
begin
 RegWriteStringValue(HKEY_CURRENT_USER, delphiRegistryPAth+'Known Packages',
    ExpandConstant('{app}')+'\Bpl\'+BuildFolderID+'\Win32\'+ExpandConstant('{#MyPackageName}'), 
    ExpandConstant('{#MyPackageDescription}'));
end;

procedure InstallPackage(const currPackage: TAvailableDelphi;
  const installIDEPackage: boolean);
var
  BuildFolderID,
  PathFolder,
  runDir, 
  basicParams,
  registryPath, 
  str: string; 
  targetStr: array of string;
  i: integer;
begin
  case currPackage of 
    availD101Berlin:
          begin
            str:='Delphi 10.1 Berlin';
            BuildFolderID:=ExpandConstant('{#Delphi101BerlinBuildDirectory}');
            PathFolder:=ExpandConstant('{#Delphi101BerlinPath}');
            RegistryPath:=ExpandConstant('{#Delphi101BerlinBaseRegistryPath}');
          end;
  else
    Exit;
  end;

  WizardForm.StatusLabel.Caption:= 'Installing component for '+str+'...';

//Remove old BPL
  WizardForm.StatusLabel.Caption:= 'Removing old BPL files...';
  if FileExists(ExpandConstant('{app}')+'\Bpl\'+BuildFolderID+'\'+ExpandConstant('{#MyPackageName}')) then
   DeleteFile(ExpandConstant('{app}')+'\Bpl\'+BuildFolderID+'\'+ExpandConstant('{#MyPackageName}'));

  //Prepare to compile
  ExtractTemporaryFile('CompileSource.bat');
  runDir:=ExpandConstant('{app}')+'\SourceCode\Package';
   
  basicParams:='"'+runDir+'"';
  basicParams:=basicParams+' "'+PathFolder+'rsvars.bat" ';
  basicParams:=basicParams+ExpandConstant('{#MyPackageProjectName}')+' ';


  SetArrayLength(targetStr, 0);

  if ChooseDelphiTargetsPage.Values[0] then 
  begin
    SetArrayLength(targetStr, length(targetStr)+1);
    targetStr[length(targetStr)-1]:='Win32';
  end; 

  if ChooseDelphiTargetsPage.Values[1] then 
  begin
    SetArrayLength(targetStr, length(targetStr)+1);
    targetStr[length(targetStr)-1]:='Win64';
  end; 

  if ChooseDelphiTargetsPage.Values[2] then 
  begin
    SetArrayLength(targetStr, length(targetStr)+1);
    targetStr[length(targetStr)-1]:='OSX32';
  end; 

  //Install - targets/platforms
  for i:=0 to length(targetStr)-1 do
  begin
    WizardForm.StatusLabel.Caption:= 'Compiling for '+targetStr[i]+'...';
    InstallForPlatform(basicParams, BuildFolderID, runDir, targetStr[i],
     RegistryPath); 
  end;

  //IDE Package        
  if InstallIDEPackage then
  begin
   WizardForm.StatusLabel.Caption:= 'Registering IDE Package';
   InstallIDEPackageProcedure(RegistryPath, BuildFolderID);
  end;

  //Delete Temp File
  DeleteFile(ExpandConstant('{tmp}')+'\CompileSource.bat');

end;

procedure UninstallForPlatform(const delphiRegistryPath: string; const 
  currPlatform: string; const BuildFolderID: string);
var
  fullStr,
  delStr, 
  fullRegistryLibraryPath: string;
begin
//Registry
  RegDeleteValue(HKEY_CURRENT_USER, delphiRegistryPath+'Known Packages',
    ExpandConstant('{app}')+'\Bpl\'+BuildFolderID+'\'+ExpandConstant('{#MyPackageName}'));

//Folders
  fullRegistryLibraryPath:=delphiRegistryPath+'Library\'+currPlatform;

  if RegQueryStringValue(HKEY_CURRENT_USER,fullRegistryLibraryPath ,'Search Path', fullStr) then
  begin
    delStr:=ExpandConstant('{app}')+'\SourceCode\Package\'+BuildFolderID+'\'+currPlatform+'\Release';
    if Pos(delStr, fullStr)>0 then
    begin 
      Delete(fullStr, Pos(delStr, fullStr), length(delStr)+1);
        RegWriteStringValue(HKEY_CURRENT_USER,fullRegistryLibraryPath,'Search Path', fullStr);
     end;
   end;
                                                                                                   
   if RegQueryStringValue(HKEY_CURRENT_USER,fullRegistryLibraryPath,'Browsing Path', fullStr) then
   begin
    delStr:=ExpandConstant('{app}')+'\SourceCode\Package';
    if Pos(delStr, fullStr)>0 then
    begin 
     Delete(fullStr, Pos(delStr, fullStr), length(delStr)+1);
     delStr:=ExpandConstant('{app}')+'\SourceCode\SupportCode';
     if Pos(delStr, fullStr)>0 then
     begin 
       Delete(fullStr, Pos(delStr, fullStr), length(delStr)+1);
     end;
     //check if the last character is ';'--if yes, then delete
     if fullstr[length(fullstr)]=';' then 
       Delete(fullstr, length(fullstr),1);

     RegWriteStringValue(HKEY_CURRENT_USER,fullRegistryLibraryPath,'Browsing Path', fullStr);
    end;
   end;

   if RegQueryStringValue(HKEY_CURRENT_USER,fullRegistryLibraryPath,'Debug DCU Path', fullStr) then
   begin
    delStr:=ExpandConstant('{app}')+'\SourceCode\Package\'+BuildFolderID+'\'+currPlatform+'\Debug';
    if Pos(delStr, fullStr)>0 then
    begin 
     Delete(fullStr, Pos(delStr, fullStr), length(delStr)+1);
     RegWriteStringValue(HKEY_CURRENT_USER,fullRegistryLibraryPath,'Debug DCU Path', fullStr);
    end;
   end;
end;

//Uninstall 
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if (CurUninstallStep=usPostUninstall) then 
  begin
   if DirExists(ExpandConstant('{#Delphi101BerlinPath}')) then
     begin
       UninstallForPlatform(
         ExpandConstant('{#Delphi101BerlinBaseRegistryPath}'), 'Win32', 
         ExpandConstant('{#Delphi101BerlinBuildDirectory}'));
       UninstallForPlatform(
         ExpandConstant('{#Delphi101BerlinBaseRegistryPath}'), 'Win64', 
         ExpandConstant('{#Delphi101BerlinBuildDirectory}'));
       UninstallForPlatform(
         ExpandConstant('{#Delphi101BerlinBaseRegistryPath}'), 'OSX32', 
         ExpandConstant('{#Delphi101BerlinBuildDirectory}'));
     end;
  end;
end;


procedure CurStepChanged(CurStep: TSetupStep);
var
  InstallIDEPackage: boolean;
  IsAnyDelphiChosen: boolean;
  i: integer;
begin
   if (CurStep=ssPostInstall) then 
   begin
     if availableDelphiInstallations=0 then 
       Exit;
     IsAnyDelphiChosen:=false;
     
     for i:=0 to availableDelphiInstallations-1 do
       if ChooseDelphiInstallationPage.Values[i] then 
         IsAnyDelphiChosen:=true;  

     if not IsAnyDelphiChosen then
       InstallIDEPackage:=false
     else
       InstallIDEPackage:=true;

     if ChooseDelphiInstallationPage.Values[0] then
       InstallPackage(availD101Berlin, InstallIDEPackage);
     
   end;
end;

