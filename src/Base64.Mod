MODULE Base64;

IMPORT Strings;

VAR
  encTable: ARRAY 64 OF CHAR;

PROCEDURE InitEncTable;
  VAR i: INTEGER;
BEGIN
  FOR i := 0 TO 25 DO encTable[i] := CHR(65 + i) END; (* A-Z *)
  FOR i := 0 TO 25 DO encTable[26 + i] := CHR(97 + i) END; (* a-z *)
  FOR i := 0 TO 9 DO encTable[52 + i] := CHR(48 + i) END; (* 0-9 *)
  encTable[62] := '+'; encTable[63] := '/';
END InitEncTable;

PROCEDURE EncodeString*(src: ARRAY OF CHAR; VAR dst: ARRAY OF CHAR);
  VAR
    i, j, c, c0, c1, c2, l, len, dstIndex: LONGINT;
    chars: ARRAY 3 OF CHAR;

  PROCEDURE OutCode;
  BEGIN
    c0 := ORD(chars[0]);
    c := ASH(c0, -2);
    dst[dstIndex] := encTable[c]; INC(dstIndex);
    c0 := c0 MOD 4;

    c1 := ORD(chars[1]);
    c := ASH(c0, 4) + ASH(c1, -4);
    dst[dstIndex] := encTable[c]; INC(dstIndex);
    c1 := c1 MOD 16;

    c2 := ORD(chars[2]);
    c := ASH(c1, 2) + ASH(c2, -6);
    dst[dstIndex] := encTable[c]; INC(dstIndex);
    c2 := c2 MOD 64;

    dst[dstIndex] := encTable[c2]; INC(dstIndex);

    INC(l, 4);
    IF l >= 76 THEN
      dst[dstIndex] := 0AX; INC(dstIndex); (* New line after 76 characters *)
      l := 0;
    END;
  END OutCode;

BEGIN
  InitEncTable;
  l := 0; dstIndex := 0; len := Strings.Length(src);
  i := 0;
  WHILE i < len DO
    chars[0] := src[i]; INC(i);
    IF i < len THEN chars[1] := src[i] ELSE chars[1] := 0X; INC(i) END;
    IF i < len THEN chars[2] := src[i] ELSE chars[2] := 0X; INC(i) END;
    OutCode;
    IF i >= len THEN
      FOR j := 0 TO 2 DO
        IF chars[j] = 0X THEN
          dst[dstIndex - (3 - j)] := '='; (* Padding with '=' *)
        END;
      END;
    END;
  END;
  dst[dstIndex] := 0X; (* Null-terminate the dst string *)
END EncodeString;

BEGIN
  InitEncTable;
END Base64.

