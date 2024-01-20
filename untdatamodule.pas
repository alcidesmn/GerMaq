unit untDataModule;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZConnection;

type

  { TdmConexao }

  TdmConexao = class(TDataModule)
    ConexaoDB: TZConnection;
  private

  public

  end;

var
  dmConexao: TdmConexao;

implementation

{$R *.lfm}

end.

