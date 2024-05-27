unit View.Discord.Settings;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,

  ToolsAPI,
  DiscordRPC,
  Discord.Settings, StdCtrls;

type
  TDiscordStatus = class(TNotifierObject, IOTAIDENotifier)
  private
    FCurrentFile: string;
    FConnected: boolean;
    procedure UpdatePresence(const aFile: string);
    procedure SetFCurrentFile(const Value: string);
    procedure FormCreate(Sender: TObject);
    procedure SetConnected(const Value: boolean);
  public
    class var FInstance: TDiscordStatus;
    class var FDiscord: TDiscordRPC;
    function GetInstancia :TDiscordStatus;
    function Connect : TDiscordRPC;
    procedure Disconnect;
    destructor Destroy; override;
    procedure AfterCompile(Succeeded: Boolean); overload;
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
    procedure FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean); overload;
    property CurrentFile: string read FCurrentFile write SetFCurrentFile;
    property Connected: boolean read FConnected write SetConnected;
  end;

type
  TFrmDiscordSettings = class(TForm)
    ChbApplication: TCheckBox;
    procedure CheckBox1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  end;

var
  FrmDiscordSettings: TFrmDiscordSettings;
  DiscordStatus: TDiscordStatus;
  IndexNotifier: Integer = -1;
  LoadingForm: Boolean;

  procedure Register;

implementation

{$R *.dfm}

procedure Register;
begin
  if(IndexNotifier < 0)then
    IndexNotifier := (BorlandIDEServices as IOTAServices).AddNotifier(TDiscordStatus.Create)
end;

procedure TDiscordStatus.AfterCompile(Succeeded: Boolean);
begin
  // Do Nothig
end;

procedure TDiscordStatus.BeforeCompile(const Project: IOTAProject;
  var Cancel: Boolean);
begin
  // Do Nothig
  Cancel := False;
end;

function TDiscordStatus.Connect : TDiscordRPC;
begin
  if not Assigned(FDiscord) then
  begin
    FDiscord := TDiscordRPC.Create;
    FDiscord.Initialize(TDiscordSettings.LoadENV(ApplicationID));
    SetConnected(True);
  end;
  result:= FDiscord;
end;


destructor TDiscordStatus.Destroy;
var
  Services: IOTAServices;
begin
    if Assigned(FDiscord) then Disconnect;
    Services := BorlandIDEServices as IOTAServices;
    if Assigned(Services) then
      Services.RemoveNotifier(IndexNotifier);
    SetConnected(True);
  inherited;
end;

procedure TDiscordStatus.Disconnect;
begin
  if Assigned(FDiscord) then
  begin
    FDiscord.Shutdown;
    SetConnected(False);
  end;
end;

procedure TDiscordStatus.FileNotification(NotifyCode: TOTAFileNotification;
  const FileName: string; var Cancel: Boolean);
begin
  if(not(NotifyCode in [ofnFileOpening, ofnFileOpened]))then Exit;

  Connect;

  case NotifyCode of
      ofnFileOpening,
      ofnFileOpened,
      ofnActiveProjectChanged: begin
                                 if Assigned(FDiscord) then
                                   UpdatePresence(ExtractFileName(FileName));
                               end;
  end;
end;

procedure TDiscordStatus.FormCreate(Sender: TObject);
begin
  if not Assigned(FDiscord) then
  begin
    FDiscord := TDiscordRPC.Create;
    FDiscord.Initialize(TDiscordSettings.LoadENV(ApplicationID));
    UpdatePresence('');
  end;
  LoadingForm:= False;
end;

function TDiscordStatus.GetInstancia: TDiscordStatus;
begin
 if not Assigned(FInstance) then
    FInstance := TDiscordStatus.Create;
  Result := FInstance;
end;

procedure TDiscordStatus.SetConnected(const Value: boolean);
begin
  FConnected := Value;
end;

procedure TDiscordStatus.SetFCurrentFile(const Value: string);
begin
  FCurrentFile := Value;
end;

procedure TDiscordStatus.UpdatePresence(const aFile: string);
begin
  if not Assigned(FDiscord) then raise Exception.Create('The Instance FDiscord can be created first!!! ');
  SetFCurrentFile(aFile);

  if aFile.Trim.IsEmpty and FCurrentFile.Trim.IsEmpty then
    FDiscord.UpdatePresence('Editing Lazarus: No active file, Start at :', FormatDateTime('dd/mm/yyyy hh:mm:ss', Now), 'lazarus', '')
  else
    FDiscord.UpdatePresence('Editing Lazarus: ' + IfThen(aFile.IsEmpty, FCurrentFile, aFile), ' Start at :' + FormatDateTime('dd/mm/yyyy hh:mm:ss', Now), 'lazarus', '');
end;

procedure TFrmDiscordSettings.Button1Click(Sender: TObject);
begin
  try
    TDiscordSettings.SaveENV(EnabledDiscord, ifthen(ChbEnabled.Checked,'1','0'));
    TDiscordSettings.SaveENV(ApplicationID, EdtApplicationID.text);
  finally
    Close;
  end;
end;

//procedure TFrmDiscordSettings.CheckBox1Click(Sender: TObject);
//begin
//  if not LoadingForm then
//  begin
//    if ChbEnabled.Checked then
//      DiscordStatus.Disconnect
//    else
//      DiscordStatus.Connect;
//  end;
//  LoadingForm:= False;
//end;

procedure TFrmDiscordSettings.FormShow(Sender: TObject);
begin
//  LoadingForm:= True;
  EdtApplicationID.Text:= TDiscordSettings.LoadENV(ApplicationID);
  ChbApplication.Checked:=  not(String(EdtApplicationID.Text).Equals(''));

//
//  if TDiscordSettings.LoadENV(EnabledDiscord) = '1' then
//  begin
//    DiscordStatus := TDiscordStatus.FInstance.GetInstancia;
//    CheckBox1.Checked:= True;
//  end else
//  begin
//    CheckBox1.Checked:= False;
//  end;
end;

initialization

finalization
  if IndexNotifier >= 0 then
  begin
    (BorlandIDEServices as IOTAServices).RemoveNotifier(IndexNotifier);
    IndexNotifier := -1;
  end;
end.

