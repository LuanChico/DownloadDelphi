unit InterfaceObservarProgresso_U;

interface

{$REGION 'usesInterface'}
uses
  System.Threading;
{$ENDREGION}

type
  TnStatusThread = (sAguardando, sExecutando, sCancelada, sConcluida, sPaginaNaoEncontrada);

  TDadosDownload = Record
    ProgressoMaximo   : Int64;
    ProgressoAtual    : Int64;
    PercentualDownload: Double;
    StatusThread      : TnStatusThread;
  End;

  IObserver = interface
  ['{4602FF2C-3407-48D4-B205-75001A2D40E8}']
    procedure Atualizar(Subject: TDadosDownload);
  end;

  ISubject = interface
  ['{48EEC6CA-BA0D-455E-B3B6-A4FD13E87E3E}']
    procedure AdicionarObserver(Observer: IObserver);
    procedure RemoverObserver(Observer: IObserver);
    procedure Notificar;
  end;

implementation

end.
