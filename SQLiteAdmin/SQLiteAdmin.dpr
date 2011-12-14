program SQLiteAdmin;

uses
  Forms,
  SQLiteAdminMain in 'SQLiteAdminMain.pas' {formSQLiteAdminMain},
  SQLiteData in '..\SQLiteData.pas',
  SQLite in '..\SQLite.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'SQLite Administrator';
  Application.CreateForm(TformSQLiteAdminMain, formSQLiteAdminMain);
  Application.Run;
end.
