unit ManutencaoLogDownload_U;

interface

type
  TManutencaoLogDownload = class(TObject)
  private
    class function GetProximoCodigoDisponivel: Integer;
  public
    class function GravarLogDownload(Url: String): Integer;
    class procedure AtualizarDataTerminoDownload(Id: Integer);
  end;

  const
    SQLInsert = 'INSERT INTO LOGDOWNLOAD (CODIGO, URL, DATAINICIO) VALUES (%d, %s, %s)';
    SQLUpdate = 'UPDATE LOGDOWNLOAD SET DATAFIM=%s WHERE CODIGO=%d';

implementation

{$REGION 'usesImplementation'}
uses
  System.SysUtils,
  FireDAC.Comp.Client,
  ConexaoSQLite_U;
{$ENDREGION}

{ TManutencaoLogDownload }

class function TManutencaoLogDownload.GetProximoCodigoDisponivel: Integer;
var
  ADados: TFDQuery;
begin
  try
    ADados := TFDQuery.Create(nil);
    try
      DataModule.FDConnection.Connected := True;
      ADados.Connection := DataModule.FDConnection;
      ADados.Open('SELECT COALESCE(MAX(CODIGO),0)+1 AS CODIGO FROM LOGDOWNLOAD');
      Result := ADados.FieldByName('CODIGO').AsInteger;
    finally
      DataModule.FDConnection.Connected := False;
      FreeAndNil(ADados);
    end;
  except on E: Exception do
    raise Exception.Create('N?o foi poss?vel pegar o pr?ximo sequencial da Tabela!');
  end;
end;

class function TManutencaoLogDownload.GravarLogDownload(Url: String): Integer;
var
  CodigoLog: Integer;

  function GetSQLFormatado: String;
  begin
    Result := Format(SQLInsert, [CodigoLog,
                                 QuotedStr(Url),
                                 QuotedStr(DateToStr(Now))]);
  end;

begin
  CodigoLog := GetProximoCodigoDisponivel;
  try
    DataModule.ExecSQL(GetSQLFormatado);
    Result := CodigoLog;
  except on E: Exception do
    raise Exception.Create('N?o foi Poss?vel Incluir o Log do Download!');
  end;
end;

class procedure TManutencaoLogDownload.AtualizarDataTerminoDownload(Id: Integer);

  function GetSQLFormatado: String;
  begin
    Result := Format(SQLUpdate, [QuotedStr(DateToStr(Now)),Id]);
  end;

begin
  try
    DataModule.ExecSQL(GetSQLFormatado);
  except on E: Exception do
    raise Exception.Create('N?o foi poss?vel Atualizar a DataFim!');
  end;
end;

end.
