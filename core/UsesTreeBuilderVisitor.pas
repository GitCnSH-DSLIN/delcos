unit UsesTreeBuilderVisitor;

interface

uses
  Classes, SysUtils, StrUtils,
  PascalParser, ParseTreeNode, ParseTreeNodeType, SourceToken,
  SourceTreeWalker;

type
  TUsesTreeBuilderVisitorMode = (vmFull, vmSimple);

  TUsesTreeBuilderVisitor = class (TInterfacedObject, INodeVisitor)
  private
    FMode: TUsesTreeBuilderVisitorMode;
    FUnits: TStrings;
    FIndent: Integer;
    FOutput: TStrings;
    function GetUnitName(Node: TParseTreeNode): String;
  protected
    property Mode: TUsesTreeBuilderVisitorMode read FMode;
    property Units: TStrings read FUnits;
    property Indent: Integer read FIndent write FIndent;
    property Output: TStrings read FOutput;
  public
    constructor Create(AMode: TUsesTreeBuilderVisitorMode; AOutput: TStrings);
    destructor Destroy; override;
    procedure Visit(Node: TParseTreeNode);
  end;

implementation

uses
  Options, UnitRegistry;

{ TUsesTreeBuilderVisitor }

{ Private declarations }

function TUsesTreeBuilderVisitor.GetUnitName(Node: TParseTreeNode): String;
begin
  Result := Node.ChildNodes[0].ChildNodes[0].Describe;
end;

{ Public declarations }

constructor TUsesTreeBuilderVisitor.Create(AMode: TUsesTreeBuilderVisitorMode; AOutput: TStrings);
begin
  inherited Create;
  FMode := AMode;
  FUnits := TStringList.Create;
  FOutput := AOutput;
end;

destructor TUsesTreeBuilderVisitor.Destroy;
begin
  FreeAndNil(FUnits);
  inherited Destroy;
end;

procedure TUsesTreeBuilderVisitor.Visit(Node: TParseTreeNode);
var
  UnitName: String;
  Parser: TPascalParser;
  UnitIndex: Integer;
begin
  if Node.NodeType = nUsesItem then
  begin
    if (Mode = vmSimple) and (Indent > 1) then
      Exit;
    UnitName := GetUnitName(Node);
    if Units.IndexOf(UnitName) = - 1 then
    begin
      UnitIndex := Units.Add(UnitName);
      Output.Add(DupeString('  ', Indent) + UnitName);
      Indent := Indent + 1;
      Parser := TUnitRegistry.Instance.UnitParser[UnitName];
      if Assigned(Parser) then
        TSourceTreeWalker.Create.Walk(Parser.Root, Self as INodeVisitor);
      Indent := Indent - 1;
      Units.Delete(UnitIndex);
    end;
  end;
end;

end.

