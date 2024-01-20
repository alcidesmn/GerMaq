unit untPrinc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls,
  untLogin,
  untGerFuncionarios,
  untGerMaquinas,
  untDataModule,
  ClasseCriaTabelas,
  classeUsuario,
  untMovimentacao,
  untEntMaquinas;

type

  { TfrmPrinc }

  TfrmPrinc = class(TForm)
    lblEntradas: TLabel;
    lblTitulo: TLabel;
    lblFunc: TLabel;
    lblMaq: TLabel;
    lblMov: TLabel;
    pnlFrm: TPanel;
    pnlBot: TPanel;
    pnlEntradas: TPanel;
    pnlTop: TPanel;
    pnlNome: TPanel;
    pnlLateral: TPanel;
    pnlCentral: TPanel;
    pnlCadFunc: TPanel;
    pnlCadMaq: TPanel;
    pnlMov: TPanel;
    spbCadastros: TSpeedButton;
    spbCadFunc: TSpeedButton;
    spbCadMaq: TSpeedButton;
    spbMov: TSpeedButton;
    spbEntradas: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pnlCadFuncClick(Sender: TObject);
    procedure pnlCadMaqClick(Sender: TObject);
    procedure pnlEntradasClick(Sender: TObject);
    procedure pnlMovClick(Sender: TObject);
    procedure spbCadastrosClick(Sender: TObject);
  private
    procedure procAumentaPainel(pnl:TPanel; pnlWidth: Integer);
    procedure procDiminuiPainel(pnl:TPanel);
    procedure procCriaLogin;
    procedure procConectaDB;
    procedure procCriaTela(NomeTela: TFormClass);
  public
    

  end;

  const
  padraoSideNav: integer = 300;

var
  frmPrinc: TfrmPrinc;
  Form: Tform;
  FobjDataModule: TdmConexao;
  FobjUsuario: TUsuarioLogado;
implementation

procedure procCriaObjUsr;
begin
  if assigned(FobjUsuario) then
    freeAndNil(FobjUsuario);

  FobjUsuario:= TUsuarioLogado.Create(FobjDataModule.ConexaoDB);
end;

{$R *.lfm}

{ TfrmPrinc }

procedure TfrmPrinc.spbCadastrosClick(Sender: TObject);
begin
  if pnlLateral.Width <> padraoSideNav
  then procAumentaPainel(pnlLateral,padraoSideNav)
  else procDiminuiPainel(pnlLateral);
end;

procedure TfrmPrinc.procDiminuiPainel(pnl: TPanel);
begin
  pnl.width:= (spbCadastros.BorderSpacing.Left + spbCadastros.Width + 1);
end;

procedure TfrmPrinc.procCriaLogin;
begin
  try
    frmLogin:= TfrmLogin.Create(nil);
    frmLogin.ShowModal;
  finally
    frmLogin.Release;
  end;
end;

procedure TfrmPrinc.procConectaDB;
begin
  FobjDataModule:= TdmConexao.Create(self);

  with FobjDataModule.ConexaoDB do
  begin
    Connected:= false;
    SQLHourGlass    := false;


    Protocol        := 'MariaDB-10';
    LibraryLocation := 'D:\LAZARUS\libmariadb.dll';
    HostName        := 'localhost';
    Port            := 3306;
    User            := 'root';
    Password        := 'ciducada';
    Database        := 'germaq';
    AutoCommit      := true;
    Connected       := true;
  end;
end;

procedure TfrmPrinc.procCriaTela(NomeTela: TFormClass);
begin
  if assigned(Form) then
    FreeAndNil(form);

  form := NomeTela.create(Application);
  Form.Parent:= frmPrinc.pnlFrm;
  Form.Align:= alClient;
  Form.BorderStyle:= bsNone;
  Form.show;
end;

procedure TfrmPrinc.procAumentaPainel(pnl: TPanel; pnlWidth: Integer);
begin
  pnl.width:= pnlWidth;
end;

procedure TfrmPrinc.FormCreate(Sender: TObject);
var objCriaTabelas : TClasseCriaTabelas;
begin
  procConectaDB;
  try
    objCriaTabelas:= TClasseCriaTabelas.Create(FobjDataModule.ConexaoDB);
  finally
    FreeAndNil(objCriaTabelas);
  end;
end;

procedure TfrmPrinc.FormDestroy(Sender: TObject);
begin
  ///
end;

procedure TfrmPrinc.FormShow(Sender: TObject);
begin
  procDiminuiPainel(pnlLateral);
end;


procedure TfrmPrinc.pnlCadFuncClick(Sender: TObject);
begin
  procCriaObjUsr;

  procCriaLogin;
  if FobjUsuario.Codigo > 0 then
  begin
    procCriaTela(TfrmGerFuncionarios);
  end;
end;

procedure TfrmPrinc.pnlCadMaqClick(Sender: TObject);
begin
  procCriaObjUsr;

  procCriaLogin;
  if FobjUsuario.Codigo > 0 then
  begin
    procCriaTela(TfrmGerMaquinas);
  end;
end;

procedure TfrmPrinc.pnlEntradasClick(Sender: TObject);
begin
  procCriaObjUsr;

  procCriaLogin;
  if FobjUsuario.Codigo > 0 then
  begin
    procCriaTela(TfrmEntMaq);
  end;
end;

procedure TfrmPrinc.pnlMovClick(Sender: TObject);
begin
  procCriaObjUsr;

  procCriaLogin;
  if FobjUsuario.Codigo > 0 then
  begin
    procCriaTela(TfrmMovimentacao);
  end;
end;
end.

