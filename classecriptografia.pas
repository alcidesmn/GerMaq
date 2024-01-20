unit classeCriptografia;

interface

uses Classes;

Function funCriptografar (const Entrada:String): String;
Function funDescCriptografar (const Entrada:String): String;

implementation

Function funCriptografar (const Entrada:String): String;
var i, iQtdeEnt, iIntervalo:integer;
    Saida: String;
    ProximoCaracter: String;
begin
  iIntervalo := 6;
  i := 0;
  iQtdeEnt := 0;

  if Entrada <> '' then
  begin
    iQtdeEnt := Length(Entrada);
    for i := iQtdeEnt downto 1 do
    begin
      ProximoCaracter := Copy(Entrada, i, 1);
      Saida := Saida + (char(ord(ProximoCaracter[1])+iIntervalo));
    end;
  end;
  result := Saida;
end;

Function funDescCriptografar (const Entrada:String): String;
var i, iQtdeEnt, iIntervalo:integer;
    Saida: String;
    ProximoCaracter: String;
begin
  iIntervalo := 6;
  i := 0;
  iQtdeEnt := 0;

  if Entrada <> '' then
  begin
    iQtdeEnt := Length(Entrada);
    for i := iQtdeEnt downto 1 do
    begin
      ProximoCaracter := Copy(Entrada, i, 1);
      Saida := Saida + (char(ord(ProximoCaracter[1])- iIntervalo));
    end;
  end;
  result := Saida;
end;

end.
