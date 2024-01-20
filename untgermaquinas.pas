unit untGerMaquinas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
   DBGrids, ComCtrls, StdCtrls, MaskEdit, EditBtn, ZDataset,  untDataModule, classeUsuario
  , ClasseMaquinas;

type

  { TfrmGerMaquinas }

  TfrmGerMaquinas = class(TForm)
    btnCancelar: TSpeedButton;
    btnConfirmar: TSpeedButton;
    btnLimpar: TSpeedButton;
    cbxSitMaq: TComboBox;
    dbgDados: TDBGrid;
    dtCompra: TDateEdit;
    dtsMaquinas: TDataSource;
    edtNome: TLabeledEdit;
    lblDtCompra: TLabel;
    lblFuncionario1: TLabel;
    lblNomeUsr: TLabel;
    lblSituacao: TLabel;
    lblUseCadastrando: TLabel;
    pgcCadMaq: TPageControl;
    lblAdm: TLabel;
    lblCPF: TLabel;
    lblFuncionario: TLabel;
    pnlCadastro: TPanel;
    pnlCentral: TPanel;
    pnlLateral: TPanel;
    pnlTop: TPanel;
    qryMaquinas: TZQuery;
    qryMaquinasDT_COMPRA: TDateField;
    qryMaquinasID_MAQ: TLongintField;
    qryMaquinasNOME_MAQ: TStringField;
    qryMaquinasSituacao: TStringField;
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
    procedure procAjustaTela (Cadastro: Boolean);
    function funGravar: Boolean;
    function funCampoObrigatorio:boolean;
  public

  end;

var
  frmGerMaquinas: TfrmGerMaquinas;
  FobjMaquinas: TMaquinas;
  TipoCadastro: integer; //1-Novo 2-Alterar

implementation

{$R *.lfm}

uses untPrinc;

{ TfrmGerMaquinas }

procedure TfrmGerMaquinas.btnCancelarClick(Sender: TObject);
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

procedure TfrmGerMaquinas.btnConfirmarClick(Sender: TObject);
begin
  if funCampoObrigatorio then
    abort;

  funGravar;

  qryMaquinas.Refresh;
  procAjustaTela(false);
  btnLimpar.Click;
end;

procedure TfrmGerMaquinas.btnLimparClick(Sender: TObject);
begin
  edtNome.Clear;
  dtCompra.Clear;
  cbxSitMaq.ItemIndex:= 1;
end;

procedure TfrmGerMaquinas.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if assigned(FobjMaquinas) then
     FreeAndNil(FobjMaquinas);
end;

procedure TfrmGerMaquinas.FormCreate(Sender: TObject);
begin
  FobjMaquinas:= TMaquinas.Create(dmConexao.ConexaoDB);
end;

procedure TfrmGerMaquinas.FormShow(Sender: TObject);
begin
  qryMaquinas.Open;
  lblNomeUsr.Caption:= FobjUsuario.Nome;
  pgcCadMaq.Pages[1].Enabled:= false;
  pgcCadMaq.Pages[1].tabvisible:= false;
  pgcCadMaq.Pages[0].Enabled:= true;
  pgcCadMaq.Pages[0].tabvisible:= true;
  cbxSitMaq.ItemIndex:= 1;
end;

procedure TfrmGerMaquinas.spbAdicionarClick(Sender: TObject);
begin
  procAjustaTela(true);
  TipoCadastro:= 1;
  if edtNome.CanFocus then
     edtNome.SetFocus;
end;

procedure TfrmGerMaquinas.spbAlterarClick(Sender: TObject);
begin
  if FobjMaquinas.Selecionar(qryMaquinas.FieldByName('ID_MAQ').AsInteger) then
  begin
    edtNome.Caption := FobjMaquinas.NomeMaq ;
    dtCompra.Date := FobjMaquinas.DtCompra;
    cbxSitMaq.ItemIndex := FobjMaquinas.StMaq;

    procAjustaTela(true);
    TipoCadastro:= 2;
  end;
end;

procedure TfrmGerMaquinas.spbExcluirClick(Sender: TObject);
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
        FobjMaquinas.IdMaq:= qryMaquinas.FieldByName('ID_MAQ').AsInteger;
        FobjMaquinas.Apagar;
        qryMaquinas.Refresh;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TfrmGerMaquinas.spbSairClick(Sender: TObject);
begin
  close;
end;

function TfrmGerMaquinas.funCampoObrigatorio: boolean;
var i: Integer;
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
  end;
end;

procedure TfrmGerMaquinas.procAjustaTela(Cadastro: Boolean);
begin
  if cadastro = true then
  begin
    spbAdicionar.Enabled:= false;
    spbAlterar.Enabled:= false;
    spbSair.Enabled:= false;
    spbExcluir.Enabled:= false;
    pgcCadMaq.Pages[0].Enabled:= false;
    pgcCadMaq.Pages[0].tabvisible:= false;
    pgcCadMaq.Pages[1].Enabled:= true;
    pgcCadMaq.Pages[1].tabvisible:= true;
  end
  else
  begin
    spbAdicionar.Enabled:= true;
    spbAlterar.Enabled:= true;
    spbSair.Enabled:= true;
    spbExcluir.Enabled:= true;
    pgcCadMaq.Pages[1].Enabled:= false;
    pgcCadMaq.Pages[1].tabvisible:= false;
    pgcCadMaq.Pages[0].Enabled:= true;
    pgcCadMaq.Pages[0].tabvisible:= true;
  end;
end;

function TfrmGerMaquinas.funGravar: Boolean;
begin
  FobjMaquinas.NomeMaq:= edtNome.Caption;
  FobjMaquinas.DtCompra:= dtCompra.Date;
  FobjMaquinas.StMaq:= cbxSitMaq.ItemIndex;
  FobjMaquinas.IdUsrCad:= FobjUsuario.Codigo;

  if TipoCadastro = 1 then
    Result:= FobjMaquinas.Inserir
  else
    Result:= FobjMaquinas.Atualizar;
end;

end.

