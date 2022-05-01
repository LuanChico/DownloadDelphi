object FormHistoricoDownload: TFormHistoricoDownload
  Left = 0
  Top = 0
  Caption = 'Hist'#243'rico de Download'#39's'
  ClientHeight = 506
  ClientWidth = 850
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnShow = FormShow
  TextHeight = 15
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 850
    Height = 506
    Align = alClient
    DataSource = DataSourceDados
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'Codigo'
        Title.Caption = 'C'#243'digo'
        Width = 80
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Url'
        Width = 500
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DATAINICIO'
        Title.Caption = 'Data In'#237'cio'
        Width = 80
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DATAFIM'
        Title.Caption = 'Data Fim'
        Width = 80
        Visible = True
      end>
  end
  object DataSetDados: TFDQuery
    Connection = DataModuleConexao.FDConnection
    SQL.Strings = (
      'select '
      'CODIGO, '
      'URL, '
      'CAST(DATAINICIO AS TEXT) AS DATAINICIO, '
      'CAST(DATAFIM AS TEXT) AS DATAFIM '
      'FROM LOGDOWNLOAD')
    Left = 600
    Top = 96
  end
  object DataSourceDados: TDataSource
    DataSet = DataSetDados
    Left = 696
    Top = 96
  end
end
