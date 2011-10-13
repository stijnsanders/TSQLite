unit SQLiteAdminMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ActnList, StdActns, ExtCtrls;

type
  TformSQLiteAdminMain = class(TForm)
    txtCommand: TMemo;
    txtParamValues: TMemo;
    Button1: TButton;
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
    Panel1: TPanel;
    ComboBox1: TComboBox;
    actNextRS: TAction;
    procedure actRunExecute(Sender: TObject);
    procedure btnDbBrowseClick(Sender: TObject);
    procedure actCopyRowExecute(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure actNextRSExecute(Sender: TObject);
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
  lv:TListView;
  li:TListItem;
  s,t:string;
begin
  Panel1.Visible:=false;
  for i:=0 to ComboBox1.Items.Count-1 do ComboBox1.Items.Objects[i].Free;
  ComboBox1.Items.Clear;
  db:=TSQLiteConnection.Create(txtDbPath.Text);
  try
    if txtCommand.SelLength=0 then
      s:=txtCommand.Text
    else
      s:=txtCommand.SelText;

    while s<>'' do
     begin
      i:=1;
      st:=TSQLiteStatement.Create(db,UTF8Encode(s),i);
      try
        s:=Copy(s,i+1,Length(s)-i);
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

        lv:=TListView.Create(Self);
        lv.Parent:=Panel1;
        lv.HideSelection:=false;
        lv.MultiSelect:=true;
        lv.ReadOnly:=true;
        lv.RowSelect:=true;
        lv.ViewStyle:=vsReport;
        lv.Align:=alClient;
        lv.Items.BeginUpdate;
        try
          with lv.Columns.Add do
           begin
            Caption:='#';
            Width:=-1;
           end;
          t:='';
          //if b then
            for i:=0 to st.FieldCount-1 do
             begin
              with lv.Columns.Add do
               begin
                Caption:=st.FieldName[i];
                Width:=-1;
               end;
              t:=t+' '+st.FieldName[i];
             end;
          i:=0;
          while b do
           begin
            inc(i);
            li:=lv.Items.Add;
            li.Caption:=IntToStr(i);
            for j:=0 to st.FieldCount-1 do li.SubItems.Add(VarToStr(st[j]));
            b:=st.Read;
           end;
        finally
          lv.Items.EndUpdate;
        end;
        ComboBox1.Items.AddObject(IntToStr(ComboBox1.Items.Count+1)+'('+IntToStr(i)+')'+t,lv);

      finally
        st.Free;
      end;
     end;
  finally
    db.Free;
    if ComboBox1.Items.Count<>0 then
     begin
      ComboBox1.ItemIndex:=0;
      (ComboBox1.Items.Objects[0] as TListView).BringToFront;
     end;
    Panel1.Visible:=true;
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
    if ActiveControl is TListView then with ActiveControl as TListView do
     begin
      for i:=0 to Items.Count-1 do
        if Items[i].Selected then
          s:=s+Items[i].Caption+#13#10+Items[i].SubItems.Text+#13#10;
      Clipboard.AsText:=s;
     end;
end;

procedure TformSQLiteAdminMain.ComboBox1Change(Sender: TObject);
begin
  (ComboBox1.Items.Objects[ComboBox1.ItemIndex] as TListView).BringToFront;
end;

procedure TformSQLiteAdminMain.actNextRSExecute(Sender: TObject);
begin
  if ComboBox1.ItemIndex=ComboBox1.Items.Count-1 then
    ComboBox1.ItemIndex:=0
  else
    ComboBox1.ItemIndex:=ComboBox1.ItemIndex+1;
  (ComboBox1.Items.Objects[ComboBox1.ItemIndex] as TListView).BringToFront;
end;

end.
