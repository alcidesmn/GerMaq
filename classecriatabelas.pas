unit ClasseCriaTabelas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  ZAbstractConnection,
  ZConnection,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  untDataModule;

type

  { TClasseCriaTabelas }

  TClasseCriaTabelas = Class
    private
    conexaoBD: TZConnection;

      function funTabelaExiste(NomeTabela: String): Boolean;
      procedure procExecutaDiretoBancoDados(Script: String);
      procedure procFunc;
      procedure procMaq;
      procedure procNsMaq;
      procedure procMovimentacao;
      procedure procEstoque;
      procedure procInsertADM;
    protected

    public
      constructor Create(Conexao: TZConnection);
      destructor Destroy; Override;

  end;

implementation

{ TClasseCriaTabelas }

function TClasseCriaTabelas.funTabelaExiste(NomeTabela: String): Boolean;
var QRY: TZQuery;
begin
 try
   result:= False;
   QRY:= TZQuery.Create(nil);
   QRY.Connection:= conexaoBD;
   QRY.SQL.Clear;
   QRY.SQL.Add('SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = :NOMETABELA ');
   QRY.ParamByName('NOMETABELA').AsString:= NomeTabela;
   qry.Open;

   if qry.FieldByName('TABLE_NAME').AsString <> EmptyStr then
     Result:= true;

 finally
   qry.Close;
   if Assigned(QRY) then
     freeandnil(QRY);
 end;
end;

procedure TClasseCriaTabelas.procExecutaDiretoBancoDados(Script: String);
var QRY: TZQuery;
begin
  try
    QRY := TZQuery.Create(nil);
    QRY.Connection := conexaoBD;
    QRY.SQL.Clear;
    QRY.SQL.Add(Script);
    try
      conexaoBD.StartTransaction;
      QRY.ExecSQL;
      conexaoBD.Commit;
    except
      conexaoBD.Rollback;
    end;
  finally
    qry.Close;
    if Assigned(QRY) then
      freeandnil(QRY);
  end;
end;

procedure TClasseCriaTabelas.procFunc;
begin
  if not funTabelaExiste('FUNCIONARIOS') then
  begin
    procExecutaDiretoBancoDados(
      'CREATE TABLE FUNCIONARIOS( '+
      ' ID_FUNC INT AUTO_INCREMENT, '+
      ' NOME_FUNC VARCHAR(100) NOT NULL, '+
      ' CPF VARCHAR(11) NOT NULL, '+
      ' USUARIO VARCHAR(20), '+
      ' SENHA VARCHAR(20), '+
      ' DT_ADM DATE, '+
      ' DT_DEM DATE, '+
      ' ID_USR_CAD INT NOT NULL, '+
      ' PRIMARY KEY(ID_FUNC))');

    procInsertADM;
  end;
end;

procedure TClasseCriaTabelas.procMaq;
begin
  if not funTabelaExiste('MAQUINAS') then
  begin
    procExecutaDiretoBancoDados(
      ' CREATE TABLE MAQUINAS( ' +
      ' ID_MAQ INT AUTO_INCREMENT, ' +
      ' NOME_MAQ VARCHAR(100) NOT NULL, ' +
      ' DT_COMPRA DATE, ' +
      ' ST_MAQ BOOLEAN, '+
      ' ID_USR_CAD INT NOT NULL, '+
      ' PRIMARY KEY(ID_MAQ), '+
      ' FOREIGN KEY(ID_USR_CAD) REFERENCES FUNCIONARIOS(ID_FUNC));');
  end;
end;

procedure TClasseCriaTabelas.procNsMaq;
begin
  if not funTabelaExiste('NS_MAQ') then
  begin
    procExecutaDiretoBancoDados(
      ' CREATE TABLE NS_MAQ( ' +
      ' ID_NS INT AUTO_INCREMENT, ' +
      ' ID_MAQ INT NOT NULL , ' +
      ' NS_MAQ VARCHAR(30) NOT NULL, ' +
      ' ST_NS BOOLEAN, '+
      ' ID_USR_CAD INT NOT NULL, '+
      ' PRIMARY KEY(ID_NS), '+
      ' FOREIGN KEY(ID_USR_CAD) REFERENCES FUNCIONARIOS(ID_FUNC), '+
      ' FOREIGN KEY(ID_MAQ ) REFERENCES MAQUINAS(ID_MAQ));');
  end;
end;

procedure TClasseCriaTabelas.procMovimentacao;
begin
  if not funTabelaExiste('Movimentacao') then
  begin
    procExecutaDiretoBancoDados(
      ' CREATE TABLE MOVIMENTACAO( ' +
      ' ID_MOV INT AUTO_INCREMENT, ' +
      ' ID_MAQ INT NOT NULL , '+
      ' ID_FUNC INT NOT NULL, ' +
      ' ID_NS INT NOT NULL, ' +
      ' TIPO_MOV BOOLEAN, '+
      ' DT_MOV DATE, '+
      ' PRIMARY KEY(ID_MOV), '+
      ' FOREIGN KEY(ID_MAQ ) REFERENCES MAQUINAS(ID_MAQ), '+
      ' FOREIGN KEY(ID_NS) REFERENCES NS_MAQ(ID_NS), '+
      ' FOREIGN KEY(ID_FUNC) REFERENCES FUNCIONARIOS(ID_FUNC));');
  end;
end;

procedure TClasseCriaTabelas.procEstoque;
begin
  if not funTabelaExiste('Estoque') then
  begin
    procExecutaDiretoBancoDados(
      ' CREATE TABLE ESTOQUE( ' +
      ' ID_ESTOQUE INT AUTO_INCREMENT, ' +
      ' ID_MOV INT NOT NULL, ' +
      ' ID_MAQ INT NOT NULL , ' +
      ' ID_NS INT NOT NULL, '+
      ' EQT_MAQ INT, '+
      ' PRIMARY KEY(ID_ESTOQUE), '+
      ' FOREIGN KEY(ID_MAQ) REFERENCES MAQUINAS(ID_MAQ), '+
      ' FOREIGN KEY(ID_NS) REFERENCES NS_MAQ(ID_NS), '+
      ' FOREIGN KEY(ID_MOV) REFERENCES MOVIMENTACAO(ID_MOV));');
  end;
end;

procedure TClasseCriaTabelas.procInsertADM;
begin
  procExecutaDiretoBancoDados('insert into funcionarios (NOME_FUNC, CPF, USUARIO, SENHA, DT_ADM, DT_DEM, ID_USR_CAD) ' +
                              ' values (''ADMINISTRADOR DO SISTEMA'', ''11111111111'', ''ADMIN'',''GJGI[JOI'', NOW(), NOW(), 1)');
end;

constructor TClasseCriaTabelas.Create(Conexao: TZConnection);
begin
  conexaoBD:= Conexao;
  procFunc;
  procMaq;
  procNsMaq;
  procMovimentacao;
  procEstoque;
end;

destructor TClasseCriaTabelas.Destroy;
begin
  inherited Destroy;
end;

end.

