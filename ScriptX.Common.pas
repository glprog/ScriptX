unit ScriptX.Common;

interface

uses System.Rtti;

type
  TVariableType = (vtString, vtInteger, vtDouble, vtObject);

  TOnGetValue = reference to procedure(var AValue : TValue);

implementation

end.
