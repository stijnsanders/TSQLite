unit SQLiteData;

interface

uses SysUtils, SQLite;

type
  TSQLiteConnection=class(TObject)
  private
    FHandle:HSQLiteDB;
    function GetLastInsertRowID:int64;
  public
    constructor Create(FileName:UTF8String);
    destructor Destroy; override;
    procedure Execute(SQL:UTF8String); overload;
    function Execute(SQL:UTF8String;Parameters:array of OleVariant):boolean; overload;
    procedure Execute(SQL:UTF8String;Parameters:array of OleVariant;var LastInsertRowID:integer); overload;
    property Handle:HSQLiteDB read FHandle;
    property LastInsertRowID:int64 read GetLastInsertRowID;
  end;

  TSQLiteStatement=class(TObject)
  private
    FDB:HSQLiteDB;
    FHandle:HSQLiteStatement;
    FEOF,FGotColumnNames,FGotParamNames,FFirstStep:boolean;
    FColumnNames,FParamNames:array of WideString;
    function GetField(Idx:OleVariant):OleVariant;
    function GetFieldName(Idx:integer):WideString;
    function GetFieldCount:integer;
    function GetColumnIdx(Idx:OleVariant):integer;
    procedure GetColumnNames;
    procedure GetParamNames;
    function GetParameter(Idx: OleVariant): OleVariant;
    procedure SetParameter(Idx: OleVariant; Value: OleVariant);
    function GetParameterCount: integer;
    function GetParameterName(Idx: integer): WideString;
  public
    constructor Create(Connection:TSQLiteConnection;SQL:UTF8String); overload;
    constructor Create(Connection:TSQLiteConnection;SQL:UTF8String;Parameters:array of OleVariant); overload;
    destructor Destroy; override;
    procedure ExecSQL;
    function Read:boolean;//Next?
    procedure Reset;
    property Handle:HSQLiteStatement read FHandle;
    property Field[Idx:OleVariant]:OleVariant read GetField; default;
    property FieldName[Idx:integer]:WideString read GetFieldName;
    property FieldCount:integer read GetFieldCount;
    property Parameter[Idx:OleVariant]:OleVariant read GetParameter write SetParameter;
    property ParameterName[Idx:integer]:WideString read GetParameterName;
    property ParameterCount:integer read GetParameterCount;
    property Eof:boolean read FEOF;
    function GetInt(Idx:OleVariant):integer;
    function GetStr(Idx:OleVariant):WideString;
    function GetDate(Idx:OleVariant):TDateTime;
    function IsNull(Idx:OleVariant):boolean;
  end;

  ESQLiteDataException=class(Exception);

implementation

uses Variants;

{ TSQLiteConnection }

constructor TSQLiteConnection.Create(FileName: UTF8String);
begin
  inherited Create;
  sqlite3_check(sqlite3_open(PAnsiChar(FileName),FHandle));
end;

destructor TSQLiteConnection.Destroy;
begin
  {sqlite3_check}(sqlite3_close(FHandle));
  inherited;
end;

procedure TSQLiteConnection.Execute(SQL: UTF8String);
var
  e:PAnsiChar;
  s:string;
begin
  sqlite3_exec(FHandle,PAnsiChar(SQL),nil,nil,e);
  if e<>nil then
   begin
    s:=Utf8ToAnsi(e);
    sqlite3_free(e);
    raise ESQLiteDataException.Create(s);//TODO: prefix?
   end;
end;

function TSQLiteConnection.Execute(SQL: UTF8String;
  Parameters: array of OleVariant):boolean;
var
  st:TSQLiteStatement;
begin
  st:=TSQLiteStatement.Create(Self,SQL,Parameters);
  try
    //TODO: next statement!!! and keep track of sqlite3_bind_parameter_count
    Result:=st.Read;
  finally
    st.Free;
  end;
end;

procedure TSQLiteConnection.Execute(SQL: UTF8String;
  Parameters: array of OleVariant; var LastInsertRowID: integer);
var
  st:TSQLiteStatement;
begin
  st:=TSQLiteStatement.Create(Self,SQL,Parameters);
  try
    //TODO: next statement!!! and keep track of sqlite3_bind_parameter_count
    st.Read;
  finally
    st.Free;
  end;
  LastInsertRowID:=sqlite3_last_insert_rowid(FHandle);
end;

function TSQLiteConnection.GetLastInsertRowID: int64;
begin
  Result:=sqlite3_last_insert_rowid(FHandle);
end;

{ TSQLiteStatement }

constructor TSQLiteStatement.Create(Connection: TSQLiteConnection;
  SQL: UTF8String);
begin
  inherited Create;
  sqlite3_prepare_v2(Connection.Handle,PAnsiChar(SQL),Length(SQL)+1,FHandle,PAnsiChar(nil^));
  //TODO: tail!
  //TODO: keep a copy of Connection.Handle for sqlite3_check
  FDB:=Connection.Handle;
  FEOF:=sqlite3_data_count(FHandle)<>0;
  FGotColumnNames:=false;
  FGotParamNames:=false;
  FFirstStep:=false;
end;

constructor TSQLiteStatement.Create(Connection: TSQLiteConnection;
  SQL: UTF8String; Parameters: array of OleVariant);
var
  i:integer;
begin
  inherited Create;
  sqlite3_prepare_v2(Connection.Handle,PAnsiChar(SQL),Length(SQL)+1,FHandle,PAnsiChar(nil^));
  //TODO: tail!
  //TODO: keep a copy of Connection.Handle for sqlite3_check
  FDB:=Connection.Handle;
  FEOF:=sqlite3_data_count(FHandle)<>0;
  FGotColumnNames:=false;
  FGotParamNames:=false;
  for i:=0 to Length(Parameters)-1 do SetParameter(i+1,Parameters[i]);
end;

destructor TSQLiteStatement.Destroy;
begin
  {sqlite3_check}(sqlite3_finalize(FHandle));
  inherited;
end;

procedure TSQLiteStatement.GetColumnNames;
var
  i,l:integer;
begin
  if not FGotColumnNames then
   begin
    l:=sqlite3_column_count(FHandle);
    SetLength(FColumnNames,l);
    for i:=0 to l-1 do FColumnNames[i]:=sqlite3_column_name16(FHandle,i);
    FGotColumnNames:=true;
   end;
end;

function TSQLiteStatement.GetColumnIdx(Idx: OleVariant): integer;
var
  l:integer;
  s:WideString;
begin
  l:=sqlite3_column_count(FHandle);
  if VarIsNumeric(Idx) then Result:=Idx else
   begin
    GetColumnNames;
    Result:=0;
    s:=VarToWideStr(Idx);
    while (Result<l) and (WideCompareText(s,FColumnNames[Result])<>0) do inc(Result);
   end;
  if (Result<0) or (Result>=l) then
    raise ESQLiteDataException.Create('Invalid column index "'+VarToStr(Idx)+'"');
end;

function TSQLiteStatement.GetField(Idx: OleVariant): OleVariant;
var
  i,l:integer;
  p:pointer;
begin
  if not FEOF and not FFirstStep then Read;
  i:=GetColumnIdx(Idx);
  //TODO: use HSQLiteValue?
  case sqlite3_column_type(FHandle,i) of
    SQLITE_INTEGER:Result:=sqlite3_column_int(FHandle,i);
    SQLITE_FLOAT:Result:=sqlite3_column_double(FHandle,i);
    SQLITE_TEXT:Result:=WideString(sqlite3_column_text16(FHandle,i));
    SQLITE_BLOB:
     begin
      l:=sqlite3_column_bytes(FHandle,i);
      if l=0 then Result:=Null else
       begin
        Result:=VarArrayCreate([0,l-1],varByte);
        p:=VarArrayLock(Result);
        try
          Move(sqlite3_column_blob(FHandle,i)^,p^,l);
        finally
          VarArrayUnlock(Result);
        end;
       end;
     end;
    SQLITE_NULL:Result:=Null;
    //TODO: detect rowid alias column (primary keu)
    else
      Result:=EmptyParam;//??
  end;
end;

function TSQLiteStatement.GetFieldCount: integer;
begin
  Result:=sqlite3_column_count(FHandle);
end;

function TSQLiteStatement.GetFieldName(Idx: integer): WideString;
begin
  GetColumnNames;
  if (Idx<0) or (Idx>=Length(FColumnNames)) then
    raise ESQLiteDataException.Create('Invalid column index "'+IntToStr(Idx)+'"');
  Result:=FColumnNames[Idx];
end;

procedure TSQLiteStatement.GetParamNames;
var
  i,l:integer;
begin
  if not FGotParamNames then
   begin
    l:=sqlite3_bind_parameter_count(FHandle);
    SetLength(FParamNames,l);
    for i:=0 to l-1 do FParamNames[i]:=UTF8Decode(sqlite3_bind_parameter_name(FHandle,i+1));
    FGotParamNames:=true;
   end;
end;

function TSQLiteStatement.GetParameter(Idx: OleVariant): OleVariant;
begin
  raise ESQLiteDataException.Create('Get parameter value not supported');
end;

procedure TSQLiteStatement.SetParameter(Idx: OleVariant; Value: OleVariant);
var
  i,j,l:integer;
  s:WideString;
  vt:TVarType;
  p:pointer;
begin
  l:=sqlite3_bind_parameter_count(FHandle);
  if VarIsNumeric(Idx) then i:=Idx else
   begin
    GetParamNames;
    i:=0;
    s:=VarToWideStr(Idx);
    while (i<l) and (WideCompareText(s,FParamNames[i])<>0) do inc(i);
    inc(i);
   end;
  if (i<1) or (i>l) then
    raise ESQLiteDataException.Create('Invalid parameter index "'+VarToStr(Idx)+'"');
  vt:=VarType(Value);
  if (vt and varArray)<>0 then
    case vt and varTypeMask of
      //TODO: support other array element types!
      varByte:
       begin
        l:=1;
        for j:=1 to VarArrayDimCount(Value) do
          l:=l*(VarArrayHighBound(Value,j)-VarArrayLowBound(Value,j));
        p:=VarArrayLock(Value);
        try
          sqlite3_bind_blob(FHandle,i,p^,l,nil);
        finally
          VarArrayUnlock(Value);
        end;
       end;
      else raise ESQLiteDataException.Create('Unsupported variant array type');
    end
  else
    case vt and varTypeMask of
      varNull:
        sqlite3_bind_null(FHandle,i);
      varSmallint,varInteger,varShortInt,varByte,varWord,varLongWord:
        sqlite3_bind_int(FHandle,i,Value);
      varInt64:
        sqlite3_bind_int64(FHandle,i,Value);
      varSingle,varDouble:
        sqlite3_bind_double(FHandle,i,Value);
      //varDate?
      //varBoolean
      varOleStr:
       begin
        s:=VarToWideStr(Value);
        sqlite3_bind_text16(FHandle,i,PWideChar(s),Length(s)+1,nil);
       end;
      //varVariant?
      //varUnknown IPersist? IStream?
      else raise ESQLiteDataException.Create('Unsupported variant type');
    end;
end;

function TSQLiteStatement.GetParameterCount: integer;
begin
  Result:=sqlite3_bind_parameter_count(FHandle);
end;

function TSQLiteStatement.GetParameterName(Idx: integer): WideString;
begin
  GetParamNames;
  if (Idx<1) or (Idx>Length(FParamNames)) then
    raise ESQLiteDataException.Create('Invalid parameter index "'+IntToStr(Idx)+'"');
  Result:=FParamNames[Idx-1];
end;

procedure TSQLiteStatement.ExecSQL;
var
  r:integer;
begin
  r:=sqlite3_step(FHandle);
  case r of
    //SQLITE_BUSY://TODO: wait a little and retry?
    SQLITE_DONE:;//ok!
    SQLITE_ROW:raise ESQLiteDataException.Create('ExecSQL with unexpected data, use Read instead.');
    //SQLITE_ERROR
    //SQLITE_MISUSE
    else sqlite3_check(r);
  end;
end;

function TSQLiteStatement.Read: boolean;
var
  r:integer;
begin
  Result:=false;//default
  if not FEOF then
   begin
    FFirstStep:=true;
    r:=sqlite3_step(FHandle);
    case r of
      //SQLITE_BUSY://TODO: wait a little and retry?
      SQLITE_DONE:FEOF:=true;
      SQLITE_ROW:Result:=true;
      //SQLITE_ERROR
      //SQLITE_MISUSE
      else sqlite3_check(FDB,r);
    end;
   end;
end;

procedure TSQLiteStatement.Reset;
begin
  sqlite3_check(sqlite3_reset(FHandle));
  sqlite3_check(sqlite3_clear_bindings(FHandle));//TODO: switch?
  FEOF:=false;
  FGotColumnNames:=false;
  FGotParamNames:=false;
  FFirstStep:=false;
end;

function TSQLiteStatement.GetDate(Idx: OleVariant): TDateTime;
begin
  Result:=sqlite3_column_double(FHandle,GetColumnIdx(Idx));
end;

function TSQLiteStatement.GetInt(Idx: OleVariant): integer;
begin
  Result:=sqlite3_column_int(FHandle,GetColumnIdx(Idx));
end;

function TSQLiteStatement.GetStr(Idx: OleVariant): WideString;
begin
  Result:=WideString(sqlite3_column_text16(FHandle,GetColumnIdx(Idx)));
end;

function TSQLiteStatement.IsNull(Idx: OleVariant): boolean;
begin
  Result:=sqlite3_column_type(FHandle,GetColumnIdx(Idx))=SQLITE_NULL;
end;

end.
