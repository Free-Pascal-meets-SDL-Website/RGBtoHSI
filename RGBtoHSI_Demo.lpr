program RGBtoHSI_Demo;
uses
  RGBtoHSI;

const
  DemoRGB: tRGBA = (R: 255; G: 0; B: 0; A: 255);
  DemoHSI: tHSI  = (H: 0.5; S: 0.5; I: 0.5; A: 128);

var
  ResultRGB: tRGBA;
  ResultHSI: tHSI;

begin

  writeln('########## Calculation of colors ##########');

  writeln;

  ResultHSI := calcHSI(DemoRGB);
  writeln('Red/Green/Blue/Alpha: ', DemoRGB.R,'/', DemoRGB.G, '/', DemoRGB.B, '/', DemoRGB.A);
  writeln;
  writeln('  translates to... Hue/Saturation/Intensity/(Alpha): ', ResultHSI.H,'/', ResultHSI.S, '/', ResultHSI.I, '/', ResultHSI.A);

  writeln;

  ResultRGB := calcRGBA(DemoHSI);
  writeln('Hue/Saturation/Intensity/(Alpha): ', DemoHSI.H,'/', DemoHSI.S, '/', DemoHSI.I, '/', DemoHSI.A);
  writeln;
  writeln('  translates to... Red/Green/Blue/Alpha: ', ResultRGB.R,'/', ResultRGB.G, '/', ResultRGB.B, '/', ResultRGB.A);

  writeln;

  writeln('###########################################');

  writeln;

  writeln('Press ENTER...');

  readln;

end.

