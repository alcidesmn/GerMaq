unit classeUsuario;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ClasseCriptografia,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Zconnection;

type
  TUsuarioLogado = class
  private
    ConexaoBD: Tzconnection;
    F_Usuarioid: Integer;
    F_Nome: String;

  public
    // class function funTenhoAcesso(aUsuarioID: integer; aChave: String; aConexao: TZConnection): Boolean; Static;
    constructor Create(Conexao: TZConnection);
    destructor Destroy; Override;
    function funLogar(Usuario, Senha: String): Boolean;

  Published
    property Codigo: integer read F_Usuarioid write F_Usuarioid;
    property Nome: String    read F_Nome      write F_Nome;
  end;

implementation

constructor TUsuarioLogado.Create(Conexao: TZConnection);
begin
  conexaoBD:= Conexao;
end;

destructor TUsuarioLogado.Destroy;
begin
  inherited;
end;

function TUsuarioLogado.funLogar(Usuario, Senha: String): Boolean;
  var QRY: TZQuery;
begin
  try
    Result := true;
    QRY := TZQuery.Create(nil);
    QRY.Connection := conexaoBD;
    QRY.SQL.Clear;
    QRY.SQL.Add('SELECT ID_FUNC, NOME_FUNC FROM funcionarios ' +
                ' WHERE USUARIO = :usuario AND SENHA = :SENHA' );
    QRY.ParamByName('USUARIO').AsString := Usuario;
    QRY.ParamByName('SENHA').AsString := funCriptografar(Senha);

    try
      QRY.Open;

       if QRY.FieldByName('NOME_FUNC').AsString <> EmptyStr then
       begin
         F_Usuarioid:= QRY.FieldByName('ID_FUNC').AsInteger;
         F_Nome:= QRY.FieldByName('NOME_FUNC').AsString;
         Result:= true;
       end
       else
         Result:= False;
    except
      result := false;
    end;
  finally
    if Assigned(QRY) then
     freeandnil(QRY);
  end;
end;
end.

