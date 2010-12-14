unit SQLite;

interface

type
  //object placeholders (=handles)
  TSQLiteDB=integer;//pointer? ^void?
  TSQLiteStatement=integer;
  TSQLiteValue=integer;
  TSQLiteContext=integer;
  TSQLiteBlob=integer;
  TSQLiteMutex=integer;
  TSQLiteBackup=integer;

  TSQLiteCallback=function(Context:pointer;N:integer;var Text:PAnsiChar;var Names:PAnsiChar):integer; cdecl;
  TSQLiteBusyHandler=function(Context:pointer;N:integer):integer; cdecl;
  TSQLiteProcessHandler=function(Context:pointer):integer; cdecl;
  TSQLiteDestructor=procedure(Data:pointer); cdecl;
  TSQLiteFunctionHandler=procedure(Context:TSQLiteContext;Index:integer;Value:TSQLiteValue); cdecl;
  TSQLiteFunctionFinal=procedure(Context:TSQLiteContext); cdecl;
  TSQLiteCollationCompare=function(pArg:pointer;N:integer;X:PAnsiChar;Y:PAnsiChar):integer; cdecl;
  TSQLiteCollationCompare16=function(pArg:pointer;N:integer;X:PWideChar;Y:PWideChar):integer; cdecl;
  TSQLiteCollationNeeded=procedure(Context:pointer;SQLiteDB:TSQLiteDB;eTextRep:integer;X:PAnsiChar); cdecl;
  TSQLiteCollationNeeded16=procedure(Context:pointer;SQLiteDB:TSQLiteDB;eTextRep:integer;X:PWideChar); cdecl;
  TSQLiteHook=function(Context:pointer):integer; cdecl;
  TSQLiteUpdateHook=procedure(Context:pointer;N:integer;X:PAnsiChar;Y:PAnsiChar;Z:int64); cdecl;
  TSQLiteUnlockNotify=procedure(var apArg:pointer;nArg:integer); cdecl;
  TSQLiteWriteAheadLogHook=function(Context:pointer;SQLiteDB:TSQLiteDB;X:PAnsiChar;N:integer):integer; cdecl; 

const
  SQLITE_OK          =  0 ;  // Successful result 
  SQLITE_ERROR       =  1 ;  // SQL error or missing database
  SQLITE_INTERNAL    =  2 ;  // Internal logic error in SQLite
  SQLITE_PERM        =  3 ;  // Access permission denied
  SQLITE_ABORT       =  4 ;  // Callback routine requested an abort
  SQLITE_BUSY        =  5 ;  // The database file is locked
  SQLITE_LOCKED      =  6 ;  // A table in the database is locked
  SQLITE_NOMEM       =  7 ;  // A malloc() failed
  SQLITE_READONLY    =  8 ;  // Attempt to write a readonly database
  SQLITE_INTERRUPT   =  9 ;  // Operation terminated by sqlite3_interrupt()
  SQLITE_IOERR       = 10 ;  // Some kind of disk I/O error occurred
  SQLITE_CORRUPT     = 11 ;  // The database disk image is malformed
  SQLITE_NOTFOUND    = 12 ;  // NOT USED. Table or record not found
  SQLITE_FULL        = 13 ;  // Insertion failed because database is full
  SQLITE_CANTOPEN    = 14 ;  // Unable to open the database file
  SQLITE_PROTOCOL    = 15 ;  // Database lock protocol error
  SQLITE_EMPTY       = 16 ;  // Database is empty
  SQLITE_SCHEMA      = 17 ;  // The database schema changed
  SQLITE_TOOBIG      = 18 ;  // String or BLOB exceeds size limit
  SQLITE_CONSTRAINT  = 19 ;  // Abort due to constraint violation
  SQLITE_MISMATCH    = 20 ;  // Data type mismatch
  SQLITE_MISUSE      = 21 ;  // Library used incorrectly
  SQLITE_NOLFS       = 22 ;  // Uses OS features not supported on host
  SQLITE_AUTH        = 23 ;  // Authorization denied
  SQLITE_FORMAT      = 24 ;  // Auxiliary database format error
  SQLITE_RANGE       = 25 ;  // 2nd parameter to sqlite3_bind out of range
  SQLITE_NOTADB      = 26 ;  // File opened that is not a database file 
  SQLITE_ROW         = 100;  // sqlite3_step() has another row ready 
  SQLITE_DONE        = 101;  // sqlite3_step() has finished executing 

  SQLITE_IOERR_READ              = SQLITE_IOERR or $0100;
  SQLITE_IOERR_SHORT_READ        = SQLITE_IOERR or $0200;
  SQLITE_IOERR_WRITE             = SQLITE_IOERR or $0300;
  SQLITE_IOERR_FSYNC             = SQLITE_IOERR or $0400;
  SQLITE_IOERR_DIR_FSYNC         = SQLITE_IOERR or $0500;
  SQLITE_IOERR_TRUNCATE          = SQLITE_IOERR or $0600;
  SQLITE_IOERR_FSTAT             = SQLITE_IOERR or $0700;
  SQLITE_IOERR_UNLOCK            = SQLITE_IOERR or $0800;
  SQLITE_IOERR_RDLOCK            = SQLITE_IOERR or $0900;
  SQLITE_IOERR_DELETE            = SQLITE_IOERR or $1A00;
  SQLITE_IOERR_BLOCKED           = SQLITE_IOERR or $1B00;
  SQLITE_IOERR_NOMEM             = SQLITE_IOERR or $1C00;
  SQLITE_IOERR_ACCESS            = SQLITE_IOERR or $1D00;
  SQLITE_IOERR_CHECKRESERVEDLOCK = SQLITE_IOERR or $1E00;
  SQLITE_IOERR_LOCK              = SQLITE_IOERR or $1F00;
  SQLITE_IOERR_CLOSE             = SQLITE_IOERR or $1000;
  SQLITE_IOERR_DIR_CLOSE         = SQLITE_IOERR or $1100;
  SQLITE_IOERR_SHMOPEN           = SQLITE_IOERR or $1200;
  SQLITE_IOERR_SHMSIZE           = SQLITE_IOERR or $1300;
  SQLITE_IOERR_SHMLOCK           = SQLITE_IOERR or $1400;
  SQLITE_LOCKED_SHAREDCACHE      = SQLITE_LOCKED or $0100;
  SQLITE_BUSY_RECOVERY           = SQLITE_BUSY   or $0100;
  SQLITE_CANTOPEN_NOTEMPDIR      = SQLITE_CANTOPEN or $0100;

  SQLITE_OPEN_READONLY         = $00000001;
  SQLITE_OPEN_READWRITE        = $00000002;
  SQLITE_OPEN_CREATE           = $00000004;
  SQLITE_OPEN_NOMUTEX          = $00008000;
  SQLITE_OPEN_FULLMUTEX        = $00010000;
  SQLITE_OPEN_SHAREDCACHE      = $00020000;
  SQLITE_OPEN_PRIVATECACHE     = $00040000;

  SQLITE_IOCAP_ATOMIC                 = $00000001;
  SQLITE_IOCAP_ATOMIC512              = $00000002;
  SQLITE_IOCAP_ATOMIC1K               = $00000004;
  SQLITE_IOCAP_ATOMIC2K               = $00000008;
  SQLITE_IOCAP_ATOMIC4K               = $00000010;
  SQLITE_IOCAP_ATOMIC8K               = $00000020;
  SQLITE_IOCAP_ATOMIC16K              = $00000040;
  SQLITE_IOCAP_ATOMIC32K              = $00000080;
  SQLITE_IOCAP_ATOMIC64K              = $00000100;
  SQLITE_IOCAP_SAFE_APPEND            = $00000200;
  SQLITE_IOCAP_SEQUENTIAL             = $00000400;
  SQLITE_IOCAP_UNDELETABLE_WHEN_OPEN  = $00000800;

  SQLITE_LOCK_NONE         = 0;
  SQLITE_LOCK_SHARED       = 1;
  SQLITE_LOCK_RESERVED     = 2;
  SQLITE_LOCK_PENDING      = 3;
  SQLITE_LOCK_EXCLUSIVE    = 4;

  SQLITE_SYNC_NORMAL        = $00002;
  SQLITE_SYNC_FULL          = $00003;
  SQLITE_SYNC_DATAONLY      = $00010;

  SQLITE_LIMIT_LENGTH                  =  0;
  SQLITE_LIMIT_SQL_LENGTH              =  1;
  SQLITE_LIMIT_COLUMN                  =  2;
  SQLITE_LIMIT_EXPR_DEPTH              =  3;
  SQLITE_LIMIT_COMPOUND_SELECT         =  4;
  SQLITE_LIMIT_VDBE_OP                 =  5;
  SQLITE_LIMIT_FUNCTION_ARG            =  6;
  SQLITE_LIMIT_ATTACHED                =  7;
  SQLITE_LIMIT_LIKE_PATTERN_LENGTH     =  8;
  SQLITE_LIMIT_VARIABLE_NUMBER         =  9;
  SQLITE_LIMIT_TRIGGER_DEPTH           = 10;

  SQLITE_INTEGER  = 1;
  SQLITE_FLOAT    = 2;
  SQLITE_TEXT     = 3;
  SQLITE_BLOB     = 4;
  SQLITE_NULL     = 5;

  SQLITE_UTF8           = 1;
  SQLITE_UTF16LE        = 2;
  SQLITE_UTF16BE        = 3;
  SQLITE_UTF16          = 4;    // Use native byte order
  SQLITE_ANY            = 5;    // sqlite3_create_function only
  SQLITE_UTF16_ALIGNED  = 8;    // sqlite3_create_collation only

  SQLITE_MUTEX_FAST            = 0;
  SQLITE_MUTEX_RECURSIVE       = 1;
  SQLITE_MUTEX_STATIC_MASTER   = 2;
  SQLITE_MUTEX_STATIC_MEM      = 3;  // sqlite3_malloc()
  SQLITE_MUTEX_STATIC_OPEN     = 4;  // sqlite3BtreeOpen()
  SQLITE_MUTEX_STATIC_PRNG     = 5;  // sqlite3_random()
  SQLITE_MUTEX_STATIC_LRU      = 6;  // lru page list 
  SQLITE_MUTEX_STATIC_LRU2     = 7;  // lru page list 

  SQLITE_STATUS_MEMORY_USED         = 0;
  SQLITE_STATUS_PAGECACHE_USED      = 1;
  SQLITE_STATUS_PAGECACHE_OVERFLOW  = 2;
  SQLITE_STATUS_SCRATCH_USED        = 3;
  SQLITE_STATUS_SCRATCH_OVERFLOW    = 4;
  SQLITE_STATUS_MALLOC_SIZE         = 5;
  SQLITE_STATUS_PARSER_STACK        = 6;
  SQLITE_STATUS_PAGECACHE_SIZE      = 7;
  SQLITE_STATUS_SCRATCH_SIZE        = 8;
  SQLITE_STATUS_MALLOC_COUNT        = 9;

  SQLITE_DBSTATUS_LOOKASIDE_USED    = 0;
  SQLITE_DBSTATUS_CACHE_USED        = 1;
  SQLITE_DBSTATUS_SCHEMA_USED       = 2;
  SQLITE_DBSTATUS_STMT_USED         = 3;
  SQLITE_DBSTATUS_MAX               = 3;   // Largest defined DBSTATUS

  SQLITE_STMTSTATUS_FULLSCAN_STEP    = 1;
  SQLITE_STMTSTATUS_SORT             = 2;
  SQLITE_STMTSTATUS_AUTOINDEX        = 3;

//ATTENTION: PAnsiChar's should point to UTF-8 strings

function sqlite3_libversion:PAnsiChar; cdecl;
function sqlite3_sourceid:PAnsiChar; cdecl;
function sqlite3_libversion_number:integer; cdecl;
//function sqlite3_compileoption_used(PAnsiChar:zOptName):integer; cdecl;
//function sqlite3_compileoption_get(N:integer):PAnsiChar; cdecl;
function sqlite3_threadsafe:integer; cdecl;
function sqlite3_close(SQLiteDB:TSQLiteDB):integer; cdecl;
function sqlite3_exec(SQLiteDB:TSQLiteDB;Sql:PAnsiChar;Callback:TSQLiteCallback;Context:pointer;
  var ErrorMessage:PAnsiChar):integer; cdecl;
function sqlite3_initialize:integer; cdecl;
function sqlite3_shutdown:integer; cdecl;
function sqlite3_os_init:integer; cdecl;
function sqlite3_os_end:integer; cdecl;
//function sqlite3_config(:integer;...):integer; cdecl;
//function sqlite3_db_config(SQLiteDB:TSQLiteDB;op:integer;...):integer; cdecl;
function sqlite3_extended_result_codes(SQLiteDB:TSQLiteDB;onoff:integer):integer; cdecl;
function sqlite3_last_insert_rowid(SQLiteDB:TSQLiteDB):int64; cdecl;
function sqlite3_changes(SQLiteDB:TSQLiteDB):integer; cdecl;
function sqlite3_total_changes(SQLiteDB:TSQLiteDB):integer; cdecl;
procedure sqlite3_interrupt(SQLiteDB:TSQLiteDB); cdecl;
function sqlite3_complete(sql:PAnsiChar):integer; cdecl;
function sqlite3_complete16(sql:PWideChar):integer; cdecl;
function sqlite3_busy_handler(SQLiteDB:TSQLiteDB;Handler:TSQLiteBusyHandler;Context:pointer):integer; cdecl;
function sqlite3_busy_timeout(SQLiteDB:TSQLiteDB;ms:integer):integer; cdecl;
function sqlite3_get_table(SQLiteDB:TSQLiteDB;Sql:PAnsiChar;
  var Results:PAnsiChar;var Rows:integer;var Columns:integer;var ErrorMessage:PAnsiChar):integer; cdecl;
function sqlite3_free_table(Results:PAnsiChar):integer; cdecl;
//function sqlite3_mprintf(:PAnsiChar;...):PAnsiChar; cdecl;
//function sqlite3_vmprintf(:PAnsiChar;va_list):integer; cdecl;
//function sqlite3_snprintf(:integer;:PAnsiChar;:PAnsiChar;...):integer; cdecl;
function sqlite3_malloc(Size:integer):pointer; cdecl;
function sqlite3_realloc(Mem:pointer;Size:integer):pointer; cdecl;
procedure sqlite3_free(Mem:pointer); cdecl;
function sqlite3_memory_used:int64; cdecl;
function sqlite3_memory_highwater(resetFlag:integer):int64; cdecl;
procedure sqlite3_randomness(N:integer;var P); cdecl;
//sqlite3_set_authorizer
//sqlite3_trace
procedure sqlite3_progress_handler(SQLiteDB:TSQLiteDB;N:integer;Callback:TSQLiteProcessHandler;Context:pointer); cdecl;
function sqlite3_open(FileName:PAnsiChar;var SQLiteDB:TSQLiteDB):integer; cdecl;
function sqlite3_open16(FileName:PWideChar;var SQLiteDB:TSQLiteDB):integer; cdecl;
function sqlite3_open_v2(FileName:PAnsiChar;var SQLiteDB:TSQLiteDB;Flags:integer;VFSModule:PAnsiChar):integer; cdecl;
function sqlite3_errcode(SQLiteDB:TSQLiteDB):integer; cdecl;
function sqlite3_extended_errcode(SQLiteDB:TSQLiteDB):integer; cdecl;
function sqlite3_errmsg(SQLiteDB:TSQLiteDB):PAnsiChar; cdecl;
function sqlite3_errmsg16(SQLiteDB:TSQLiteDB):PWideChar; cdecl;
function sqlite3_limit(SQLiteDB:TSQLiteDB;id:integer;newVal:integer):integer; cdecl;

function sqlite3_prepare(SQLiteDB:TSQLiteDB;Sql:PAnsiChar;nByte:integer;
  var Statement:TSQLiteStatement;var Tail:PAnsiChar):integer; cdecl;
function sqlite3_prepare_v2(SQLiteDB:TSQLiteDB;Sql:PAnsiChar;nByte:integer;
  var Statement:TSQLiteStatement;var Tail:PAnsiChar):integer; cdecl;
function sqlite3_prepare16(SQLiteDB:TSQLiteDB;Sql:PWideChar;nByte:integer;
  var Statement:TSQLiteStatement;var Tail:PWideChar):integer; cdecl;
function sqlite3_prepare16_v2(SQLiteDB:TSQLiteDB;Sql:PWideChar;nByte:integer;
  var Statement:TSQLiteStatement;var Tail:PWideChar):integer; cdecl;
function sqlite3_sql(Statement:TSQLiteStatement):PAnsiChar; cdecl;
function sqlite3_stmt_readonly(Statement:TSQLiteStatement):integer; cdecl;

function sqlite3_bind_blob(Statement:TSQLiteStatement;Index:integer;var X;N:integer;Z:TSQLiteDestructor):integer; cdecl;
function sqlite3_bind_double(Statement:TSQLiteStatement;Index:integer;X:Double):integer; cdecl;
function sqlite3_bind_int(Statement:TSQLiteStatement;Index:integer;X:integer):integer; cdecl;
function sqlite3_bind_int64(Statement:TSQLiteStatement;Index:integer;X:int64):integer; cdecl;
function sqlite3_bind_null(Statement:TSQLiteStatement;Index:integer):integer; cdecl;
function sqlite3_bind_text(Statement:TSQLiteStatement;Index:integer;
  X:PAnsiChar;N:integer;Z:TSQLiteDestructor):integer; cdecl;
function sqlite3_bind_text16(Statement:TSQLiteStatement;Index:integer;
  X:PWideChar;N:integer;Z:TSQLiteDestructor):integer; cdecl;
function sqlite3_bind_value(Statement:TSQLiteStatement;Index:integer;X:TSQLiteValue):integer; cdecl;
function sqlite3_bind_zeroblob(Statement:TSQLiteStatement;Index:integer;N:integer):integer; cdecl;
function sqlite3_bind_parameter_count(Statement:TSQLiteStatement):integer; cdecl;
function sqlite3_bind_parameter_name(Statement:TSQLiteStatement;Index:integer):PAnsiChar; cdecl;
function sqlite3_bind_parameter_index(Statement:TSQLiteStatement;Name:PAnsiChar):integer; cdecl;
function sqlite3_clear_bindings(Statement:TSQLiteStatement):integer; cdecl;

function sqlite3_column_count(Statement:TSQLiteStatement):integer; cdecl;
function sqlite3_column_name(Statement:TSQLiteStatement):PAnsiChar; cdecl;
function sqlite3_column_name16(Statement:TSQLiteStatement):PWideChar; cdecl;
function sqlite3_column_database_name(Statement:TSQLiteStatement):PAnsiChar; cdecl;
function sqlite3_column_database_name16(Statement:TSQLiteStatement):PWideChar; cdecl;
function sqlite3_column_table_name(Statement:TSQLiteStatement):PAnsiChar; cdecl;
function sqlite3_column_table_name16(Statement:TSQLiteStatement):PWideChar; cdecl;
function sqlite3_column_origin_name(Statement:TSQLiteStatement):PAnsiChar; cdecl;
function sqlite3_column_origin_name16(Statement:TSQLiteStatement):PWideChar; cdecl;
function sqlite3_column_decltype(Statement:TSQLiteStatement;Index:integer):PAnsiChar; cdecl;
function sqlite3_column_decltype16(Statement:TSQLiteStatement;Index:integer):PWideChar; cdecl;

function sqlite3_step(Statement:TSQLiteStatement):integer; cdecl;
function sqlite3_data_count(Statement:TSQLiteStatement):integer; cdecl;

function sqlite3_column_blob(Statement:TSQLiteStatement;Index:integer):pointer; cdecl;
function sqlite3_column_bytes(Statement:TSQLiteStatement;Index:integer):integer; cdecl;
function sqlite3_column_bytes16(Statement:TSQLiteStatement;Index:integer):integer; cdecl;
function sqlite3_column_double(Statement:TSQLiteStatement;Index:integer):Double; cdecl;
function sqlite3_column_int(Statement:TSQLiteStatement;Index:integer):integer; cdecl;
function sqlite3_column_int64(Statement:TSQLiteStatement;Index:integer):int64; cdecl;
function sqlite3_column_text(Statement:TSQLiteStatement;Index:integer):PAnsiChar; cdecl;
function sqlite3_column_text16(Statement:TSQLiteStatement;Index:integer):PWideChar; cdecl;
function sqlite3_column_type(Statement:TSQLiteStatement;Index:integer):integer; cdecl;
function sqlite3_column_value(Statement:TSQLiteStatement;Index:integer):TSQLiteValue; cdecl;

function sqlite3_finalize(Statement:TSQLiteStatement):integer; cdecl;
function sqlite3_reset(Statement:TSQLiteStatement):integer; cdecl;

function sqlite3_create_function(SQLiteDB:TSQLiteDB;FunctionName:PAnsiChar;
  nArg:integer;eTextRep:integer;pApp:pointer;
  xFunc:TSQLiteFunctionHandler;xStep:TSQLiteFunctionHandler;xFinal:TSQLiteFunctionFinal):integer; cdecl;
function sqlite3_create_function16(SQLiteDB:TSQLiteDB;FunctionName:PAnsiChar;
  nArg:integer;eTextRep:integer;pApp:pointer;
  xFunc:TSQLiteFunctionHandler;xStep:TSQLiteFunctionHandler;xFinal:TSQLiteFunctionFinal):integer; cdecl;
function sqlite3_create_function_v2(SQLiteDB:TSQLiteDB;FunctionName:PAnsiChar;
  nArg:integer;eTextRep:integer;pApp:pointer;
  xFunc:TSQLiteFunctionHandler;xStep:TSQLiteFunctionHandler;xFinal:TSQLiteFunctionFinal;
  xDestroy:TSQLiteDestructor):integer; cdecl;

function sqlite3_value_blob(Value:TSQLiteValue):pointer; cdecl;
function sqlite3_value_bytes(Value:TSQLiteValue):integer; cdecl;
function sqlite3_value_bytes16(Value:TSQLiteValue):integer; cdecl;
function sqlite3_value_double(Value:TSQLiteValue):double; cdecl;
function sqlite3_value_int(Value:TSQLiteValue):integer; cdecl;
function sqlite3_value_int64(Value:TSQLiteValue):int64; cdecl;
function sqlite3_value_text(Value:TSQLiteValue):PAnsiChar; cdecl;
function sqlite3_value_text16(Value:TSQLiteValue):PWideChar; cdecl;
function sqlite3_value_text16le(Value:TSQLiteValue):PWideChar; cdecl;
function sqlite3_value_text16be(Value:TSQLiteValue):PWideChar; cdecl;
function sqlite3_value_type(Value:TSQLiteValue):integer; cdecl;
function sqlite3_value_numeric_type(Value:TSQLiteValue):integer; cdecl;

function sqlite3_aggregate_context(Context:TSQLiteContext;nBytes:integer):pointer; cdecl;
function sqlite3_user_data(Context:TSQLiteContext):pointer; cdecl;
function sqlite3_context_db_handle(Context:TSQLiteContext):TSQLiteDB; cdecl;
function sqlite3_get_auxdata(Context:TSQLiteContext;N:integer):pointer; cdecl;
procedure sqlite3_set_auxdata(Context:TSQLiteContext;N:integer;var X;Z:TSQLiteDestructor); cdecl;

procedure sqlite3_result_blob(Context:TSQLiteContext;var X;N:integer;Z:TSQLiteDestructor); cdecl;
procedure sqlite3_result_double(Context:TSQLiteContext;X:Double); cdecl;
procedure sqlite3_result_error(Context:TSQLiteContext;X:PAnsiChar;N:integer); cdecl;
procedure sqlite3_result_error16(Context:TSQLiteContext;X:PWideChar;N:integer); cdecl;
procedure sqlite3_result_error_toobig(Context:TSQLiteContext); cdecl;
procedure sqlite3_result_error_nomem(Context:TSQLiteContext); cdecl;
procedure sqlite3_result_error_code(Context:TSQLiteContext;ErrorCode:integer); cdecl;
procedure sqlite3_result_int(Context:TSQLiteContext;X:integer); cdecl;
procedure sqlite3_result_int64(Context:TSQLiteContext;X:int64); cdecl;
procedure sqlite3_result_null(Context:TSQLiteContext); cdecl;
procedure sqlite3_result_text(Context:TSQLiteContext;X:PAnsiChar;N:integer;Z:TSQLiteDestructor); cdecl;
procedure sqlite3_result_text16(Context:TSQLiteContext;X:PWideChar;N:integer;Z:TSQLiteDestructor); cdecl;
procedure sqlite3_result_text16le(Context:TSQLiteContext;X:PWideChar;N:integer;Z:TSQLiteDestructor); cdecl;
procedure sqlite3_result_text16be(Context:TSQLiteContext;X:PWideChar;N:integer;Z:TSQLiteDestructor); cdecl;
procedure sqlite3_result_value(Context:TSQLiteContext;X:TSQLiteValue); cdecl;
procedure sqlite3_result_zeroblob(Context:TSQLiteContext;N:integer); cdecl;

function sqlite3_create_collation(SQLiteDB:TSQLiteDB;Name:PAnsiChar;
  eTextRep:integer;pArg:pointer;xCompare:TSQLiteCollationCompare):integer; cdecl;
function sqlite3_create_collation_v2(SQLiteDB:TSQLiteDB;Name:PAnsiChar;
  eTextRep:integer;pArg:pointer;xCompare:TSQLiteCollationCompare;xDestroy:TSQLiteDestructor):integer; cdecl;
function sqlite3_create_collation16(SQLiteDB:TSQLiteDB;Name:PWideChar;
  eTextRep:integer;pArg:pointer;xCompare:TSQLiteCollationCompare16):integer; cdecl;

function sqlite3_collation_needed(SQLiteDB:TSQLiteDB;Context:pointer;CallBack:TSQLiteCollationNeeded):integer; cdecl;
function sqlite3_collation_needed16(SQLiteDB:TSQLiteDB;Context:pointer;CallBack:TSQLiteCollationNeeded16):integer; cdecl;

//sqlite3_key
//sqlite3_rekey
//sqlite3_activate_cerod

function sqlite3_sleep(ms:integer):integer; cdecl;
function sqlite3_get_autocommit(SQLiteDB:TSQLiteDB):integer; cdecl;
function sqlite3_db_handle(Statement:TSQLiteStatement):TSQLiteDB; cdecl;
function sqlite3_next_stmt(SQLiteDB:TSQLiteDB;Statement:TSQLiteStatement):TSQLiteStatement; cdecl;

function sqlite3_commit_hook(SQLiteDB:TSQLiteDB;X:TSQLiteHook;Context:pointer):pointer; cdecl;
function sqlite3_rollback_hook(SQLiteDB:TSQLiteDB;X:TSQLiteDestructor;Context:pointer):pointer; cdecl;
function sqlite3_update_hook(SQLiteDB:TSQLiteDB;X:TSQLiteUpdateHook;Context:pointer):pointer; cdecl;

function sqlite3_enable_shared_cache(X:integer):integer; cdecl;
function sqlite3_release_memory(X:integer):integer; cdecl;
function sqlite3_soft_heap_limit64(N:int64):int64; cdecl;

function sqlite3_table_column_metadata(SQLiteDB:TSQLiteDB;Name:PAnsiChar;TableName:PAnsiChar;ColumnName:PAnsiChar;
  var DataType:PAnsiChar;var CollationSequence:PAnsiChar;
  var NotNull:integer;var PrimaryKey:integer;var AutoInc:integer):integer; cdecl;
function sqlite3_load_extension(SQLiteDB:TSQLiteDB;xFile:PAnsiChar;xProc:PAnsiChar;
  var ErrorMessage:PAnsiChar):integer; cdecl;
function sqlite3_enable_load_extension(SQLiteDB:TSQLiteDB;onoff:integer):integer; cdecl;
//sqlite3_auto_extension
//sqlite3_reset_auto_extension

//TODO: virtual table modules
//sqlite3_create_module
//sqlite3_create_module_v2
//sqlite3_declare_vtab
//sqlite3_overload_function

function sqlite3_blob_open(SQLiteDB:TSQLiteDB;DB:PAnsiChar;TableName:PAnsiChar;ColumnName:PAnsiChar;Row:int64;Flags:integer;Blob:TSQLiteBlob):integer; cdecl;
function sqlite3_blob_reopen(Blob:TSQLiteBlob;N:int64):integer; cdecl;
function sqlite3_blob_close(Blob:TSQLiteBlob):integer; cdecl;
function sqlite3_blob_bytes(Blob:TSQLiteBlob):integer; cdecl;
function sqlite3_blob_read(Blob:TSQLiteBlob;var Z;N:integer;Offset:integer):integer; cdecl;
function sqlite3_blob_write(Blob:TSQLiteBlob;var Z;N:integer;Offset:integer):integer; cdecl;

//sqlite3_vfs_find
//sqlite3_vfs_register
//sqlite3_vfs_unregister

function sqlite3_mutex_alloc(X:integer):TSQLiteBlob; cdecl;
procedure sqlite3_mutex_free(Mutex:TSQLiteMutex); cdecl;
procedure sqlite3_mutex_enter(Mutex:TSQLiteMutex); cdecl;
function sqlite3_mutex_try(Mutex:TSQLiteMutex):integer; cdecl;
procedure sqlite3_mutex_leave(Mutex:TSQLiteMutex); cdecl;
//sqlite3_mutex_held
//sqlite3_mutex_notheld
function sqlite3_db_mutex(SQLiteDB:TSQLiteDB):TSQLiteMutex; cdecl;

function sqlite3_file_control(SQLiteDB:TSQLiteDB;Name:PAnsiChar;Op:integer;X:pointer):integer; cdecl;
//sqlite3_test_control
function sqlite3_status(Op:integer;var Current:integer;var HighWater:integer;ResetFlag:integer):integer; cdecl;
function sqlite3_db_status(SQLiteDB:TSQLiteDB;Op:integer;var Current:integer;var HighWater:integer;ResetFlag:integer):integer; cdecl;
function sqlite3_stmt_status(Statement:TSQLiteStatement;Op:integer;ResetFlag:integer):integer; cdecl;

function sqlite3_backup_init(Dest:TSQLiteDB;DestName:PAnsiChar;Source:TSQLiteDB;SourceName:PAnsiChar):TSQLiteBackup; cdecl;
function sqlite3_backup_step(Backup:TSQLiteBackup;Page:integer):integer; cdecl;
function sqlite3_backup_finish(Backup:TSQLiteBackup):integer; cdecl;
function sqlite3_backup_remaining(Backup:TSQLiteBackup):integer; cdecl;
function sqlite3_backup_pagecount(Backup:TSQLiteBackup):integer; cdecl;

function sqlite3_unlock_notify(Blocked:TSQLiteDB;xNotify:TSQLiteUnlockNotify;Context:pointer):integer; cdecl;

function sqlite3_strnicmp(X:PAnsiChar;Y:PAnsiChar;Z:integer):integer; cdecl;

//sqlite3_log

function sqlite3_wal_hook(SQLiteDB:TSQLiteDB;Hook:TSQLiteWriteAheadLogHook;Context:pointer):pointer; cdecl;
function sqlite3_wal_autocheckpoint(SQLiteDB:TSQLiteDB;N:integer):integer; cdecl;
function sqlite3_wal_checkpoint(SQLiteDB:TSQLiteDB;DB:PAnsiChar):integer; cdecl;

//sqlite3_rtree_geometry_callback
//sqlite3_rtree_geometry

implementation

const
  SqlLite3Dll='sqlite3.dll';

function sqlite3_libversion; external SqlLite3Dll;
function sqlite3_sourceid; external SqlLite3Dll;
function sqlite3_libversion_number; external SqlLite3Dll;
//function sqlite3_compileoption_used; external SqlLite3Dll;
//function sqlite3_compileoption_get; external SqlLite3Dll;
function sqlite3_threadsafe; external SqlLite3Dll;
function sqlite3_close; external SqlLite3Dll;
function sqlite3_exec; external SqlLite3Dll;
function sqlite3_initialize; external SqlLite3Dll;
function sqlite3_shutdown; external SqlLite3Dll;
function sqlite3_os_init; external SqlLite3Dll;
function sqlite3_os_end; external SqlLite3Dll;
//function sqlite3_config; external SqlLite3Dll;
//function sqlite3_db_config; external SqlLite3Dll;
function sqlite3_extended_result_codes; external SqlLite3Dll;
function sqlite3_last_insert_rowid; external SqlLite3Dll;
function sqlite3_changes; external SqlLite3Dll;
function sqlite3_total_changes; external SqlLite3Dll;
procedure sqlite3_interrupt; external SqlLite3Dll;
function sqlite3_complete; external SqlLite3Dll;
function sqlite3_complete16; external SqlLite3Dll;
function sqlite3_busy_handler; external SqlLite3Dll;
function sqlite3_busy_timeout; external SqlLite3Dll;
function sqlite3_get_table; external SqlLite3Dll;
function sqlite3_free_table; external SqlLite3Dll;
//function sqlite3_mprintf; external SqlLite3Dll;
//function sqlite3_vmprintf; external SqlLite3Dll;
//function sqlite3_snprintf; external SqlLite3Dll;
function sqlite3_malloc; external SqlLite3Dll;
function sqlite3_realloc; external SqlLite3Dll;
procedure sqlite3_free; external SqlLite3Dll;
function sqlite3_memory_used; external SqlLite3Dll;
function sqlite3_memory_highwater; external SqlLite3Dll;
procedure sqlite3_randomness; external SqlLite3Dll;
//sqlite3_set_authorizer
//sqlite3_trace
procedure sqlite3_progress_handler; external SqlLite3Dll;
function sqlite3_open; external SqlLite3Dll;
function sqlite3_open16; external SqlLite3Dll;
function sqlite3_open_v2; external SqlLite3Dll;
function sqlite3_errcode; external SqlLite3Dll;
function sqlite3_extended_errcode; external SqlLite3Dll;
function sqlite3_errmsg; external SqlLite3Dll;
function sqlite3_errmsg16; external SqlLite3Dll;
function sqlite3_limit; external SqlLite3Dll;

function sqlite3_prepare; external SqlLite3Dll;
function sqlite3_prepare_v2; external SqlLite3Dll;
function sqlite3_prepare16; external SqlLite3Dll;
function sqlite3_prepare16_v2; external SqlLite3Dll;
function sqlite3_sql; external SqlLite3Dll;
function sqlite3_stmt_readonly; external SqlLite3Dll;

function sqlite3_bind_blob; external SqlLite3Dll;
function sqlite3_bind_double; external SqlLite3Dll;
function sqlite3_bind_int; external SqlLite3Dll;
function sqlite3_bind_int64; external SqlLite3Dll;
function sqlite3_bind_null; external SqlLite3Dll;
function sqlite3_bind_text; external SqlLite3Dll;
function sqlite3_bind_text16; external SqlLite3Dll;
function sqlite3_bind_value; external SqlLite3Dll;
function sqlite3_bind_zeroblob; external SqlLite3Dll;
function sqlite3_bind_parameter_count; external SqlLite3Dll;
function sqlite3_bind_parameter_name; external SqlLite3Dll;
function sqlite3_bind_parameter_index; external SqlLite3Dll;
function sqlite3_clear_bindings; external SqlLite3Dll;

function sqlite3_column_count; external SqlLite3Dll;
function sqlite3_column_name; external SqlLite3Dll;
function sqlite3_column_name16; external SqlLite3Dll;
function sqlite3_column_database_name; external SqlLite3Dll;
function sqlite3_column_database_name16; external SqlLite3Dll;
function sqlite3_column_table_name; external SqlLite3Dll;
function sqlite3_column_table_name16; external SqlLite3Dll;
function sqlite3_column_origin_name; external SqlLite3Dll;
function sqlite3_column_origin_name16; external SqlLite3Dll;
function sqlite3_column_decltype; external SqlLite3Dll;
function sqlite3_column_decltype16; external SqlLite3Dll;

function sqlite3_step; external SqlLite3Dll;
function sqlite3_data_count; external SqlLite3Dll;

function sqlite3_column_blob; external SqlLite3Dll;
function sqlite3_column_bytes; external SqlLite3Dll;
function sqlite3_column_bytes16; external SqlLite3Dll;
function sqlite3_column_double; external SqlLite3Dll;
function sqlite3_column_int; external SqlLite3Dll;
function sqlite3_column_int64; external SqlLite3Dll;
function sqlite3_column_text; external SqlLite3Dll;
function sqlite3_column_text16; external SqlLite3Dll;
function sqlite3_column_type; external SqlLite3Dll;
function sqlite3_column_value; external SqlLite3Dll;

function sqlite3_finalize; external SqlLite3Dll;
function sqlite3_reset; external SqlLite3Dll;

function sqlite3_create_function; external SqlLite3Dll;
function sqlite3_create_function16; external SqlLite3Dll;
function sqlite3_create_function_v2; external SqlLite3Dll;

function sqlite3_value_blob; external SqlLite3Dll;
function sqlite3_value_bytes; external SqlLite3Dll;
function sqlite3_value_bytes16; external SqlLite3Dll;
function sqlite3_value_double; external SqlLite3Dll;
function sqlite3_value_int; external SqlLite3Dll;
function sqlite3_value_int64; external SqlLite3Dll;
function sqlite3_value_text; external SqlLite3Dll;
function sqlite3_value_text16; external SqlLite3Dll;
function sqlite3_value_text16le; external SqlLite3Dll;
function sqlite3_value_text16be; external SqlLite3Dll;
function sqlite3_value_type; external SqlLite3Dll;
function sqlite3_value_numeric_type; external SqlLite3Dll;

function sqlite3_aggregate_context; external SqlLite3Dll;
function sqlite3_user_data; external SqlLite3Dll;
function sqlite3_context_db_handle; external SqlLite3Dll;
function sqlite3_get_auxdata; external SqlLite3Dll;
procedure sqlite3_set_auxdata; external SqlLite3Dll;

procedure sqlite3_result_blob; external SqlLite3Dll;
procedure sqlite3_result_double; external SqlLite3Dll;
procedure sqlite3_result_error; external SqlLite3Dll;
procedure sqlite3_result_error16; external SqlLite3Dll;
procedure sqlite3_result_error_toobig; external SqlLite3Dll;
procedure sqlite3_result_error_nomem; external SqlLite3Dll;
procedure sqlite3_result_error_code; external SqlLite3Dll;
procedure sqlite3_result_int; external SqlLite3Dll;
procedure sqlite3_result_int64; external SqlLite3Dll;
procedure sqlite3_result_null; external SqlLite3Dll;
procedure sqlite3_result_text; external SqlLite3Dll;
procedure sqlite3_result_text16; external SqlLite3Dll;
procedure sqlite3_result_text16le; external SqlLite3Dll;
procedure sqlite3_result_text16be; external SqlLite3Dll;
procedure sqlite3_result_value; external SqlLite3Dll;
procedure sqlite3_result_zeroblob; external SqlLite3Dll;

function sqlite3_create_collation; external SqlLite3Dll;
function sqlite3_create_collation_v2; external SqlLite3Dll;
function sqlite3_create_collation16; external SqlLite3Dll;

function sqlite3_collation_needed; external SqlLite3Dll;
function sqlite3_collation_needed16; external SqlLite3Dll;

//sqlite3_key
//sqlite3_rekey
//sqlite3_activate_cerod

function sqlite3_sleep; external SqlLite3Dll;
function sqlite3_get_autocommit; external SqlLite3Dll;
function sqlite3_db_handle; external SqlLite3Dll;
function sqlite3_next_stmt; external SqlLite3Dll;

function sqlite3_commit_hook; external SqlLite3Dll;
function sqlite3_rollback_hook; external SqlLite3Dll;
function sqlite3_update_hook; external SqlLite3Dll;

function sqlite3_enable_shared_cache; external SqlLite3Dll;
function sqlite3_release_memory; external SqlLite3Dll;
function sqlite3_soft_heap_limit64; external SqlLite3Dll;

function sqlite3_table_column_metadata; external SqlLite3Dll;
function sqlite3_load_extension; external SqlLite3Dll;
function sqlite3_enable_load_extension; external SqlLite3Dll;
//sqlite3_auto_extension
//sqlite3_reset_auto_extension

//TODO: virtual table modules
//sqlite3_create_module
//sqlite3_create_module_v2
//sqlite3_declare_vtab
//sqlite3_overload_function

function sqlite3_blob_open; external SqlLite3Dll;
function sqlite3_blob_reopen; external SqlLite3Dll;
function sqlite3_blob_close; external SqlLite3Dll;
function sqlite3_blob_bytes; external SqlLite3Dll;
function sqlite3_blob_read; external SqlLite3Dll;
function sqlite3_blob_write; external SqlLite3Dll;

//sqlite3_vfs_find
//sqlite3_vfs_register
//sqlite3_vfs_unregister

function sqlite3_mutex_alloc; external SqlLite3Dll;
procedure sqlite3_mutex_free; external SqlLite3Dll;
procedure sqlite3_mutex_enter; external SqlLite3Dll;
function sqlite3_mutex_try; external SqlLite3Dll;
procedure sqlite3_mutex_leave; external SqlLite3Dll;
//sqlite3_mutex_held
//sqlite3_mutex_notheld
function sqlite3_db_mutex; external SqlLite3Dll;

function sqlite3_file_control; external SqlLite3Dll;
//sqlite3_test_control
function sqlite3_status; external SqlLite3Dll;
function sqlite3_db_status; external SqlLite3Dll;
function sqlite3_stmt_status; external SqlLite3Dll;

function sqlite3_backup_init; external SqlLite3Dll;
function sqlite3_backup_step; external SqlLite3Dll;
function sqlite3_backup_finish; external SqlLite3Dll;
function sqlite3_backup_remaining; external SqlLite3Dll;
function sqlite3_backup_pagecount; external SqlLite3Dll;

function sqlite3_unlock_notify; external SqlLite3Dll;

function sqlite3_strnicmp; external SqlLite3Dll;

//sqlite3_log

function sqlite3_wal_hook; external SqlLite3Dll;
function sqlite3_wal_autocheckpoint; external SqlLite3Dll;
function sqlite3_wal_checkpoint; external SqlLite3Dll;

//sqlite3_rtree_geometry_callback
//sqlite3_rtree_geometry

end.
