unit UDiscordRPC;

interface

uses
  SysUtils, Classes, dynlibs, Discord.Consts;

procedure Register;

type
  TDiscordRPC = class
  private
    FClientID: string;
    FInitialized: Boolean;
    FLibraryHandle: TLibHandle;
    procedure InitializeDiscord;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Initialize(const ClientID: string);
    procedure UpdatePresence(const Details, State, LargeImageKey, LargeImageText: string);
    procedure Shutdown;
  end;

type
  DiscordEventHandlers = record
    ready: procedure; cdecl;
    disconnected: procedure(errorCode: Integer; message: PAnsiChar); cdecl;
    errored: procedure(errorCode: Integer; message: PAnsiChar); cdecl;
    joinGame: procedure(secret: PAnsiChar); cdecl;
    spectateGame: procedure(secret: PAnsiChar); cdecl;
    joinRequest: procedure(user: PAnsiChar); cdecl;
  end;

  DiscordRichPresence = record
    state: PAnsiChar;
    details: PAnsiChar;
    startTimestamp: Int64;
    endTimestamp: Int64;
    largeImageKey: PAnsiChar;
    largeImageText: PAnsiChar;
    smallImageKey: PAnsiChar;
    smallImageText: PAnsiChar;
    partyId: PAnsiChar;
    partySize: Integer;
    partyMax: Integer;
    matchSecret: PAnsiChar;
    joinSecret: PAnsiChar;
    spectateSecret: PAnsiChar;
    instance: Integer;
  end;

  PDiscordRichPresence = ^DiscordRichPresence;

var
  Discord_Initialize: procedure(applicationId: PAnsiChar; handlers: DiscordEventHandlers; autoRegister: Integer; optionalSteamId: PAnsiChar); cdecl;
  Discord_Shutdown: procedure; cdecl;
  Discord_RunCallbacks: procedure; cdecl;
  Discord_UpdatePresence: procedure(presence: PDiscordRichPresence); cdecl;

{ TDiscordRPC }

Implementation

procedure Register;
begin

end;

constructor TDiscordRPC.Create;
begin
  FInitialized := False;
  FLibraryHandle := 0;
end;

destructor TDiscordRPC.Destroy;
begin
  if FInitialized then
    Shutdown;
  inherited;
end;

procedure TDiscordRPC.Initialize(const ClientID: string);
begin
  FClientID := ClientID;
  InitializeDiscord;
  FInitialized := True;
end;

procedure TDiscordRPC.InitializeDiscord;
var
  Handlers: DiscordEventHandlers;
  path: string;
begin
  path := DISCORD_LIBRABRY_RPC + DISCORD_LIBRABRY;
  FLibraryHandle := LoadLibrary(PChar(path));
  if FLibraryHandle = NilHandle then
    raise Exception.Create('Could not load Discord RPC library.');

  Pointer(Discord_Initialize) := GetProcAddress(FLibraryHandle, 'Discord_Initialize');
  Pointer(Discord_Shutdown) := GetProcAddress(FLibraryHandle, 'Discord_Shutdown');
  Pointer(Discord_RunCallbacks) := GetProcAddress(FLibraryHandle, 'Discord_RunCallbacks');
  Pointer(Discord_UpdatePresence) := GetProcAddress(FLibraryHandle, 'Discord_UpdatePresence');

  if not Assigned(Discord_Initialize) or not Assigned(Discord_Shutdown) or not Assigned(Discord_RunCallbacks) or not Assigned(Discord_UpdatePresence) then
    raise Exception.Create('Could not get Discord RPC functions.');

  FillChar(Handlers, SizeOf(Handlers), 0);
  Discord_Initialize(PAnsiChar(AnsiString(FClientID)), Handlers, 1, nil);
end;

procedure TDiscordRPC.UpdatePresence(const Details, State, LargeImageKey, LargeImageText: string);
var
  Presence: DiscordRichPresence;
begin
  FillChar(Presence, SizeOf(Presence), 0);
  Presence.details := PAnsiChar(AnsiString(Details));
  Presence.state := PAnsiChar(AnsiString(State));
  Presence.largeImageKey := PAnsiChar(AnsiString(LargeImageKey));
  Presence.largeImageText := PAnsiChar(AnsiString(LargeImageText));

  Discord_UpdatePresence(@Presence);
end;

procedure TDiscordRPC.Shutdown;
begin
  Discord_Shutdown;
  UnloadLibrary(FLibraryHandle);
  FInitialized := False;
end;

end.

