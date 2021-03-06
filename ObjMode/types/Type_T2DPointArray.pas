{!DOCTOPIC}{ 
  Type � T2DPointArray
}


{!DOCREF} {
  @method: function T2DPointArray.Len(): Int32;
  @desc: Returns the length of the ATPA. Same as c'Length(ATPA)'
}
function T2DPointArray.Len(): Int32;
begin
  Result := Length(Self);
end;


{!DOCREF} {
  @method: function T2DPointArray.IsEmpty(): Boolean;
  @desc: Returns True if the ATPA is empty. Same as c'Length(ATPA) = 0'
}
function T2DPointArray.IsEmpty(): Boolean;
begin
  Result := Length(Self) = 0;
end;


{!DOCREF} {
  @method: procedure T2DPointArray.Append(const TPA:TPointArray);
  @desc: Add another TPA to the ATPA
}
procedure T2DPointArray.Append(const TPA:TPointArray);
var
  l:Int32;
begin
  l := Length(Self);
  SetLength(Self, l+1);
  Self[l] := TPA;
end;


{!DOCREF} {
  @method: procedure T2DPointArray.Insert(idx:Int32; Value:TPointArray);
  @desc: 
    Inserts a new item `value` in the array at the given position. If position `idx` is greater then the length, 
    it will append the item `value` to the end. If it's less then 0 it will substract the index from the length of the array.[br]
    
    `Arr.Insert(0, x)` inserts at the front of the list, and `Arr.Insert(length(a), x)` is equivalent to `Arr.Append(x)`.
}
procedure T2DPointArray.Insert(idx:Int32; Value:TPointArray);
var i,l:Int32;
begin
  l := Length(Self);
  if (idx < 0) then
    idx := math.modulo(idx,l);

  if (l <= idx) then begin
    self.append(value);
    Exit();
  end;

  SetLength(Self, l+1);
  for i:=l downto idx+1 do
    Self[i] := Self[i-1];
  Self[i] := Value;
end;


{!DOCREF} {
  @method: function T2DPointArray.Pop(): TPointArray;
  @desc: Removes and returns the last item in the array
}
function T2DPointArray.Pop(): TPointArray;
var
  H:Int32;
begin
  H := high(Self);
  Result := Self[H];
  SetLength(Self, H);
end;


{!DOCREF} {
  @method: function T2DPointArray.PopLeft(): TPointArray;
  @desc: Removes and returns the first item in the array
}
function T2DPointArray.PopLeft(): TPointArray;
begin
  Result := Self[0];
  Self := Self.Slice(1,-1);
end;


{!DOCREF} {
  @method: function T2DPointArray.Slice(Start,Stop: Int32; Step:Int32=1): T2DPointArray;
  @desc:
    Slicing similar to slice in Python, tho goes from 'start to and including stop'
    Can be used to eg reverse an array, and at the same time allows you to c'step' past items.
    You can give it negative start, and stop, then it will wrap around based on length(..)
    
    If c'Start >= Stop', and c'Step <= -1' it will result in reversed output.
    
    [note]Don't pass positive c'Step', combined with c'Start > Stop', that is undefined[/note]
}
function T2DPointArray.Slice(Start:Int64=DefVar64; Stop: Int64=DefVar64; Step:Int64=1): T2DPointArray;
begin
  if (Start = DefVar64) then
    if Step < 0 then Start := -1
    else Start := 0;       
  if (Stop = DefVar64) then 
    if Step > 0 then Stop := -1
    else Stop := 0;
  
  if Step = 0 then Exit;
  try Result := exp_slice(Self, Start,Stop,Step);
  except SetLength(Result,0) end;
end;


{!DOCREF} {
  @method: procedure T2DPointArray.Extend(Arr:T2DPointArray);
  @desc: Extends the 2d-array with a 2d-array
}
procedure T2DPointArray.Extend(Arr:T2DPointArray);
var L,i:Int32;
begin
  L := Length(Self);
  SetLength(Self, Length(Arr) + L);
  for i:=L to High(Self) do
  begin
    SetLength(Self[i],Length(Arr[i-L]));
    MemMove(Arr[i-L][0], Self[i][0], Length(Arr[i-L])*SizeOf(TPoint));
  end;
end;  


{!DOCREF} {
  @method: function T2DPointArray.Merge(): TPointArray;
  @desc: Merges all the groups in the ATPA, and return the TPA
}
function T2DPointArray.Merge(): TPointArray; {$IFDEF SRL6}override;{$ENDIF}
begin
  Result := MergeATPA(Self);
end;


{!DOCREF} {
  @method: function T2DPointArray.Sorted(Key:TSortKey=sort_Default): T2DPointArray;
  @desc: 
    Sorts a copy of the ATPA with the given key, returns a copy
    Supported keys: c'sort_Default, sort_Length, sort_Mean, sort_First'
}
function T2DPointArray.Sorted(Key:TSortKey=sort_Default): T2DPointArray;
begin
  Result := Self.Slice();
  case Key of
    sort_Default, sort_Length: se.SortATPAByLength(Result);
    sort_Mean: se.SortATPAByMean(Result);
    sort_First: se.SortATPAByFirst(Result);
  else
    WriteLn('TSortKey not supported');
  end;
end;


{!DOCREF} {
  @method: function T2DPointArray.Sorted(Index:Integer): T2DPointArray; overload;
  @desc: Sorts a copy of the ATPA by the given index in each group
}
function T2DPointArray.Sorted(Index:Integer): T2DPointArray; overload;
begin
  Result := Self.Slice();
  se.SortATPAByIndex(Result, Index);
end;


{!DOCREF} {
  @method: procedure T2DPointArray.Sort(Key:TSortKey=sort_Default);
  @desc: 
    Sorts the ATPA with the given key, returns a copy
    Supported keys: c'sort_Default, sort_Length, sort_Mean, sort_First'
}
procedure T2DPointArray.Sort(Key:TSortKey=sort_Default);
begin
  case Key of
    sort_Default, sort_Length: se.SortATPAByLength(Self);
    sort_Mean: se.SortATPAByMean(Self);
    sort_First: se.SortATPAByFirst(Self);
  else
    WriteLn('TSortKey not supported');
  end;
end;


{!DOCREF} {
  @method: procedure T2DPointArray.Sort(Index:Integer); overload;
  @desc: 
    Sorts the ATPA by the given index in each group. If the group is not that large it will be set to the last item in that group.
    Negative 'index' will result in counting from right to left: High(Arr[i]) - index
  
}
procedure T2DPointArray.Sort(Index:Integer); overload;
begin
  se.SortATPAByIndex(Self, Index);
end;



{!DOCREF} {
  @method: function T2DPointArray.Reversed(): T2DPointArray;
  @desc:  
    Creates a reversed copy of the array
}
function T2DPointArray.Reversed(): T2DPointArray;
begin
  Result := Self.Slice(,,-1);
end;


{!DOCREF} {
  @method: procedure T2DPointArray.Reverse();
  @desc:  
    Reverses the array  
}
procedure T2DPointArray.Reverse();
begin
  Self := Self.Slice(,,-1);
end;





{=============================================================================}
// The functions below this line is not in the standard array functionality
//
// By "standard array functionality" I mean, functions that all standard
// array types should have.
{=============================================================================}




