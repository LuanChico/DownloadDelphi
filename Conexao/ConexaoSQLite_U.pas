unit ConexaoSQLite_U;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat;

type
  TDataModuleConexao = class(TDataModule)
    FDConnection: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);
  public
    procedure ExecSQL(SQL: String);
  end;
var
  DataModule: TDataModuleConexao;

implementation

{$R *.dfm}

{ TDataModuleConexao }

procedure TDataModuleConexao.DataModuleCreate(Sender: TObject);
begin
  Self.FDConnection.Params.Database := Concat(GetCurrentDir, '\..\..\BancoDeDados\logDownload.db');
  Self.FDConnection.Connected       := True;
end;
procedure TDataModuleConexao.ExecSQL(SQL: String);
begin
  try
    Self.FDConnection.Connected := True;
    Self.FDConnection.ExecSQL(SQL);
  finally
    Self.FDConnection.Connected := False;
  end;
end;

end.
