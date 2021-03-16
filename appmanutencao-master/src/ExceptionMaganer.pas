unit ExceptionMaganer;

interface

uses
  System.SysUtils, Forms;

type
  TExceptionManager = class
    private
      FLogfile : String;
    public
      constructor create;
      procedure TrataException(Sender: TObject; E: Exception);
      procedure GravarLog(Value: String);

  end;

implementation

uses
  System.Classes, Vcl.Dialogs;


{ TExceptionManager }

constructor TExceptionManager.create;
begin
  FLogfile := ChangeFileExt(ParamStr(0), '.Log');
  Application.OnException := TrataException;
end;

procedure TExceptionManager.GravarLog(Value: String);
var
  txtLog: TextFile;
begin
  AssignFile(txtLog, FLogfile);
  if FileExists(FLogfile) then
  begin
    Append(txtLog)
  end
  else
    Rewrite(txtlog);

  Writeln(txtLog, FormatDateTime('dd/mm/yy hh:mm:ss - ' , now) + Value);
  CloseFile(txtLog);
end;

procedure TExceptionManager.TrataException(Sender: TObject; E: Exception);
begin
  GravarLog('=========================================================');
  if TComponent(Sender) is TForm then
  begin
    GravarLog('Form: ' + TForm(Sender).Name);
    GravarLog('Caption: ' + TForm(Sender).Caption);
    GravarLog('Erro: ' + E.ClassName);
    GravarLog('Erro: ' + E.Message);
  end
  else
  begin
    GravarLog('Form: ' + TForm(TComponent(Sender).Owner).Name);
    GravarLog('Caption: ' + TForm(TComponent(Sender).Owner).Caption);
    GravarLog('Erro: ' + E.ClassName);
    GravarLog('Erro: ' + E.Message);
  end;

  Showmessage(E.Message);

end;

end.
