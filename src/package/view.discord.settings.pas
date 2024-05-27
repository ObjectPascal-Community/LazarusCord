unit View.Discord.Settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Spin, StdCtrls;

type

  { TSettingsFrm }

  TSettingsFrm = class(TForm)
    EdtApplicationID: TEdit;
    Label1: TLabel;
    OkButton: TButton;
    cbEnableDiscord: TCheckBox;
    lbInterval: TLabel;
    lbSec: TLabel;
    spAutoSaveInterval: TSpinEdit;
    procedure bpSettingsClick(Sender: TObject);
    procedure cbEnableDiscordChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    procedure LoadSettings;
    procedure SaveSettings;
  public

  end;

var
  SettingsFrm: TSettingsFrm;

implementation

uses Discord.Consts, Discord.Settings;

{$R *.lfm}

procedure TSettingsFrm.FormCreate(Sender: TObject);
begin
  LoadSettings;
end;

procedure TSettingsFrm.cbEnableDiscordChange(Sender: TObject);
begin
  spAutoSaveInterval.Enabled := cbEnableDiscord.Checked;
end;

procedure TSettingsFrm.bpSettingsClick(Sender: TObject);
begin
end;

procedure TSettingsFrm.LoadSettings;
begin
  cbEnableDiscord.Checked := Settings.EnableDiscord;
  spAutoSaveInterval.Value := Settings.AutoSaveInteval;
  spAutoSaveInterval.Enabled := cbEnableDiscord.Checked;
  EdtApplicationID.Text:= Settings.ApplicationID;
end;

procedure TSettingsFrm.SaveSettings;
begin
  Settings.EnableDiscord := cbEnableDiscord.Checked;
  Settings.AutoSaveInteval := spAutoSaveInterval.Value;
  Settings.ApplicationID := EdtApplicationID.Text;
  Settings.Save;
end;

procedure TSettingsFrm.OKButtonClick(Sender: TObject);
begin
  SaveSettings;
  Close;
end;

end.

