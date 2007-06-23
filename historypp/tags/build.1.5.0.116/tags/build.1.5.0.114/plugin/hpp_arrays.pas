unit hpp_arrays;

interface

uses hpp_jclSysUtils, hpp_global;

function IntSortedArray_Add(var A: TIntArray; Value: Integer): Integer;
procedure IntSortedArray_Remove(var A: TIntArray; Value: Integer);
function IntSortedArray_Find(var A: TIntArray; Value: Integer): Integer;
procedure IntSortedArray_Sort(var A: TIntArray);
function IntSortedArray_NonIntersect(var A,B: TIntArray): TIntArray;

procedure IntArrayRemove(var A: TIntArray; Index: Integer);
procedure IntArrayInsert(var A: TIntArray; Index: Integer; Value: Integer);

implementation

procedure IntArrayRemove(var A: TIntArray; Index: Integer);
var
  i: Integer;
begin
  for i := Index to Length(A) - 2 do
    A[i] := A[i+1];
  SetLength(A,Length(A)-1);
end;

procedure IntArrayInsert(var A: TIntArray; Index: Integer; Value: Integer);
var
  i: Integer;
begin
  SetLength(A,Length(A)+1);
  for i := Length(A)-1 downto Index do
    A[i] := A[i-1];
  A[Index] := Value;
end;

function IntSortedArray_Add(var A: TIntArray; Value: Integer): Integer;
begin
  Result := SearchDynArray(A,SizeOf(Integer),DynArrayCompareInteger,@Value,True);
  if Result <> -1 then begin // we have nearest or match
    if A[Result] = Value then exit;
    if A[Result] < Value then
      Inc(Result);
  end
  else // we don't have any nearest values, array is empty
    Result := 0;
  IntArrayInsert(A,Result,Value);
end;

procedure IntSortedArray_Remove(var A: TIntArray; Value: Integer);
var
  idx: Integer;
begin
  idx := SearchDynArray(A,SizeOf(Integer),DynArrayCompareInteger,@Value);
  if idx = -1 then exit;
  IntArrayRemove(A,idx);
end;

function IntSortedArray_Find(var A: TIntArray; Value: Integer): Integer;
begin
  Result := SearchDynArray(A,SizeOf(Integer),DynArrayCompareInteger,@Value);
end;

procedure IntSortedArray_Sort(var A: TIntArray);
begin
  SortDynArray(A,SizeOf(Integer),DynArrayCompareInteger);
end;

function IntSortedArray_NonIntersect(var A,B: TIntArray): TIntArray;
var
  ia,ib: Integer;
  lenr,lena,lenb: Integer;

  procedure AddToResult(Item: Integer);
  begin
    Inc(lenr);
    SetLength(Result,lenr);
    Result[lenr-1] := Item;
  end;
begin
  SetLength(Result,0);
  lenr := 0;
  lena := Length(A);
  lenb := Length(B);
  ib := 0;
  ia := 0;
  
  while ia < lena do begin

    if ib >= lenb then begin
      AddToResult(A[ia]);
      Inc(ia);
      continue;
    end;

    if A[ia] = B[ib] then begin
      Inc(ib);
      Inc(ia);
      continue;
    end;

    if A[ia] > B[ib] then begin
      while A[ia] > B[ib] do begin
        AddToResult(B[ib]);
        Inc(ib);
        if ib >= lenb then break;
      end;
    continue;
    end;

    if A[ia] < B[ib] then begin
      AddToResult(A[ia]);
      Inc(ia);
      continue;
    end;

  end;

  while ib < lenb do begin
    AddToResult(B[ib]);
    Inc(ib);
    end;
end;


end.
