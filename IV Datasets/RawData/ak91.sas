options ls=80 nocenter;
filename indat 'asciiqob.txt';
libname save 'sasdata';

*goptions device=xcolor;


filename grafout pipe 'lpr -Pbrar';
goptions device=pslmono gsfname=grafout gsfmode=replace gaccess=sasgastd
         vsize=7 vorigin=3 ftext=centx;

/* read stripped ak-91 extract and process means for figures */

data zero;
 infile indat;
 input lwklywge educ yob qob pob;

proc means;
title '1980 qob extract';

data one;
 set zero;

%MACRO QTRSYR;
             QTR220 QTR320 QTR420        QTR221 QTR321 QTR421
             QTR222 QTR322 QTR422
             QTR223 QTR323 QTR423        QTR224 QTR324 QTR424
             QTR225 QTR325 QTR425
             QTR226 QTR326 QTR426        QTR227 QTR327 QTR427
             QTR228 QTR328 QTR428        QTR229 QTR329 QTR429
%mend;

LENGTH QTR120 3
       %QTRSYR 3
       YR20-YR29 3
       QTR1-QTR4 3;

ARRAY AQTR QTRSYR;
  DO OVER AQTR; AQTR = 0 ; END;

YR20 = ((YOB=30) OR (YOB=40));
YR21 = ((YOB=31) OR (YOB=41));
YR22 = ((YOB=32) OR (YOB=42));
YR23 = ((YOB=33) OR (YOB=43));
YR24 = ((YOB=34) OR (YOB=44));
YR25 = ((YOB=35) OR (YOB=45));
YR26 = ((YOB=36) OR (YOB=46));
YR27 = ((YOB=37) OR (YOB=47));
YR28 = ((YOB=38) OR (YOB=48));
YR29 = ((YOB=39) OR (YOB=49));

QTR1 = (QOB=1);
QTR2 = (QOB=2);
QTR3 = (QOB=3);
QTR4 = (QOB=4);

QTR120 = QTR1 * YR20; QTR220 = QTR2 * YR20; QTR320 = QTR3 * YR20;
QTR420 = QTR4 * YR20;
QTR121 = QTR1 * YR21; QTR221 = QTR2 * YR21; QTR321 = QTR3 * YR21;
QTR421 = QTR4 * YR21;
QTR122 = QTR1 * YR22; QTR222 = QTR2 * YR22; QTR322 = QTR3 * YR22;
QTR422 = QTR4 * YR22;
QTR123 = QTR1 * YR23; QTR223 = QTR2 * YR23; QTR323 = QTR3 * YR23;
QTR423 = QTR4 * YR23;
QTR124 = QTR1 * YR24; QTR224 = QTR2 * YR24; QTR324 = QTR3 * YR24;
QTR424 = QTR4 * YR24;
QTR125 = QTR1 * YR25; QTR225 = QTR2 * YR25; QTR325 = QTR3 * YR25;
QTR425 = QTR4 * YR25;
QTR126 = QTR1 * YR26; QTR226 = QTR2 * YR26; QTR326 = QTR3 * YR26;
QTR426 = QTR4 * YR26;
QTR127 = QTR1 * YR27; QTR227 = QTR2 * YR27; QTR327 = QTR3 * YR27;
QTR427 = QTR4 * YR27;
QTR128 = QTR1 * YR28; QTR228 = QTR2 * YR28; QTR328 = QTR3 * YR28;
QTR428 = QTR4 * YR28;
QTR129 = QTR1 * YR29; QTR229 = QTR2 * YR29; QTR329 = QTR3 * YR29;
QTR429 = QTR4 * YR29;

keep yr21-yr29 %qtrsyr educ lwklywge qtr1-qtr3;

*******************************************************;

proc means;
title 'working data set';


proc syslin data=one;
title 'OLS';

model lwklywge = yr21-yr29 educ;

/* part I: 30 instrument case */

     proc syslin data=one 2sls;
     title '30-instrument case: regular 2sls';
     instruments yr21-yr29 %qtrsyr;
     endogenous lwklywge educ;
     model lwklywge = yr21-yr29 educ/overid;


run;
