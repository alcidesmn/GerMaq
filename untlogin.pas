unit untLogin;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  classeUsuario, untDataModule;

type

  { TfrmLogin }

  TfrmLogin = class(TForm)
    edtLogin: TLabeledEdit;
    edtSenha: TLabeledEdit;
    pnlCancelar: TPanel;
    pnlLogin: TPanel;
    spbCancelar: TSpeedButton;
    spbLogin: TSpeedButton;
    procedure edtLoginKeyPress(Sender: TObject; var Key: char);
    procedure edtSenhaKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure spbCancelarClick(Sender: TObject);
    procedure spbLoginClick(Sender: TObject);
  private

  public

  end;
var
  frmLogin: TfrmLogin;

implementation

uses untPrinc;

{$R *.lfm}

{ TfrmLogin }

procedure TfrmLogin.spbCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmLogin.spbLoginClick(Sender: TObject);
var UsuarioLG: TUsuarioLogado;
    objDmPrincipal: TdmConexao;
begin
try
  objDmPrincipal:= TdmConexao.Create(nil);
  UsuarioLG:= TUsuarioLogado.Create(objDmPrincipal.ConexaoDB);
  if UsuarioLG.funLogar(edtLogin.Text, UpperCase(edtSenha.Text)) then
  begin
    FobjUsuario.Codigo:= UsuarioLG.Codigo;
    FobjUsuario.Nome:= UsuarioLG.Nome;
    close;
  end
  else
  begin
    MessageDlg('Usuário ou Senha inválidos', mtInformation, [mbOK], 0);
    edtLogin.SetFocus;
  end;
finally
  if Assigned(UsuarioLG) then
    FreeAndNil(UsuarioLG);

  if Assigned(objDmPrincipal) then
    FreeAndNil(objDmPrincipal);
end;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  edtLogin.SetFocus;
end;

procedure TfrmLogin.edtSenhaKeyPress(Sender: TObject; var Key: char);
begin
  if key=#13 then
    spbLogin.Click;
end;

procedure TfrmLogin.edtLoginKeyPress(Sender: TObject; var Key: char);
begin
  if key=#13 then
    edtSenha.SetFocus;
end;

end.

