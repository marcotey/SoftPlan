unit ArquivoStream;

interface
uses
  System.Classes, System.SysUtils;

type

  TArquivoStream = class
  private

  public
    procedure LoadData(FileName: TFileName);
    function ReadStreamInt(Stream: TStream): integer;
    function ReadStreamStr(Stream: TStream): string;
    procedure SaveData(FileName: TFileName);
    procedure WriteStreamInt(Stream: TStream; Num: integer);
    procedure WriteStreamStr(Stream: TStream; Str: string);
  end;

implementation



procedure TArquivoStream.SaveData(FileName: TFileName);
var
 MemStr: TMemoryStream;
 Title: String;
begin
 MemStr:= TMemoryStream.Create;
try
 MemStr.Seek(0, soFromBeginning);
 WriteStreamStr( MemStr, TItle );
 MemStr.SaveToFile(FileName);
finally
 MemStr.Free;
end;
end;

procedure TArquivoStream.LoadData(FileName: TFileName);
var
 MemStr: TMemoryStream;
 Title: String;
begin
 MemStr:= TMemoryStream.Create;
 try
  MemStr.LoadFromFile(FileName);
  MemStr.Seek(0, soFromBeginning);
  Title := ReadStreamStr( MemStr );
 finally
   MemStr.Free;
  end;
end;



procedure TArquivoStream.WriteStreamInt(Stream : TStream; Num : integer);
 {writes an integer to the stream}
begin
 Stream.WriteBuffer(Num, SizeOf(Integer));
end;

procedure TArquivoStream.WriteStreamStr(Stream : TStream; Str : string);
 {writes a string to the stream}
var
 StrLen : integer;
begin
 {get length of string}
 StrLen := Length(Str);
 {write length of string}
 WriteStreamInt(Stream, StrLen);
 if StrLen > 0 then
 {write characters}
 //Stream.Write(Str[1], StrLen);
 Stream.Write(Str[1], StrLen * SizeOf(Str[1]));
end;


function TArquivoStream.ReadStreamInt(Stream : TStream) : integer;
 {returns an integer from stream}
begin
 Stream.ReadBuffer(Result, SizeOf(Integer));
end;

function TArquivoStream.ReadStreamStr(Stream : TStream) : string;
 {returns a string from the stream}
var
 LenStr : integer;
begin
 Result := '';
 {get length of string}
 LenStr := ReadStreamInt(Stream);
 {set string to get memory}
 SetLength(Result, LenStr);
 {read characters}
 Stream.Read(Result[1], LenStr);
end;

end.
