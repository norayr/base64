MODULE testBase64;
IMPORT Out, Base64;

VAR src, dst: ARRAY 128 OF CHAR;

BEGIN
COPY("mypassword", src);
Base64.EncodeString(src, dst);
Out.String(dst); Out.Ln;


END testBase64.
