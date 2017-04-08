unit ScriptX;

interface

uses System.SysUtils, System.Rtti, System.Generics.Collections , ScriptX.Common, ScriptX.Intf,
uPSComponent, uPSCompiler, uPSRunTime, uPSR_DB, uPSC_DB, uPSUtils;

type

  TScriptXContext = class(TInterfacedObject, IScriptXContext)
  private
    FDataSetList : TList<IScriptXDataSetInfo>;
    FVariableList : TList<IScriptXVariable>;
  public
    constructor Create;
    destructor Destroy;override;
    class function New : IScriptXContext;
    procedure AddDataSet(ADataSetInfo: IScriptXDataSetInfo);
    procedure AddVariable(AVariable: IScriptXVariable);
    function GetVariables: System.TArray<ScriptX.Intf.IScriptXVariable>;
    procedure RemoveDataSet(ADataSetInfo: IScriptXDataSetInfo);
    procedure RemoveVariable(AVariable: IScriptXVariable);
  end;

  TScriptX = class(TInterfacedObject, IScriptX)
  private
    FContext : IScriptXContext;
    FRttiContext : TRttiContext;
    FScript : TPSScript;
    FCompiled : Boolean;
    FOnCompile : TPSEvent;
    FOnExecute : TPSEvent;
    FOnCompImport : TPSOnCompImportEvent;
    FOnExecImport : TPSOnExecImportEvent;
    FMethods : TList<TRttiMethod>;
    FDummyObject : TObject;
    FCompiledData : AnsiString;
    //procedure OnCompile(Sender: TPSScript);
    procedure InternalOnCompile(Sender : TPSScript);
    procedure InternalOnExecute(Sender: TPSScript);
    procedure InternalOnCompileImport(Sender: TObject; x: TPSPascalCompiler);
    procedure InternalOnExecImport(Sender: TObject; se: TPSExec; x: TPSRuntimeClassImporter);
    procedure LoadVars(AExec : TPSExec);
  public
    constructor Create;
    destructor Destroy;override;
    class function New : IScriptX;
    function GetContext: IScriptXContext;
    function GetScript: string;
    function SetContext(AContext: IScriptXContext): IScriptX;
    function SetScript(AScript: string): IScriptX;
    function Execute: Boolean;
    function GetMethod(AMethodName : string) : TMethod;
    function OnCompile(AOnCompile: TPSEvent): IScriptX;
    function OnExecute(AOnExecute: TPSEvent): IScriptX;
    function OnCompImport(AOnCompImport: TPSOnCompImportEvent): IScriptX;
    function OnExecImport(AOnExecImport: TPSOnExecImportEvent): IScriptX;
    function RegisterMethods(ADummyClass : TClass): IScriptX;
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

class function TScriptXContext.New: IScriptXContext;
begin
  Result := Create;
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
  FScript.OnCompile := InternalOnCompile;
  FScript.OnExecute := InternalOnExecute;
  FRttiContext := TRttiContext.Create;
  FRttiContext.KeepContext;
  FMethods := TList<TRttiMethod>.Create;
  FDummyObject := nil;
end;

destructor TScriptX.Destroy;
begin
  FScript.Free;
  FMethods.Free;
  FDummyObject.Free;
  FRttiContext.DropContext;
  inherited;
end;

function TScriptX.Execute: Boolean;
var LMsg : string;
    I : Integer;
begin
  FCompiled := FScript.Compile;
  if not FCompiled then { TODO : Refatorar }
  begin
    for I := 0 to Pred(FScript.CompilerMessageCount) do
      LMsg := LMsg + #13 + FScript.CompilerMessages[I].MessageToString;
    raise Exception.Create('Erro: ' + LMsg);
  end;
  Result := FCompiled and FScript.Execute;
end;

function TScriptX.GetContext: IScriptXContext;
begin
  Result := FContext;
end;

function TScriptX.GetMethod(AMethodName : string) : TMethod;
var LMsg : string;
    I : Integer;
    LCompiler : TPSPascalCompiler;
    LExec : TPSExec;
begin
  LCompiler := Self.FScript.Comp;
  LExec := FScript.Exec;
  FCompiled := LCompiler.Compile(FScript.Script.Text);
  if not FCompiled then
  begin
    for I := 0 to Pred(LCompiler.MsgCount) do
      LMsg := LMsg + #13 + LCompiler.Msg[I].MessageToString;
    raise Exception.Create('Erro: ' + LMsg);
  end;
  LCompiler.GetOutput(FCompiledData);
  LExec.LoadData(FCompiledData);
  LoadVars(LExec);
  Result := LExec.GetProcAsMethodN(AMethodName);
end;

function TScriptX.GetScript: string;
begin
  Result := FScript.Script.Text;
end;

procedure TScriptX.InternalOnCompile(Sender: TPSScript);
var LMethod : TRttiMethod;
    LVariable : IScriptXVariable;
    LVariableType : string;
begin
  if Assigned(FOnCompile) then
    FOnCompile(Sender);
  if Assigned(FDummyObject) then
  begin
    for LMethod in FMethods do
      Sender.AddMethod(FDummyObject, LMethod.CodeAddress, LMethod.ToString);
  end;
end;

procedure TScriptX.InternalOnCompileImport(Sender: TObject; x: TPSPascalCompiler);
var LVariable : IScriptXVariable;
    //LDataSet : IScriptXDataSetInfo;
    LVariableType : string;
begin
  SIRegister_DB(x);{ TODO : Remover }
  if Assigned(FOnCompImport) then
    FOnCompImport(Sender, x);
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
  RIRegister_DB(x);{ TODO : Remover }
  if Assigned(FOnExecImport) then
    FOnExecImport(Sender, se, x);
end;

procedure TScriptX.InternalOnExecute(Sender: TPSScript);
var LPPSVariant : PPSVariant;
    LVariable : IScriptXVariable;
    LMethod : TRttiMethod;
begin
  if Assigned(FOnExecute) then
    FOnExecute(Sender);
  LoadVars(Sender.Exec);
end;

procedure TScriptX.LoadVars(AExec: TPSExec);
var LPPSVariant : PPSVariant;
    LVariable : IScriptXVariable;
begin
  if Assigned(FContext) then
  begin
    for LVariable in FContext.GetVariables do
    begin
      LPPSVariant := AExec.GetVar2(LVariable.GetName);
      case LVariable.GetVariableType of
        vtString : PPSVariantUString(LPPSVariant).Data := LVariable.GetValue.AsString;
        vtInteger : PPSVariantS32(LPPSVariant).Data := LVariable.GetValue.AsInteger;
        vtDouble : PPSVariantDouble(LPPSVariant).Data := LVariable.GetValue.AsExtended;
        vtObject : PPSVariantClass(LPPSVariant).Data := LVariable.GetValue.AsObject;
      end;
    end;
  end;
end;

class function TScriptX.New: IScriptX;
begin
  Result := Create;
end;

function TScriptX.OnCompile(AOnCompile: TPSEvent): IScriptX;
begin
  FOnCompile := AOnCompile;
end;

function TScriptX.OnCompImport(AOnCompImport: TPSOnCompImportEvent): IScriptX;
begin
  FOnCompImport := AOnCompImport;
  Result := Self;
end;

function TScriptX.OnExecImport(AOnExecImport: TPSOnExecImportEvent): IScriptX;
begin
  FOnExecImport := AOnExecImport;
  Result := Self;
end;

function TScriptX.OnExecute(AOnExecute: TPSEvent): IScriptX;
begin
  FOnExecute := AOnExecute;
  Result := Self;
end;

function TScriptX.RegisterMethods(ADummyClass : TClass): IScriptX;
var LType : TRttiType;
    LMethod : TRttiMethod;
begin
  LType := FRttiContext.GetType(ADummyClass);
  FMethods.Clear;
  FreeAndNil(FDummyObject);
  FDummyObject := ADummyClass.Create;
  for LMethod in LType.GetDeclaredMethods do
    FMethods.Add(LMethod);
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
