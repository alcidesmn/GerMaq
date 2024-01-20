unit ClasseMovimentacao;

{$mode ObjFPC}{$H+}

interface


uses
  Classes, SysUtils, ZAbstractRODataset, ZAbstractDataset, ZDataset, Zconnection;

type

  { TNsMaq }

  { TMovimentacao }

  TMovimentacao = Class
  private
    conexaoBD: TZConnection;
    F_IdMov: integer;
    F_IdMaq: integer;
    F_IdFunc: integer;
    F_IdNs: integer;
    F_TipoMov: integer;
    F_DtMov: TDate;
    F_QtEstoque: integer;


  Public
    constructor Create(Conexao: TZConnection);
    destructor Destroy; Override;
    function Inserir: Boolean;
    //function Atualizar: Boolean;
    //function Apagar: Boolean;
    function Selecionar(id:integer): Boolean;

  published
    property IdMov: integer       read F_IdMov       write F_IdMov;
    property IdMaq: integer       read F_IdMaq       write F_IdMaq;
    property IdFunc: integer      read F_IdFunc      write F_IdFunc;
    property IdNs: integer        read F_IdNs        write F_IdNs;
    property TipoMov: integer     read F_TipoMov     write F_TipoMov;
    property DtMov: TDate         read F_DtMov       write F_DtMov;
    property QtEstoque: integer   read F_QtEstoque   write F_QtEstoque;
  End;
implementation

{ TMovimentacao }

constructor TMovimentacao.Create(Conexao: TZConnection);
begin
  conexaoBD:= Conexao;
end;

destructor TMovimentacao.Destroy;
begin
  inherited Destroy;
end;

function TMovimentacao.Inserir: Boolean;
var QRY, Select: TZQuery;
begin
 try
   Select := TZQuery.Create(nil);
   Select.Connection := conexaoBD;
   Select.SQL.Clear;

   Result := true;
   QRY := TZQuery.Create(nil);
   QRY.Connection := conexaoBD;
   QRY.SQL.Clear;
   QRY.SQL.Add('INSERT INTO movimentacao  (ID_MAQ, ID_FUNC, ID_NS, TIPO_MOV, DT_MOV, QT_ESTOQUE) '+
               ' VALUES(:ID_MAQ, :ID_FUNC, :ID_NS, :TIPO_MOV, Now(), :QT_ESTOQUE);' );
   //tipomov 0 Saida / 1 Entrada / 2 Entrada estoque

   if  (self.F_TipoMov = 0) or (self.F_TipoMov = 1) then
   begin
     Select.SQL.Add('SELECT QT_ESTOQUE FROM MOVIMENTACAO WHERE ID_MAQ = :ID_MAQ AND ID_NS = :ID_NS ORDER BY DT_MOV DESC LIMIT 1 ');
     Select.ParamByName('ID_MAQ').AsInteger := self.F_IdMaq;
     Select.ParamByName('ID_NS').AsInteger := self.F_IdNs;
     select.Open;


     if (self.F_TipoMov = 1) then
       SELF.F_QtEstoque:= select.FieldByName('QT_ESTOQUE').AsInteger + SELF.F_QtEstoque
     else
       SELF.F_QtEstoque:= select.FieldByName('QT_ESTOQUE').AsInteger - SELF.F_QtEstoque
   end;



   QRY.ParamByName('ID_MAQ').AsInteger := self.F_IdMaq;
   QRY.ParamByName('ID_FUNC').AsInteger := SELF.F_IdFunc;
   QRY.ParamByName('ID_NS').AsInteger := SELF.F_IdNs;
   QRY.ParamByName('TIPO_MOV').AsInteger := SELF.F_TipoMov;
   QRY.ParamByName('QT_ESTOQUE').AsInteger := SELF.F_QtEstoque;

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

  if assigned(Select) then
    FreeAndNil(Select)
 end;
end;

function TMovimentacao.Selecionar(id: integer): Boolean;
var QRY: TZQuery;
begin
  try
    Result := true;
    QRY := TZQuery.Create(nil);
    QRY.Connection := conexaoBD;
    QRY.SQL.Clear;
    QRY.SQL.Add('SELECT ID_MOV, ID_MAQ, ID_FUNC, ID_NS, TIPO_MOV, DT_MOV, QT_ESTOQUE FROM movimentacao WHERE ID_MOV = :ID_MOV' );
    QRY.ParamByName('ID_MOV').AsInteger := id;

    try
      QRY.Open;

      self.F_IdMov:= QRY.FieldByName('ID_MOV').AsInteger;
      self.F_IdMaq := QRY.FieldByName('ID_MAQ').AsInteger;
      SELF.F_IdFunc := QRY.FieldByName('ID_FUNC').AsInteger;
      SELF.F_IdNs := QRY.FieldByName('ID_NS').AsInteger;
      SELF.F_TipoMov := QRY.FieldByName('TIPO_MOV').AsInteger;
      SELF.F_DtMov := QRY.FieldByName('DT_MOV').AsDateTime;
      SELF.F_QtEstoque:= QRY.FieldByName('QT_ESTOQUE').AsInteger;

    except
      result := false;
    end;

  finally
    if Assigned(QRY) then
     freeandnil(QRY);
  end;
end;

end.

