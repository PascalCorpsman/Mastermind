(******************************************************************************)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* This file is part of Mastermind                                            *)
(*                                                                            *)
(*  See the file license.md, located under:                                   *)
(*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *)
(*  for details about the license.                                            *)
(*                                                                            *)
(*               It is not allowed to change or remove this text from any     *)
(*               source file of the project.                                  *)
(*                                                                            *)
(******************************************************************************)
Unit umastermind;

{$MODE ObjFPC}{$H+}

Interface

Uses
  Classes, SysUtils, ExtCtrls, StdCtrls, controls;

Type

  tGuess = Array[0..3] Of TShape;

  { TMasterMind }

  TMasterMind = Class
  private
  public
    SixColorGame: Boolean; // True, wenn mit 6 Farben zur Auswahl gespielt wird.
    ColorsToGuess: TGuess; // Die zu eratenden Farben
    Boards: Array Of TGroupBox; // Die bisherigen Rateversuche
    Constructor Create(); virtual;
    Destructor Destroy(); override;

    Procedure FreeBoards; // Gibt alle Boards Frei
    Procedure MixColors; // Mischt Colors
    Function BoardToGuess(Index: integer): TGuess;
    Procedure AddEmptyBoard(Const aOwner: TWinControl;
      Const TemplateGroupBox: TGroupBox; CirleDiameter: integer); // Schiebt alle Boards um eins nach unten und erstellt ein neues leeres
  End;

Operator = (a, b: tGuess): Boolean;

(*
 * Vergleicht ColorGuess und ColortMatch und gibt die "Übereinstimmungen"
 * als Ergebniss eines "-ws" strings zurück.
 *)
Function GetMatchString(Const ColorGuess, ColorMatch: TGuess): String;

Implementation

Operator = (a, b: tGuess): Boolean;
Begin
  result :=
    (a[0].Brush.Color = b[0].Brush.Color) And
    (a[1].Brush.Color = b[1].Brush.Color) And
    (a[2].Brush.Color = b[2].Brush.Color) And
    (a[3].Brush.Color = b[3].Brush.Color);
End;

Function GetMatchString(Const ColorGuess, ColorMatch: TGuess): String;
  Function cmp(a, b: Char): integer;
  Const
    gew = '-ws';
  Var
    p1, p2: integer;
  Begin
    p1 := pos(a, gew);
    p2 := pos(b, gew);
    result := p2 - p1;
  End;
Var
  bs: Array[0..3] Of Char;
  i, j: Integer;
  t: Char;

Begin
  (*
   * - = Kein Match
   * w = Richtige Farbe aber Falsche Position
   * s = Richtige Farbe auf Richtiger Position
   *)
  For i := 0 To 3 Do Begin
    bs[i] := '-';
    For j := 0 To 3 Do Begin
      If ColorGuess[i].Brush.Color = ColorMatch[j].Brush.Color Then Begin
        If i = j Then Begin
          bs[i] := 's';
        End
        Else Begin
          bs[i] := 'w';
        End;
      End;
    End;
  End;
  // Die Antwort ist Ermittelt nun wird sie Sortiert, weils besser aussieht, und weil es die zwischenergebnisse Verschleiert
  For i := 3 Downto 1 Do Begin
    For j := 1 To i Do Begin
      If cmp(bs[j], bs[j - 1]) > 0 Then Begin
        t := bs[j - 1];
        bs[j - 1] := bs[j];
        bs[j] := t;
      End;
    End;
  End;
  result := bs[0] + bs[1] + bs[2] + bs[3];
End;

{ TMasterMind }

Constructor TMasterMind.Create;
Begin
  Inherited create;
  SixColorGame := false;
End;

Destructor TMasterMind.Destroy;
Begin
  // Nothing todo ?
End;

Procedure TMasterMind.FreeBoards;
Var
  i: Integer;
Begin
  For i := 0 To high(Boards) Do Begin
    Boards[i].free;
  End;
  setlength(boards, 0);
End;

Procedure TMasterMind.MixColors;
Var
  i, j, k: integer;
  tmp: TShape;
Begin
  For i := 0 To 100 Do Begin
    j := random(length(ColorsToGuess));
    k := random(length(ColorsToGuess));
    If j <> k Then Begin
      tmp := ColorsToGuess[j];
      ColorsToGuess[j] := ColorsToGuess[k];
      ColorsToGuess[k] := tmp;
    End;
  End;
End;

Function TMasterMind.BoardToGuess(Index: integer): TGuess;
Begin
  result[0] := Boards[Index].Components[0] As TShape;
  result[1] := Boards[Index].Components[1] As TShape;
  result[2] := Boards[Index].Components[2] As TShape;
  result[3] := Boards[Index].Components[3] As TShape;
End;

Procedure TMasterMind.AddEmptyBoard(Const aOwner: TWinControl; Const TemplateGroupBox: TGroupBox; CirleDiameter: integer);
Var
  i, j: integer;
  s: TShape;
Begin
  setlength(Boards, high(Boards) + 2); // + 1 Board
  // Shift alle Boards eins nach hinten
  For i := high(Boards) Downto 1 Do Begin
    boards[i] := Boards[i - 1];
  End;
  // Neues Board initialisieren
  boards[0] := TGroupBox.Create(aOwner);
  boards[0].Parent := aOwner;
  boards[0].Left := TemplateGroupBox.Left;
  boards[0].Width := length(ColorsToGuess) * (CirleDiameter + 10) + CirleDiameter + 20 { Bereich für die Lösung};
  boards[0].Height := TemplateGroupBox.Height;
  boards[0].Name := 'Guessboard' + inttostr(length(Boards));
  boards[0].Caption := ' Guessboard ' + inttostr(length(Boards)) + ' ';
  For i := 0 To high(Boards) Do Begin
    // Neu Berechnen der angezeigten Höhe der Boards
    boards[i].Top := TemplateGroupBox.top + TemplateGroupBox.Height + 1 + (TemplateGroupBox.Height + 1) * i;
    If i = 1 Then Begin // Deaktivieren der "Lösch" routine innerhalb der bereits evaluierten Boards
      For j := 0 To Boards[i].ComponentCount - 1 Do Begin
        If Boards[i].Components[j] Is TShape Then Begin
          s := Boards[i].Components[j] As TShape;
          s.OnMouseUp := Nil;
        End;
      End;
    End;
  End;

End;

End.

