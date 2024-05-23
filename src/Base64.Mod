MODULE Base64;
 IMPORT Out, Strings;
VAR
  EncodingTable : ARRAY 64 OF CHAR;
  fixToIncludeEOL*: BOOLEAN;
(* Function to safely access characters in the EncodingTable *)
PROCEDURE GetEncodingChar(index: LONGINT): CHAR;
BEGIN
    RETURN EncodingTable[index];
END GetEncodingChar;

PROCEDURE fix(VAR src: ARRAY OF CHAR);
VAR
  l: LONGINT;
BEGIN
  l := Strings.Length(src);
  IF l+1 < LEN(src) THEN
    src[l] := 0AX;
    src[l+1] := 0X;
  ELSE
    Out.String("warning, passed string has not enough capacity to be fixed to contain 0A"); Out.Ln;
  END;
END fix;

(* Encodes the input string into Base64 format and returns the result via a VAR parameter. *)

PROCEDURE EncodeString*(src: ARRAY OF CHAR; VAR dst: ARRAY OF CHAR);
VAR
  i, j, k, srcLength, dstLen: LONGINT;
  block: ARRAY 3 OF LONGINT;
  enc: ARRAY 4 OF LONGINT;
  pad: LONGINT;
BEGIN
  IF fixToIncludeEOL THEN fix(src) END;
  dstLen := LEN(dst);
  j := 0; (* Index for dst string *)
  i := 0; (* Index for src string *)
  srcLength := Strings.Length(src); (* Use the total allocated length of src *)

  WHILE i < srcLength DO
    (* Fill the block with up to three bytes of input *)
    FOR k := 0 TO 2 DO
      IF i+k < srcLength THEN
        block[k] := ORD(src[i+k])
      ELSE
        block[k] := 0;
      END;
    END;

    (* Convert the 3 bytes into 4 encoded Base64 characters *)
    enc[0] := block[0] DIV 4;
    enc[1] := (block[0] MOD 4) * 16 + block[1] DIV 16;
    enc[2] := (block[1] MOD 16) * 4 + block[2] DIV 64;
    enc[3] := block[2] MOD 64;

    (* Determine the number of padding characters required *)
    IF i+3 > srcLength THEN
      pad := 3 - (srcLength - i)
    ELSE
      pad := 0;
    END;

    (* Write the encoded characters *)
    FOR k := 0 TO 3 DO
      IF j+k < dstLen THEN
        IF k >= 4 - pad THEN
          dst[j+k] := "=";
        ELSE
          dst[j+k] := GetEncodingChar(enc[k]);
        END;
      ELSE
        Out.String("destination capacity is not enough to fit base64 encoded string"); Out.Ln;
        HALT(5);
      END;
    END;

    INC(i, 3);
    INC(j, 4);
  END;
  dst[j] := 0X; (* Null-terminate the dst string *)
END EncodeString;

PROCEDURE GetDecodingChar(ch: CHAR): LONGINT;
VAR
  i: LONGINT;
BEGIN
  FOR i := 0 TO LEN(EncodingTable)-1 DO
    IF EncodingTable[i] = ch THEN
      RETURN i;
    END;
  END;
  Out.String("Invalid character in Base64 encoded string"); Out.Ln;
  HALT(5);
END GetDecodingChar;

(* Decodes the input string from Base64 format and returns the result via a VAR parameter. *)
PROCEDURE DecodeString*(src: ARRAY OF CHAR; VAR dst: ARRAY OF CHAR);
VAR
  i, j, k, srcLength, dstLen: LONGINT;
  block: ARRAY 4 OF LONGINT;
  dec: ARRAY 3 OF LONGINT;
  pad: LONGINT;
  (* Determine the number of padding characters *)
BEGIN
  IF fixToIncludeEOL THEN fix(src) END;
  dstLen := LEN(dst);
  j := 0; (* Index for dst string *)
  i := 0; (* Index for src string *)
  srcLength := Strings.Length(src); (* Use the total allocated length of src *)
  
  IF i+4 > srcLength THEN
    pad := 4 - (srcLength - i)
  ELSE
    pad := 0;
  END;
  (* Convert the 4 encoded Base64 characters into 3 bytes *)
  FOR k := 0 TO 3 DO
    IF j+k < dstLen THEN
      IF k >= 4 - pad THEN
        block[k] := 0;
      ELSE
        block[k] := GetDecodingChar(src[j+k]);
      END;
    ELSE
      Out.String("destination capacity is not enough to fit decoded string"); Out.Ln;
      HALT(5);
    END;
  END;
  (* Convert the 3 bytes into 4 decoded characters *)
  dec[0] := (block[0] * 4) + (block[1] DIV 16);
  dec[1] := ((block[1] MOD 16) * 16) + (block[2] DIV 4);
  dec[2] := ((block[2] MOD 4) * 64) + block[3];
  (* Write the decoded characters *)
  FOR k := 0 TO 2 DO
    IF i+k < dstLen THEN
      dst[i+k] := CHR(dec[k]);
    ELSE
      Out.String("destination capacity is not enough to fit decoded string"); Out.Ln;
      HALT(5);
    END;
  END;
  INC(i, 4);
  INC(j, 3);
END DecodeString;

BEGIN
  fixToIncludeEOL := TRUE;
  COPY("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", EncodingTable);

END Base64.

