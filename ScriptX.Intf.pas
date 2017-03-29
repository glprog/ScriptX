unit ScriptX.Intf;

interface

uses System.Rtti, Data.DB, ScriptX.Common, uPSComponent;

type
  IScriptXDataSetInfo = interface
    ['{D0ED8730-9497-4BD2-BF94-5CF9A9806556}']
    function GetDataSet : TDataSet;
    function SetDataSet(ADataSet : TDataSet) : IScriptXDataSetInfo;
    function GetName : string;
    function SetName(AName : string) : IScriptXDataSetInfo;
  end;

  IScriptXVariable = interface
    ['{AC48AA2C-E59B-4569-8673-8E78B62EC933}']
    function GetName : string;
    function SetName(AName : string) : IScriptXVariable;
    function GetValue : TValue;
    function SetValue(AValue : TValue) : IScriptXVariable;
    function GetVariableType : TVariableType;
    function SetVariableType(AType : TVariableType) : IScriptXVariable;
    function GetOnGetValue : TOnGetValue;
    function SetOnGetValue(AProc : TOnGetValue) : IScriptXVariable;
  end;

  IScriptXContext = interface
    ['{E7009FDB-5710-439F-9E59-B5FBBA9FEA6C}']
    procedure AddDataSet(ADataSetInfo : IScriptXDataSetInfo);
    procedure RemoveDataSet(ADataSetInfo : IScriptXDataSetInfo);
    procedure AddVariable(AVariable : IScriptXVariable);
    procedure RemoveVariable(AVariable : IScriptXVariable);
    function GetVariables : TArray<IScriptXVariable>;
  end;

  IScriptX = interface
    ['{9DD1C76F-D87D-4E75-BE12-3D18030EC9D1}']
    function GetContext : IScriptXContext;
    function SetContext(AContext : IScriptXContext) : IScriptX;
    function GetScript : string;
    function SetScript(AScript : string) : IScriptX;
    function Execute : Boolean;
    function GetMethod(AMethodName : string) : TMethod;
    function OnExecute(AOnExecute : TPSEvent) : IScriptX;
    function OnCompImport(AOnCompImport : TPSOnCompImportEvent) : IScriptX;
    function OnExecImport(AOnExecImport : TPSOnExecImportEvent) : IScriptX;
  end;

implementation

end.
