unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  TreeView.DynamicDataTreeView, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, FMX.TreeView;

type

  TForm1 = class(TForm)
      Button1: TButton;
      MainLayout: TLayout;
      procedure FormCreate(Sender: TObject);
      procedure Button1Click(Sender: TObject);
    private const
      ITEM_NUM = 5;
      CHILD_ITEM_NUM = 3;
    private
      fTreeView: TTreeView;
      procedure onFetchData(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

uses
  System.Generics.Collections;

{$R *.fmx}


procedure TForm1.FormCreate(Sender: TObject);
begin
  fTreeView := TTreeView.Create(Self);
  fTreeView.HitTest := False;
  fTreeView.Align  := TAlignLayout.Contents;
  fTreeView.Parent := MainLayout;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  wItem: TDynamicDataTreeViewItem;
  I: Integer;
begin
  fTreeView.BeginUpdate();

  for I := 0 to ITEM_NUM - 1 do
  begin
    wItem := TDynamicDataTreeViewItem.Create(fTreeView);
    wItem.Text := 'item ' + IntToStr(fTreeView.Count + 1);
    wItem.OnFetch := onFetchData;
    wItem.Parent := fTreeView;
  end;

  fTreeView.EndUpdate();
end;


procedure TForm1.onFetchData(Sender: TObject);
var
  wExpandItem: TDynamicDataTreeViewItem;
begin

  if Sender is TDynamicDataTreeViewItem then
  begin
    wExpandItem := TDynamicDataTreeViewItem(Sender);

    // [Mock] Call API to fetch chidren data.
    TThread.CreateAnonymousThread(
      procedure()
      begin
        TThread.Sleep(2000); // [msec]

        TThread.Synchronize(nil,
          procedure()
          var
            I: Integer;
            wItem: TDynamicDataTreeViewItem;
            wItemList: TFetchedItemList;
          begin

            wItemList := TList<TDynamicDataTreeViewItem>.Create();

            for I := 0 to CHILD_ITEM_NUM - 1 do
            begin
              wItem := TDynamicDataTreeViewItem.Create(wExpandItem, {NeedIndicator} False);
              wItem.Text := wExpandItem.Text + '-' + IntToStr(I + 1);
              wItemList.Add(wItem);
            end;

            wExpandItem.AddFetchedItems(wItemList);
          end
        );
      end
    ).Start();

  end;

end;

end.

