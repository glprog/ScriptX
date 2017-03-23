unit ScriptX.Variable;

interface

uses System.Rtti, ScriptX.Intf, ScriptX.Common;

type
  TScriptXVariable = class(TInterfacedObject,IScriptXVariable)
  private
    FName : string;
    FOnGetValue : TOnGetValue;
    FValue : TValue;
    FType : TVariableType;
  public
    function GetName: string;
    function GetValue: TValue;
    function GetVariableType: TVariableType;
    function SetName(AName: string): IScriptXVariable;
    function SetOnGetValue(AProc: TOnGetValue): IScriptXVariable;
    function GetOnGetValue : TOnGetValue;
    function SetValue(AValue: TValue): IScriptXVariable;
    function SetVariableType(AType: TVariableType): IScriptXVariable;
  end;

implementation

{ TScriptXVariable }

function TScriptXVariable.GetName: string;
begin
  Result := FName;
end;

function TScriptXVariable.GetOnGetValue: TOnGetValue;
begin
  Result := FOnGetValue;
end;

function TScriptXVariable.GetValue: TValue;
begin
  if Assigned(FOnGetValue) then
    FOnGetValue(Result)
  else
    Result := FValue;
end;

function TScriptXVariable.GetVariableType: TVariableType;
begin
  Result := FType;
end;

function TScriptXVariable.SetName(AName: string): IScriptXVariable;
begin
  FName := AName;
  Result := Self;
end;

function TScriptXVariable.SetOnGetValue(AProc: TOnGetValue): IScriptXVariable;
begin
  FOnGetValue := AProc;
  Result := Self;
end;

function TScriptXVariable.SetValue(AValue: TValue): IScriptXVariable;
begin
  FValue := AValue;
  Result := Self;
end;

function TScriptXVariable.SetVariableType(
  AType: TVariableType): IScriptXVariable;
begin
  FType := AType;
  Result := Self;
end;

end.
