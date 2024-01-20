unit untEntMaquinas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
   DBGrids, ComCtrls, StdCtrls, MaskEdit, ZDataset, untDataModule, classeUsuario
  , ClasseNsMaq
  , DBCtrls
  , ClasseMovimentacao;

type

  { TfrmEntMaq }

  TfrmEntMaq = class(TForm)
    btnCancelar: TSpeedButton;
    btnConfirmar: TSpeedButton;
    btnLimpar: TSpeedButton;
    cbxSitMaq: TComboBox;
    dbgDados: TDBGrid;
    edtQuantidade: TEdit;
    lblQuant: TLabel;
    lblSituacao: TLabel;
    lcbMaquinas: TDBLookupComboBox;
    dtsMaqNs: TDataSource;
    dtsMaqExist: TDataSource;
    edtNsMaq: TLabeledEdit;
    lblMaquina: TLabel;
    lblFuncionario1: TLabel;
    lblNomeUsr: TLabel;
    lblUseCadastrando: TLabel;
    pgcEntrada: TPageControl;
    pnlCadastro: TPanel;
    pnlCentral: TPanel;
    pnlLateral: TPanel;
    pnlTop: TPanel;
    qryMaqNs: TZQuery;
    qryMaqExist: TZQuery;
    qryMaqExistID_MAQ: TLongintField;
    qryMaqExistNOME_MAQ: TStringField;
    qryMaqNsID_MAQ: TLongintField;
    qryMaqNsNOME_MAQ: TStringField;
    qryMaqNsNS_MAQ: TStringField;
    qryMaqNsSituacao: TStringField;
    spbAdicionar: TSpeedButton;
    spbAlterar: TSpeedButton;
    spbExcluir: TSpeedButton;
    spbSair: TSpeedButton;
    tbsCadastro: TTabSheet;
    tbsGerenciar: TTabSheet;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure spbAdicionarClick(Sender: TObject);
    procedure spbAlterarClick(Sender: TObject);
    procedure spbExcluirClick(Sender: TObject);
    procedure spbSairClick(Sender: TObject);
  private
    procedure procAjustaTela(Cadastro:boolean);
    function funCampoObrigatorio:Boolean;
    function funGravar: Boolean;
  public

  end;

var
  frmEntMaq: TfrmEntMaq;
  FobjNsMaq: TNsMaq;
  FobjMovimentacao: TMovimentacao;
  TipoCadastro: integer; //1-Novo 2-Alterar

implementation

{$R *.lfm}

uses untPrinc;

{ TfrmEntMaq }

procedure TfrmEntMaq.spbSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmEntMaq.procAjustaTela(Cadastro: boolean);
begin
  if cadastro = true then
  begin
    spbAdicionar.Enabled:= false;
    spbAlterar.Enabled:= false;
    spbSair.Enabled:= false;
    spbExcluir.Enabled:= false;
    pgcEntrada.Pages[0].Enabled:= false;
    pgcEntrada.Pages[0].tabvisible:= false;
    pgcEntrada.Pages[1].Enabled:= true;
    pgcEntrada.Pages[1].tabvisible:= true;
  end
  else
  begin
    spbAdicionar.Enabled:= true;
    spbAlterar.Enabled:= true;
    spbSair.Enabled:= true;
    spbExcluir.Enabled:= true;
    pgcEntrada.Pages[1].Enabled:= false;
    pgcEntrada.Pages[1].tabvisible:= false;
    pgcEntrada.Pages[0].Enabled:= true;
    pgcEntrada.Pages[0].tabvisible:= true;
  end;
end;

function TfrmEntMaq.funCampoObrigatorio: Boolean;
var i: integer;
begin
  result:= false;
  for i := 0 to ComponentCount -1 do
  begin
    if Components[i] is TLabeledEdit then
    begin
      if (TLabeledEdit (Components[i]).Tag = 2) and (TLabeledEdit (Components[i]).Text = EmptyStr) then
      begin
        MessageDlg(TLabeledEdit (Components[i]).EditLabel.Caption + ' é um campo obrigatório', mtInformation, [mbOK], 0);
        TLabeledEdit (Components[i]).SetFocus;
        result := true;
        break;
      end;
    end;

    if Components[i] is TEdit then
    begin
      if (TEdit (Components[i]).Tag = 2) and (TEdit (Components[i]).Text = EmptyStr) then
      begin
        MessageDlg('Existem campos obrigatórios não preenchidos.', mtInformation, [mbOK], 0);
        TEdit (Components[i]).SetFocus;
        result := true;
        break;
      end;
    end;
  end;

  if (result = false) and (lcbMaquinas.Caption = EmptyStr) then
  begin
    MessageDlg('Máquina é um campo obrigatório', mtInformation, [mbOK], 0);
    lcbMaquinas.SetFocus;
    Result := true;
  end;
end;

function TfrmEntMaq.funGravar: Boolean;
begin

  FobjNsMaq.IdMaq:= lcbMaquinas.KeyValue;
  FobjNsMaq.NsMaq:= edtNsMaq.Caption;
  FobjNsMaq.StNs:= cbxSitMaq.ItemIndex;
  FobjNsMaq.IdUsrCad:= FobjUsuario.Codigo;

  if TipoCadastro = 1 then
  begin
    Result:= FobjNsMaq.Inserir;
    FobjNsMaq.proximoID;
  end
  else
    Result:= FobjNsMaq.Atualizar;

  FobjMovimentacao.IdMaq:= lcbMaquinas.KeyValue;
  FobjMovimentacao.IdFunc:= FobjUsuario.Codigo;
  FobjMovimentacao.IdNs:= FobjNsMaq.IdNS;
  FobjMovimentacao.TipoMov:= 2;
  FobjMovimentacao.QtEstoque:= StrToInt(edtQuantidade.Caption);


  if TipoCadastro = 1 then
  begin
    Result:= FobjMovimentacao.Inserir;
  end;
end;

procedure TfrmEntMaq.FormShow(Sender: TObject);
begin
  qryMaqExist.Open;
  qryMaqNs.open;
  cbxSitMaq.ItemIndex:= 1;
  lblNomeUsr.Caption:= FobjUsuario.Nome;
  pgcEntrada.Pages[1].Enabled:= false;
  pgcEntrada.Pages[1].tabvisible:= false;
  pgcEntrada.Pages[0].Enabled:= true;
  pgcEntrada.Pages[0].tabvisible:= true;
end;

procedure TfrmEntMaq.spbAdicionarClick(Sender: TObject);
begin
  procAjustaTela(true);
  TipoCadastro:= 1;
  if lcbMaquinas.CanFocus then
     lcbMaquinas.SetFocus;
end;

procedure TfrmEntMaq.spbAlterarClick(Sender: TObject);
begin
 { if FobjFuncionarios.Selecionar(qryFuncionarios.FieldByName('ID_FUNC').AsInteger) then
  begin
    edtNome.Caption := FobjFuncionarios.NomeFunc ;
    edtCPF.Caption := FobjFuncionarios.Cpf;
    edtUsuario.Caption := FobjFuncionarios.Usuario;
    edtSenha.Caption := FobjFuncionarios.Senha;
    dtAdm.Date := FobjFuncionarios.DtAdm;

    procAjustaTela(true);
    TipoCadastro:= 2;
  end;   }
end;

procedure TfrmEntMaq.spbExcluirClick(Sender: TObject);
begin
  with TTaskDialog.Create(self) do
  try
    Caption := 'Confirmação:';
    Title := 'Excluir o Cadastro?';
    Text := 'Deseja EXCLUIR o cadastro? Não será possível recuperar!';
    CommonButtons := [tcbYes, tcbNo];
    MainIcon := tdiWarning;
    if Execute then
    begin
      if ModalResult = mrYes then
      begin
        FobjNsMaq.IdNS:= qryMaqNs.FieldByName('ID_NS').AsInteger;
        FobjNsMaq.Inativar;
        qryMaqNs.Refresh;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TfrmEntMaq.btnLimparClick(Sender: TObject);
begin
  lcbMaquinas.Caption:= EmptyStr;
  edtNsMaq.Clear;
  edtQuantidade.Clear;
end;

procedure TfrmEntMaq.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Assigned(FobjNsMaq) then
    FreeAndNil(FobjNsMaq);

  if Assigned(FobjMovimentacao) Then
    FreeAndNil(FobjMovimentacao);
end;

procedure TfrmEntMaq.FormCreate(Sender: TObject);
begin
  FobjNsMaq:= TNsMaq.Create(dmConexao.ConexaoDB);
  FobjMovimentacao:= TMovimentacao.Create(dmConexao.ConexaoDB);
end;

procedure TfrmEntMaq.btnCancelarClick(Sender: TObject);
begin
  with TTaskDialog.Create(self) do
  try
    Caption := 'Confirmação:';
    Title := 'Cancelar o cadastro?';
    Text := 'Deseja cancelar o cadastro e sair da tela?';
    CommonButtons := [tcbYes, tcbNo];
    MainIcon := tdiQuestion;
    if Execute then
    begin
      if ModalResult = mrYes then
      begin
        procAjustaTela(false);
        btnLimpar.Click;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TfrmEntMaq.btnConfirmarClick(Sender: TObject);
begin
  if funCampoObrigatorio then
    abort;

  funGravar;

  qryMaqNs.Refresh;
  procAjustaTela(false);
  btnLimpar.Click;
end;

end.

