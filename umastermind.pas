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
  Classes, SysUtils, ExtCtrls, StdCtrls, controls, Graphics;

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
    Procedure InitColors(Const aOwner: TWinControl); // Initialisiert Colors und macht nur diejenigen Vorschlagsfarben sichtbar, welche verwendet wurden
    Function CreateBoardEvaluationAndEval(CirleDiameter: integer; Const HideUnusedButton: TButton): Boolean; // Erzeugt das Auswertungsbildchen in Board[0], true, wenn die Lösung gefunden wurde
    Procedure CreateTipp(aOwner: TWinControl);

    Procedure StartNewGame(SixPlayer: Boolean; aOwner: TWinControl;
      Const TemplateGroupBox: TGroupBox; CirleDiameter: integer);
    Procedure AddColorToActualSolution(aColor: TColor; CirleDiameter: integer; OnMouseUpCallback: TMouseEvent);
    Procedure HideUnusedColorsInBoards();
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
  Boards := Nil;
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

Procedure TMasterMind.AddEmptyBoard(Const aOwner: TWinControl;
  Const TemplateGroupBox: TGroupBox; CirleDiameter: integer);
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

Procedure TMasterMind.InitColors(Const aOwner: TWinControl);
Var
  k, j, i: Integer;
  b: boolean;
  s: TShape;
Begin
  For i := 0 To high(ColorsToGuess) Do Begin
    ColorsToGuess[i] := Nil;
    b := true;
    While b Do Begin
      j := random(6) + 1;
      s := TShape(aOwner.FindComponent('Shape' + inttostr(j)));
      b := false;
      For k := 0 To i - 1 Do Begin
        If ColorsToGuess[k] = s Then Begin
          b := true;
          break;
        End;
      End;
      If Not b Then Begin
        ColorsToGuess[i] := s;
        s.Visible := true;
      End;
    End;
  End;
End;

Function TMasterMind.CreateBoardEvaluationAndEval(CirleDiameter: integer;
  Const HideUnusedButton: TButton): Boolean;
Var
  x, y, i: integer;
  b: Tbitmap;
  im: TImage;
  s: String;
  g: tGuess;
Begin
  g[0] := Boards[0].Components[0] As TShape;
  g[1] := Boards[0].Components[1] As TShape;
  g[2] := Boards[0].Components[2] As TShape;
  g[3] := Boards[0].Components[3] As TShape;
  s := GetMatchString(g, ColorsToGuess);
  // Visualisieren
  b := TBitmap.Create;
  b.Width := CirleDiameter;
  b.Height := CirleDiameter;
  For i := 0 To 3 Do Begin
    Case s[i + 1] Of
      '-': b.Canvas.Brush.Color := clGray;
      'w': b.Canvas.Brush.Color := clwhite;
      's': b.Canvas.Brush.Color := clBlack;
    End;
    x := i Mod 2;
    y := i Div 2;
    x := x * (CirleDiameter Div 2);
    y := y * (CirleDiameter Div 2);
    b.canvas.Rectangle(x, y, x + (CirleDiameter Div 2) + 1, y + (CirleDiameter Div 2) + 1);
  End;
  im := TImage.Create(Boards[0]);
  im.Parent := Boards[0];
  im.top := 3;
  im.left := 4 * (CirleDiameter + 10) + 5;
  im.AutoSize := false;
  im.Width := CirleDiameter;
  im.Height := CirleDiameter;
  im.Center := true;
  im.Picture.Assign(b);
  b.free;
  If (s[1] <> '-') And (SixColorGame) Then HideUnusedButton.Enabled := true;
  result := (s[1] = 's') And (s[2] = 's') And (s[3] = 's') And (s[4] = 's');
End;

Procedure TMasterMind.CreateTipp(aOwner: TWinControl);
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
  // 1. Bestimmen aller Möglichen Farbkombinationen
  AviableColors := Nil;
  For i := 1 To 6 Do Begin
    s := (aOwner.FindComponent('Shape' + inttostr(i))) As Tshape;
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
    For i := 1 To high(Boards) Do Begin
      // 2.1 Der neue Vorschlag muss unterschiedlich zu allen bisher gefundenen sein
      GuessFromGuessboard := BoardToGuess(i);
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
      If GetMatchString(GuessFromGuessboard, ColorsToGuess) <> GetMatchString(GuessFromGuessboard, NewGuess) Then Begin
        KeepTrying := true;
        break;
      End;
    End;
  End;
  // 3.1 Löschen der bisherigen Eingabe
  For i := 0 To Boards[0].Componentcount - 1 Do Begin
    Boards[0].Components[0].Free;
  End;
  // 3.2 Setzen der gefundenen Lösung
  For i := 0 To 3 Do Begin
    NewGuess[i].OnMouseUp(NewGuess[i], mbLeft, [ssleft], 1, 1);
  End;
End;

Procedure TMasterMind.StartNewGame(SixPlayer: Boolean; aOwner: TWinControl;
  Const TemplateGroupBox: TGroupBox; CirleDiameter: integer);
Begin
  SixColorGame := SixPlayer;
  FreeBoards;
  InitColors(aOwner);
  MixColors;
  AddEmptyBoard(aOwner, TemplateGroupBox, CirleDiameter);
End;

Procedure TMasterMind.AddColorToActualSolution(aColor: TColor;
  CirleDiameter: integer; OnMouseUpCallback: TMouseEvent);
Var
  t: TShape;
  l, i, j: Integer;
  b: Boolean;
Begin
  (*
   * Fügt eine neue Farbe in die Potenzielle Lösung hinzu
   *)
  If assigned(Boards) And (boards[0].ComponentCount < length(ColorsToGuess)) Then Begin
    // Prüfen obs die Farbe schon gibt..
    For i := 0 To Boards[0].ComponentCount - 1 Do Begin
      t := Boards[0].Components[i] As TShape;
      If t.Brush.Color = aColor Then exit;
    End;
    // Wir erstellen ein neues Element, aber an welcher Position ?
    t := TShape.Create(boards[0]);
    t.Parent := boards[0];
    t.Shape := stCircle;
    t.Brush.Color := aColor;
    t.Top := 3;
    t.Width := CirleDiameter;
    t.Height := CirleDiameter;
    t.OnMouseUp := OnMouseUpCallback;
    // Suchen der 1. Freien Position
    For i := 0 To boards[0].ComponentCount - 1 Do Begin
      l := 10 + i * (CirleDiameter + 10);
      b := true;
      For j := 0 To boards[0].ComponentCount - 2 Do Begin
        If l = (boards[0].Components[j] As TShape).left Then Begin
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

Procedure TMasterMind.HideUnusedColorsInBoards();
Var
  i, j, k: integer;
  s: TShape;
  b: Boolean;
Begin
  // Löschen der nicht genutzten Farben aus allen "Lösungen"
  For i := 1 To high(Boards) Do Begin
    For j := 0 To Boards[i].ComponentCount - 1 Do Begin
      If Boards[i].Components[j] Is TShape Then Begin
        s := Boards[i].Components[j] As TShape;
        b := false;
        For k := 0 To high(ColorsToGuess) Do Begin
          If s.Brush.Color = ColorsToGuess[k].Brush.Color Then Begin
            b := true;
            break;
          End;
        End;
        s.Visible := b;
      End;
    End;
  End;
End;

End.

