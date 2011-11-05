object formSQLiteAdminMain: TformSQLiteAdminMain
  Left = 192
  Top = 110
  Width = 423
  Height = 552
  Caption = 'SQLite Administrator'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Consolas'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    415
    525)
  PixelsPerInch = 96
  TextHeight = 14
  object Label2: TLabel
    Left = 8
    Top = 32
    Width = 21
    Height = 14
    Caption = 'SQL'
  end
  object Label3: TLabel
    Left = 184
    Top = 32
    Width = 70
    Height = 14
    Anchors = [akTop, akRight]
    Caption = 'Parameters'
  end
  object Label4: TLabel
    Left = 288
    Top = 32
    Width = 42
    Height = 14
    Anchors = [akTop, akRight]
    Caption = 'Values'
  end
  object txtCommand: TMemo
    Left = 8
    Top = 48
    Width = 169
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    Lines.Strings = (
      'select * from sqlite_master')
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object txtParamValues: TMemo
    Left = 288
    Top = 48
    Width = 113
    Height = 105
    Anchors = [akTop, akRight]
    ScrollBars = ssVertical
    TabOrder = 4
    WordWrap = False
  end
  object Button1: TButton
    Left = 8
    Top = 160
    Width = 393
    Height = 25
    Action = actRun
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
  end
  object txtParamNames: TMemo
    Left = 184
    Top = 48
    Width = 97
    Height = 105
    TabStop = False
    Anchors = [akTop, akRight]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
    WordWrap = False
  end
  object txtDbPath: TEdit
    Left = 8
    Top = 8
    Width = 361
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'test.db'
    OnChange = txtDbPathChange
  end
  object btnDbBrowse: TButton
    Left = 376
    Top = 8
    Width = 25
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 1
    OnClick = btnDbBrowseClick
  end
  object Panel1: TPanel
    Left = 8
    Top = 216
    Width = 393
    Height = 297
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Color = clAppWorkSpace
    TabOrder = 7
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 192
    Width = 393
    Height = 22
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    DropDownCount = 25
    ItemHeight = 14
    TabOrder = 6
    OnChange = ComboBox1Change
  end
  object ActionList1: TActionList
    Left = 32
    Top = 216
    object actRun: TAction
      Caption = 'Run'
      ShortCut = 116
      OnExecute = actRunExecute
    end
    object EditCut1: TEditCut
      Category = 'Edit'
      Caption = 'Cu&t'
      Hint = 'Cut|Cuts the selection and puts it on the Clipboard'
      ImageIndex = 0
      ShortCut = 16472
    end
    object EditPaste1: TEditPaste
      Category = 'Edit'
      Caption = '&Paste'
      Hint = 'Paste|Inserts Clipboard contents'
      ImageIndex = 2
      ShortCut = 16470
    end
    object EditSelectAll1: TEditSelectAll
      Category = 'Edit'
      Caption = 'Select &All'
      Hint = 'Select All|Selects the entire document'
      ShortCut = 16449
    end
    object EditUndo1: TEditUndo
      Category = 'Edit'
      Caption = '&Undo'
      Hint = 'Undo|Reverts the last action'
      ImageIndex = 3
      ShortCut = 16474
    end
    object EditDelete1: TEditDelete
      Category = 'Edit'
      Caption = '&Delete'
      Hint = 'Delete|Erases the selection'
      ImageIndex = 5
      ShortCut = 46
    end
    object actCopyRow: TAction
      Caption = 'Copy row data'
      ShortCut = 16451
      OnExecute = actCopyRowExecute
    end
    object actNextRS: TAction
      Caption = 'actNextRS'
      ShortCut = 117
      OnExecute = actNextRSExecute
    end
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 64
    Top = 216
  end
end
