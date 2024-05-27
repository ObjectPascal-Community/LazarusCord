unit Discord.Status;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Controls,
  //LCL
  LCLType,
  //IDEIntf
  MenuIntf, ToolbarIntf, IDECommands;

procedure Register;

implementation

uses Discord.Consts, View.Discord.Settings, Discord.Main, Discord.Settings, dialogs;

procedure IDEMenuSectionClicked(Sender: TObject);
begin
  SettingsFrm := TSettingsFrm.Create(nil);
  try
    if SettingsFrm.ShowModal = mrOk then
    begin
      if DiscordMain.Timer.Interval <> Settings.AutoSaveInteval then
      begin
        DiscordMain.Timer.StopTimer;
        DiscordMain.Timer.Interval := Settings.AutoSaveInteval*1000;
        DIscordMain.Timer.StartTimer;
      end;
    end;
  finally
    SettingsFrm.Free;
    SettingsFrm := nil;
  end;
end;

procedure Register;
var
  IDEShortCutX: TIDEShortCut;
  IDECommandCategory: TIDECommandCategory;
  IDECommand: TIDECommand;
begin
  Try
    IDEShortCutX := IDEShortCut(VK_A, [ssShift, ssCtrl], VK_UNKNOWN, []);
    IDECommandCategory := IDECommandList.FindCategoryByName('FileMenu');
    if IDECommandCategory <> nil then
    begin
      IDECommand := RegisterIDECommand(IDECommandCategory, 'Discord', 'Discord Options', IDEShortCutX, nil, @IDEMenuSectionClicked);
      if IDECommand <> nil then
        RegisterIDEButtonCommand(IDECommand);
    end;
    RegisterIDEMenuCommand(itmFileOpenSave, 'Discord', 'Discord Options', nil, @IDEMenuSectionClicked, IDECommand);
  Except on E: Exception do
    begin
      ShowMessage('Register '+E.Message);
    end;
  end;
end;

initialization
  DiscordMain := TDIscordMain.Create;

finalization
  FreeAndNil(DiscordMain);

end.

