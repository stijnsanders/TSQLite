unit SQLiteBatchMain;

interface

procedure ShowUsage;
procedure PerformSQLBatch;

implementation

uses SysUtils, Windows, Classes, SQLite, SQLiteData;

var
  qa,qf:int64;

procedure Log(const x:string);
var
  qb:int64;
  c:cardinal;
begin
  if qf=0 then qb:=GetTickCount else QueryPerformanceCounter(qb);
  if qf=0 then c:=cardinal(qb)-cardinal(qa) else c:=(qb-qa)*1000 div qf;
  WriteLn(Format('%8dms %s',[c,x]));
end;

procedure ShowUsage;
begin
  WriteLn('Usage: SQLiteBatch <database> [-<switches] <script>');
  WriteLn('Switches:');
  WriteLn('    -T  encapsulate in a transaction');
  WriteLn('    -X  only perform when database file exists');
  WriteLn('    -N  only perform when database file doesn''t exist');
  WriteLn('    -I  ignore errors, skip to next ";"');
end;

procedure PerformSQLBatch;
var
  db:TSQLiteConnection;
  px,i,j,k,l,r:integer;
  fn,s:UTF8String;
  f:TFileStream;
  c:cardinal;
  st:TSQLiteStatement;
  fExisted,fTrans,fSkip:boolean;
  fCrit:integer;
begin
  if not QueryPerformanceFrequency(qf) then qf:=0;
  if qf=0 then qa:=GetTickCount else QueryPerformanceCounter(qa);

  //defaults
  fCrit:=0;
  fTrans:=false;
  fSkip:=false;

  fn:=ParamStr(1);
  fExisted:=FileExists(fn);
  Log('Connecting to "'+fn+'"...');
  db:=TSQLiteConnection.Create(fn);
  try
    px:=2;
    while px<=ParamCount do
     begin
      fn:=ParamStr(px);
      inc(px);
      if (fn<>'') and (fn[1] in ['-','/']) then
       begin
        l:=Length(fn);
        i:=2;
        while i<=l do
         begin
          case fn[i] of
            'T','t':fTrans:=true;
            'N','n':fCrit:=1;//only when not fExisted
            'X','x':fCrit:=2;//only when fExisted
            'I','i':fSkip:=true;
            else Log('Unknown switch "'+fn[i]+'"');
          end;
          inc(i);
         end;
       end
      else
       begin
        case fCrit of
          0:;//normal run
          1: //N: only if not existed
            if fExisted then
             begin
              Log('Skipping "'+fn+'", database file exists');
              fn:='';
             end;
          2://X: only if existed
            if not fExisted then
             begin
              Log('Skipping "'+fn+'", database file doesn''t exists');
              fn:='';
             end;
          //else raise?
        end;
        if fn<>'' then
         begin
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
          //TODO: detect+ignore closing whitespace on trailing ';'

          if fTrans then db.Execute('BEGIN TRANSACTION');
          try

            j:=0;
            k:=0;
            while s<>'' do
             begin
              l:=Length(s);
              try
                i:=1;
                st:=TSQLiteStatement.Create(db,s,i);
                try
                  while (i<l) and (s[i+1]<=' ') do inc(i);
                  {
                  t:='';
                  for i:=0 to st.FieldCount-1 do
                    t:=t+' '+st.FieldName[i];
                  i:=0;
                  }
                  //TODO: count EOL's for line indicator?
                  if st.Read then r:=1 else r:=0;
                  //while st.Read do inc(l);?
                finally
                  st.Free;
                end;
                Log(Format('%8d #%8d/%d :%d',[j,k,c,r]));
              except
                on e:Exception do
                  if fSkip then
                   begin
                    Log(Format('%8d #%8d/%d !!!',[j,k,c]));
                    WriteLn(ErrOutput,'###'+e.ClassName);
                    WriteLn(ErrOutput,e.Message);
                    //ExitCode:=?

                    //sqlite3_prepare_v2 doesn't update Tail on error
                    //advance ourselves to next ";":
                    while (i<=l) and (s[i]<>';') do
                      if s[i]='''' then
                       begin
                        inc(i);
                        while (i<=l) and (s[i]<>'''') do inc(i);
                       end
                      else
                        inc(i);
                    if (i<=l) then inc(i);
                    while (i<l) and (s[i+1]<=' ') do inc(i);
                   end
                  else
                    raise;
              end;
              s:=Copy(s,i+1,l-i);
              inc(j);
              inc(k,i);
             end;

            if fTrans then db.Execute('COMMIT TRANSACTION');
          except
            if fTrans then db.Execute('ROLLBACK TRANSACTION');
            raise;
          end;

         end;
       end;
     end;
  finally
    db.Free;
  end;
end;

end.
