program EstoqueMaq;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, untPrinc, untLogin, zcomponent, untDataModule, classeUsuario,
  classeCriptografia, ClasseCriaTabelas, ClasseFuncionarios, untGerFuncionarios,
  ClasseMaquinas, ClasseNsMaq, untGerMaquinas, untEntMaquinas, ClasseComuns,
  ClasseMovimentacao, untMovimentacao;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmPrinc, frmPrinc);
  Application.CreateForm(TdmConexao, dmConexao);
  Application.Run;
end.

