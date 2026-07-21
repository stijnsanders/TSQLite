unit ISQLiteData;
interface
uses SQLite;

type
   ISQLiteStatement = interface;
   ISQLiteConnection = interface;

   /// <summary>
   ///   call TSQLite.Connect to create a new ISQLiteConnection instance
   /// </summary>

   TSQLite = class
   public
      type TAccessMode = (saReadonly, saReadWrite);
      class function Connect(const FileName:UTF8String;AccessMode:TAccessMode):ISQLiteConnection;
   end;

   /// <summary>
   /// ISQLiteConnection is reference-counted version of TSqliteConnection: it gets deallocated automatically
   /// when the reference count gets to zero. <br>
   /// Call Prepare() methods to instantiate a new ISQLiteStatement
   /// </summary>
   ISQLiteConnection = interface
      ['{A6FF0C88-6BA5-41A4-BBED-E78341F21266}']
      function GetBusyTimeout:integer;
      procedure SetBusyTimeout(value:integer);

      function Execute(const SQL:UTF8String):integer; overload;
      function Execute(const SQL:UTF8String;const Parameters:array of OleVariant):integer; overload;
      function Insert(const TableName:UTF8String;const Values:array of OleVariant):int64;
      procedure Update(const TableName:UTF8String;const Values:array of OleVariant);
      function Exists(const SQL:UTF8String):boolean; overload;
      function Exists(const SQL:UTF8String;const Parameters:array of OleVariant):boolean; overload;
      procedure BeginTrans;
      procedure CommitTrans;
      procedure RollbackTrans;
      function Handle:HSQLiteDB;
      property BusyTimeout:integer read GetBusyTimeout write SetBusyTimeout;
      function LastInsertRowID:int64;
      function Changes:integer;

      function Prepare(const SQL:UTF8String):ISqliteStatement; overload;
      function Prepare(const SQL:UTF8String;var NextIndex:integer):ISqliteStatement;  overload;
      function Prepare(const SQL:UTF8String;const Parameters:array of OleVariant):ISqliteStatement;  overload;
   end;

   /// <summary>
   ///  Reference counted version of TSqliteStatement.
   /// </summary>
   ISQLiteStatement = interface
      ['{BF9913EE-ADD1-47A3-961A-404E89DEC1B0}']
      // property accessors
      function GetField(const Idx:OleVariant):OleVariant;
      function GetFieldName(Idx:integer):WideString;
      function GetParameter(const Idx:OleVariant):OleVariant;
      procedure SetParameter(const Idx:OleVariant;value:OleVariant);
      function GetParameterName(Idx:integer):WideString;

      //
      function Connection:ISqliteConnection;
      procedure ExecSQL;
      function Read:boolean;
      procedure Reset;
      function Handle:HSQLiteStatement;
      property Field[const Idx:OleVariant]:OleVariant read GetField; default;
      property FieldName[Idx:integer]:WideString read GetFieldName;
      function FieldCount:integer;
      property Parameter[const Idx:OleVariant]:OleVariant read GetParameter write SetParameter;
      property ParameterName[Idx:integer]:WideString read GetParameterName;
      function ParameterCount:integer;
      function Eof:boolean;
      function GetInt(const Idx:OleVariant):integer;
      function GetInt64(const Idx:OleVariant):int64;
      function GetStr(const Idx:OleVariant):WideString;
      function GetDate(const Idx:OleVariant):TDateTime;
      function GetDefault(const Idx,Default:OleVariant):OleVariant;
      function IsNull(const Idx:OleVariant):boolean;
   end;



implementation
uses System.Classes,
     System.SysUtils,
     SqliteData;

{$REGION 'Interface Implementing classes declaration'}

type
   TReferenceCountedStatement = class;
   TReferenceCountedConnection = class(TInterfacedObject,ISQLiteConnection)
   strict private
     FConnection :TSQLiteConnection;
   public
      function GetBusyTimeout:integer;
      procedure SetBusyTimeout(value:integer);

      function Execute(const SQL:UTF8String):integer; overload;
      function Execute(const SQL:UTF8String;const Parameters:array of OleVariant):integer; overload;
      function Insert(const TableName:UTF8String;const Values:array of OleVariant):int64;
      procedure Update(const TableName:UTF8String;const Values:array of OleVariant);
      function Exists(const SQL:UTF8String):boolean; overload;
      function Exists(const SQL:UTF8String;const Parameters:array of OleVariant):boolean; overload;
      procedure BeginTrans;
      procedure CommitTrans;
      procedure RollbackTrans;
      function Handle:HSQLiteDB;
      property BusyTimeout:integer read GetBusyTimeout write SetBusyTimeout;
      function LastInsertRowID:int64;
      function Changes:integer;

      function Prepare(const SQL:UTF8String):ISqliteStatement; overload;
      function Prepare(const SQL:UTF8String;var NextIndex:integer):ISqliteStatement;  overload;
      function Prepare(const SQL:UTF8String;const Parameters:array of OleVariant):ISqliteStatement;  overload;


      constructor Create(const FileName:UTF8String);
      constructor CreateReadOnly(const FileName:UTF8String);
      destructor Destroy; override;
   end;



   TReferenceCountedStatement = class(TInterfacedObject,ISqliteStatement)
   strict private
     FConnection:ISQLiteConnection; // this keeps the connection alive when there are still some statements around
     FStatement:TSQLiteStatement;
   public
     constructor Create(AConnection:ISqliteConnection;AStatement:TSqliteStatement);
     destructor Destroy; override;
     function GetField(const Idx:OleVariant):OleVariant;
     function GetFieldName(Idx:integer):WideString;
     function GetParameter(const Idx:OleVariant):OleVariant;
     procedure SetParameter(const Idx:OleVariant;value:OleVariant);
     function GetParameterName(Idx:integer):WideString;
     function Connection:ISqliteConnection;
     procedure ExecSQL;
     function Read:boolean;
     procedure Reset;
     function Handle:HSQLiteStatement;
     function FieldCount:integer;
     function ParameterCount:integer;
     function Eof:boolean;
     function GetInt(const Idx:OleVariant):integer;
     function GetInt64(const Idx:OleVariant):int64;
     function GetStr(const Idx:OleVariant):WideString;
     function GetDate(const Idx:OleVariant):TDateTime;
     function GetDefault(const Idx,Default:OleVariant):OleVariant;
     function IsNull(const Idx:OleVariant):boolean;
   end;

{$ENDREGION}


{$REGION 'TSQLite Implementation'}

class function TSQLite.Connect(const FileName:UTF8String;AccessMode:TAccessMode):ISQLiteConnection;
begin
   if AccessMode = TAccessMode.saReadWrite then
     result := TReferenceCountedConnection.Create(FileName)
   else
     result := TReferenceCountedConnection.CreateReadOnly(FileName);
end;

{$ENDREGION}

{$REGION 'TReferenceCountedConnection Implementation'}
function TReferenceCountedConnection.GetBusyTimeout:integer;
begin
  result := FConnection.BusyTimeout;
end;

procedure TReferenceCountedConnection.SetBusyTimeout(value:integer);
begin
  FConnection.BusyTimeout := value;
end;

function TReferenceCountedConnection.Execute(const SQL:UTF8String):integer;
begin
  result := FConnection.Execute(SQL);
end;

function TReferenceCountedConnection.Execute(const SQL:UTF8String;const Parameters:array of OleVariant):integer;
begin
  result := FConnection.Execute(SQL,Parameters);
end;

function TReferenceCountedConnection.Insert(const TableName:UTF8String;const Values:array of OleVariant):int64;
begin
  result := FConnection.Insert(TableName,Values);
end;

procedure TReferenceCountedConnection.Update(const TableName:UTF8String;const Values:array of OleVariant);
begin
 FConnection.Update(TableName,Values);
end;

function TReferenceCountedConnection.Exists(const SQL:UTF8String):boolean;
begin
  result := FConnection.Exists(SQL);
end;

function TReferenceCountedConnection.Exists(const SQL:UTF8String;const Parameters:array of OleVariant):boolean;
begin
  result := FConnection.Exists(SQL,Parameters);
end;

procedure TReferenceCountedConnection.BeginTrans;
begin
  FConnection.BeginTrans;
end;

procedure TReferenceCountedConnection.CommitTrans;
begin
  FConnection.CommitTrans;
end;

procedure TReferenceCountedConnection.RollbackTrans;
begin
  FConnection.RollbackTrans;
end;


function TReferenceCountedConnection.Handle:HSQLiteDB;
begin
  result := FConnection.Handle;
end;

function TReferenceCountedConnection.LastInsertRowID:int64;
begin
  result := FConnection.LastInsertRowID
end;

function TReferenceCountedConnection.Changes:integer;
begin
  result := FConnection.Changes
end;


function TReferenceCountedConnection.Prepare(const SQL:UTF8String):ISqliteStatement;
var stmt:TSQLiteStatement;
begin
    stmt:= TSQLiteStatement.Create(FConnection,sql);
    try
      result := TReferenceCountedStatement.Create(self,stmt);
    except
      stmt.Free;
      raise;
    end;
end;

function TReferenceCountedConnection.Prepare(const SQL:UTF8String;var NextIndex:integer):ISqliteStatement;
var stmt:TSQLiteStatement;
begin
    stmt:= TSQLiteStatement.Create(FConnection,sql,NextIndex);
    try
      result := TReferenceCountedStatement.Create(self,stmt);
    except
      stmt.Free;
      raise;
    end;
end;

function TReferenceCountedConnection.Prepare(const SQL:UTF8String;const Parameters:array of OleVariant):ISqliteStatement;
var stmt:TSQLiteStatement;
begin
    stmt:= TSQLiteStatement.Create(FConnection,sql,Parameters);
    try
      result := TReferenceCountedStatement.Create(self,stmt);
    except
      stmt.Free;
      raise;
    end;
end;


constructor TReferenceCountedConnection.Create(const FileName: UTF8String);
begin
   inherited Create;
   FConnection := TSqliteConnection.Create(FileName);
end;

constructor TReferenceCountedConnection.CreateReadOnly(const FileName: UTF8String);
begin
   inherited Create;
   FConnection := TSqliteConnection.CreateReadOnly(FileName);
end;

destructor TReferenceCountedConnection.Destroy;
begin
  FreeAndNil(FConnection);
  inherited;
end;
{$ENDREGION}


{$REGION 'TReferenceCountedStatement implementation'}

constructor TReferenceCountedStatement.Create(AConnection:ISqliteConnection;Astatement:TSqliteStatement);
begin
  inherited Create;
  FConnection := AConnection;
  FStatement := AStatement;
end;

destructor TReferenceCountedStatement.Destroy;
begin
  FreeAndNil(FStatement);
  FConnection := nil;
  inherited;
end;

function TReferenceCountedStatement.Connection:ISqliteConnection;
begin
   result := FConnection;
end;


function TReferenceCountedStatement.GetField(const Idx:OleVariant):OleVariant;
begin
   result := FStatement.Field[idx];
end;

function TReferenceCountedStatement.GetFieldName(Idx:integer):WideString;
begin
   result := FStatement.FieldName[Idx]
end;

function TReferenceCountedStatement.GetParameter(const Idx:OleVariant):OleVariant;
begin
   result := FStatement.Parameter[Idx]
end;

procedure TReferenceCountedStatement.SetParameter(const Idx:OleVariant;value:OleVariant);
begin
  FStatement.Parameter[Idx] := value;
end;

function TReferenceCountedStatement.GetParameterName(Idx:integer):WideString;
begin
   result := FStatement.ParameterName[Idx];
end;

procedure TReferenceCountedStatement.ExecSQL;
begin
   FStatement.ExecSQL;
end;

function TReferenceCountedStatement.Read:boolean;
begin
   result := FStatement.Read;
end;

procedure TReferenceCountedStatement.Reset;
begin
  FStatement.Reset;
end;

function TReferenceCountedStatement.Handle:HSQLiteStatement;
begin
   result := FStatement.Handle;
end;

function TReferenceCountedStatement.FieldCount:integer;
begin
   result := FStatement.FieldCount;
end;

function TReferenceCountedStatement.ParameterCount:integer;
begin
   result := FStatement.ParameterCount;
end;

function TReferenceCountedStatement.Eof:boolean;
begin
   result := FStatement.Eof;
end;

function TReferenceCountedStatement.GetInt(const Idx:OleVariant):integer;
begin
   result := FStatement.GetInt(Idx);
end;

function TReferenceCountedStatement.GetInt64(const Idx:OleVariant):int64;
begin
   result := FStatement.GetInt64(Idx);
end;

function TReferenceCountedStatement.GetStr(const Idx:OleVariant):WideString;
begin
   result := FStatement.GetStr(Idx);
end;

function TReferenceCountedStatement.GetDate(const Idx:OleVariant):TDateTime;
begin
   result := FStatement.GetDate(Idx);
end;

function TReferenceCountedStatement.GetDefault(const Idx,Default:OleVariant):OleVariant;
begin
   result := FStatement.GetDefault(Idx,Default);
end;

function TReferenceCountedStatement.IsNull(const Idx:OleVariant):boolean;
begin
   result := FStatement.IsNull(Idx);
end;

{$ENDREGION}

end.
