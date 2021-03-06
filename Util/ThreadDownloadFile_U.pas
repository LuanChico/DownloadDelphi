unit ThreadDownloadFile_U;

interface

{$REGION 'usesInterface'}
uses
  System.Classes,
  Vcl.ComCtrls,
  IdHTTP,
  IdSSLOpenSSL,
  IdAntiFreeze,
  IdComponent,
  ConexaoSQLite_U,
  InterfaceObservarProgresso_U,
  System.Generics.Collections,
  System.Threading;
{$ENDREGION}

type
  TThreadDownload = class(TInterfacedObject, ISubject)
    procedure IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;AWorkCountMax: Int64);
    procedure IdHTTP1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;AWorkCount: Int64);
  private
    FIdHTTP            : TIdHTTP;
    FIdSSL             : TIdSSLIOHandlerSocketOpenSSL;
    FIdAntiFreeze      : TIdAntiFreeze;
    FURL               : String;
    FDestinoDownload   : String;
    FIdLogDownload     : Integer;
    FListaObserver     : TList<IObserver>;
    FTask              : ITask;
    FDadosDownload     : TDadosDownload;

    procedure CriarObjetosHTTP;
    procedure DestruirObjetos;
  public
    procedure AdicionarObserver(Observer: IObserver);
    procedure RemoverObserver(Observer: IObserver);
    procedure Notificar;
    procedure Executar;
    procedure PararDownload;

    destructor Destroy; override;

    property URL            : String write FURL;
    property DestinoDownload: String write FDestinoDownload;
  end;

implementation

{$REGION 'usesImplementation'}
uses
  System.SysUtils,
  Vcl.Dialogs,
  ManutencaoLogDownload_U;
{$ENDREGION}

{ TThreadDownload }

procedure TThreadDownload.CriarObjetosHTTP;
begin
  Self.DestruirObjetos;
  Self.FIdHTTP                     := TIdHTTP.Create(nil);
  Self.FIdSSL                      := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  Self.FIdSSL.SSLOptions.Method    := sslvSSLv23;
  Self.FIdHTTP.IOHandler           := FIdSSL;
  Self.FIdHTTP.OnWork              := Self.IdHTTPWork;
  Self.FIdHTTP.OnWorkBegin         := Self.IdHTTPWorkBegin;
  Self.FIdHTTP.OnWorkEnd           := Self.IdHTTP1WorkEnd;

  Self.FDadosDownload.StatusThread := sAguardando;
  Self.FIdAntiFreeze               := TIdAntiFreeze.Create(nil);
end;

destructor TThreadDownload.Destroy;
begin
  Self.DestruirObjetos;
  if Assigned(Self.FListaObserver) then
    FreeAndNil(Self.FListaObserver);
  inherited;
end;

procedure TThreadDownload.DestruirObjetos;
begin
  if Assigned(Self.FIdHTTP) then
    FreeAndNil(Self.FIdHTTP);

  if Assigned(Self.FIdSSL) then
    FreeAndNil(Self.FIdSSL);

  if Assigned(Self.FIdAntiFreeze) then
    FreeAndNil(Self.FIdAntiFreeze);
end;

procedure TThreadDownload.IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;AWorkCountMax: Int64);
begin
  Self.FIdLogDownload                 := TManutencaoLogDownload.GravarLogDownload(Self.FURL);
  Self.FDadosDownload.ProgressoMaximo := AWorkCountMax;
  Self.FDadosDownload.StatusThread    := sExecutando;
  Self.Notificar;
end;

procedure TThreadDownload.IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;AWorkCount: Int64);
begin
  Self.FTask.CheckCanceled;
  Self.FDadosDownload.ProgressoAtual     := AWorkCount;
  Self.FDadosDownload.PercentualDownload := (AWorkCount * 100) / Self.FDadosDownload.ProgressoMaximo;
  Self.Notificar;
end;

procedure TThreadDownload.IdHTTP1WorkEnd(ASender: TObject;AWorkMode: TWorkMode);
begin
  if not (Self.FTask.Status = TTaskStatus.Canceled) then
  begin
    if Self.FDadosDownload.ProgressoMaximo > 200 then
    begin
      TManutencaoLogDownload.AtualizarDataTerminoDownload(Self.FIdLogDownload);
      Self.FDadosDownload.StatusThread := sConcluida;
      Self.Notificar;
    end;
  end;
end;

procedure TThreadDownload.PararDownload;
begin
  Self.FTask.Cancel;
end;

procedure TThreadDownload.Executar;
begin
  Self.CriarObjetosHTTP;
  FTask := TTask.Create(
  procedure
  begin
    TThread.Synchronize(TThread.CurrentThread,
    procedure
    var
      FileDownload : TFileStream;
    begin
      FileDownload := TFileStream.Create(Self.FDestinoDownload, fmCreate);
      try
        try
          FIdHTTP.Get(Self.FURL, fileDownload);
        except
          on E:Exception do
          begin
            if E.Message.ToUpper.Contains('404 NOT FOUND') then
              Self.FDadosDownload.StatusThread := sPaginaNaoEncontrada
            else
              Self.FDadosDownload.StatusThread := sCancelada;
            Self.Notificar;
          end;
        end;
      finally
        FreeAndNil(fileDownload);
      end;
    end);
  end);

  try
    Self.FTask.Start;
  except on E: Exception do
    raise Exception.Create('Falha ao Rodar Thread!');
  end;
end;

procedure TThreadDownload.AdicionarObserver(Observer: IObserver);
begin
  if not Assigned(Self.FListaObserver) then
    Self.FListaObserver := TList<IObserver>.Create;
  Self.FListaObserver.Add(Observer);
end;

procedure TThreadDownload.RemoverObserver(Observer: IObserver);
begin
  if Assigned(Self.FListaObserver) then
    Self.FListaObserver.Remove(Observer);
end;

procedure TThreadDownload.Notificar;
var
  Observer: IObserver;
begin
  for Observer in Self.FListaObserver do
    Observer.Atualizar(Self.FDadosDownload);
end;
end.
