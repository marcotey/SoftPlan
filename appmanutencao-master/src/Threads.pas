unit Threads;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Math;


type
   MinhaThread = class(TThread)
   procedure Execute; override;
   procedure Verifica;
   procedure Fechar;
   Private
   constructor Create();
end;

type
  TfThreads = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    ProgressBar1: TProgressBar;
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fThreads: TfThreads;
  BarraProgressoCount:integer;

implementation

uses
  System.SyncObjs;

{$R *.dfm}

{ MinhaThread }

constructor MinhaThread.Create;
begin
inherited
  Create(True);
  FreeOnTerminate := True;
  Priority := tpLower;
  //Resume;
end;

procedure MinhaThread.Execute;
Var
  I: Integer;
begin
   Synchronize(Verifica);


   while not Terminated do
    begin
      fThreads.Memo1.Lines.Add(IntToStr(self.ThreadID) + ' - Iniciando processamento');
      for I := 0 to 100 do
      begin
        Sleep(RandomRange(Random(StrtoInt(fThreads.Edit2.Text)), StrtoInt(fThreads.Edit2.Text)));
        TInterLocked.Increment(BarraProgressoCount);
        fThreads.ProgressBar1.Position := BarraProgressoCount;
        if BarraProgressoCount >= 100 then
        begin
          fThreads.Memo1.Lines.Add(IntToStr(self.ThreadID) + ' - Finalizando processamento');
          Terminate; // Finaliza a Thread
          Synchronize(Fechar);
          Break;
        end;
      end;
    end;

end;

procedure MinhaThread.Fechar;
begin
  fThreads.Caption := 'Finalizado';
end;

procedure MinhaThread.Verifica;
begin
  fThreads.Caption := 'EXECUTANDO...';
end;

procedure TfThreads.Button1Click(Sender: TObject);
var
  MinhasThreads: Array of MinhaThread;
  i: Integer;
begin

  SetLength(MinhasThreads, STRTOINT(Edit1.Text));
  ProgressBar1.Max := 101;
  ProgressBar1.Position := 0;
  BarraProgressoCount := 0;

  // Criando as threads dinâmicamente
  for i := 1 to Length(MinhasThreads) do
    begin
      MinhasThreads[High(MinhasThreads)] := MinhaThread.Create();
      MinhasThreads[High(MinhasThreads)].FreeOnTerminate := True;
      MinhasThreads[High(MinhasThreads)].Start;
    end;

  // Verificar se existe alguma Thread em execução
  //O sistema irá ficar rodando esse laço de repetição até que todas as threads sejam finalizadas.
 { i := 0;
  while (i <= High(MinhasThreads)) do
    begin
      if (MinhasThreads[i] <> nil) then
        i := 0
      else
        Inc(i);
    end; }
end;

end.
