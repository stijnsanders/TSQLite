//////////////////////////////////////////////////
//  TSQLite                                     //
//    Delphi SQLite3 wrapper                    //
//                                              //
//  https://github.com/stijnsanders/TSQLite     //
//////////////////////////////////////////////////

unit SQLiteEx;

//based on sqlite.h 3.44.2 2023-11-24

interface

uses SQLite;

type
  DSQLiteSnapshot=record
    hidden:array[0..47] of byte;
  end;
  HSQLiteSnapshot=^DSQLiteSnapshot;
  HSQLiteSession=type pointer;
  HSQLiteChangesetIterator=type pointer;
  HSQLiteChangeGroup=type pointer;
  HSQLiteRebaser=type pointer;

type
  TSQLiteSessionFilter=function(Context:pointer;zTab:PAnsiChar):integer; cdecl;
  TSQLiteChangesetConflict=function(Context:pointer;eConflict:integer;p:HSQLiteChangesetIterator):integer; cdecl;
  TSQLiteInputFn=function(pIn:pointer;pData:pointer;var pnData):integer; cdecl;
  TSQLiteOutputFn=function(pOut:pointer;pData:pointer;nData:integer):integer; cdecl;

//sqlite3_vtab_config (cdecl)
//sqlite3_vtab_on_conflict

//sqlite3_preupdate

function sqlite3_snapshot_get(SQLiteDB:HSQLiteDB;zSchema:PAnsiChar;
  var ppSnapshot:HSQLiteSnapshot):integer; cdecl;
function sqlite3_snapshot_open(SQLiteDB:HSQLiteDB;zSchema:PAnsiChar;
  var ppSnapshot:HSQLiteSnapshot):integer; cdecl;
procedure sqlite3_snapshot_free(pSnapshot:HSQLiteSnapshot); cdecl;
function sqlite3_snapshot_cmp(p1,p2:HSQLiteSnapshot):integer; cdecl;

//sqlite3_rtree_geometry_callback
//sqlite3_rtree_geometry
//sqlite3_rtree_query_callback
//sqlite3_rtree_query_info

function sqlite3session_create(SQLiteDB:HSQLiteDB;zDb:PAnsiChar;
  var ppSession:HSQLiteSession):integer; cdecl;
procedure sqlite3session_delete(SQLiteSession:HSQLiteSession);
function sqlite3session_enable(SQLiteSession:HSQLiteSession;
  bEnable:integer):integer; cdecl;
function sqlite3session_indirect(SQLiteSession:HSQLiteSession;
  bIndirect:integer):integer; cdecl;
function sqlite3session_attach(SQLiteSession:HSQLiteSession;
  {const?} zTab:PAnsiChar):integer; cdecl;
procedure sqlite3session_table_filter(SQLiteSession:HSQLiteSession;
  xFilter:TSQLiteSessionFilter;pCtx:pointer); cdecl;
function sqlite3session_changeset(SQLiteSession:HSQLiteSession;
  var pnChangeset:integer;var ppChangeset:pointer):integer; cdecl;
function sqlite3session_diff(SQLiteSession:HSQLiteSession;
  zFromDb,zTbl:PAnsiChar;var pzErrMsg:PAnsiChar):integer; cdecl;
function sqlite3session_patchset(SQLiteSession:HSQLiteSession;
  var pnPatchset:integer;var ppPatchset:pointer):integer; cdecl;
function sqlite3session_isempty(SQLiteSession:HSQLiteSession):integer; cdecl;
function sqlite3changeset_start(var pp:HSQLiteChangesetIterator;
  nChangeset:integer;pChangeset:pointer):integer; cdecl;
function sqlite3changeset_next(pIter:HSQLiteChangesetIterator):integer; cdecl;
function sqlite3changeset_op(pIter:HSQLiteChangesetIterator;var pzTab:PAnsiChar;
  var pnCol,pOp,pbIndirect:integer):integer; cdecl;
function sqlite3changeset_pk(pIter:HSQLiteChangesetIterator;var pabPK:pointer;
  var pnCol:integer):integer; cdecl;
function sqlite3changeset_old(pIter:HSQLiteChangesetIterator;iVal:integer;
  var ppValue:HSQLiteValue): integer; cdecl;
function sqlite3changeset_new(pIter:HSQLiteChangesetIterator;iVal:integer;
  var ppValue:HSQLiteValue): integer; cdecl;
function sqlite3changeset_conflict(pIter:HSQLiteChangesetIterator;iVal:integer;
  var ppValue:HSQLiteValue): integer; cdecl;
function sqlite3changeset_fk_conflicts(pIter:HSQLiteChangesetIterator;
  var pnOut:integer):integer; cdecl;
function sqlite3changeset_finalize(pIter:HSQLiteChangesetIterator):integer; cdecl;
function sqlite3changeset_invert(nIn:integer;pIn:pointer;var pnOut:integer;
  var ppOut:pointer):integer; cdecl;
function sqlite3changeset_concat(nA:integer;pA:pointer;nB:integer;pB:pointer;
  var pnOut:integer;var ppOut:pointer):integer; cdecl;
function sqlite3changeset_upgrade(SQLiteDB:HSQLiteDB;zDb:PAnsiChar;nIn:integer;
  pIn;pointer;var pnOut:integer;var ppOut:pointer):integer; cdecl;
function sqlite3changegroup_new(var pp:HSQLiteChangeGroup):integer; cdecl;
function sqlite3changegroup_add(cg:HSQLiteChangeGroup;nData:integer;
  pData:pointer):integer; cdecl;
function sqlite3changegroup_schema(cg:HSQLiteChangeGroup;db:HSQLiteDB;
  zDb:PAnsiChar):integer; cdecl;
function sqlite3changegroup_output(cg:HSQLiteChangeGroup;var pnData;
  var ppData:pointer):integer; cdecl;
procedure sqlite3changegroup_delete(cg:HSQLiteChangeGroup); cdecl;
function sqlite3changeset_apply(SQLiteDB:HSQLiteDB;nChangeset:integer;
  pChangeset:pointer;xFilter:TSQLiteSessionFilter;
  xConflict:TSQLiteChangesetConflict;pCtx:pointer):integer; cdecl;
function sqlite3changeset_apply_v2(SQLiteDB:HSQLiteDB;nChangeset:integer;
  pChangeset:pointer;xFilter:TSQLiteSessionFilter;
  xConflict:TSQLiteChangesetConflict;pCtx:pointer;var ppRebase:pointer;
  var pnRebase:integer;flags:integer):integer; cdecl;

const
  SQLITE_CHANGESETAPPLY_NOSAVEPOINT   = $0001;
  SQLITE_CHANGESETAPPLY_INVERT        = $0002;
  SQLITE_CHANGESETAPPLY_IGNORENOOP    = $0004;
  SQLITE_CHANGESETAPPLY_FKNOACTION    = $0008;

  SQLITE_CHANGESET_DATA        = 1;
  SQLITE_CHANGESET_NOTFOUND    = 2;
  SQLITE_CHANGESET_CONFLICT    = 3;
  SQLITE_CHANGESET_CONSTRAINT  = 4;
  SQLITE_CHANGESET_FOREIGN_KEY = 5;

  SQLITE_CHANGESET_OMIT       = 0;
  SQLITE_CHANGESET_REPLACE    = 1;
  SQLITE_CHANGESET_ABORT      = 2;

function sqlite3rebaser_create(var ppNew:HSQLiteRebaser):integer; cdecl;
function sqlite3rebaser_configure(SQLiteRebaser:HSQLiteRebaser;nRebase:integer;
  var pRebase:pointer):integer; cdecl;
function sqlite3rebaser_rebase(SQLiteRebaser:HSQLiteRebaser;nIn:integer;
  pIn:pointer;var pnOut:integer;var ppOut:pointer):integer; cdecl;
procedure sqlite3rebaser_delete(SQLiteRebaser:HSQLiteRebaser); cdecl;
function sqlite3changeset_apply_strm(SQLiteDB:HSQLiteDB;
  xInput:TSQLiteInputFn;pIn:pointer;xFilter:TSQLiteSessionFilter;
  xConflict:TSQLiteChangesetConflict;pCtx:pointer):integer; cdecl;
function sqlite3changeset_apply_v2_strm(SQLiteDB:HSQLiteDB;
  xInput:TSQLiteInputFn;pIn:pointer;xFilter:TSQLiteSessionFilter;
  xConflict:TSQLiteChangesetConflict;pCtx:pointer;var ppRebase:pointer;
  var pnRebase:integer;flags:integer):integer; cdecl;
function sqlite3changeset_concat_strm(xInputA:TSQLiteInputFn;pInA:pointer;
  xInputB:TSQLiteInputFn;pInB:pointer;xOutput:TSQLiteOutputFn;
  pOut:pointer):integer; cdecl;
function sqlite3changeset_invert_strm(xInput:TSQLiteInputFn;pIn:pointer;
  xOutput:TSQLiteOutputFn;pOut:pointer):integer; cdecl;
function sqlite3changeset_start_strm(var pp:HSQLiteChangesetIterator;
  xInput:TSQLiteInputFn;pIn:pointer):integer; cdecl;
function sqlite3session_changeset_strm(pSession:HSQLiteSession;
  xOutput:TSQLiteOutputFn;pOut:pointer):integer; cdecl;
function sqlite3session_patchset_strm(pSession:HSQLiteSession;
  xOutput:TSQLiteOutputFn;pOut:pointer):integer; cdecl;
function sqlite3changegroup_add_strm(cg:HSQLiteChangeGroup;
  xInput:TSQLiteInputFn;pIn:pointer):integer; cdecl;
function sqlite3rebaser_rebase_strm(pRebaser:HSQLiteRebaser;
  xInput:TSQLiteInputFn;pIn:pointer):integer; cdecl;
function sqlite3changegroup_output_strm(cg:HSQLiteChangeGroup;
  xOutput:TSQLiteOutputFn;pOut:pointer):integer; cdecl;

//fts5

implementation

const
  Sqlite3Dll='sqlite3.dll';

{$IF (CompilerVersion >= 14) and (defined(Win32) OR defined(Win64))}
{$DEFINE DELAYED_DLL_LOAD }
{$WARN symbol_platform OFF}
{$endif}

//sqlite3_preupdate

function sqlite3_snapshot_get; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3_snapshot_open; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
procedure sqlite3_snapshot_free; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3_snapshot_cmp; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};

//sqlite3_rtree_geometry_callback
//sqlite3_rtree_geometry

function sqlite3session_create; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
procedure sqlite3session_delete; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3session_enable; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3session_indirect; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3session_attach; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
procedure sqlite3session_table_filter; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3session_changeset; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3session_diff; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3session_patchset; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3session_isempty; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_start; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_next; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_op; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_pk; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_old; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_new; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_conflict; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_fk_conflicts; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_finalize; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_invert; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_concat; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_upgrade; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changegroup_new; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changegroup_add; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changegroup_schema; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changegroup_output; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
procedure sqlite3changegroup_delete; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_apply; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_apply_v2; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};

function sqlite3rebaser_create; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3rebaser_configure; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3rebaser_rebase; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
procedure sqlite3rebaser_delete; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_apply_strm; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_apply_v2_strm; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_concat_strm; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_invert_strm; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changeset_start_strm; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3session_changeset_strm; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3session_patchset_strm; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changegroup_add_strm; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3rebaser_rebase_strm; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};
function sqlite3changegroup_output_strm; external Sqlite3Dll {$IF DEFINED(DELAYED_DLL_LOAD)} delayed {$endif};

end.
