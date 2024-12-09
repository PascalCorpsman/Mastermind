(******************************************************************************)
(* Mastermind                                                      07.08.2017 *)
(*                                                                            *)
(* Version     : 0.01                                                         *)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* Support     : www.Corpsman.de                                              *)
(*                                                                            *)
(* Description : Implementation of the Board game Mastermind, including AI    *)
(*                                                                            *)
(* License     : See the file license.md, located under:                      *)
(*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *)
(*  for details about the license.                                            *)
(*                                                                            *)
(*               It is not allowed to change or remove this text from any     *)
(*               source file of the project.                                  *)
(*                                                                            *)
(* Warranty    : There is no warranty, neither in correctness of the          *)
(*               implementation, nor anything other that could happen         *)
(*               or go wrong, use at your own risk.                           *)
(*                                                                            *)
(* Known Issues: none                                                         *)
(*                                                                            *)
(* History     : 0.01 - Initial version                                       *)
(*                                                                            *)
(******************************************************************************)
(*
 * Refactoring history:
 *   1. Extract everything into umastermind.pas
 *   2. Move Back all LCL related stuff to unit1 -> Prepare decoupling LCL and TMastermind
 *)

unit Unit1;

{$MODE objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, umastermind;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Shape1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
  private
    { private declarations }
    fMasterMind: TMasterMind;

    procedure OnBoard0ShapeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    // Callback zum entfernen einer Farbe aus Board[0]
    procedure ResetLCLForNewGame;

    procedure HideAllColors(); // Versteckt alle Vorschlagsfarben
    procedure ShowAllColors(); // Zeigt alle Vorschlagsfarben an

    procedure HideUnusedColorsInAvailables();
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.OnBoard0ShapeMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  // Entfernen des Aktuellen Elementes in Guess
  Sender.Free;
end;

procedure TForm1.ResetLCLForNewGame;
begin
  button3.Enabled := True; // Check Freischalten
  button5.Enabled := False; // Hide unused sperren
  button7.Enabled := True; // Tipp Freischalten
end;

procedure TForm1.HideAllColors();
var
  i: integer;
begin
  for i := 1 to 6 do
  begin
    TShape(FindComponent('Shape' + IntToStr(i))).Visible := False;
  end;
end;

procedure TForm1.ShowAllColors();
var
  i: integer;
  // Zeigen aber wieder alle an, so das der User nicht weiß welche beiden wir nicht nutzen
begin
  for i := 1 to 6 do
  begin
    TShape(FindComponent('Shape' + IntToStr(i))).Visible := True;
  end;
end;

procedure TForm1.HideUnusedColorsInAvailables;
var
  j, k: integer;
  s: TShape;
  b: boolean;
begin
  // Verstecken der nicht genutzten Farben aus den "Vorschlägen"
  for j := 1 to 6 do
  begin
    s := FindComponent('Shape' + IntToStr(j)) as TShape;
    b := False;
    for k := 0 to high(fMasterMind.ColorsToGuess) do
    begin
      if s.Brush.Color = fMasterMind.ColorsToGuess[k].Brush.Color then
      begin
        b := True;
        break;
      end;
    end;
    s.Visible := b;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  // Starte Spiel mit 4 Farben
  HideAllColors();
  fMasterMind.StartNewGame(False, self, GroupBox1, Shape1.Width);
  ResetLCLForNewGame;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  // Starte Spiel mit 6 Farben
  fMasterMind.StartNewGame(True, self, GroupBox1, Shape1.Width);
  ShowAllColors;
  ResetLCLForNewGame;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  // Checkt Board[0]
  // Check ob überhaupt genug farben gesetzt wurden ..
  if (not Assigned(fMasterMind.Boards)) or
    (fMasterMind.Boards[0].ComponentCount <> Length(fMasterMind.ColorsToGuess)) then exit;
  if fMasterMind.CreateBoardEvaluationAndEval(Shape1.Width, Button5) then
  begin // Ist es gelöst ?
    button3.Enabled := False;
    button7.Enabled := False;
    ShowMessage('You win with ' + IntToStr(length(fMasterMind.Boards)) + ' tries.');
  end
  else
  begin
    if Length(fMasterMind.Boards) = 10 then
    begin // Verliert der Spieler ?
      button7.Enabled := False;
      ShowMessage('You loose.');
    end
    else
    begin
      fMasterMind.AddEmptyBoard(self, GroupBox1, Shape1.Width);
    end;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  // Hide unused
  HideUnusedColorsInAvailables();
  fMasterMind.HideUnusedColorsInBoards();
  Button5.Enabled := False;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  // Hilfe
  ShowMessage(
    Caption + LineEnding + LineEnding +
    'This is the Mastermind board game implementation' + LineEnding +
    'Play it like you would play the game with a partner.' + LineEnding +
    'Gameplay:' + LineEnding + '- Start game by choosing start with 4 or 6 colors.' +
    LineEnding + '- Click on the available colors to fill with your' +
    LineEnding + '  guess board.' + LineEnding +
    '- Click on a color whithin your guess board to undo' + LineEnding +
    '  your guessed color.' + LineEnding + '- Press the check button for evaluation' +
    LineEnding + LineEnding + 'Colors:' + LineEnding + '  Gray = no match' +
    LineEnding + '  white = correct color but wrong position' +
    LineEnding + '  black = correct color on correct position' +
    LineEnding + 'You win if you find the solution in less than 11' +
    LineEnding + 'steps.'
    );
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  // Tipp
  if not button3.Enabled then exit;
  // Wenn wir nicht mehr die Möglichkeit zum "checken" haben brauchts auch keinen Tipp mehr.
  if button5.Enabled then
  begin // Wenn die Möglichkeit besteht Farben aus zu Grenzen, dann Weg damit
    button5.Click;
  end;
  fMasterMind.CreateTipp(self);
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  // Load
  ShowMessage('Todo');
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  // Save, hart Codiert in einer .save Datei => Speichern als TFilestream, sonst ists zu leicht "hackbar"
  ShowMessage('Todo');
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  fMasterMind.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Caption := 'Mastermind ver 0.01 by Corpsman | www.Corpsman.de |';
  Randomize;
  fMasterMind := TMasterMind.Create();
  button3.Enabled := False; // Check Freischalten
  button5.Enabled := False; // Hide unused sperren
  button7.Enabled := False; // Tipp Freischalten
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
end;

procedure TForm1.Shape1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  s: Tshape;
begin
  s := Sender as TShape;
  fMasterMind.AddColorToActualSolution(s.brush.Color, s.Width, @OnBoard0ShapeMouseUp);
end;

end.
