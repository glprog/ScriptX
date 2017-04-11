unit ScriptX.Common;

interface

uses System.Rtti;

type
  TVariableType = (vtString, vtInteger, vtDouble, vtObject);

  TOnGetValue = reference to procedure(var AValue : TValue);

  IgnoreProc = class(TCustomAttribute);

  RegisterMethodAttribute = class(TCustomAttribute);

implementation

end.
