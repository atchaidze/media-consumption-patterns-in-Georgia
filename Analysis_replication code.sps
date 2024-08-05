* Encoding: UTF-8.
* Encoding: .
* Encoding: .
* Encoding: .
* Encoding: .
GET 
  FILE='C:\Users\crrc_\OneDrive\Documents\PHD thesis\Article\CB_2024_Geo_04.06.2024.sav'. 
 

*compute normalized weights to doublecheck effects. 
COMPUTE wt_norm=(indwt*1509) / 2887608.
VARIABLE LABELS  wt_norm 'Normalized weights'.
EXECUTE.


*WEIGHT BY indwt.
WEIGHT BY wt_indwt.

MISSING VALUES in n1 to phone (-7, -9, -3).

*first and second source of information

FREQUENCIES VARIABLES=m1a m1b 
  /BARCHART PERCENT 
  /ORDER=ANALYSIS.

*recode main source.
RECODE m1a (999=SYSMIS) (8=0) (Lowest thru -3=SYSMIS) (-2 thru -1=SYSMIS) (1 thru 3=1) (4 thru 5=2)
    (6 thru 7=SYSMIS) INTO main_source.
VARIABLE LABELS  main_source 'main source of information'.
VALUE LABELS main_source
'0' "TV"
'1' 'Word of mouth'
'2' 'Internet and social media'
EXECUTE.

*multinomial regression model:.

MISSING VALUES in d9 d11 d2 age j7 (-9 thru -1).


RECODE d2 (Lowest thru -1=SYSMIS)  (1 thru 4=1) (5=2) (6 thru 8=3) INTO edu.
VARIABLE LABELS  edu 'Level of education'.
VALUE LABELS edu
'1' 'Secondary or lower'
'2' 'Vocational'
'3' 'Incomplete or complete tertiary'. 
EXECUTE.

*multinomial. 1st. 

NOMREG main_source (BASE=FIRST ORDER=ASCENDING) BY sex d9 d11 edu WITH age j7
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001)
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE FIT PARAMETER SUMMARY LRT CPS STEP MFI.




*trust towards the media
*2024


FREQUENCIES VARIABLES=p7_12
  /STATISTICS=MEDIAN
  /ORDER=ANALYSIS.

*tv stations to trust.
MISSING VALUES in m2 (-9,  -7, -5).
FREQUENCIES VARIABLES=m2
  /ORDER=ANALYSIS.

RECODE m2 (-9=SYSMIS) (-7=SYSMIS) (-3=SYSMIS) (-2=SYSMIS) (-1=SYSMIS) (-4=-4)   (301=1) (305=1) (306=1) (308=1) (302=0) (307=0) (304=0) (303=0) (ELSE=SYSMIS) INTO tru_tv.
VARIABLE LABELS  tru_tv 'Trusts pro-government or pro-oppositional TVs'.
VALUE LABELS tru_tv
'-4' 'Does not trust TV channels at all'
'0' 'Pro-oppositional'
'1' 'Pro-governmental'. 
EXECUTE.
MISSING VALUES in m2 (-9,  -7, -5).

*party support progov, proopp .
RECODE p27 (301=1) (-5 thru -1=-1) (302 thru Highest=0) INTO party.
VARIABLE LABELS  party 'Closest party'.
VALUE LABELS party
'-1' 'None/DK/RA'
'0' 'Oppositional party'
'1' 'Georgian Dream'. 
EXECUTE.

MISSING VALUES in party (-9 thru -1).

WEIGHT BY wt_indwt.
LOGISTIC REGRESSION VARIABLES party
  /METHOD=ENTER tru_tv
  /CONTRAST (tru_tv)=Indicator(1)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).



*chi square test. 
CROSSTABS
  /TABLES=tru_tv BY party
  /FORMAT=AVALUE TABLES
  /STATISTICS=CHISQ CC PHI
  /CELLS=COUNT ROW
  /COUNT ROUND CELL.




*agegroup. 

RECODE age (18 thru 34=1) (35 thru 54=2) (55 thru Highest=3) INTO agegroup.
VARIABLE LABELS  agegroup 'Age group'.
VALUE LABELS agegroup
'1' '18-34'
'2' '35-54'
'3' '55+'. 
EXECUTE.



*multinomial. repeat the model. 2nd with additional variables.
NOMREG main_source (BASE=FIRST ORDER=ASCENDING) BY agegroup sex d9 d11 edu party stratum  WITH j7
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001)
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE FIT PARAMETER SUMMARY LRT CPS STEP MFI.

FREQUENCIES VARIABLES=m4
  /STATISTICS=MEDIAN
  /ORDER=ANALYSIS.


CROSSTABS
  /TABLES=main_source BY agegroup sex d9 d11 edu party
  /FORMAT=AVALUE TABLES
  /STATISTICS=CHISQ CC PHI
  /CELLS=COUNT COLUMN
  /COUNT ROUND CELL.



*Ordinal regression. internet usage.
*reverse coding.

RECODE age (18 thru 34=3) (35 thru 54=2) (55 thru Highest=1) INTO agegroup_rev.
VARIABLE LABELS  agegroup_rev 'Age group - descending'.
VALUE LABELS agegroup_rev
'1' '55+'
'2' '35-54'
'3' '18-34'. 
EXECUTE.



RECODE sex (1=1) (2=0) INTO sex_rev.
VARIABLE LABELS  sex_rev 'Sex - Female - Male'.
VALUE LABELS sex_rev
'1' 'Male'
'0' 'Female'
EXECUTE.

RECODE stratum (3=20) (2=21) (1=22) INTO stratum_mid.
COMPUTE stratum_rev=stratum_mid-20.
VARIABLE LABELS  stratum_rev 'Settlement type - rural - urban - capital'.
VALUE LABELS stratum_rev
'0' 'Rural'
'1' 'Urban'
'2' 'Capital'. 
EXECUTE.


RECODE d2 (Lowest thru -1=SYSMIS)  (1 thru 4=3) (5=2) (6 thru 8=1) INTO edu_rev.
VARIABLE LABELS  edu_rev 'Level of education_Higher to secondary'.
VALUE LABELS edu_rev
'1' 'Incomplete or complete tertiary'
'2' 'Vocational'
'3' 'Secondary or lower'. 
EXECUTE.



FREQUENCIES VARIABLES=m5_1
m5_2
m5_3
m5_4
m5_5
m5_6
m5_7
m5_8
m5_9
m5_10
m5_11
m5_12
m5_13
m5_999
  /ORDER=ANALYSIS.


COUNT soc_network=m5_3 m5_4(1). 
VARIABLE LABELS  soc_network 'FB and/or other soc.network'. 
EXECUTE. 
*81% mentioned at least one: FB or other soc. networks.






* OMS- To compute exp(b) in spss. Run this code once:. 

* OMS. 
DATASET DECLARE  PLUM3. 
OMS 
  /SELECT TABLES 
  /IF COMMANDS=['PLUM'] SUBTYPES=['Parameter Estimates'] 
  /DESTINATION FORMAT=SAV NUMBERED=TableNumber_ 
   OUTFILE='PLUM3' VIEWER=YES.



MISSING VALUES in m4 (-9 thru -1).

PLUM m4 BY sex_rev stratum_rev edu_rev agegroup_rev
  /CRITERIA=CIN(95) DELTA(0) LCONVERGE(0) MXITER(100) MXSTEP(5) PCONVERGE(1.0E-6) SINGULAR(1.0E-8)
  /LINK=LOGIT
  /PRINT=FIT PARAMETER SUMMARY TPARALLEL
  /SAVE=ESTPROB PREDCAT PCPROB ACPROB
  /TEST=stratum_rev 1 0 -1;
             stratum_rev  0 1 -1
  /TEST=edu_rev 1 0 -1;
             edu_rev 0 1 -1
  /TEST=agegroup_rev 1 0 -1;
             agegroup_rev 0 1 -1.


* OMSEND. OMS end.
OMSEND TAG=['$Id1'].

* Save newly generated dataset.
* Create a new Syntax file and activate saved dataset.
* Run these code to calculate exp(B)s
* COMPUTE Exp_B = EXP(Estimate).
* COMPUTE Lower = EXP(LowerBound).
* COMPUTE Upper = EXP(UpperBound).
* FORMATS Exp_B Lower Upper (F8.3).
*EXECUTE.





*open 2013 data to see the frequencies for comparison

GET 
  FILE='C:\Users\crrc_\OneDrive\Documents\PHD thesis\Article\CB2013_Regional_only_responses_07032014.sav'.
WEIGHT BY indwt.
MISSING VALUES in ACTPBLM to RC6_5 (-7, -9, -3).

USE ALL.
COMPUTE filter_$=(COUNTRY=3).
VARIABLE LABELS filter_$ 'COUNTRY=3 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

FREQUENCIES VARIABLES=TRUMEDI
  /STATISTICS=MEDIAN
  /ORDER=ANALYSIS.


* internet usage fre.

FREQUENCIES VARIABLES=FRQINTR
  /STATISTICS=MEDIAN
  /ORDER=ANALYSIS.



MISSING VALUES in FRQINTR (-9 thru -1).

MISSING VALUES in  RESPEDU (-9 thru -1).


PLUM FRQINTR BY STRATUM RESPSEX RESPEDU WITH RESPAGE 
  /CRITERIA=CIN(95) DELTA(0) LCONVERGE(0) MXITER(100) MXSTEP(5) PCONVERGE(1.0E-6) SINGULAR(1.0E-8) 
  /LINK=LOGIT 
  /PRINT=FIT PARAMETER SUMMARY.


FREQUENCIES VARIABLES=INTACEM
INTASCNA
INTASKY
INTAIMSG
INTACFD
INTACBL
INTACIN
INTACSH
INTACNW
INTACEN
INTACGM
INTACDW
INTACOT
  /ORDER=ANALYSIS.



COUNT skyp_mess=INTASKY INTAIMSG(1). 
VARIABLE LABELS  skyp_mess 'Skype and other messangers'. 
EXECUTE. 

*36% mentioned at least one: Skype or other messanger app.







