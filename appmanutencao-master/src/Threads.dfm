object fThreads: TfThreads
  Left = 0
  Top = 0
  Caption = 'fThreads'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 88
    Top = 21
    Width = 92
    Height = 13
    Caption = 'N'#250'mero de threads'
  end
  object Label2: TLabel
    Left = 232
    Top = 21
    Width = 108
    Height = 13
    Caption = 'Tempo entre itera'#231#245'es'
  end
  object Edit1: TEdit
    Left = 88
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'Edit1'
  end
  object Edit2: TEdit
    Left = 232
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 368
    Top = 38
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 2
    OnClick = Button1Click
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 282
    Width = 635
    Height = 17
    Align = alBottom
    TabOrder = 3
    ExplicitLeft = 112
    ExplicitTop = 240
    ExplicitWidth = 150
  end
  object Memo1: TMemo
    Left = 0
    Top = 80
    Width = 635
    Height = 202
    Align = alBottom
    Lines.Strings = (
      'Memo1')
    TabOrder = 4
  end
end
