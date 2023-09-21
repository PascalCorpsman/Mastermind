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

Unit Unit1;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, umastermind;

Type

  { TForm1 }

  TForm1 = Class(TForm)
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
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure Button8Click(Sender: TObject);
    Procedure Button9Click(Sender: TObject);
    Procedure FormClose(Sender: TObject; Var CloseAction: TCloseAction);
    Procedure FormCreate(Sender: TObject);
    Procedure Shape1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
    fMasterMind: TMasterMind;

    Procedure OnBoard0ShapeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); // Callback zum entfernen einer Farbe aus Board[0]
    Procedure ResetLCLForNewGame;

  public
    { public declarations }
  End;

Var
  Form1: TForm1;

Implementation

{$R *.lfm}

{ TForm1 }

Procedure TForm1.OnBoard0ShapeMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Begin
  // Entfernen des Aktuellen Elementes in Guess
  sender.free;
End;

Procedure TForm1.ResetLCLForNewGame;
Begin
  button3.enabled := true; // Check Freischalten
  button5.enabled := false; // Hide unused sperren
  button7.enabled := true; // Tipp Freischalten
End;

Procedure TForm1.Button1Click(Sender: TObject);
Begin
  // Starte Spiel mit 4 Farben
  fMasterMind.StartNewGame(false, self, GroupBox1, Shape1.Width);
  ResetLCLForNewGame;
End;

Procedure TForm1.Button2Click(Sender: TObject);
Begin
  // Starte Spiel mit 6 Farben
  fMasterMind.StartNewGame(true, self, GroupBox1, Shape1.Width);
  ResetLCLForNewGame;
End;

Procedure TForm1.Button3Click(Sender: TObject);
Begin
  // Checkt Board[0]
  // Check ob überhaupt genug farben gesetzt wurden ..
  If (Not Assigned(fMasterMind.Boards)) Or (fMasterMind.Boards[0].ComponentCount <> Length(fMasterMind.ColorsToGuess)) Then exit;
  If fMasterMind.CreateBoardEvaluationAndEval(Shape1.Width, Button5) Then Begin // Ist es gelöst ?
    button3.enabled := false;
    button7.enabled := false;
    showmessage('You win with ' + inttostr(length(fMasterMind.Boards)) + ' tries.');
  End
  Else Begin
    If Length(fMasterMind.Boards) = 10 Then Begin // Verliert der Spieler ?
      button7.enabled := false;
      showmessage('You loose.');
    End
    Else Begin
      fMasterMind.AddEmptyBoard(self, GroupBox1, Shape1.Width);
    End;
  End;
End;

Procedure TForm1.Button4Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm1.Button5Click(Sender: TObject);
Var
  i, j, k: integer;
  s: TShape;
  b: Boolean;
Begin
  // hide unused
  // Löschen der nicht genutzten Farben aus den "Vorschlägen"
  For j := 1 To 6 Do Begin
    s := FindComponent('Shape' + inttostr(j)) As TShape;
    b := false;
    For k := 0 To high(fMasterMind.ColorsToGuess) Do Begin
      If s.Brush.Color = fMasterMind.ColorsToGuess[k].Brush.Color Then Begin
        b := true;
        break;
      End;
    End;
    s.Visible := b;
  End;

  // Löschen der nicht genutzten Farben aus allen "Lösungen"
  For i := 1 To high(fMasterMind.Boards) Do Begin
    For j := 0 To fMasterMind.Boards[i].ComponentCount - 1 Do Begin
      If fMasterMind.Boards[i].Components[j] Is TShape Then Begin
        s := fMasterMind.Boards[i].Components[j] As TShape;
        b := false;
        For k := 0 To high(fMasterMind.ColorsToGuess) Do Begin
          If s.Brush.Color = fMasterMind.ColorsToGuess[k].Brush.Color Then Begin
            b := true;
            break;
          End;
        End;
        s.Visible := b;
      End;
    End;
  End;
  Button5.enabled := false;
End;

Procedure TForm1.Button6Click(Sender: TObject);
Begin
  // Hilfe
  showmessage(
    Caption + LineEnding + LineEnding +
    'This is the Mastermind board game implementation' + LineEnding +
    'Play it like you would play the game with a partner.' + LineEnding +
    'Gameplay:' + LineEnding +
    '- Start game by choosing start with 4 or 6 colors.' + LineEnding +
    '- Click on the available colors to fill with your' + LineEnding +
    '  guess board.' + LineEnding +
    '- Click on a color whithin your guess board to undo' + LineEnding +
    '  your guessed color.' + LineEnding +
    '- Press the check button for evaluation' + LineEnding + LineEnding +
    'Colors:' + LineEnding +
    '  Gray = no match' + LineEnding +
    '  white = correct color but wrong position' + LineEnding +
    '  black = correct color on correct position' + LineEnding +
    'You win if you find the solution in less than 11' + LineEnding +
    'steps.'
    );
End;

Procedure TForm1.Button7Click(Sender: TObject);
Begin
  // Tipp
  If Not button3.enabled Then exit; // Wenn wir nicht mehr die Möglichkeit zum "checken" haben brauchts auch keinen Tipp mehr.
  If button5.enabled Then Begin // Wenn die Möglichkeit besteht Farben aus zu Grenzen, dann Weg damit
    button5.Click;
  End;
  fMasterMind.CreateTipp(self);
End;

Procedure TForm1.Button8Click(Sender: TObject);
Begin
  // Load
  showmessage('Todo');
End;

Procedure TForm1.Button9Click(Sender: TObject);
Begin
  // Save, hart Codiert in einer .save Datei => Speichern als TFilestream, sonst ists zu leicht "hackbar"
  showmessage('Todo');
End;

Procedure TForm1.FormClose(Sender: TObject; Var CloseAction: TCloseAction);
Begin
  fMasterMind.Free;
End;

Procedure TForm1.FormCreate(Sender: TObject);
Begin
  caption := 'Mastermind ver 0.01 by Corpsman | www.Corpsman.de |';
  Randomize;
  fMasterMind := TMasterMind.Create();
  button3.enabled := false;
  button5.enabled := false;
  button7.enabled := false;
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
End;

Procedure TForm1.Shape1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var
  s: Tshape;
Begin
  s := sender As TShape;
  fMasterMind.AddColorToActualSolution(s.brush.Color, s.Width, @OnBoard0ShapeMouseUp);
End;

End.

