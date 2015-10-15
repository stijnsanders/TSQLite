unit SQLiteBatchMain;

interface

procedure PerformSQLBatch;

implementation

uses SysUtils, Windows, Classes, SQLiteData;

var
  qa,qf:int64;

procedure Log(const x:string);
var
  qb:int64;
  c:cardinal;
begin
  if qf=0 then qb:=GetTickCount else QueryPerformanceCounter(qb);
  if qf=0 then c:=cardinal(qb)-cardinal(qa) else c:=(qb-qa)*1000 div qf;
  WriteLn(Format('%.8d %s',[c,x]));
end;

procedure PerformSQLBatch;
var
  db:TSQLiteConnection;
  i,j:integer;
  fn,s:UTF8String;
  f:TFileStream;
  c:cardinal;
  st:TSQLiteStatement;
begin
  if not QueryPerformanceFrequency(qf) then qf:=0;
  if qf=0 then qa:=GetTickCount else QueryPerformanceCounter(qa);
  fn:=ParamStr(1);
  Log('Connecting to "'+fn+'"...');
  db:=TSQLiteConnection.Create(fn);
  try
    i:=2;
    while i<=ParamCount do
     begin
      fn:=ParamStr(i);
      Log('Performing "'+fn+'"...');

      f:=TFileStream.Create(fn,fmOpenRead or fmShareDenyWrite);
      try
        //TODO: support UTF-8, UTF-16
        c:=f.Size;
        SetLength(s,c);
        f.Read(s[1],c);
      finally
        f.Free;
      end;

      //s:=UTF8Encode(s);

      j:=0;
      while s<>'' do
       begin
        i:=1;
        st:=TSQLiteStatement.Create(db,s,i);
        try
          {
          t:='';
          for i:=0 to st.FieldCount-1 do
            t:=t+' '+st.FieldName[i];
          i:=0;
          while st.Read do inc(i);
          }
          WriteLn(Format('%d #%d',[j,i]));
          inc(j);
        finally
          st.Free;
        end;
        s:=Copy(s,i+1,Length(s)-i);
       end;
     end;
  finally
    db.Free;
  end;
end;

end.
