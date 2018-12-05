unit TreeView.DynamicDataTreeView;

interface

uses
  FMX.TreeView, System.Classes, FMX.StdCtrls, System.Generics.Collections,
  System.SysUtils;

type

  TIndicatorTreeViewItem = class(TTreeViewItem)
    private
      fIndicator: TAniIndicator;
    public
      constructor Create(AOwner: TComponent); override;
  end;


  TDynamicDataTreeViewItem = class;

  TFetchedItemList = TList<TDynamicDataTreeViewItem>;

  TDynamicDataTreeViewItem = class(TTreeViewItem)
    private
      fOnExpand:    TNotifyEvent;
      fOnExpanded:  TNotifyEvent;
      fOnCollapse:  TNotifyEvent;
      fOnCollapsed: TNotifyEvent;
      fOnFetch: TNotifyEvent;
      procedure onExpandProc(Sender: TObject);
    protected
      procedure SetIsExpanded(const Value: Boolean); override;
    public
      constructor Create(AOwner: TComponent; ANeedIndicator: Boolean = True); overload;
      procedure AddFetchedItems(AItemList: TFetchedItemList);
      property OnExpand:    TNotifyEvent read fOnExpand    write fOnExpand;
      property OnExpanded:  TNotifyEvent read fOnExpanded  write fOnExpanded;
      property OnCollapse:  TNotifyEvent read fOnCollapse  write fOnCollapse;
      property OnCollapsed: TNotifyEvent read fOnCollapsed write fOnCollapsed;
      property OnFetch: TNotifyEvent read fOnFetch write fOnFetch;
  end;


implementation

uses
  System.UITypes, FMX.Types;


{ TIndicatorTreeViewItem }

constructor TIndicatorTreeViewItem.Create(AOwner: TComponent);
begin
  inherited;
  Self.Text := 'Loading...';
  fIndicator := TAniIndicator.Create(Self);
  fIndicator.Align := TAlignLayout.FitLeft;
  fIndicator.Margins.Left  := 5;
  fIndicator.Margins.Right := 5;
  fIndicator.Enabled := True;
  AddObject(fIndicator);
end;


{ TDynamicDataTreeViewItem }

constructor TDynamicDataTreeViewItem.Create(AOwner: TComponent; ANeedIndicator: Boolean);
begin
  inherited Create(AOwner);
  Self.Height   := Self.DefaultHeight;
  Self.OnExpand := onExpandProc;
  if ANeedIndicator then
    Self.AddObject( TIndicatorTreeViewItem.Create(Self) );
end;


procedure TDynamicDataTreeViewItem.SetIsExpanded(const Value: Boolean);
begin
  if IsExpanded <> Value then
  begin
    if Value AND Assigned(OnExpand) then
      OnExpand(Self);
    if (not Value) AND Assigned(OnCollapse) then
      OnCollapse(Self);

    inherited;

    if Value AND Assigned(OnExpanded) then
      OnExpanded(Self);
    if (not Value) AND Assigned(OnCollapsed) then
      OnCollapsed(Self);

  end else begin
    inherited;
  end;
end;


procedure TDynamicDataTreeViewItem.onExpandProc(Sender: TObject);
begin
  // Check whether children have already been fetched.
  if (Self.Count = 0) OR
     (not (Self.Items[0] is TIndicatorTreeViewItem)) then
    exit();

  // Try to fetch children.
  if Assigned(fOnFetch) then
    fOnFetch(Sender);
end;


procedure TDynamicDataTreeViewItem.AddFetchedItems(AItemList: TFetchedItemList);
var
  wIndicatorItem: TIndicatorTreeViewItem;
  wItem: TDynamicDataTreeViewItem;
begin
  Self.TreeView.BeginUpdate();

  // Remove indicator item.
  if (Self.Count > 0) AND (Self.Items[0] is TIndicatorTreeViewItem) then
  begin
    wIndicatorItem := Self.Items[0] as TIndicatorTreeViewItem;
    Self.RemoveObject(wIndicatorItem);
    FreeAndNil(wIndicatorItem);
  end;

  // Add fetched items as children.
  for wItem in AItemList do
    Self.AddObject(wItem);

  Self.TreeView.EndUpdate();
end;

end.

