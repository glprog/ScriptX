unit ScriptX;

interface

uses System.SysUtils, System.Generics.Collections , ScriptX.Common, ScriptX.Intf,
uPSComponent, uPSCompiler, uPSRunTime, uPSR_DB, uPSC_DB;

type

  TScriptXContext = class(TInterfacedObject, IScriptXContext)
  private
    FDataSetList : TList<IScriptXDataSetInfo>;
    FVariableList : TList<IScriptXVariable>;
  public
    constructor Create;
    destructor Destroy;override;
    procedure AddDataSet(ADataSetInfo: IScriptXDataSetInfo);
    procedure AddVariable(AVariable: IScriptXVariable);
    function GetVariables: System.TArray<ScriptX.Intf.IScriptXVariable>;
    procedure RemoveDataSet(ADataSetInfo: IScriptXDataSetInfo);
    procedure RemoveVariable(AVariable: IScriptXVariable);
  end;

  TScriptX = class(TInterfacedObject, IScriptX)
  private
    FContext : IScriptXContext;
    FScript : TPSScript;
    FCompiled : Boolean;
    //procedure OnCompile(Sender: TPSScript);
    procedure InternalOnExecute(Sender: TPSScript);
    procedure InternalOnCompileImport(Sender: TObject; x: TPSPascalCompiler);
    procedure InternalOnExecImport(Sender: TObject; se: TPSExec; x: TPSRuntimeClassImporter);
  public
    constructor Create;
    destructor Destroy;override;
    function GetContext: IScriptXContext;
    function GetScript: string;
    function SetContext(AContext: IScriptXContext): IScriptX;
    function SetScript(AScript: string): IScriptX;
    function Execute: Boolean;
    function GetMethod(AMethodName : string) : TMethod;
  end;

implementation

{ TScriptXContext }

procedure TScriptXContext.AddDataSet(ADataSetInfo: IScriptXDataSetInfo);
begin
  if not FDataSetList.Contains(ADataSetInfo) then
    FDataSetList.Add(ADataSetInfo);
end;

procedure TScriptXContext.AddVariable(AVariable: IScriptXVariable);
begin
  if not FVariableList.Contains(AVariable) then
    FVariableList.Add(AVariable);
end;

constructor TScriptXContext.Create;
begin
  FDataSetList := TList<IScriptXDataSetInfo>.Create;
  FVariableList := TList<IScriptXVariable>.Create;
end;

destructor TScriptXContext.Destroy;
begin
  FDataSetList.Free;
  FVariableList.Free;
  inherited;
end;

function TScriptXContext.GetVariables: System.TArray<ScriptX.Intf.IScriptXVariable>;
begin
  Result := FVariableList.ToArray;
end;

procedure TScriptXContext.RemoveDataSet(ADataSetInfo: IScriptXDataSetInfo);
begin
{ TODO : Implementar }
end;

procedure TScriptXContext.RemoveVariable(AVariable: IScriptXVariable);
begin
{ TODO : Implementar }
end;

{ TScriptX }

constructor TScriptX.Create;
begin
  FScript := TPSScript.Create(nil);
  FScript.OnCompImport := InternalOnCompileImport;
  FScript.OnExecImport := InternalOnExecImport;
  FScript.OnExecute := InternalOnExecute;
end;

destructor TScriptX.Destroy;
begin
  FScript.Free;
  inherited;
end;

function TScriptX.Execute: Boolean;
begin
  FCompiled := FScript.Compile;
  Result := FCompiled and FScript.Execute;
end;

function TScriptX.GetContext: IScriptXContext;
begin
  Result := FContext;
end;

function TScriptX.GetMethod(AMethodName : string) : TMethod;
var LMsg : string;
    I : Integer;
begin
  FCompiled := FScript.Compile;
  if not FCompiled then
  begin
    for I := 0 to Pred(FScript.CompilerMessageCount) do
      LMsg := LMsg + #13 + FScript.CompilerMessages[I].MessageToString;
    raise Exception.Create('Erro: ' + LMsg);
  end;
  Result := FScript.GetProcMethod(AMethodName);
end;

function TScriptX.GetScript: string;
begin
  Result := FScript.Script.Text;
end;

procedure TScriptX.InternalOnCompileImport(Sender: TObject; x: TPSPascalCompiler);
var LVariable : IScriptXVariable;
    //LDataSet : IScriptXDataSetInfo;
    LVariableType : string;
begin
  SIRegister_DB(x);
  if Assigned(FContext) then
  begin
    for LVariable in FContext.GetVariables do
    begin
      case LVariable.GetVariableType of
        vtString : LVariableType := 'string';
        vtInteger : LVariableType := 'integer';
        vtDouble : LVariableType := 'double';
        vtObject : LVariableType := LVariable.GetValue.AsObject.ClassName;
      end;
      x.AddVariable(LVariable.GetName, x.FindType(LVariableType));
    end;
  end;
end;

procedure TScriptX.InternalOnExecImport(Sender: TObject; se: TPSExec;
  x: TPSRuntimeClassImporter);
begin
  RIRegister_DB(x);
end;

procedure TScriptX.InternalOnExecute(Sender: TPSScript);
var LPPSVariant : PPSVariant;
    LVariable : IScriptXVariable;
begin
  if Assigned(FContext) then
  begin
    for LVariable in FContext.GetVariables do
    begin
      LPPSVariant := Sender.GetVariable(LVariable.GetName);
      case LVariable.GetVariableType of
        vtString : PPSVariantUString(LPPSVariant).Data := LVariable.GetValue.AsString;
        vtInteger : PPSVariantS32(LPPSVariant).Data := LVariable.GetValue.AsInteger;
        vtDouble : PPSVariantDouble(LPPSVariant).Data := LVariable.GetValue.AsExtended;
        vtObject : PPSVariantClass(LPPSVariant).Data := LVariable.GetValue.AsObject;
      end;
    end;
  end;
end;

function TScriptX.SetContext(AContext: IScriptXContext): IScriptX;
begin
  FContext := AContext;
  FCompiled := False;
  Result := Self;
end;

function TScriptX.SetScript(AScript: string): IScriptX;
begin
  FScript.Script.Text := AScript;
  FCompiled := False;
  Result := Self;
end;

end.
