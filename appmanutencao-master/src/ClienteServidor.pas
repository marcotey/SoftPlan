unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB,
  System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Threading,
  IOUtils, System.Generics.Collections, ArquivoStream;

type
  TServidor = class
  private
    FPath: String;

  public
    constructor Create;
    //Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean;
    procedure SalvarArquivoParalelo(Arquivo: TMemoryStream; numero:integer);
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
    procedure enviarParalelo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FPath: String;
    FServidor: TServidor;

    function InitDataset: TClientDataset;
  public
  end;

var
  fClienteServidor: TfClienteServidor;
  Contador: integer;

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  System.SyncObjs;
{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
  procedure RollbackFiles(Lista:TList<String>);
  var
    FileName: String;
    j: Integer;
  begin
    for j := 0 to Lista.count do
    begin
      FileName := fServidor.FPath + Lista[j];
      if TFile.Exists(FileName) then
          TFile.Delete(FileName);
    end;
  end;
var
  cds: TClientDataset;
  ArquivoSalvo: TList<String>;
  i: Integer;
begin
  cds := InitDataset;
  ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
  Contador := 1;
  ArquivoSalvo  := TList<String>.Create;
  try
    try
      for i := 0 to QTD_ARQUIVOS_ENVIAR do
      begin
        cds.Append;
        TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
        cds.Post;

        {$REGION Simulação de erro, não alterar}
        if i = (QTD_ARQUIVOS_ENVIAR/2) then
          FServidor.SalvarArquivos(NULL);
        {$ENDREGION}

        FServidor.SalvarArquivos(cds.Data);
        ArquivoSalvo.Add(contador.ToString +  '.pdf');
        cds.EmptyDataSet;
        inc(contador);
        ProgressBar.Position := i;
      end;
    except
      RollbackFiles(ArquivoSalvo);
    end;
  finally
    cds.Free;
    ArquivoSalvo.Free;
  end;
end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
begin
  enviarParalelo;
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  cds := InitDataset;
  ProgressBar.Max :=  QTD_ARQUIVOS_ENVIAR;
  ProgressBar.Position := 0;
  Contador := 1;
  try
      for i := 0 to QTD_ARQUIVOS_ENVIAR do
      begin
        cds.Append;
        TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
        cds.Post;
        FServidor.SalvarArquivos(cds.Data);
        inc(contador);
        cds.EmptyDataSet;
        ProgressBar.Position:=i;
      end;

  finally
    cds.Free;
  end;

end;

procedure TfClienteServidor.enviarParalelo;
var
  ListaArquivos: TList<TMemoryStream>;
  FS:TFileStream;
  MS:TMemoryStream;
  I: Integer;
begin
  FS := TFileStream.Create(FPath, fmOpenRead);
  MS := TMemoryStream.Create;
  MS.LoadFromStream(FS);
  fs.free;
  ListaArquivos := TList<TMemoryStream>.Create;
  try
     ProgressBar.Max :=  QTD_ARQUIVOS_ENVIAR;
     ProgressBar.Position := 0;
     for I := 0 to QTD_ARQUIVOS_ENVIAR do
     begin
        ListaArquivos.Add(MS);
     end;
     i := 0;
      TParallel.&For(0,Pred(ListaArquivos.Count),
            procedure (j: integer)
            begin
              FServidor.SalvarArquivoParalelo(ListaArquivos[j], j);
                  TInterLocked.Increment(i);
            end);

  finally
    if ProgressBar.Position = QTD_ARQUIVOS_ENVIAR then
    begin
      MS.Free;
      ListaArquivos.Free;
    end
    else ProgressBar.Position := i;
  end;
end;

procedure TfClienteServidor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FServidor.Free;
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  FPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
  FServidor := TServidor.Create;
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Clear;
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := ExtractFilePath(ParamStr(0)) + 'Servidor\';
end;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
    cds := TClientDataset.Create(nil);
    Result := False;
  try
    try
      cds.Data := AData;

      {$REGION Simulação de erro, não alterar}
      if cds.RecordCount = 0 then
        Exit;
      {$ENDREGION}

      cds.First;

      while not cds.Eof do
      begin
        FileName := FPath + IntToStr(contador) + '.pdf';
        if TFile.Exists(FileName) then
          TFile.Delete(FileName);

        TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
        cds.Next;
      end;

      Result := True;
    except
      raise;
    end;
  finally
    cds.free;
  end;
end;


procedure TServidor.SalvarArquivoParalelo(Arquivo: TMemoryStream; numero:integer);
var
  FileName: string;
begin
  try
        FileName := FPath + IntToStr(numero) + '.pdf';

        if TFile.Exists(FileName) then
          TFile.Delete(FileName);

        Arquivo.SaveToFile(FileName);
  finally

  end;
end;

end.
