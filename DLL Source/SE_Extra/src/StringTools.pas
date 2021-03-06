unit StringTools;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
{$mode objfpc}{$H+}
{$macro on}
interface

uses
  SysUtils, CoreTypes;

function StrPosEx(const SubStr, Text:String): TIntArray;
function StrPosL(const SubStr, Text: String): Integer;
function StrPosR(const SubStr, Text: String): Integer;
function StrReplace(const Text, SubStr, RepStr: String; Flags:TReplaceFlags): String;
function StrExplode(const Text, Sep: String): TStrArray;


//-----------------------------------------------------------------------
implementation

{*
  Returns all positions of the given pattern/substring.
  @note: 
    28.apr.2014: Fixed imporant bug!
*}
function StrPosEx(const SubStr, Text:String): TIntArray;
var
  HitPos,LenSub,h,q,i: Integer;
begin
  LenSub := Length(SubStr);
  if LenSub = 0 then Exit;
  HitPos := 1;
  h := 0;
  q := 1;
  SetLength(Result, q);
  for i:=1 to Length(Text) do
  begin
    if Text[i] = SubStr[HitPos] then
    begin
      if (HitPos = LenSub) then
      begin
        if q <= h then
        begin
          q := q+q;
          SetLength(Result, q);
        end;
        Result[h] := (i - HitPos) + 1;
        Inc(h);
        HitPos := 1;
      end else
        Inc(HitPos);
    end else
      HitPos := 1;
  end;
  SetLength(Result, h);
end;



{*
 Returns first position of the given pattern/substring from left.
*}
function StrPosL(const SubStr, Text: String): Integer;
var
  HitPos,LenSub,i: Integer;
begin
  LenSub := Length(SubStr);
  if LenSub = 0 then Exit(-1);
  HitPos := 1;
  for i:=1 to Length(Text) do
  begin
    if Text[i] = SubStr[HitPos] then
    begin
      if (HitPos = LenSub) then
        Exit((i - HitPos) + 1);
      Inc(HitPos);
    end else
      HitPos := 1;
  end;
  Exit(-1);
end;


{*
 Returns first position of the given pattern/substring from right.
*}
function StrPosR(const SubStr, Text: String): Integer;
var
  HitPos,LenSub,i: Integer;
begin
  LenSub := Length(SubStr);
  if LenSub = 0 then Exit(-1);
  HitPos := LenSub;
  for i:=Length(Text) downto 1 do
  begin
    if Text[i] = SubStr[HitPos] then
    begin
      if (HitPos = LenSub) then
        Exit((i - HitPos) + 1);
      Dec(HitPos);
    end else
      HitPos := LenSub;
  end;
  Exit(-1);
end;



{*
 Return a copy of string `Text` with all occurrences of `substr` replaced by `RepStr`.
*}
function StrReplace(const Text, SubStr, RepStr: String; Flags:TReplaceFlags): String;
var
  Hi,HiSub,HiRep,i,j,k: Integer;
  Prev,Curr:Integer;
  Subs: TIntArray;
begin
  Hi := Length(Text);
  if Hi = 0 then Exit;
  case (rfIgnoreCase in flags) of
    True: Subs := StrPosEx(LowerCase(SubStr), LowerCase(Text));
    False:Subs := StrPosEx(SubStr, Text);
  end;

  if Length(Subs) = 0 then
    Exit(Copy(Text, 1,Hi));

  HiRep := Length(RepStr);
  HiSub := Length(SubStr);

  SetLength(Result, Hi + (Length(Subs) * (HiRep-HiSub)));
  k := 1;
  Prev := 1;
  case (rfReplaceAll in Flags) of
  True:
    begin
      for i:=0 to High(Subs) do
      begin
        Curr := Subs[i];
        j := (Curr-Prev);
        Move(Text[Prev], Result[k], j);
        k := k + j;
        Move(RepStr[1], Result[k], HiRep);
        k := k+HiRep;
        Prev := Curr + HiSub;
      end;
      Move(Text[Prev], Result[k], Hi-Prev+1);
    end;
  False:
    begin
      Curr := Subs[0];
      j := (Curr-Prev);
      Move(Text[Prev], Result[k], j);
      k := k + j;
      Move(RepStr[1], Result[k], HiRep);
      k := k+HiRep;
      Prev := Curr + HiSub;
      Move(Text[Prev], Result[k], Hi-Prev+1);
      SetLength(Result, k+(Hi-Prev)+1);
    end;
  end;
end;



{*
 StrExplode lets you take a string and blow it up into smaller pieces, at each
 occurance of the given seperator `Sep`. 
*}
function StrExplode(const Text, Sep: String): TStrArray;
var
  Subs:TIntArray;
  Hi,i,Curr,Prev,HiSep: Integer;
begin
  Hi := Length(Text);
  if Hi = 0 then Exit;

  Subs := StrPosEx(Sep, Text);
  if Length(Subs) = 0 then
  begin
    SetLength(Result, 1);
    Result[0] := Copy(Text, 1,Hi);
    Exit;
  end;
  HiSep := Length(Sep);
  Prev := 1;
  SetLength(Result, Length(Subs));
  for i:=0 to High(Subs) do
  begin
    Curr := Subs[i];
    Result[i] := Copy(Text, Prev, (Curr-Prev));
    Prev := Curr+HiSep;
  end;
  if Prev <= Hi then
  begin
    SetLength(Result, Length(Subs)+1);
    Result[Length(Subs)] := Copy(Text, Prev, Hi);
  end;
end;

end.
