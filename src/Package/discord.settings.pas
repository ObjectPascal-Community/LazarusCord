unit discord.Settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics,
  // LazUtils
  Laz2_XMLCfg, LazFileUtils,
  // IdeIntf
  LazIDEIntf,
  // AutoSave
  Discord.Consts;

procedure Register;

type
  { TDiscordSettings }

  TDiscordSettings = class
  private
    FXML: TXMLConfig;
    FVersion: Integer;
    FChanged: Boolean;
    FEnableDiscord: Boolean;
    FAutoSaveInterval: Integer;
    FApplicationID: String;
  public
    constructor Create(const AFileName: String);
    destructor Destroy; override;
    procedure Load;
    procedure Save;
    procedure LoadDefault;
  published
    property Changed: Boolean read FChanged write FChanged;
    property EnableDiscord: Boolean read FEnableDiscord write FEnableDiscord;
    property AutoSaveInteval: Integer read FAutoSaveInterval write FAutoSaveInterval;
    property ApplicationID: String read FApplicationID write FApplicationID;
  end;

var
  Settings: TDiscordSettings = nil;

implementation

const
  AutoSaveVersion = 1;
  DefAutoSaveInterval = 5;

{ TDiscordSettings }


procedure Register;
begin
end;

constructor TDiscordSettings.Create(const AFileName: String);
begin
  FXML := TXMLConfig.Create(AFileName);
  if FileExists(AFileName) then
    Load
  else
    LoadDefault;
end;

destructor TDiscordSettings.Destroy;
begin
  if FChanged then
    Save;
  FXML.Free;
  inherited Destroy;
end;

procedure TDiscordSettings.Load;
begin
  if FileExists(DISCORD_LIBRABRY_RPC+cDiscordStatusConfigFile)then
  begin
    FEnableDiscord:= FXML.GetValue('Discord/EnableDiscord/Value', True);
    FAutoSaveInterval:= FXML.GetValue('Discord/AutoSaveInterval/Value', DefAutoSaveInterval);
    FApplicationID:= FXML.GetValue('Discord/ApplicationID/Value','');
  end;
end;

procedure TDiscordSettings.Save;
begin
  FXML.SetDeleteValue('Version/Value', AutoSaveVersion, 0);
  FXML.SetDeleteValue('Discord/EnableDiscord/Value', FEnableDiscord, True);
  FXML.SetDeleteValue('Discord/AutoSaveInterval/Value', FAutoSaveInterval, DefAutoSaveInterval);
  FXML.SetDeleteValue('Discord/ApplicationID/Value', FApplicationID, '1244072383447433357');
  FXML.Flush;
  FChanged := False;
end;

procedure TDiscordSettings.LoadDefault;
begin
  FEnableDiscord := True;
  FAutoSaveInterval := DefAutoSaveInterval;
  FApplicationID:= '1244072383447433357';
  Save;
end;

end.


