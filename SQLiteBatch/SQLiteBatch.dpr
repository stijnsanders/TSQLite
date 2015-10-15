program SQLiteBatch;

uses
  SysUtils,
  SQLiteBatchMain in 'SQLiteBatchMain.pas',
  SQLiteData in '..\SQLiteData.pas',
  SQLite in '..\SQLite.pas';

{$APPTYPE CONSOLE}
{$R *.res}

begin
  try
    if ParamCount<2 then
      WriteLn('Usage: SQLiteBatch <database> <script>')
    else
      PerformSQLBatch;
  except
    on e:Exception do
     begin
      WriteLn(ErrOutput,'###'+e.ClassName);
      WriteLn(ErrOutput,e.Message);
      ExitCode:=1;
     end;
  end;
end.
