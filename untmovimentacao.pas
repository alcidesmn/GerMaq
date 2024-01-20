unit untMovimentacao;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  DBGrids, ComCtrls, StdCtrls, MaskEdit, EditBtn, DBCtrls, ZDataset,
  untDataModule, ClasseMovimentacao;

type

  { TfrmMovimentacao }

  TfrmMovimentacao = class(TForm)
    btnCancelar: TSpeedButton;
    btnConfirmar: TSpeedButton;
    btnLimpar: TSpeedButton;
    cbxTipoMov: TComboBox;
    cbxNsMaq: TComboBox;
    dbgDados: TDBGrid;
    dtsMaqExist: TDataSource;
    dtsNsMaq: TDataSource;
    dtsMovimentacao: TDataSource;
    Edit1: TEdit;
    edtQuantidade: TEdit;
    lblMaquina: TLabel;
    lblMaquina1: TLabel;
    lblMovimentacao: TLabel;
    lblNomeUsr: TLabel;
    lblQuant: TLabel;
    lblTipoMov: TLabel;
    lblUseCadastrando: TLabel;
    lcbMaquinas: TDBLookupComboBox;
    pnlBusca: TPanel;
    pgcGerMov: TPageControl;
    pnlCadastro: TPanel;
    pnlCentral: TPanel;
    pnlLateral: TPanel;
    pnlTop: TPanel;
    qryMaqExist: TZQuery;
    qryNsMaq: TZQuery;
    qryMaqExistID_MAQ: TLongintField;
    qryMaqExistNOME_MAQ: TStringField;
    qryMovimentacao: TZQuery;
    qryMovimentacaoDT_MOV: TDateField;
    qryMovimentacaoNOME_FUNC: TStringField;
    qryMovimentacaoNOME_MAQ: TStringField;
    qryMovimentacaoNS_MAQ: TStringField;
    qryMovimentacaoQT_ESTOQUE: TLongintField;
    qryMovimentacaoTipoMov: TStringField;
    qryNsMaqID_NS: TLongintField;
    qryNsMaqNS_MAQ: TStringField;
    spbMovimentar: TSpeedButton;
    spbAlterar: TSpeedButton;
    spbExcluir: TSpeedButton;
    spbSair: TSpeedButton;
    tbsCadastro: TTabSheet;
    tbsGerenciar: TTabSheet;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lcbMaquinasSelect(Sender: TObject);
    procedure spbMovimentarClick(Sender: TObject);
    procedure spbSairClick(Sender: TObject);
  private
    procedure procAjustaTela(Cadastro:Boolean);
    function funCampoObrigatorio: boolean;
    function funGravar:Boolean;
  public

  end;

var
  frmMovimentacao: TfrmMovimentacao;
  TipoCadastro: Integer;
  FobjMovimentacao: TMovimentacao;

implementation

{$R *.lfm}

uses untPrinc;

{ TfrmMovimentacao }

procedure TfrmMovimentacao.FormCreate(Sender: TObject);
begin
  qryMovimentacao.open;
  qryMaqExist.open;
  FobjMovimentacao:= TMovimentacao.Create(dmConexao.ConexaoDB);
end;

procedure TfrmMovimentacao.FormShow(Sender: TObject);
begin
  procAjustaTela(false);
  cbxTipoMov.ItemIndex:= 1;
  cbxNsMaq.clear;
end;

procedure TfrmMovimentacao.lcbMaquinasSelect(Sender: TObject);
begin
  qryNsMaq.Close;
  qryNsMaq.ParamByName('ID_MAQ').asString:= intToStr(lcbMaquinas.KeyValue);
  qryNsMaq.Open;

  cbxNsMaq.items.Clear;
  qryNsMaq.First;
  while not qryNsMaq.eof do
  begin
    cbxNsMaq.Items.AddObject(qryNsMaq.FieldByName('NS_MAQ').AsString, TObject(qryNsMaq.FieldByName('ID_NS').AsInteger));
    qryNsMaq.Next;
  end;
end;



procedure TfrmMovimentacao.btnCancelarClick(Sender: TObject);
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

procedure TfrmMovimentacao.btnConfirmarClick(Sender: TObject);
begin
  if funCampoObrigatorio then
    abort;

  funGravar;

  qryMovimentacao.Refresh;
  procAjustaTela(false);
  btnLimpar.Click;
end;

procedure TfrmMovimentacao.btnLimparClick(Sender: TObject);
begin
  lcbMaquinas.Caption:= EmptyStr;
  cbxNsMaq.items.clear;
  edtQuantidade.Clear;
end;

procedure TfrmMovimentacao.Edit1Change(Sender: TObject);
begin
  qryMovimentacao.Locate('NOME_MAQ', Edit1.Text, [loPartialKey]);
end;

procedure TfrmMovimentacao.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Assigned(FobjMovimentacao) then
     FreeAndNil(FobjMovimentacao);
end;

procedure TfrmMovimentacao.spbMovimentarClick(Sender: TObject);
begin
  procAjustaTela(true);
  TipoCadastro:= 1;
  if lcbMaquinas.CanFocus then
     lcbMaquinas.SetFocus;
end;

procedure TfrmMovimentacao.spbSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMovimentacao.procAjustaTela(Cadastro: Boolean);
begin
  if cadastro = true then
  begin
    spbMovimentar.Enabled:= false;
    spbAlterar.Enabled:= false;
    spbSair.Enabled:= false;
    spbExcluir.Enabled:= false;
    pgcGerMov.Pages[0].Enabled:= false;
    pgcGerMov.Pages[0].tabvisible:= false;
    pgcGerMov.Pages[1].Enabled:= true;
    pgcGerMov.Pages[1].tabvisible:= true;
    cbxNsMaq.items.Clear;
    cbxNsMaq.Caption:= EmptyStr;
  end
  else
  begin
    spbMovimentar.Enabled:= true;
   // spbAlterar.Enabled:= true;
    spbSair.Enabled:= true;
   // spbExcluir.Enabled:= true;
    pgcGerMov.Pages[1].Enabled:= false;
    pgcGerMov.Pages[1].tabvisible:= false;
    pgcGerMov.Pages[0].Enabled:= true;
    pgcGerMov.Pages[0].tabvisible:= true;
  end;
end;

function TfrmMovimentacao.funCampoObrigatorio: boolean;
var i: integer;
begin
  result:= false;
  for i := 0 to ComponentCount -1 do
  begin
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

  if (result = false) and (cbxNsMaq.Caption = EmptyStr) then
  begin
    MessageDlg('Número de série é um campo obrigatório', mtInformation, [mbOK], 0);
    cbxNsMaq.SetFocus;
    Result := true;
  end;

  if (result = false) and (cbxTipoMov.Caption = EmptyStr) then
  begin
    MessageDlg('Tipo da Movimentação é um campo obrigatório', mtInformation, [mbOK], 0);
    cbxTipoMov.SetFocus;
    Result := true;
  end;
end;

function TfrmMovimentacao.funGravar: Boolean;
begin
  FobjMovimentacao.IdMaq:= lcbMaquinas.KeyValue;
  FobjMovimentacao.IdFunc:= FobjUsuario.Codigo;
  FobjMovimentacao.IdNs:= Integer(cbxNsMaq.Items.Objects[cbxNsMaq.ItemIndex]);
  FobjMovimentacao.TipoMov:= cbxTipoMov.ItemIndex;
  FobjMovimentacao.QtEstoque:= StrToInt(edtQuantidade.Caption);

  if TipoCadastro = 1 then
  begin
    Result:= FobjMovimentacao.Inserir;
  end;

end;

end.

