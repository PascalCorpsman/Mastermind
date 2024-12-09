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
unit umastermind;

{$MODE ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, StdCtrls, Controls, Graphics;

type

  tGuess = array[0..3] of TShape;

  { TMasterMind }

  TMasterMind = class
  private
  public
    SixColorGame: boolean; // True, wenn mit 6 Farben zur Auswahl gespielt wird.
    ColorsToGuess: TGuess; // Die zu eratenden Farben
    Boards: array of TGroupBox; // Die bisherigen Rateversuche

    constructor Create(); virtual;
    destructor Destroy(); override;

    procedure FreeBoards; // Gibt alle Boards Frei
    procedure MixColors; // Mischt Colors
    function BoardToGuess(Index: integer): TGuess;
    procedure AddEmptyBoard(const aOwner: TWinControl;
      const TemplateGroupBox: TGroupBox; CirleDiameter: integer);
    // Schiebt alle Boards um eins nach unten und erstellt ein neues leeres
    procedure InitColors(const aOwner: TWinControl);
    // Initialisiert Colors und macht nur diejenigen Vorschlagsfarben sichtbar, welche verwendet wurden
    function CreateBoardEvaluationAndEval(CirleDiameter: integer;
      const HideUnusedButton: TButton): boolean;
    // Erzeugt das Auswertungsbildchen in Board[0], true, wenn die Lösung gefunden wurde
    procedure CreateTipp(aOwner: TWinControl);

    procedure StartNewGame(SixPlayer: boolean; aOwner: TWinControl;
      const TemplateGroupBox: TGroupBox; CirleDiameter: integer);
    procedure AddColorToActualSolution(aColor: TColor; CirleDiameter: integer;
      OnMouseUpCallback: TMouseEvent);
    procedure HideUnusedColorsInBoards();
  end;

operator =(a, b: tGuess): boolean;

(*
 * Vergleicht ColorGuess und ColortMatch und gibt die "Übereinstimmungen"
 * als Ergebniss eines "-ws" strings zurück.
 *)
function GetMatchString(const ColorGuess, ColorMatch: TGuess): string;

implementation

operator =(a, b: tGuess): boolean;
begin
  Result :=
    (a[0].Brush.Color = b[0].Brush.Color) and (a[1].Brush.Color =
    b[1].Brush.Color) and (a[2].Brush.Color = b[2].Brush.Color) and
    (a[3].Brush.Color = b[3].Brush.Color);
end;

function GetMatchString(const ColorGuess, ColorMatch: TGuess): string;

  function cmp(a, b: char): integer;
  const
    gew = '-ws';
  var
    p1, p2: integer;
  begin
    p1 := pos(a, gew);
    p2 := pos(b, gew);
    Result := p2 - p1;
  end;

var
  bs: array[0..3] of char;
  i, j: integer;
  t: char;
begin
  (*
   * - = Kein Match
   * w = Richtige Farbe aber Falsche Position
   * s = Richtige Farbe auf Richtiger Position
   *)
  for i := 0 to 3 do
  begin
    bs[i] := '-';
    for j := 0 to 3 do
    begin
      if ColorGuess[i].Brush.Color = ColorMatch[j].Brush.Color then
      begin
        if i = j then
        begin
          bs[i] := 's';
        end
        else
        begin
          bs[i] := 'w';
        end;
      end;
    end;
  end;
  // Die Antwort ist Ermittelt nun wird sie Sortiert, weils besser aussieht, und weil es die zwischenergebnisse Verschleiert
  for i := 3 downto 1 do
  begin
    for j := 1 to i do
    begin
      if cmp(bs[j], bs[j - 1]) > 0 then
      begin
        t := bs[j - 1];
        bs[j - 1] := bs[j];
        bs[j] := t;
      end;
    end;
  end;
  Result := bs[0] + bs[1] + bs[2] + bs[3];
end;

{ TMasterMind }

constructor TMasterMind.Create;
begin
  inherited Create;
  SixColorGame := False;
  Boards := nil;
end;

destructor TMasterMind.Destroy;
begin
  // Nothing todo ?
end;

procedure TMasterMind.FreeBoards;
var
  i: integer;
begin
  for i := 0 to high(Boards) do
  begin
    Boards[i].Free;
  end;
  setlength(boards, 0);
end;

procedure TMasterMind.MixColors;
var
  i, j, k: integer;
  tmp: TShape;
begin
  for i := 0 to 100 do
  begin
    j := random(length(ColorsToGuess));
    k := random(length(ColorsToGuess));
    if j <> k then
    begin
      tmp := ColorsToGuess[j];
      ColorsToGuess[j] := ColorsToGuess[k];
      ColorsToGuess[k] := tmp;
    end;
  end;
end;

function TMasterMind.BoardToGuess(Index: integer): TGuess;
begin
  Result[0] := Boards[Index].Components[0] as TShape;
  Result[1] := Boards[Index].Components[1] as TShape;
  Result[2] := Boards[Index].Components[2] as TShape;
  Result[3] := Boards[Index].Components[3] as TShape;
end;

procedure TMasterMind.AddEmptyBoard(const aOwner: TWinControl;
  const TemplateGroupBox: TGroupBox; CirleDiameter: integer);
var
  i, j: integer;
  s: TShape;
begin
  setlength(Boards, high(Boards) + 2); // + 1 Board
  // Shift alle Boards eins nach hinten
  for i := high(Boards) downto 1 do
  begin
    boards[i] := Boards[i - 1];
  end;
  // Neues Board initialisieren
  boards[0] := TGroupBox.Create(aOwner);
  boards[0].Parent := aOwner;
  boards[0].Left := TemplateGroupBox.Left;
  boards[0].Width := length(ColorsToGuess) * (CirleDiameter + 10) +
    CirleDiameter + 20 { Bereich für die Lösung};
  boards[0].Height := TemplateGroupBox.Height;
  boards[0].Name := 'Guessboard' + IntToStr(length(Boards));
  boards[0].Caption := ' Guessboard ' + IntToStr(length(Boards)) + ' ';
  for i := 0 to high(Boards) do
  begin
    // Neu Berechnen der angezeigten Höhe der Boards
    boards[i].Top := TemplateGroupBox.top + TemplateGroupBox.Height +
      1 + (TemplateGroupBox.Height + 1) * i;
    if i = 1 then
    begin // Deaktivieren der "Lösch" routine innerhalb der bereits evaluierten Boards
      for j := 0 to Boards[i].ComponentCount - 1 do
      begin
        if Boards[i].Components[j] is TShape then
        begin
          s := Boards[i].Components[j] as TShape;
          s.OnMouseUp := nil;
        end;
      end;
    end;
  end;
end;

procedure TMasterMind.InitColors(const aOwner: TWinControl);
var
  k, j, i: integer;
  b: boolean;
  s: TShape;
begin
  for i := 0 to high(ColorsToGuess) do
  begin
    ColorsToGuess[i] := nil;
    b := True;
    while b do
    begin
      j := random(6) + 1;
      s := TShape(aOwner.FindComponent('Shape' + IntToStr(j)));
      b := False;
      for k := 0 to i - 1 do
      begin
        if ColorsToGuess[k] = s then
        begin
          b := True;
          break;
        end;
      end;
      if not b then
      begin
        ColorsToGuess[i] := s;
        s.Visible := True;
      end;
    end;
  end;
end;

function TMasterMind.CreateBoardEvaluationAndEval(CirleDiameter: integer;
  const HideUnusedButton: TButton): boolean;
var
  x, y, i: integer;
  b: Tbitmap;
  im: TImage;
  s: string;
  g: tGuess;
begin
  g[0] := Boards[0].Components[0] as TShape;
  g[1] := Boards[0].Components[1] as TShape;
  g[2] := Boards[0].Components[2] as TShape;
  g[3] := Boards[0].Components[3] as TShape;
  s := GetMatchString(g, ColorsToGuess);
  // Visualisieren
  b := TBitmap.Create;
  b.Width := CirleDiameter;
  b.Height := CirleDiameter;
  for i := 0 to 3 do
  begin
    case s[i + 1] of
      '-': b.Canvas.Brush.Color := clGray;
      'w': b.Canvas.Brush.Color := clwhite;
      's': b.Canvas.Brush.Color := clBlack;
    end;
    x := i mod 2;
    y := i div 2;
    x := x * (CirleDiameter div 2);
    y := y * (CirleDiameter div 2);
    b.canvas.Rectangle(x, y, x + (CirleDiameter div 2) + 1, y +
      (CirleDiameter div 2) + 1);
  end;
  im := TImage.Create(Boards[0]);
  im.Parent := Boards[0];
  im.top := 3;
  im.left := 4 * (CirleDiameter + 10) + 5;
  im.AutoSize := False;
  im.Width := CirleDiameter;
  im.Height := CirleDiameter;
  im.Center := True;
  im.Picture.Assign(b);
  b.Free;
  if (s[1] <> '-') and (SixColorGame) then HideUnusedButton.Enabled := True;
  Result := (s[1] = 's') and (s[2] = 's') and (s[3] = 's') and (s[4] = 's');
end;

procedure TMasterMind.CreateTipp(aOwner: TWinControl);
var
  AviableColors: array of TShape;
  s: TShape; // Zwischenspeicher, für den leichteren Zugriff
  i: integer;
  KeepTrying: boolean;
  Permutation: string;
  GuessFromGuessboard, NewGuess: TGuess;
begin
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
  AviableColors := nil;
  for i := 1 to 6 do
  begin
    s := (aOwner.FindComponent('Shape' + IntToStr(i))) as Tshape;
    if s.Visible then
    begin
      setlength(AviableColors, high(AviableColors) + 2);
      AviableColors[high(AviableColors)] := s;
    end;
  end;
  if length(AviableColors) < 4 then
  begin
    raise Exception.Create('Logik fehler');
  end;
  // 2. bestimmen einer Poteniellen lösung
  KeepTrying := True;
  while KeepTrying do
  begin
    // Bestimmen einer Zufälligen Permutation der indizees von AviableColors
    Permutation := '';
    while length(Permutation) < 4 do
    begin
      i := random(length(AviableColors));
      if pos(IntToStr(i), Permutation) = 0 then
      begin
        Permutation := Permutation + IntToStr(i);
      end;
    end;
    // Umwandeln der Permutation in eine TGuess
    NewGuess[0] := AviableColors[StrToInt(Permutation[1])];
    NewGuess[1] := AviableColors[StrToInt(Permutation[2])];
    NewGuess[2] := AviableColors[StrToInt(Permutation[3])];
    NewGuess[3] := AviableColors[StrToInt(Permutation[4])];
    KeepTrying := False; // Annemen dass wir eine neue passende Permutation gefunden haben
    for i := 1 to high(Boards) do
    begin
      // 2.1 Der neue Vorschlag muss unterschiedlich zu allen bisher gefundenen sein
      GuessFromGuessboard := BoardToGuess(i);
      if NewGuess = GuessFromGuessboard then
      begin
        KeepTrying := True;
        break;
      end;
      // 2.2 Prüfen ob der neue Vorschlag bei allen alten Ergebnissen das selbe Ergebnis erzeugt => also valide ist.
      (*
       * Hier wird auf die zu eratende Farbreihenfolge zurück gegriffen, weil
       * die für den User sichtbare Version nirgends gespeichert wird.
       * ColorsToGuess wird aber nicht direkt ausgewertet oder verglichen damit
       * bleibt der Algorithmus entsprechend "blind" gegen die zu erratende Farbsequenz
       * Wollte man dies Ausbauen müsste im Eval Schritt jedes jeweilige Ergebnis
       * als Matchstring an die entdprechenden Boards angehängt werden.
       *)
      if GetMatchString(GuessFromGuessboard, ColorsToGuess) <>
        GetMatchString(GuessFromGuessboard, NewGuess) then
      begin
        KeepTrying := True;
        break;
      end;
    end;
  end;
  // 3.1 Löschen der bisherigen Eingabe
  for i := 0 to Boards[0].Componentcount - 1 do
  begin
    Boards[0].Components[0].Free;
  end;
  // 3.2 Setzen der gefundenen Lösung
  for i := 0 to 3 do
  begin
    NewGuess[i].OnMouseUp(NewGuess[i], mbLeft, [ssleft], 1, 1);
  end;
end;

procedure TMasterMind.StartNewGame(SixPlayer: boolean; aOwner: TWinControl;
  const TemplateGroupBox: TGroupBox; CirleDiameter: integer);
begin
  SixColorGame := SixPlayer;
  FreeBoards;
  InitColors(aOwner);
  MixColors;
  AddEmptyBoard(aOwner, TemplateGroupBox, CirleDiameter);
end;

procedure TMasterMind.AddColorToActualSolution(aColor: TColor;
  CirleDiameter: integer; OnMouseUpCallback: TMouseEvent);
var
  t: TShape;
  l, i, j: integer;
  b: boolean;
begin
  (*
   * Fügt eine neue Farbe in die Potenzielle Lösung hinzu
   *)
  if assigned(Boards) and (boards[0].ComponentCount < length(ColorsToGuess)) then
  begin
    // Prüfen obs die Farbe schon gibt..
    for i := 0 to Boards[0].ComponentCount - 1 do
    begin
      t := Boards[0].Components[i] as TShape;
      if t.Brush.Color = aColor then exit;
    end;
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
    for i := 0 to boards[0].ComponentCount - 1 do
    begin
      l := 10 + i * (CirleDiameter + 10);
      b := True;
      for j := 0 to boards[0].ComponentCount - 2 do
      begin
        if l = (boards[0].Components[j] as TShape).left then
        begin
          b := False;
          break;
        end;
      end;
      if b then
      begin
        t.left := l;
        break;
      end;
    end;
  end;
end;

procedure TMasterMind.HideUnusedColorsInBoards();
var
  i, j, k: integer;
  s: TShape;
  b: boolean;
begin
  // Löschen der nicht genutzten Farben aus allen "Lösungen"
  for i := 1 to high(Boards) do
  begin
    for j := 0 to Boards[i].ComponentCount - 1 do
    begin
      if Boards[i].Components[j] is TShape then
      begin
        s := Boards[i].Components[j] as TShape;
        b := False;
        for k := 0 to high(ColorsToGuess) do
        begin
          if s.Brush.Color = ColorsToGuess[k].Brush.Color then
          begin
            b := True;
            break;
          end;
        end;
        s.Visible := b;
      end;
    end;
  end;
end;

end.
