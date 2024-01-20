unit ClasseNsMaq;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZAbstractRODataset, ZAbstractDataset, ZDataset, Zconnection;

type

  { TNsMaq }

  TNsMaq = Class
  private
    conexaoBD: TZConnection;
    F_IdNS: integer;
    F_IdMaq: integer;
    F_NsMaq: String;
    F_StNs: integer;
    F_IdUsrCad: integer;


  Public
    constructor Create(Conexao: TZConnection);
    destructor Destroy; Override;
    function Inserir: Boolean;
    function Atualizar: Boolean;
    function Apagar: Boolean;
    function Inativar: Boolean;
    function Selecionar(id:integer): Boolean;
    function proximoID:Boolean;

  published
    property IdNS: integer         read F_IdNS       write F_IdNS;
    property IdMaq: integer        read F_IdMaq      write F_IdMaq;
    property NsMaq: String         read F_NsMaq      write F_NsMaq;
    property StNs: integer         read F_StNs       write F_StNs;
    property IdUsrCad: integer     read F_IdUsrCad   write F_IdUsrCad;

  End;

implementation

{ TNsMaq }

constructor TNsMaq.Create(Conexao: TZConnection);
begin
  conexaoBD:= Conexao;
end;

destructor TNsMaq.Destroy;
begin
  inherited Destroy;
end;

function TNsMaq.Inserir: Boolean;
var QRY: TZQuery;
begin
   try
     Result := true;
     QRY := TZQuery.Create(nil);
     QRY.Connection := conexaoBD;
     QRY.SQL.Clear;
     QRY.SQL.Add('INSERT INTO ns_maq (ID_MAQ, NS_MAQ, ST_NS, ID_USR_CAD) '+
                 'VALUES(:ID_MAQ, :NS_MAQ, :ST_NS, :ID_USR_CAD);');


     QRY.ParamByName('ID_MAQ').AsInteger := self.F_IdMaq;
     QRY.ParamByName('NS_MAQ').AsString := SELF.F_NsMaq;
     QRY.ParamByName('ST_NS').AsInteger := SELF.F_StNs;
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

function TNsMaq.Atualizar: Boolean;
var QRY: TZQuery;
begin
   try
     Result := true;
     QRY := TZQuery.Create(nil);
     QRY.Connection := conexaoBD;
     QRY.SQL.Clear;

     QRY.SQL.Add('UPDATE ns_maq SET ID_MAQ= :ID_MAQ, NS_MAQ= :NS_MAQ, ST_NS= :ST_NS, ID_USR_CAD= :ID_USR_CAD WHERE ID_NS= :ID_NS;');

     QRY.ParamByName('ID_NS').AsInteger := self.F_IdNS;
     QRY.ParamByName('ID_MAQ').AsInteger := self.F_IdMaq;
     QRY.ParamByName('NS_MAQ').AsString := SELF.F_NsMaq;
     QRY.ParamByName('ST_NS').AsInteger := SELF.F_StNs;
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

function TNsMaq.Apagar: Boolean;
var QRY: TZQuery;
begin
  try
   Result := true;
   QRY := TZQuery.Create(nil);
   QRY.Connection := conexaoBD;
   QRY.SQL.Clear;

   QRY.SQL.Add('DELETE FROM ns_maq WHERE ID_NS = :ID_NS');

   QRY.ParamByName('ID_NS').AsInteger := self.F_IdMaq;
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

function TNsMaq.Inativar: Boolean;
var QRY: TZQuery;
begin
   try
     Result := true;
     QRY := TZQuery.Create(nil);
     QRY.Connection := conexaoBD;
     QRY.SQL.Clear;

     QRY.SQL.Add('UPDATE ns_maq SET ST_NS = :ST_NS WHERE ID_NS= :ID_NS;');

     QRY.ParamByName('ID_NS').AsInteger := self.F_IdNS;
     QRY.ParamByName('ST_NS').AsInteger := 0;

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

function TNsMaq.Selecionar(id: integer): Boolean;
var QRY: TZQuery;
begin
  try
    Result := true;
    QRY := TZQuery.Create(nil);
    QRY.Connection := conexaoBD;
    QRY.SQL.Clear;
    QRY.SQL.Add('SELECT ID_NS, ID_MAQ, NS_MAQ, ST_NS, ID_USR_CAD FROM ns_maq WHERE ID_NS = :ID_NS;' );
    QRY.ParamByName('ID_NS').AsInteger := id;

    try
      QRY.Open;

      self.F_IdNS:= QRY.FieldByName('ID_NS').AsInteger;
      self.F_IdMaq := QRY.FieldByName('ID_MAQ').AsInteger;
      SELF.F_NsMaq := QRY.FieldByName('NS_MAQ').AsString;
      SELF.F_StNs := QRY.FieldByName('ST_NS').AsInteger;
      SELF.F_IdUsrCad := QRY.FieldByName('ID_USR_CAD').AsInteger;

    except
      result := false;
    end;

  finally
    if Assigned(QRY) then
     freeandnil(QRY);
  end;
end;

function TNsMaq.proximoID: Boolean;
var QRY: TZQuery;
begin
  try
    Result := true;
    QRY := TZQuery.Create(nil);
    QRY.Connection := conexaoBD;
    QRY.SQL.Clear;
    QRY.SQL.Add('SELECT LAST_INSERT_ID();' );

    try
      QRY.Open;
      self.F_IdNS:= qry.FieldByName('LAST_INSERT_ID()').AsInteger;
    except
      result := false;
    end;

  finally
    if Assigned(QRY) then
     freeandnil(QRY);
  end;
end;

end.

