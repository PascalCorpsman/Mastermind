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

    Procedure ShowAllColors; // Zeigt alle Vorschlagsfarben an
    Procedure HideAllColors; // Versteckt alle Vorschlagsfarben

    Procedure OnBoard0ShapeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); // Callback zum entfernen einer Farbe aus Board[0]

  public
    { public declarations }
  End;

Var
  Form1: TForm1;

Implementation

{$R *.lfm}

{ TForm1 }

Procedure TForm1.HideAllColors;
Var
  i: Integer;
Begin
  For i := 1 To 6 Do Begin
    TShape(FindComponent('Shape' + inttostr(i))).visible := false;
  End;
End;

Procedure TForm1.OnBoard0ShapeMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Begin
  // Entfernen des Aktuellen Elementes in Guess
  sender.free;
End;

Procedure TForm1.ShowAllColors;
Var
  i: Integer; // Zeigen aber wieder alle an, so das der User nicht weiß welche beiden wir nicht nutzen
Begin
  For i := 1 To 6 Do Begin
    TShape(FindComponent('Shape' + inttostr(i))).visible := true;
  End;
End;

Procedure TForm1.Button1Click(Sender: TObject);
Begin
  // Starte Spiel mit 4 Farben
  fMasterMind.SixColorGame := false;
  fMasterMind.FreeBoards;
  HideAllColors;
  fMasterMind.InitColors(self);
  fMasterMind.MixColors;
  fMasterMind.AddEmptyBoard(self, GroupBox1, Shape1.Width);
  button3.enabled := true; // Check Freischalten
  button5.enabled := false; // Hide unused sperren
  button7.enabled := true; // Tipp Freischalten
End;

Procedure TForm1.Button2Click(Sender: TObject);
Begin
  // Starte Spiel mit 6 Farben
  fMasterMind.SixColorGame := true;
  fMasterMind.FreeBoards;
  fMasterMind.InitColors(self);
  ShowAllColors;
  fMasterMind.MixColors;
  fMasterMind.AddEmptyBoard(self, GroupBox1, Shape1.Width);
  button3.enabled := true; // Check Freischalten
  button5.enabled := false; // Hide unused sperren
  button7.enabled := true; // Tipp Freischalten
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
Var
  AviableColors: Array Of TShape;
  s: TShape; // Zwischenspeicher, für den leichteren Zugriff
  i: Integer;
  KeepTrying: Boolean;
  Permutation: String;
  GuessFromGuessboard, NewGuess: TGuess;
Begin
  (*
   * Die Idee hinter dem Algorithmus :
   * 1. Raten einer zufälligen Farbreihenfolge
   * 2. Prüfen ob diese Reihenfolge alle bisher bekannten Ergebnisse Bestätigt
   * 3. Wenn Ja   -> diese Vorschlagen
   *    Wenn Nein -> zrück zu 1.
   *
   * Der Algorithmus verwendet im Kern keine Informationen, welche nicht auch dem User bekannt
   * sind. Er spielt also ehrlich.
   * Einziger Unterschied, ein Mensch würde evtl. den neuen Vorschlag durch Logik bestimmen und
   * nicht raten.
   * Effizient wird der Algorithmus durch die Konsequente Vermeidung von Widerhohlungsfehlern
   * so ist quasi garantiert, das bei jeder neuen Iteration (Tipp -> Check) die Wissensbasis
   * bereichert wird mit neuem Wissen und deswegen die Lösung näher rückt *g*.
   *)
  If Not button3.enabled Then exit; // Wenn wir nicht mehr die Möglichkeit zum "checken" haben brauchts auch keinen Tipp mehr.
  If button5.enabled Then Begin // Wenn die Möglichkeit besteht Farben aus zu Grenzen, dann Weg damit
    button5.Click;
  End;
  // 1. Bestimmen aller Möglichen Farbkombinationen
  AviableColors := Nil;
  For i := 1 To 6 Do Begin
    s := (FindComponent('Shape' + inttostr(i))) As Tshape;
    If s.Visible Then Begin
      setlength(AviableColors, high(AviableColors) + 2);
      AviableColors[high(AviableColors)] := s;
    End;
  End;
  If length(AviableColors) < 4 Then Begin
    Raise exception.create('Logik fehler');
  End;
  // 2. bestimmen einer Poteniellen lösung
  KeepTrying := true;
  While KeepTrying Do Begin
    // Bestimmen einer Zufälligen Permutation der indizees von AviableColors
    Permutation := '';
    While length(Permutation) < 4 Do Begin
      i := random(length(AviableColors));
      If pos(inttostr(i), Permutation) = 0 Then Begin
        Permutation := Permutation + inttostr(i);
      End;
    End;
    // Umwandeln der Permutation in eine TGuess
    NewGuess[0] := AviableColors[strtoint(Permutation[1])];
    NewGuess[1] := AviableColors[strtoint(Permutation[2])];
    NewGuess[2] := AviableColors[strtoint(Permutation[3])];
    NewGuess[3] := AviableColors[strtoint(Permutation[4])];
    KeepTrying := false; // Annemen dass wir eine neue passende Permutation gefunden haben
    For i := 1 To high(fMasterMind.Boards) Do Begin
      // 2.1 Der neue Vorschlag muss unterschiedlich zu allen bisher gefundenen sein
      GuessFromGuessboard := fMasterMind.BoardToGuess(i);
      If NewGuess = GuessFromGuessboard Then Begin
        KeepTrying := true;
        break;
      End;
      // 2.2 Prüfen ob der neue Vorschlag bei allen alten Ergebnissen das selbe Ergebnis erzeugt => also valide ist.
      (*
       * Hier wird auf die zu eratende Farbreihenfolge zurück gegriffen, weil
       * die für den User sichtbare Version nirgends gespeichert wird.
       * ColorsToGuess wird aber nicht direkt ausgewertet oder verglichen damit
       * bleibt der Algorithmus entsprechend "blind" gegen die zu erratende Farbsequenz
       * Wollte man dies Ausbauen müsste im Eval Schritt jedes jeweilige Ergebnis
       * als Matchstring an die entdprechenden Boards angehängt werden.
       *)
      If GetMatchString(GuessFromGuessboard, fMasterMind.ColorsToGuess) <> GetMatchString(GuessFromGuessboard, NewGuess) Then Begin
        KeepTrying := true;
        break;
      End;
    End;
  End;
  // 3.1 Löschen der bisherigen Eingabe
  For i := 0 To fMasterMind.Boards[0].Componentcount - 1 Do Begin
    fMasterMind.Boards[0].Components[0].Free;
  End;
  // 3.2 Setzen der gefundenen Lösung
  For i := 0 To 3 Do Begin
    NewGuess[i].OnMouseUp(NewGuess[i], mbLeft, [ssleft], 1, 1);
  End;
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
  fMasterMind.Boards := Nil;
  button3.enabled := false;
  button5.enabled := false;
  button7.enabled := false;
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
End;

Procedure TForm1.Shape1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var
  s, t: TShape;
  l, i, j: Integer;
  b: Boolean;
Begin
  (*
   * Fügt eine neue Farbe in die Potenzielle Lösung hinzu
   *)
  If assigned(fMasterMind.Boards) And (fMasterMind.boards[0].ComponentCount < length(fMasterMind.ColorsToGuess)) Then Begin
    s := sender As TShape;
    // Prüfen obs die Farbe schon gibt..
    For i := 0 To fMasterMind.Boards[0].ComponentCount - 1 Do Begin
      t := fMasterMind.Boards[0].Components[i] As TShape;
      If t.Brush.Color = s.brush.Color Then exit;
    End;
    // Wir erstellen ein neues Element, aber an welcher Position ?
    t := TShape.Create(fMasterMind.boards[0]);
    t.Parent := fMasterMind.boards[0];
    t.Shape := stCircle;
    t.Brush.Color := s.brush.Color;
    t.Top := 3;
    t.Width := s.Width;
    t.Height := s.Height;
    t.OnMouseUp := @OnBoard0ShapeMouseUp;
    // Suchen der 1. Freien Position
    For i := 0 To fMasterMind.boards[0].ComponentCount - 1 Do Begin
      l := 10 + i * (s.Width + 10);
      b := true;
      For j := 0 To fMasterMind.boards[0].ComponentCount - 2 Do Begin
        If l = (fMasterMind.boards[0].Components[j] As TShape).left Then Begin
          b := false;
          break;
        End;
      End;
      If b Then Begin
        t.left := l;
        break;
      End;
    End;
  End;
End;

End.

