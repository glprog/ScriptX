unit uPrincipal;

interface
uses
  System.SysUtils, System.Rtti, DUnitX.TestFramework, ScriptX.Intf, ScriptX, ScriptX.Common,
  ScriptX.Variable;

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
    procedure RegisterMethods;
    [Test]
    procedure GetMethod;
    [Test]
    procedure RunScriptWithVariable;
    [Test]
    procedure GetMethodWithVariable;
  end;

  TDummy = class
    public
      [RegisterMethod]
      function Sum(A, B : Integer) : Integer;
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
  Assert.IsTrue(LSumMethod(1,1) = 2,'Sum(1,1) <> 2');
end;

procedure TTestScriptX.GetMethodWithVariable;
type
  TSomeMethod = function : string of object;
var
  LSomeMethod : TSomeMethod;
begin
  FScript.SetContext(TScriptXContext.New);
  FScript.GetContext.AddVariable(TScriptXVariable.New
    .SetName('LSomeValue')
    .SetVariableType(vtString)
    .SetOnGetValue(procedure (var AValue : TValue)
    begin
      AValue := 'NOOB TEST';
    end));
  FScript.SetScript(
  'function SomeMethod : string; ' +
  'begin ' +
  '  Result := LSomeValue; ' +
  'end; ' +
  'begin end. ');
  LSomeMethod := TSomeMethod(FScript.GetMethod('SomeMethod'));
  Assert.IsTrue(LSomeMethod = 'NOOB TEST' ,'LSomeMethod <> ''NOOB TEST''');
end;

procedure TTestScriptX.RegisterMethods;
type
  TSomaMethod = function (A, B : Integer) : Integer of object;
var
  LSomaMethod : TSomaMethod;
begin
  FScript.RegisterMethods(TDummy);
  FScript.SetScript(
  'function Soma(A, B : Integer) : Integer;' +
  'begin ' +
  '  Result := Sum(A, B);' +
  'end;' +
  'begin end.');
  LSomaMethod := TSomaMethod(FScript.GetMethod('Soma'));
  Assert.IsTrue(LSomaMethod(1,1) = 2,'Sum(1,1) <> 2');
end;

procedure TTestScriptX.RunScriptWithVariable;
begin
  FScript.SetContext(TScriptXContext.New);
  FScript.GetContext.AddVariable(TScriptXVariable.New
    .SetName('LSomeValue')
    .SetVariableType(vtString)
    .SetOnGetValue(procedure (var AValue : TValue)
    begin
      AValue := 'NOOB TEST';
    end));
  FScript.SetScript('var s : string; begin s := LSomeValue; end.').Execute;
end;

procedure TTestScriptX.RunSimpleScript;
begin
  FScript.SetScript('var n : string; begin n:=''noob''; end.').Execute;
end;

procedure TTestScriptX.SetupFixture;
begin
  FScript := TScriptX.New;
end;

{ TDummy }

function TDummy.Sum(A, B: Integer): Integer;
begin
  Result := A + B;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestScriptX);
end.
