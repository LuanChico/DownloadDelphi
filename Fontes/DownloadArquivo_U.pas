unit DownloadArquivo_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Variants, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Vcl.ComCtrls, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, System.Threading,
  ThreadDownloadFile_U, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, HistoricoDownload_U, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, System.Classes, InterfaceObservarProgresso_U,
  Vcl.Buttons;

type
  TFormDownloadArquivo = class(TForm, IObserver)
    PanelIcones: TPanel;
    Image1: TImage;
    Image2: TImage;
    PanelControles: TPanel;
    SaveDialog: TSaveDialog;
    EditURL: TEdit;
    EditDestinoDownload: TEdit;
    ProgressBar: TProgressBar;
    BotaoIniciarDownload: TButton;
    BotaoPararDownload: TButton;
    BotaoExibirMensagem: TButton;
    Button1: TButton;
    BotaoCaminhoSalvarDownload: TSpeedButton;
    LabelDestinoDownload: TLabel;
    LabelURL: TLabel;
    procedure BotaoIniciarDownloadClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BotaoExibirMensagemClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BotaoPararDownloadClick(Sender: TObject);
    procedure BotaoCaminhoSalvarDownloadClick(Sender: TObject);
  private
    FThreadDownload    : TThreadDownload;
    FPercentualDownload: Double;
    FStatusThread      : TnStatusThread;

    procedure StartDownload;
    procedure InicializarVariaveis;
    procedure VerificaOperacao;
    procedure HabilitaControles(Habilita: Boolean = True);

    function ValidarCampos: Boolean;
  public
    procedure Atualizar(Subject: TDadosDownload);
  end;

var
  FormDownloadArquivo: TFormDownloadArquivo;

implementation

uses
  System.SysUtils;

{$R *.dfm}

procedure TFormDownloadArquivo.Atualizar(Subject: TDadosDownload);
begin
  Self.ProgressBar.Max      := Subject.ProgressoMaximo;
  Self.ProgressBar.Position := Subject.ProgressoAtual;
  Self.FPercentualDownload  := Subject.PercentualDownload;
  Self.FStatusThread        := Subject.StatusThread;
  Self.VerificaOperacao;
end;

procedure TFormDownloadArquivo.BotaoCaminhoSalvarDownloadClick(Sender: TObject);

  function GetExtencaoArquivo: String;
  begin
    Result := ExtractFileExt(EditURL.Text);
  end;

  function GetNomeArquivo: String;
  var
    ArrayNomes: TArray<String>;
  begin
    ArrayNomes := String(EditURL.Text).Split(['/']);
    Result     := ArrayNomes[Length(ArrayNomes)-1].Replace(GetExtencaoArquivo, EmptyStr);
  end;

  function GetFilter: String;
  begin
    Result := Concat('Download (', GetExtencaoArquivo, ')|*', GetExtencaoArquivo);
  end;

begin
  SaveDialog.Filter   := GetFilter;
  SaveDialog.FileName := GetNomeArquivo;

  if SaveDialog.Execute then
    EditDestinoDownload.Text := Concat(SaveDialog.FileName, GetExtencaoArquivo);
end;

procedure TFormDownloadArquivo.BotaoExibirMensagemClick(Sender: TObject);
var
  Mensagem: PWideChar;
begin
  Mensagem := PWideChar(Concat('Download em ', FormatFloat('0 %', FPercentualDownload)));
  if Assigned(Self.FThreadDownload) then
    Application.MessageBox(Mensagem, '', MB_OK);
end;

procedure TFormDownloadArquivo.Button1Click(Sender: TObject);
var
  HistoricoDownload: TFormHistoricoDownload;
begin
  HistoricoDownload := TFormHistoricoDownload.Create(Self);
  try
    HistoricoDownload.ShowModal;
  finally
    FreeAndNil(HistoricoDownload);
  end;
end;

procedure TFormDownloadArquivo.BotaoIniciarDownloadClick(Sender: TObject);
begin
  Self.StartDownload;
end;

procedure TFormDownloadArquivo.BotaoPararDownloadClick(Sender: TObject);
begin
  Self.FThreadDownload.PararDownload;
end;

procedure TFormDownloadArquivo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Self.FStatusThread = sExecutando then
  begin
    if Application.MessageBox('Existe um download em andamento, deseja interrompe-lo?', '', MB_YESNO) = 6 then
    begin
      Self.FThreadDownload.PararDownload;
    end
    else
      Abort;
  end;
end;

procedure TFormDownloadArquivo.FormCreate(Sender: TObject);
begin
  Self.FThreadDownload := TThreadDownload.Create;
  Self.FThreadDownload.AdicionarObserver(Self);
  Self.InicializarVariaveis;
end;

procedure TFormDownloadArquivo.InicializarVariaveis;
begin
  Self.ProgressBar.Max      := 0;
  Self.ProgressBar.Position := 0;
  Self.FPercentualDownload  := 0;
  Self.HabilitaControles;
end;

procedure TFormDownloadArquivo.HabilitaControles(Habilita: Boolean);
begin
  Self.EditURL.Enabled              := Habilita;
  Self.EditDestinoDownload.Enabled  := Habilita;
  Self.BotaoIniciarDownload.Enabled := Habilita;
  Self.BotaoPararDownload.Enabled   := (not Self.BotaoIniciarDownload.Enabled);
end;

procedure TFormDownloadArquivo.StartDownload;
begin
  if not Self.ValidarCampos then
    Exit;

  Self.HabilitaControles(False);
  Self.FThreadDownload.URL             := Self.EditURL.Text;
  Self.FThreadDownload.DestinoDownload := Self.EditDestinoDownload.Text;
  Self.FThreadDownload.Executar;
end;

function TFormDownloadArquivo.ValidarCampos: Boolean;
begin
  Result := False;

  if Trim(EditURL.Text).IsEmpty then
  begin
    Application.MessageBox('O Campo URL ? de Preenchimento Obrigat?rio!', '', MB_OK);
    Exit;
  end;

  if Trim(EditDestinoDownload.Text).IsEmpty then
  begin
    Application.MessageBox('O Campo Destino Download ? de Preenchimento Obrigat?rio!', '', MB_OK);
    Exit;
  end;

  Result := True;
end;

procedure TFormDownloadArquivo.VerificaOperacao;
begin
  if Self.FStatusThread = sConcluida then
  begin
    Application.MessageBox('Download Conclu?do com Sucesso!', '', MB_OK);
    Self.InicializarVariaveis;
  end else
  if Self.FStatusThread = sCancelada then
  begin
    Application.MessageBox('Download Cancelado Pelo Usu?rio!', '', MB_OK);
    Self.InicializarVariaveis;
  end else
  if Self.FStatusThread = sPaginaNaoEncontrada then
  begin
    Application.MessageBox('URL informado n?o existe!', '', MB_OK);
    Self.InicializarVariaveis;
  end;
end;

end.
