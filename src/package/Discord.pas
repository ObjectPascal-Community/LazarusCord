{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit Discord;

{$warn 5023 off : no warning about unused units}
interface

uses
  Discord.Status, Discord.Consts, View.Discord.Settings, Discord.Main, 
  discord.Settings, UDiscordRPC, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('Discord.Status', @Discord.Status.Register);
end;

initialization
  RegisterPackage('Discord', @Register);
end.
