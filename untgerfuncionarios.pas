unit untGerFuncionarios;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  DBGrids, ComCtrls, StdCtrls, MaskEdit, EditBtn, ZDataset, Math,
  ClasseFuncionarios, untDataModule, classeCriptografia
  ;

type

  { TfrmGerFuncionarios }

  TfrmGerFuncionarios = class(TForm)
    btnCancelar: TSpeedButton;
    btnConfirmar: TSpeedButton;
    btnLimpar: TSpeedButton;
    dtAdm: TDateEdit;
    dbgDados: TDBGrid;
    dtsFuncionarios: TDataSource;
    edtCPF: TMaskEdit;
    edtNome: TLabeledEdit;
    edtSenha: TLabeledEdit;
    edtUsuario: TLabeledEdit;
    lblAdm: TLabel;
    lblCPF: TLabel;
    lblFuncionario1: TLabel;
    lblNomeUsr: TLabel;
    lblUseCadastrando: TLabel;
    pgcCadFunc: TPageControl;
    pnlTop: TPanel;
    pnlLateral: TPanel;
    pnlCentral: TPanel;
    pnlCadastro: TPanel;
    qryFuncionarios: TZQuery;
    qryFuncionariosCPF: TStringField;
    qryFuncionariosDT_ADM: TDateField;
    qryFuncionariosID_FUNC: TLongintField;
    qryFuncionariosNOME_FUNC: TStringField;
    qryMaquinasID_FUNC: TLongintField;
    spbAdicionar: TSpeedButton;
    spbExcluir: TSpeedButton;
    spbAlterar: TSpeedButton;
    spbSair: TSpeedButton;
    tbsGerenciar: TTabSheet;
    tbsCadastro: TTabSheet;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure dbgDadosDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure spbAdicionarClick(Sender: TObject);
    procedure spbAlterarClick(Sender: TObject);
    procedure spbExcluirClick(Sender: TObject);
    procedure spbSairClick(Sender: TObject);
  private
    procedure procAjustaTela(Cadastro: boolean);
    function funValidaCpf: Boolean;
    function funCampoObrigatorio: boolean;
    function funGravar: Boolean;
  public

  end;

var
  frmGerFuncionarios: TfrmGerFuncionarios;
  FobjFuncionarios: TFuncionarios;
  TipoCadastro: integer; //1-Novo 2-Alterar

implementation

{$R *.lfm}

uses untPrinc;

{ TfrmGerFuncionarios }

procedure TfrmGerFuncionarios.FormShow(Sender: TObject);
begin
  qryFuncionarios.Open;
  lblNomeUsr.Caption:= FobjUsuario.Nome;
  pgcCadFunc.Pages[1].Enabled:= false;
  pgcCadFunc.Pages[1].tabvisible:= false;
  pgcCadFunc.Pages[0].Enabled:= true;
  pgcCadFunc.Pages[0].tabvisible:= true;
end;

procedure TfrmGerFuncionarios.btnCancelarClick(Sender: TObject);
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

procedure TfrmGerFuncionarios.btnConfirmarClick(Sender: TObject);
begin
  if not funValidaCPF then
  begin
    MessageDlg( 'CPF é inválido.', mtInformation, [mbOK], 0);
    edtCpf.Clear;
    edtCpf.SetFocus;
    exit;
  end;

  if funCampoObrigatorio then
    abort;

  funGravar;

  qryFuncionarios.Refresh;
  procAjustaTela(false);
  btnLimpar.Click;
end;

procedure TfrmGerFuncionarios.btnLimparClick(Sender: TObject);
begin
  edtNome.Clear;
  edtCPF.Clear;
  edtSenha.Clear;
  edtUsuario.Clear;
  dtAdm.Clear;
end;

procedure TfrmGerFuncionarios.dbgDadosDblClick(Sender: TObject);
begin
  spbAlterar.click;
end;

procedure TfrmGerFuncionarios.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if assigned (FobjFuncionarios) then
     FreeAndNil(FobjFuncionarios);
end;

procedure TfrmGerFuncionarios.FormCreate(Sender: TObject);
begin
  FobjFuncionarios:= TFuncionarios.Create(dmConexao.ConexaoDB);
end;

procedure TfrmGerFuncionarios.spbAdicionarClick(Sender: TObject);
begin
  procAjustaTela(true);
  TipoCadastro:= 1;
  if edtNome.CanFocus then
     edtNome.SetFocus;
end;

procedure TfrmGerFuncionarios.spbAlterarClick(Sender: TObject);
begin
  if FobjFuncionarios.Selecionar(qryFuncionarios.FieldByName('ID_FUNC').AsInteger) then
  begin
    edtNome.Caption := FobjFuncionarios.NomeFunc ;
    edtCPF.Caption := FobjFuncionarios.Cpf;
    edtUsuario.Caption := FobjFuncionarios.Usuario;
    edtSenha.Caption := FobjFuncionarios.Senha;
    dtAdm.Date := FobjFuncionarios.DtAdm;

    procAjustaTela(true);
    TipoCadastro:= 2;
  end;
end;

procedure TfrmGerFuncionarios.spbExcluirClick(Sender: TObject);
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
        FobjFuncionarios.IdFunc:= qryFuncionarios.FieldByName('ID_FUNC').AsInteger;
        FobjFuncionarios.Apagar;
        qryFuncionarios.Refresh;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TfrmGerFuncionarios.spbSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmGerFuncionarios.procAjustaTela(Cadastro: boolean);
begin
  if cadastro = true then
  begin
    spbAdicionar.Enabled:= false;
    spbAlterar.Enabled:= false;
    spbSair.Enabled:= false;
    spbExcluir.Enabled:= false;
    pgcCadFunc.Pages[0].Enabled:= false;
    pgcCadFunc.Pages[0].tabvisible:= false;
    pgcCadFunc.Pages[1].Enabled:= true;
    pgcCadFunc.Pages[1].tabvisible:= true;
  end
  else
  begin
    spbAdicionar.Enabled:= true;
    spbAlterar.Enabled:= true;
    spbSair.Enabled:= true;
    spbExcluir.Enabled:= true;
    pgcCadFunc.Pages[1].Enabled:= false;
    pgcCadFunc.Pages[1].tabvisible:= false;
    pgcCadFunc.Pages[0].Enabled:= true;
    pgcCadFunc.Pages[0].tabvisible:= true;
  end;
end;

function TfrmGerFuncionarios.funValidaCpf: Boolean;
var
  v: array [0 .. 1] of Word;
  cpf: array [0 .. 10] of Byte;
  I: Byte;
  CPFstring: String;
begin
  Result:= False;
  cpfString:= stringreplace(stringreplace(edtCpf.Text,'.', '', [rfReplaceAll, rfIgnoreCase]),'-', '', [rfReplaceAll, rfIgnoreCase]);

  { Verificando se tem 11 caracteres }
  if Length(cpfString) <> 11 then
  begin
    Exit;
  end;

  { Conferindo se todos dígitos são iguais }
  if cpfString = StringOfChar('0', 11) then
    Exit;

  if cpfString = StringOfChar('1', 11) then
    Exit;

  if cpfString = StringOfChar('2', 11) then
    Exit;

  if cpfString = StringOfChar('3', 11) then
    Exit;

  if cpfString = StringOfChar('4', 11) then
    Exit;

  if cpfString = StringOfChar('5', 11) then
    Exit;

  if cpfString = StringOfChar('6', 11) then
    Exit;

  if cpfString = StringOfChar('7', 11) then
    Exit;

  if cpfString = StringOfChar('8', 11) then
    Exit;

  if cpfString = StringOfChar('9', 11) then
    Exit;

  try
    for I := 1 to 11 do
      cpf[I - 1] := StrToInt(cpfString[I]);
    // Nota: Calcula o primeiro dígito de verificação.
    v[0] := 10 * cpf[0] + 9 * cpf[1] + 8 * cpf[2];
    v[0] := v[0] + 7 * cpf[3] + 6 * cpf[4] + 5 * cpf[5];
    v[0] := v[0] + 4 * cpf[6] + 3 * cpf[7] + 2 * cpf[8];
    v[0] := 11 - v[0] mod 11;
    v[0] := IfThen(v[0] >= 10, 0, v[0]);
    // Nota: Calcula o segundo dígito de verificação.
    v[1] := 11 * cpf[0] + 10 * cpf[1] + 9 * cpf[2];
    v[1] := v[1] + 8 * cpf[3] + 7 * cpf[4] + 6 * cpf[5];
    v[1] := v[1] + 5 * cpf[6] + 4 * cpf[7] + 3 * cpf[8];
    v[1] := v[1] + 2 * v[0];
    v[1] := 11 - v[1] mod 11;
    v[1] := IfThen(v[1] >= 10, 0, v[1]);
    // Nota: Verdadeiro se os dígitos de verificação são os esperados.
    Result := ((v[0] = cpf[9]) and (v[1] = cpf[10]));
  except
    on E: Exception do
      Result := False;
  end;
end;

function TfrmGerFuncionarios.funCampoObrigatorio: boolean;
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
end;

function TfrmGerFuncionarios.funGravar: Boolean;
begin
  FobjFuncionarios.NomeFunc:= edtNome.Caption;
  FobjFuncionarios.Cpf:= edtCPF.Caption;
  FobjFuncionarios.Usuario:= edtUsuario.Caption;
  FobjFuncionarios.Senha:= funCriptografar(uppercase(edtSenha.Caption));
  FobjFuncionarios.DtAdm:= dtAdm.Date;
  FobjFuncionarios.IdUsrCad:= FobjUsuario.Codigo;

  if TipoCadastro = 1 then
    Result:= FobjFuncionarios.Inserir
  else
    Result:= FobjFuncionarios.Atualizar;
end;

end.

