unit Discord.Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls,
  // LazUtils
  LazFileUtils,
  LazVersion,
  IDEExternToolIntf, LazarusPackageIntf , SrcEditorIntf,

  IDECommands, ProjectIntf, LazIDEIntf, UDiscordRPC,SynEdit;

type

  { TThreadTimer }

  TThreadTimer = class(TThread)
   private
     FTime: QWORD;
     FInterval: Integer;
     FOnTimer: TNotifyEvent;
     FEnabled: Boolean;
     procedure DoOnTimer;
   protected
     procedure Execute; override;
   public
     constructor Create;
     destructor Destroy; override;
   public
     property OnTimer: TNotifyEvent read FOnTimer write FOnTimer;
     property Interval: Integer read FInterval write FInterval;
     property Enabled: Boolean read FEnabled write FEnabled;
     procedure StopTimer;
     procedure StartTimer;

   end;

  { TDIscordMain }

  TDIscordMain = class(TObject)
  private
    FDiscord: TDiscordRPC;
    FTimer: TThreadTimer;
    procedure OnTimer(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Connect(const aFIleName: string);
    procedure Disconnect;
    function GetCurrentFileName: string;
  public
    property Timer: TThreadTimer read FTimer;
  end;

var
  DIscordMain: TDIscordMain = nil;


implementation

uses  Discord.Settings, Discord.Consts, Dialogs;

constructor TThreadTimer.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FEnabled := False;
end;

destructor TThreadTimer.Destroy;
begin
  inherited Destroy;
end;

procedure TThreadTimer.DoOnTimer;
begin
  if Assigned(FOnTimer) then
    FOnTimer(Self);
end;

procedure TThreadTimer.Execute;
begin
  while not Terminated do
  begin
    Sleep(10);
    if (GetTickCount64 - FTime > FInterval) and (FEnabled) and (not Application.Terminated) then
    begin
      FTime := GetTickCount64;
      Synchronize(@DoOnTimer);
    end;
  end;
end;

procedure TThreadTimer.StopTimer;
begin
  FEnabled := False;
end;

procedure TThreadTimer.StartTimer;
begin
  FTime := GetTickCount64;
  FEnabled := True;
  if Self.Suspended then
    Start;
end;

{ TDIscordMain }

procedure TDIscordMain.OnTimer(Sender: TObject);
begin
  if Settings = nil then
  begin
    if LazarusIDE <> nil then //wait until IDE startup
    begin
      Settings := TDiscordSettings.Create(DISCORD_LIBRABRY_RPC + cDiscordStatusConfigFile);
      FTimer.StopTimer;
      FTimer.Interval := Settings.AutoSaveInteval*1000;
      FTimer.StartTimer;
    end;
  end else
  begin
    Settings.Load;
    if Settings.EnableDiscord then
      Connect(GetCurrentFileName)
    else
      Disconnect;
  end;
end;

constructor TDIscordMain.Create;
begin
  FTimer := TThreadTimer.Create;
  FTimer.FreeOnTerminate := True;
  FTimer.Interval := 100;
  FTimer.OnTimer := @OnTimer;
  FTimer.StartTimer;
end;

destructor TDIscordMain.Destroy;
begin
  FTimer.StopTimer;
  FTimer.Terminate;
  if Settings <> nil then
    Settings.Free;
  inherited;
end;

procedure TDIscordMain.Connect(const aFIleName: string);
var
  Settings :TDiscordSettings;
begin
  Settings := TDiscordSettings.Create(DISCORD_LIBRABRY_RPC + cDiscordStatusConfigFile);
  Try
    if not Assigned(FDiscord) then
    begin
      FDiscord:= TDiscordRPC.Create;
      FDiscord.Initialize(Settings.ApplicationID);
      FDiscord.UpdatePresence('Lazarus '+laz_version +' Editing file: '+aFIleName, ' Start at: '+ FormatDateTime('dd/mm/yyyy hh:mm:ss',Now),Settings.ImageName,'');
    end else
       FDiscord.UpdatePresence('Lazarus '+laz_version +' Editing file: '+aFIleName, ' Start at: '+ FormatDateTime('dd/mm/yyyy hh:mm:ss',Now), Settings.ImageName,'');
  finally
    Settings.Free;
  end;
end;

procedure TDIscordMain.Disconnect;
begin
  if Assigned(FDiscord)then
     FDiscord.Shutdown;
end;

function TDIscordMain.GetCurrentFileName: string;
var
   Editor : TSourceEditorInterface;
begin
  Editor:= SourceEditorManagerIntf.ActiveEditor;
  if Editor = nil then exit;
  result:= ExtractFileName(Editor.FileName);
end;

end.

