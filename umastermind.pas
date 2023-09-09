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
  Classes, SysUtils;

Type

  { TMasterMind }

  TMasterMind = Class
  private
  public
    SixColorGame: Boolean; // True, wenn mit 6 Farben zur Auswahl gespielt wird.
    Constructor Create(); virtual;
    Destructor Destroy(); override;
  End;

Implementation

{ TMasterMind }

Constructor TMasterMind.Create();
Begin
  Inherited create;
  SixColorGame := false;
End;

Destructor TMasterMind.Destroy;
Begin

End;

End.

