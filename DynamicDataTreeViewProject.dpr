program DynamicDataTreeViewProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  TreeView.DynamicDataTreeView in 'TreeView.DynamicDataTreeView.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
