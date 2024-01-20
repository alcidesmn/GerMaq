unit ClasseMaquinas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZAbstractRODataset, ZAbstractDataset, ZDataset, Zconnection;

type

  { TMaquinas }

  TMaquinas = Class
  private
    conexaoBD: TZConnection;
    F_IdMaq: integer;
    F_NomeMaq: String;
    F_DtCompra: TDate;
    F_StMaq: integer;
    F_IdUsrCad: Integer;


  Public
    constructor Create(Conexao: TZConnection);
    destructor Destroy; Override;
    function Inserir: Boolean;
    function Atualizar: Boolean;
    function Apagar: Boolean;
    function Selecionar(id:integer): Boolean;

  published
    property IdMaq: integer         read F_IdMaq        write F_IdMaq;
    property NomeMaq: String        read F_NomeMaq      write F_NomeMaq;
    property DtCompra: TDate        read F_DtCompra     write F_DtCompra;
    property StMaq: integer         read F_StMaq        write F_StMaq;
    property IdUsrCad: integer      read F_IdUsrCad     write F_IdUsrCad;

  End;

implementation
{ TMaquinas }

constructor TMaquinas.Create(Conexao: TZConnection);
begin
  conexaoBD:= Conexao;
end;

destructor TMaquinas.Destroy;
begin
  inherited Destroy;
end;

function TMaquinas.Inserir: Boolean;
var QRY: TZQuery;
begin
   try
     Result := true;
     QRY := TZQuery.Create(nil);
     QRY.Connection := conexaoBD;
     QRY.SQL.Clear;
     QRY.SQL.Add('INSERT INTO maquinas (NOME_MAQ, DT_COMPRA, ST_MAQ, ID_USR_CAD) ' +
                 'VALUES (:NOME_MAQ, :DT_COMPRA, :ST_MAQ, :ID_USR_CAD);' );


     QRY.ParamByName('NOME_MAQ').AsString := self.F_NomeMaq;
     QRY.ParamByName('DT_COMPRA').AsDate := SELF.F_DtCompra;
     QRY.ParamByName('ST_MAQ').AsInteger := SELF.F_StMaq;
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

function TMaquinas.Atualizar: Boolean;
var QRY: TZQuery;
begin
   try
     Result := true;
     QRY := TZQuery.Create(nil);
     QRY.Connection := conexaoBD;
     QRY.SQL.Clear;

     QRY.SQL.Add('UPDATE maquinas SET NOME_MAQ= :NOME_MAQ, DT_COMPRA= :DT_COMPRA, ST_MAQ= :ST_MAQ, ID_USR_CAD= :ID_USR_CAD WHERE ID_MAQ= :ID_MAQ;');

     QRY.ParamByName('ID_MAQ').AsInteger := self.F_IdMaq;
     QRY.ParamByName('NOME_MAQ').AsString := self.F_NomeMaq;
     QRY.ParamByName('DT_COMPRA').AsDate := SELF.F_DtCompra;
     QRY.ParamByName('ST_MAQ').AsInteger := SELF.F_StMaq;
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

function TMaquinas.Apagar: Boolean;
var QRY: TZQuery;
begin
  try
   Result := true;
   QRY := TZQuery.Create(nil);
   QRY.Connection := conexaoBD;
   QRY.SQL.Clear;

   QRY.SQL.Add('DELETE FROM maquinas WHERE ID_MAQ = :ID_MAQ');

   QRY.ParamByName('ID_MAQ').AsInteger := self.F_IdMaq;
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

function TMaquinas.Selecionar(id: integer): Boolean;
var QRY: TZQuery;
begin
  try
    Result := true;
    QRY := TZQuery.Create(nil);
    QRY.Connection := conexaoBD;
    QRY.SQL.Clear;
    QRY.SQL.Add('SELECT ID_MAQ, NOME_MAQ, DT_COMPRA, ST_MAQ, ID_USR_CAD FROM germaq.maquinas WHERE ID_MAQ= :ID_MAQ' );
    QRY.ParamByName('ID_MAQ').AsInteger := id;

    try
      QRY.Open;

      self.F_IdMaq:= QRY.FieldByName('ID_MAQ').AsInteger;
      self.F_NomeMaq := QRY.FieldByName('NOME_MAQ').AsString;
      SELF.F_DtCompra := QRY.FieldByName('DT_COMPRA').AsDateTime;
      SELF.F_StMaq := QRY.FieldByName('ST_MAQ').AsInteger;
      SELF.F_IdUsrCad := QRY.FieldByName('ID_USR_CAD').AsInteger;

    except
      result := false;
    end;

  finally
    if Assigned(QRY) then
     freeandnil(QRY);
  end;
end;

end.


