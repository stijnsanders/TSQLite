unit SQLiteAdminMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ActnList, StdActns;

type
  TformSQLiteAdminMain = class(TForm)
    txtCommand: TMemo;
    txtParamValues: TMemo;
    Button1: TButton;
    ListView1: TListView;
    ActionList1: TActionList;
    actRun: TAction;
    txtParamNames: TMemo;
    EditCut1: TEditCut;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditUndo1: TEditUndo;
    EditDelete1: TEditDelete;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    OpenDialog1: TOpenDialog;
    txtDbPath: TEdit;
    btnDbBrowse: TButton;
    actCopyRow: TAction;
    procedure actRunExecute(Sender: TObject);
    procedure btnDbBrowseClick(Sender: TObject);
    procedure actCopyRowExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formSQLiteAdminMain: TformSQLiteAdminMain;

implementation

uses
  SQLiteData, Clipbrd;

{$R *.dfm}

procedure TformSQLiteAdminMain.actRunExecute(Sender: TObject);
var
  db:TSQLiteConnection;
  st:TSQLiteStatement;
  b:boolean;
  i,j:integer;
  li:TListItem;
  s:string;
begin
  db:=TSQLiteConnection.Create(txtDbPath.Text);
  try
    if txtCommand.SelLength=0 then
      s:=txtCommand.Text
    else
      s:=txtCommand.SelText;
    st:=TSQLiteStatement.Create(db,UTF8Encode(s));
    try
      txtParamNames.Lines.BeginUpdate;
      try
        txtParamNames.Clear;
        for i:=1 to st.ParameterCount do
          txtParamNames.Lines.Add(st.ParameterName[i]);
      finally
        txtParamNames.Lines.EndUpdate;
      end;

      for i:=0 to txtParamValues.Lines.Count-1 do
        if TryStrToInt(txtParamValues.Lines[i],j) then
          st.Parameter[i+1]:=j
        else
          st.Parameter[i+1]:=txtParamValues.Lines[i];
      b:=st.Read;
      ListView1.Items.BeginUpdate;
      try
        ListView1.Clear;
        ListView1.Columns.Clear;
        with ListView1.Columns.Add do
         begin
          Caption:='#';
          Width:=-1;
         end;
        //if b then
          for i:=0 to st.FieldCount-1 do
            with ListView1.Columns.Add do
             begin
              Caption:=st.FieldName[i];
              Width:=-1;
             end;
        i:=0;
        while b do
         begin
          inc(i);
          li:=ListView1.Items.Add;
          li.Caption:=IntToStr(i);
          for j:=0 to st.FieldCount-1 do li.SubItems.Add(VarToStr(st[j]));
          b:=st.Read;
         end;
      finally
        ListView1.Items.EndUpdate;
      end;
    finally
      st.Free;
    end;
  finally
    db.Free;
  end;
end;

procedure TformSQLiteAdminMain.btnDbBrowseClick(Sender: TObject);
begin
  OpenDialog1.FileName:=txtDbPath.Text;
  if OpenDialog1.Execute then txtDbPath.Text:=OpenDialog1.FileName;
end;

procedure TformSQLiteAdminMain.actCopyRowExecute(Sender: TObject);
var
  s:string;
  i:integer;
begin
  if ActiveControl is TCustomEdit then (ActiveControl as TCustomEdit).CopyToClipboard else
    if ActiveControl=ListView1 then
     begin
      for i:=0 to ListView1.Items.Count-1 do
        if ListView1.Items[i].Selected then
          s:=s+ListView1.Items[i].Caption+#13#10+ListView1.Items[i].SubItems.Text+#13#10;
      Clipboard.AsText:=s;
     end;
end;

end.
