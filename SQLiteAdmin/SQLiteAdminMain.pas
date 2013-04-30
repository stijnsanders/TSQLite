unit SQLiteAdminMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ActnList, StdActns, ExtCtrls, SQLiteData;

type
  TformSQLiteAdminMain = class(TForm)
    ActionList1: TActionList;
    actRun: TAction;
    EditCut1: TEditCut;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditUndo1: TEditUndo;
    EditDelete1: TEditDelete;
    OpenDialog1: TOpenDialog;
    actCopyRow: TAction;
    actNextRS: TAction;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Splitter1: TSplitter;
    Panel1: TPanel;
    ComboBox1: TComboBox;
    btnRun: TButton;
    txtDbPath: TEdit;
    btnDbBrowse: TButton;
    Label2: TLabel;
    txtCommand: TMemo;
    Label3: TLabel;
    txtParamNames: TMemo;
    Label4: TLabel;
    txtParamValues: TMemo;
    actAbort: TAction;
    procedure actRunExecute(Sender: TObject);
    procedure btnDbBrowseClick(Sender: TObject);
    procedure actCopyRowExecute(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure actNextRSExecute(Sender: TObject);
    procedure txtDbPathChange(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure EditSelectAll1Execute(Sender: TObject);
    procedure actAbortExecute(Sender: TObject);
  private
    Fdb: TSQLiteConnection;
    FAbortRequest:boolean;
    FAbortCheck:cardinal;
    procedure ResetAbort;
    procedure CheckAbort;
  protected
    procedure DoCreate; override;
    procedure DoDestroy; override;
  public
    function CloseQuery: Boolean; override;
  end;

var
  formSQLiteAdminMain: TformSQLiteAdminMain;

implementation

uses
  Clipbrd;

{$R *.dfm}

procedure TformSQLiteAdminMain.DoCreate;
begin
  inherited;
  Fdb:=nil;
  if ParamCount>0 then txtDbPath.Text:=ParamStr(1);
  if ParamCount>1 then txtCommand.Lines.LoadFromFile(ParamStr(2));
end;

procedure TformSQLiteAdminMain.DoDestroy;
begin
  inherited;
  FreeAndNil(Fdb);
end;

procedure TformSQLiteAdminMain.actRunExecute(Sender: TObject);
var
  st:TSQLiteStatement;
  b:boolean;
  i,j,ref1,ref2,firstres:integer;
  lv:TListView;
  li:TListItem;
  s,t:string;
begin
  ResetAbort;
  Panel1.Visible:=false;
  for i:=0 to ComboBox1.Items.Count-1 do ComboBox1.Items.Objects[i].Free;
  ComboBox1.Items.Clear;
  if Fdb=nil then Fdb:=TSQLiteConnection.Create(txtDbPath.Text);
  firstres:=0;
  Screen.Cursor:=crHourGlass;
  try
    if txtCommand.SelLength=0 then
     begin
      s:=txtCommand.Text;
      ref2:=0;
     end
    else
     begin
      s:=txtCommand.SelText;
      ref2:=txtCommand.SelStart;
     end;

    ref1:=ref2;
    try
      while s<>'' do
       begin
        i:=1;
        st:=TSQLiteStatement.Create(Fdb,UTF8Encode(s),i);
        try
          ref1:=ref2;
          inc(ref2,i);
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
              CheckAbort;
             end;
          finally
            lv.Items.EndUpdate;
          end;
          if (firstres=0) and (st.FieldCount<>0) then // and (i<>0) then ?
            firstres:=ComboBox1.Items.Count;
          ComboBox1.Items.AddObject(IntToStr(ComboBox1.Items.Count+1)+'('+IntToStr(i)+')'+t,lv);

          if s<>'' then CheckAbort;
        finally
          st.Free;
        end;
       end;
    except
      txtCommand.SelLength:=0;
      txtCommand.SelStart:=ref1;
      txtCommand.SelLength:=ref2-ref1-1;
      txtCommand.SetFocus;
      raise;
    end;
  finally
    Screen.Cursor:=crDefault;
    if ComboBox1.Items.Count<>0 then
     begin
      ComboBox1.ItemIndex:=firstres;
      (ComboBox1.Items.Objects[firstres] as TListView).BringToFront;
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
  if ActiveControl is TCustomEdit then
    (ActiveControl as TCustomEdit).CopyToClipboard
  else
    if ActiveControl is TListView then with ActiveControl as TListView do
     begin
      s:='';
      for i:=0 to Items.Count-1 do
        if Items[i].Selected then
         begin
          Items[i].SubItems.Delimiter:=#9;
          s:=s+//Items[i].Caption+#9+
            Items[i].SubItems.DelimitedText+#13#10;
         end;
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

procedure TformSQLiteAdminMain.txtDbPathChange(Sender: TObject);
begin
  FreeAndNil(Fdb);
end;

procedure TformSQLiteAdminMain.Splitter1Moved(Sender: TObject);
begin
  btnRun.Top:=Splitter1.Top+8;
end;

procedure TformSQLiteAdminMain.EditSelectAll1Execute(Sender: TObject);
begin
  if ActiveControl is TCustomEdit then
    (ActiveControl as TCustomEdit).SelectAll
  else
    if ActiveControl is TListView then
      (ActiveControl as TListView).SelectAll;
end;

procedure TformSQLiteAdminMain.actAbortExecute(Sender: TObject);
begin
  FAbortRequest:=true;
end;

procedure TformSQLiteAdminMain.ResetAbort;
begin
  FAbortRequest:=false;
  FAbortCheck:=GetTickCount;
end;

procedure TformSQLiteAdminMain.CheckAbort;
begin
  if cardinal(GetTickCount-FAbortCheck)>=100 then
   begin
    Application.ProcessMessages;
    if FAbortRequest then raise Exception.Create('User aborted.');
   end;
end;

function TformSQLiteAdminMain.CloseQuery: Boolean;
begin
  Result:=inherited CloseQuery;
  FAbortRequest:=true;
end;

end.
