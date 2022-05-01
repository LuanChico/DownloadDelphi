program DownloadArquivo;

uses
  Vcl.Forms,
  ConexaoSQLite_U in 'Conexao\ConexaoSQLite_U.pas' {DataModuleConexao: TDataModule},
  DownloadArquivo_U in 'Fontes\DownloadArquivo_U.pas' {FormDownloadArquivo},
  HistoricoDownload_U in 'Fontes\HistoricoDownload_U.pas' {FormHistoricoDownload},
  InterfaceObservarProgresso_U in 'Interfaces\InterfaceObservarProgresso_U.pas',
  ManutencaoLogDownload_U in 'Util\ManutencaoLogDownload_U.pas',
  ThreadDownloadFile_U in 'Util\ThreadDownloadFile_U.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDataModuleConexao, DataModule);
  Application.CreateForm(TFormDownloadArquivo, FormDownloadArquivo);
  Application.Run;
end.
