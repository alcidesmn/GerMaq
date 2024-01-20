unit ClasseFuncionarios;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZAbstractRODataset, ZAbstractDataset, ZDataset, Zconnection;

type

  { TFuncionarios }

  TFuncionarios = Class
  private
    conexaoBD: TZConnection;
    F_IdFunc: integer;
    F_NomeFunc: String;
    F_Cpf: String;
    F_Usuario: String;
    F_Senha: String;
    F_DtAdm: TDateTime;
    F_IdUsrCad: Integer;


  Public
    constructor Create(Conexao: TZConnection);
    destructor Destroy; Override;
    function Inserir: Boolean;
    function Atualizar: Boolean;
    function Apagar: Boolean;
    function Selecionar(id:integer): Boolean;
    function existeCPFcadastrado(CPF_CNPJ:string): boolean;
    function existeCPFcadastradoAlteracao(CPF_CNPJ:string; ID: integer): boolean;


  published
    property IdFunc: integer         read F_IdFunc        write F_IdFunc;
    property NomeFunc: String        read F_NomeFunc      write F_NomeFunc;
    property Cpf: String             read F_Cpf           write F_Cpf;
    property Usuario: String         read F_Usuario       write F_Usuario;
    property Senha: String           read F_Senha         write F_Senha;
    property DtAdm: TDateTime        read F_DtAdm         write F_DtAdm;
    property IdUsrCad: integer       read F_IdUsrCad      write F_IdUsrCad;

  End;

implementation

{ TFuncionarios }

constructor TFuncionarios.Create(Conexao: TZConnection);
begin
  conexaoBD:= Conexao;
end;

destructor TFuncionarios.Destroy;
begin
  inherited Destroy;
end;

function TFuncionarios.Inserir: Boolean;
var QRY: TZQuery;
begin
 try
   Result := true;
   QRY := TZQuery.Create(nil);
   QRY.Connection := conexaoBD;
   QRY.SQL.Clear;
   QRY.SQL.Add('INSERT INTO funcionarios (NOME_FUNC, CPF, USUARIO, SENHA, DT_ADM, ID_USR_CAD)' +
               'VALUES (:NOME_FUNC, :CPF, :USUARIO, :SENHA, :DT_ADM, :ID_USR_CAD);' );


   QRY.ParamByName('NOME_FUNC').AsString := self.F_NomeFunc;
   QRY.ParamByName('CPF').AsString := SELF.F_Cpf;
   QRY.ParamByName('USUARIO').AsString := SELF.F_Usuario;
   QRY.ParamByName('SENHA').AsString := SELF.F_Senha;
   QRY.ParamByName('DT_ADM').AsDateTime := SELF.F_DtAdm;
   QRY.ParamByName('ID_USR_CAD').AsInteger := SELF.F_IdUsrCad;

   try
     conexaoBD.StartTransaction;
     QRY.ExecSQL;
     conexaoBD.Commit;
   except
     conexaoBD.Rollback;
     Result := false;
   end;
 finally
  if Assigned(QRY) then
    freeandnil(QRY);
 end;
end;

function TFuncionarios.Atualizar: Boolean;
var QRY: TZQuery;
begin
 try
   Result := true;
   QRY := TZQuery.Create(nil);
   QRY.Connection := conexaoBD;
   QRY.SQL.Clear;

   QRY.SQL.Add('UPDATE FUNCIONARIOS SET  ID_FUNC = :ID_FUNC, NOME_FUNC = :NOME_FUNC, CPF = :CPF, USUARIO = :USUARIO, '+
               'SENHA = :SENHA, DT_ADM = :DT_ADM, ID_USR_CAD = :ID_USR_CAD WHERE ID_FUNC = :ID_FUNC ');

   QRY.ParamByName('ID_FUNC').AsInteger := self.F_IdFunc;
   QRY.ParamByName('NOME_FUNC').AsString := self.F_NomeFunc;
   QRY.ParamByName('CPF').AsString := SELF.F_Cpf;
   QRY.ParamByName('USUARIO').AsString := SELF.F_Usuario;
   QRY.ParamByName('SENHA').AsString := SELF.F_Senha;
   QRY.ParamByName('DT_ADM').AsDateTime := SELF.F_DtAdm;
   QRY.ParamByName('ID_USR_CAD').AsInteger := SELF.F_IdUsrCad;

   try
     conexaoBD.StartTransaction;
     QRY.ExecSQL;
     conexaoBD.Commit;
   except
     conexaoBD.Rollback;
     Result := false;
   end;
 finally
   if Assigned(QRY) then
     freeandnil(QRY);
 end;
end;

function TFuncionarios.Apagar: Boolean;
var QRY: TZQuery;
begin
  try
   Result := true;
   QRY := TZQuery.Create(nil);
   QRY.Connection := conexaoBD;
   QRY.SQL.Clear;

   QRY.SQL.Add('DELETE FROM FUNCIONARIOS WHERE ID_FUNC = :ID_FUNC');

   QRY.ParamByName('ID_FUNC').AsInteger := self.F_IdFunc;
    try
      conexaoBD.StartTransaction;
      QRY.ExecSQL;
      conexaoBD.Commit;
    except
      conexaoBD.Rollback;
      Result := false;
    end;
  finally
    if Assigned(QRY) then
      freeandnil(QRY);
  end;
end;

function TFuncionarios.Selecionar(id: integer): Boolean;
var QRY: TZQuery;
begin
  try
    Result := true;
    QRY := TZQuery.Create(nil);
    QRY.Connection := conexaoBD;
    QRY.SQL.Clear;
    QRY.SQL.Add('SELECT ID_FUNC, NOME_FUNC, CPF, USUARIO, SENHA, DT_ADM FROM FUNCIONARIOS WHERE ID_FUNC = :ID_FUNC' );
    QRY.ParamByName('ID_FUNC').AsInteger := id;

    try
      QRY.Open;

      self.F_IdFunc:= QRY.FieldByName('ID_FUNC').AsInteger;
      self.F_NomeFunc := QRY.FieldByName('NOME_FUNC').AsString;
      SELF.F_Cpf := QRY.FieldByName('CPF').AsString;
      SELF.F_Usuario := QRY.FieldByName('USUARIO').AsString;
      SELF.F_Senha := QRY.FieldByName('SENHA').AsString;
      SELF.F_DtAdm := QRY.FieldByName('DT_ADM').AsDateTime;

    except
      result := false;
    end;

  finally
    if Assigned(QRY) then
     freeandnil(QRY);
  end;
end;



function TFuncionarios.existeCPFcadastrado(CPF_CNPJ: string): boolean;
//var QRY: TZQuery;
begin
 { try    //TODO: FAZER AQUI
    Result := false;
    QRY := TZQuery.Create(nil);
    QRY.Connection := conexaoBD;
    QRY.SQL.Clear;
    QRY.SQL.Add('SELECT CPF_CNPJ FROM PESSOAS WHERE CPF_CNPJ = :CPF_CNPJ' );
    QRY.ParamByName('CPF_CNPJ').AsString := CPF_CNPJ;

    try
      QRY.Open;
      if qry.FieldByName('CPF_CNPJ').AsString <> '' then
        result:= true;
    except
      result := false;
    end;

  finally
    if Assigned(QRY) then
     freeandnil(QRY);
  end; }
end;

function TFuncionarios.existeCPFcadastradoAlteracao(CPF_CNPJ: string; ID: integer): boolean;
//var QRY: TZQuery;
begin
 { try        //TODO: FAZER AQUI
    Result := false;
    QRY := TZQuery.Create(nil);
    QRY.Connection := conexaoBD;
    QRY.SQL.Clear;
    QRY.SQL.Add('SELECT CPF_CNPJ FROM PESSOAS WHERE CPF_CNPJ = :CPF_CNPJ AND ID_PESSOA <> :ID_PESSOA' );
    QRY.ParamByName('CPF_CNPJ').AsString := CPF_CNPJ;
    QRY.ParamByName('ID_PESSOA').AsInteger := ID;

    try
      QRY.Open;
      if qry.FieldByName('CPF_CNPJ').AsString <> '' then
        result:= true;
    except
      result := false;
    end;

  finally
    if Assigned(QRY) then
     freeandnil(QRY);
  end;}

end;

end.

