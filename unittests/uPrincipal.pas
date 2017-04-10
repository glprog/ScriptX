unit uPrincipal;

interface
uses
  System.SysUtils, DUnitX.TestFramework, ScriptX.Intf, ScriptX;

type

  [TestFixture('TScriptX')]
  TTestScriptX = class(TObject)
  private
    FScript : IScriptX;
  public
    [SetupFixture]
    procedure SetupFixture;
    [Test]
    procedure RunSimpleScript;
    [Test]
    procedure GetMethod;
  end;

implementation


{ TTestScriptX }

procedure TTestScriptX.GetMethod;
type
  TSumMethod = function (A, B : Integer) : Integer of object;
var
  LSumMethod : TSumMethod;
begin
  FScript.SetScript(
  'function Sum(A, B : Integer) : Integer; ' +
  'begin ' +
  '  Result := A + B; ' +
  'end; ' +
  'begin end. ');
  LSumMethod := TSumMethod(FScript.GetMethod('Sum'));
  if (LSumMethod(1,1) <> 2) then
    raise Exception.Create('Erro Sum(1, 1) <> 2');
end;

procedure TTestScriptX.RunSimpleScript;
begin
  FScript.SetScript('var n : string; begin n:=''noob''; end.').Execute;
end;

procedure TTestScriptX.SetupFixture;
begin
  FScript := TScriptX.New;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestScriptX);
end.
