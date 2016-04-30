//
// Validation Project (PCRF) - Stimulus Control App
// Copyright (C) 2014-2016,  Carlos Rafael Fernandes Picanço, Universidade Federal do Pará.
//
// cpicanco@ufpa.br
//
// This file is part of Validation Project (PCRF).
//
// Validation Project (PCRF) is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Validation Project (PCRF) is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Validation Project (PCRF).  If not, see <http://www.gnu.org/licenses/>.
//
unit session;

{$mode objfpc}{$H+}

interface

uses Classes, Controls, SysUtils, LCLIntf
     //,dialogs
     , bass_player
     , config_session
     , countermanager
     , FileUtil
     , regdata
     , blocs
     , timestamps_logger
     , timestamp
     , client
     ;

type

  { TSession }

  TSession = class(TComponent)
  private
    //FOnBeginSess: TNotifyEvent;
    //FOnBeginTrial: TNotifyEvent;
    //FOnCriteria: TNotifyEvent;
    FAudioDevice: TBassAudioDevice;
    FBackGround: TWinControl;
    FBlc: TBlc;
    FCfgSes: TCfgSes;
    FCrtReached : Boolean;
    FDataTicks: Boolean;
    FManager : TCounterManager;
    FClientThread : TClientThread;

    FRegData: TRegData;
    FRegDataTicks: TRegData;
    FTimestampsData : TRegData;
    FServerAddress: string;
    FSessName: string;
    FShowCounter : Boolean;
    FSubjName: string;
    FTestMode: Boolean;
    FTimeStart : Extended;

    // events
    FOnBkGndResponse: TNotifyEvent;
    FOnConsequence: TNotifyEvent;
    FOnEndBlc: TNotifyEvent;
    FOnEndSess: TNotifyEvent;
    FOnEndTrial: TNotifyEvent;
    FOnHit: TNotifyEvent;
    FOnMiss: TNotifyEvent;
    FOnStmResponse: TNotifyEvent;

    procedure BkGndResponse(Sender: TObject);
    procedure BlcEndBlc(Sender: TObject);
    procedure Consequence(Sender: TObject);
    procedure Criteria(Sender: TObject);
    procedure EndSess(Sender: TObject);
    procedure EndTrial(Sender: TObject);
    procedure Hit(Sender: TObject);
    procedure Miss(Sender: TObject);
    procedure SetBackGround(BackGround: TWinControl);
    procedure StmResponse(Sender:TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoEndSess(Sender: TObject);
    procedure Play(CfgSes: TCfgSes; Manager : TCounterManager; FileData: String);
    procedure PlayBlc(Sender: TObject);
    property AudioDevice : TBassAudioDevice read FAudioDevice write FAudioDevice;
    property BackGround: TWinControl read FBackGround write SetBackGround;
    property ServerAddress : string read FServerAddress write FServerAddress;
    property SessName: String  read FSessName write FSessName;
    property ShowCounter : Boolean read FShowCounter write FShowCounter;
    property SubjName: String  read FSubjName write FSubjName;
    property TestMode: Boolean  read FTestMode write FTestMode;
    property DataTicks : Boolean read FDataTicks write FDataTicks;
  public
    property OnBkGndResponse : TNotifyEvent read FOnBkGndResponse write FOnBkGndResponse;
    property OnConsequence : TNotifyEvent read FOnConsequence write FOnConsequence;
    property OnEndBlc: TNotifyEvent read FOnEndBlc write FOnEndBlc;
    property OnEndSess: TNotifyEvent read FOnEndSess write FOnEndSess;
    property OnEndTrial : TNotifyEvent read FOnEndTrial write FOnEndTrial;
    property OnHit: TNotifyEvent read FOnHit write FOnHit;
    property OnMiss: TNotifyEvent read FOnMiss write FOnMiss;
    property OnStmResponse : TNotifyEvent read FOnStmResponse write FOnStmResponse;

  end;

implementation

procedure TSession.BkGndResponse(Sender: TObject);
begin
  if Assigned(OnBkGndResponse) then FOnBkGndResponse(Sender);
end;

procedure TSession.BlcEndBlc(Sender: TObject);
begin
  if FCfgSes.SesType = 'CIC' then
    begin
      if FBlc.NextBlc = 'END' then FManager.CurrentBlc.Counter := FCfgSes.NumBlc //ir para último bloco apenas se END constar
      else  //próximo bloco sob qualquer outra condição
        begin
          FManager.OnEndBlc(Sender)
        end;
    end;
  if FCfgSes.SesType = 'CRT' then
    begin
      if not FCrtReached then FManager.CurrentBlc.Counter := FCfgSes.NumBlc
      else  //próximo bloco apenas se o critério foi alcançado
        begin
          FManager.OnEndBlc(Sender)
        end;
    end;

  if Assigned(OnEndBlc) then FOnEndBlc(Sender);
  PlayBlc(Sender);
end;

procedure TSession.EndSess(Sender: TObject);
begin
  FClientThread.SendRequest('pupil_stop_recording',-1,'r');
  //Sleep(1000);
  FRegData.SaveData('Hora de Término:' + #9 + TimeToStr(Time) + LineEnding);

  if DataTicks then
    FRegDataTicks.SaveData('Hora de Término:' + #9 + TimeToStr(Time) + LineEnding);

  if Assigned(OnEndSess) then FOnEndSess(Sender);
end;

procedure TSession.EndTrial(Sender: TObject);
begin
   if Assigned(OnEndTrial) then FOnEndTrial (Sender);
end;

procedure TSession.Hit(Sender: TObject);
begin
  if Assigned(OnHit) then FOnHit (Sender);
end;

procedure TSession.Miss(Sender: TObject);
begin
  if Assigned(OnMiss) then FOnMiss (Sender);
end;

procedure TSession.SetBackGround(BackGround: TWinControl);
begin
  FBackGround:= BackGround;
end;

procedure TSession.StmResponse(Sender: TObject);
begin
  if Assigned(OnStmResponse) then FOnStmResponse (Sender);
end;

procedure TSession.Consequence(Sender: TObject);
begin
  if Assigned(OnConsequence) then FOnConsequence (Sender);
end;

constructor TSession.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBlc:= TBlc.Create(nil);
  FBlc.OnStmResponse:= @StmResponse;
  FBlc.OnConsequence:= @Consequence;
  FBlc.OnBkGndResponse:= @BkGndResponse;
  FBlc.OnEndTrial:= @EndTrial;
  FBlc.OnHit:= @Hit;
  FBlc.OnMiss:= @Miss;
  FBlc.OnEndBlc:= @BlcEndBlc;
  FBlc.OnCriteria := @Criteria;
end;

procedure TSession.Criteria(Sender: TObject);
begin
  FCrtReached := True;
end;

destructor TSession.Destroy;
begin
  //events
  FBlc.OnStmResponse := nil;
  FBlc.OnConsequence := nil;
  FBlc.OnBkGndResponse := nil;
  FBlc.OnEndTrial := nil;
  FBlc.OnHit := nil;
  FBlc.OnMiss := nil;
  FBlc.OnEndBlc := nil;
  FBlc.OnCriteria := nil;

  //external objects
  FBackGround := nil;
  FAudioDevice := nil;
  FManager := nil;
  FCfgSes := nil;

  //internal objects
  FClientThread.Terminate;
  if Assigned(FRegData) then FreeAndNil(FRegData);
  if Assigned(FRegDataTicks) then FreeAndNil(FRegDataTicks);
  if Assigned(FBlc) then FreeAndNil(FBlc);
  inherited;
end;

procedure TSession.DoEndSess(Sender: TObject);
begin
  if DataTicks then
    FRegDataTicks.SaveData(LineEnding + 'Sessão Cancelada' + LineEnding);

  FRegData.SaveData(LineEnding + 'Sessão Cancelada' + LineEnding);
  EndSess(Sender);
end;

procedure TSession.Play(CfgSes: TCfgSes; Manager : TCounterManager; FileData: String);
begin
  FCfgSes:= CfgSes;
  FManager := Manager;

  if FileData = #0 then FileData:= 'Dados_000.txt';
  if FTestMode then
    begin
      FSessName:= FSessName + #9 + '(Modo de Teste)';
      FileData:= 'Teste_000.txt';
    end;

  FRegData := TRegData.Create(nil, FCfgSes.RootData + FileData);

  {
    File writing operations are called from a different thread.
  }
  FTimestampsData := TRegData.Create(nil, ExtractFileNameWithoutExt(FRegData.FileName) + '.timestamps');
  UpdateTimestampsFileName(FTimestampsData.FileName);
  FTimestampsData.Free;

  FBlc.ShowCounter := ShowCounter;
  FBlc.RegData:= FRegData;
  FBlc.BackGround:= FBackGround;

  FRegData.SaveData('Sujeito:' + #9 + FSubjName + LineEnding +
                    'Sessão:' + #9+ FSessName + LineEnding +
                    'Data:' + #9 + DateTimeToStr(Date)+ LineEnding +
                    'Hora de Início:' + #9 + TimeToStr(Time)+ LineEnding + LineEnding);

  if DataTicks then
    begin
      FRegDataTicks:= TRegData.Create(nil, FCfgSes.RootData + 'Ticks_000.txt');
      FBlc.RegDataTicks := FRegDataTicks;
      FRegDataTicks.SaveData('Sujeito:' + #9 + FSubjName + LineEnding +
                    'Sessão:' + #9+ FSessName + LineEnding +
                    'Data:' + #9 + DateTimeToStr(Date) + LineEnding +
                    'Hora de Início:' + #9 + TimeToStr(Time)+ LineEnding + LineEnding);

    end;

  FClientThread := TClientThread.Create(FServerAddress);
  FBlc.SetClientThread(FClientThread);
  FClientThread.Start;
  FClientThread.SendRequest('pupil_start_recording',-1,'R');
  FTimeStart := GetCustomTick;
  FBlc.TimeStart := FTimeStart;
  FManager.OnBeginSess(Self);

  PlayBlc(Self);
end;

procedure TSession.PlayBlc(Sender: TObject);
var IndBlc, IndTrial : integer;
begin
  IndBlc := FManager.CurrentBlc.Counter;
  IndTrial := FManager.CurrentTrial.Counter;
  if IndBlc < FCfgSes.NumBlc then
    begin
      FManager.SetVirtualTrialValue(FCfgSes.Blcs[IndBlc].VirtualTrialValue);
      FBlc.Play(FCfgSes.CfgBlc[IndBlc], FManager, IndTrial, FTestMode)
    end
  else EndSess(Sender);
end;

end.


