unit RGBtoHSI;

interface

uses
  Math;

type
  (* Stores colors in rgb color model + alpha component *)
  tRGBA = record
    r: byte;
    g: byte;
    b: byte;
    a: byte;
  end;

  (* Stores colors in hsi color model *)
  tHSI = record
    // hue
    h: Single;
    // saturation
    s: Single;
    // intensity
    i: Single;
    // alpha value from tRGBA (just to transmit in case of backtransformation)
    a: byte;
  end;

  (*
  Calculate HSI (hue, saturation, intensity) from RGB values.
  Source for equations: http://www.had2know.com/technology/hsi-rgb-color-converter-equations.html
*)
function CalcHSI(InColor: tRGBA): tHSI; inline;

(*
  Calculate RGB (red, green, blue) from HSI values. Might be inaccurate by 1 digit.
  Source for equations: http://www.had2know.com/technology/hsi-rgb-color-converter-equations.html
*)
function CalcRGBA(InColorHSI: tHSI): tRGBA; inline;

implementation

function CalcHSI(InColor: tRGBA): tHSI;
var
  tempHSI: tHSI;
  red, green, blue: Single;
  hueNum, hueDenom: Single; //numerator and denominator for hue calc.
begin
  red   := InColor.r/255;
  green := InColor.g/255;
  blue  := InColor.b/255;

  //calc. intensity and saturation
  tempHSI.i := (red + green + blue)/3;
  if tempHSI.i > 0 then
    tempHSI.s := 1 - ( (min( min(red, green), blue ))/tempHSI.i )
  else
    tempHSI.i := 0;

  //calc. hue
  //arccos() - arg. needs to be radians; domain -1..1, range 0..pi
  hueNum := red-(0.5*green)-(0.5*blue);
  hueDenom := sqrt( (red*red)+(green*green)+(blue*blue)-(red*green)-(red*blue)-(green*blue) );
  if hueDenom = 0 then
    tempHSI.h := 0
  else
  if green >= blue then
    tempHSI.h := arccos( hueNum/hueDenom )
  else
    tempHSI.h := (2*pi)-arccos( hueNum/hueDenom );

  //transfer alpha value
  tempHSI.a := InColor.a;

  //writeln('HSI = ',tempHSI.h,' ',tempHSI.s,' ',tempHSI.i); //ranges: H rad -1..+1 (pi), s 0..1, i 0..1
  CalcHSI := tempHSI;
end;

function CalcRGBA(InColorHSI: tHSI): tRGBA;
var
  tempRGBA: tRGBA;
  hueDegree: Word;
begin
  tempRGBA.r := 0;
  tempRGBA.g := 0;
  tempRGBA.b := 0;
  tempRGBA.a := InColorHSI.a;
  hueDegree := Round( RadToDeg(InColorHSI.h) );
  if (hueDegree = 0) or (hueDegree = 1) then
  begin
    tempRGBA.r := Round( (InColorHSI.i + 2*InColorHSI.i*InColorHSI.s)*255 );
    tempRGBA.g := Round( (InColorHSI.i - InColorHSI.i*InColorHSI.s)*255 );
    tempRGBA.b := Round( (InColorHSI.i - InColorHSI.i*InColorHSI.s)*255 );
  end else
  if hueDegree = 120 then
  begin
    tempRGBA.r := Round( (InColorHSI.i - InColorHSI.i*InColorHSI.s)*255 );
    tempRGBA.g := Round( (InColorHSI.i + 2*InColorHSI.i*InColorHSI.s)*255 );
    tempRGBA.b := Round( (InColorHSI.i - InColorHSI.i*InColorHSI.s)*255 );
  end else
  if hueDegree = 240 then
  begin
    tempRGBA.r := Round( (InColorHSI.i - InColorHSI.i*InColorHSI.s)*255 );
    tempRGBA.g := Round( (InColorHSI.i - InColorHSI.i*InColorHSI.s)*255 );
    tempRGBA.b := Round( (InColorHSI.i + 2*InColorHSI.i*InColorHSI.s)*255 );
  end else
  //cos() - arg. needs to be radians
  if (hueDegree > 0) and (hueDegree < 120) then
  begin
    tempRGBA.r := Round( (InColorHSI.i + (InColorHSI.i*InColorHSI.s*cos(InColorHSI.h) / cos(DegToRad(60)-InColorHSI.h)) )*255 );
    tempRGBA.g := Round( (InColorHSI.i + (InColorHSI.i*InColorHSI.s*( 1 - ( cos(InColorHSI.h) / cos(DegToRad(60)-InColorHSI.h) )) ))*255 );
    tempRGBA.b := Round( (InColorHSI.i - InColorHSI.i*InColorHSI.s)*255 );
  end else
  if (hueDegree >120) and (hueDegree < 240) then
  begin
    tempRGBA.r := Round( (InColorHSI.i - InColorHSI.i*InColorHSI.s)*255 );
    tempRGBA.g := Round( (InColorHSI.i + ((InColorHSI.i*InColorHSI.s*cos(InColorHSI.h-DegToRad(120))) / cos(DegToRad(180)-InColorHSI.h)))*255 );
    tempRGBA.b := Round( (InColorHSI.i + InColorHSI.i*InColorHSI.s*( 1 - (cos(InColorHSI.h-DegToRad(120)) / cos(DegToRad(180)-InColorHSI.h)) ))*255 );
  end else
  if (hueDegree > 240) and (hueDegree < 360) then
  begin
    tempRGBA.r := Round( (InColorHSI.i + InColorHSI.i*InColorHSI.s*( 1 - (cos(InColorHSI.h-DegToRad(240)) / cos(DegToRad(300)-InColorHSI.h)) ))*255 );
    tempRGBA.g := Round( (InColorHSI.i - InColorHSI.i*InColorHSI.s)*255 );
    tempRGBA.b := Round( (InColorHSI.i + ((InColorHSI.i*InColorHSI.s*cos(InColorHSI.h-DegToRad(240))) / cos(DegToRad(300)-InColorHSI.h)))*255 );
  end;

  //writeln('RGBA = ',tempRGBA.r,' ',tempRGBA.g,' ',tempRGBA.b,' ',tempRGBA.a);
  CalcRGBA := tempRGBA;
end;

end.

