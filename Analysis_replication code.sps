* Encoding: UTF-8.
* Encoding: .
* Encoding: .
* Encoding: .
* Encoding: .
*____________________________________________________2009 data.
GET 
  STATA FILE='C:\Users\crrc_\OneDrive\Documents\PHD thesis\Article\CB2009_Regional_only_responses_18012011.dta'. 
DATASET NAME DataSet1 WINDOW=FRONT.

USE ALL.
COMPUTE filter_$=(COUNTRY = 3).
VARIABLE LABELS filter_$ 'COUNTRY = 3 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.


WEIGHT BY INDWT.

MISSING VALUES in INTLANG to SEWGACC (-7, -9, -3).
MISSING VALUES in HEATCCS to LISTENO(-7, -9, -3).
MISSING VALUES in RESPINT to INTID (-7, -9, -3).
*first and second source of information

FREQUENCIES VARIABLES=INFSOU1 INFSOU2 
  /BARCHART PERCENT 
  /ORDER=ANALYSIS.



*__________________________________________________________2024 data. 

GET 
  FILE='C:\Users\crrc_\OneDrive\Documents\PHD thesis\Article\CB_2024_Geo_04.06.2024.sav'. 
 
WEIGHT OFF.

*compute normalized weights to doublecheck effects. 
COMPUTE wt_norm=(indwt*1509) / 2887608.
VARIABLE LABELS  wt_norm 'Normalized weights'.
EXECUTE.


*recode wealth index.
MISSING VALUES in c2_1 to c2_15 (-9 thru -1).
COMPUTE wealth_index24=sum(c2_1,
c2_2,
c2_3,
c2_4,
c2_5,
c2_6,
c2_7,
c2_8,
c2_9,
c2_10,
c2_11,
c2_12,
c2_13,
c2_14,
c2_15).
VARIABLE LABELS  wealth_index24 'Wealth index'.
EXECUTE.

*split by median.  wealth. 
RANK VARIABLES=wealth_index24 (A) 
  /NTILES(2) 
  /PRINT=YES 
  /TIES=MEAN.

VALUE LABELS Nwealth_
"1" "Wealth below median"
"2" "Wealth above median".
EXECUTE.




*WEIGHT BY indwt.
WEIGHT BY indwt.

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
'2' 'Internet and social media'.
EXECUTE.







*multinomial regression model:.

MISSING VALUES in d9 d11 d2 age j7 (-9 thru -1).



*agegroup. 

RECODE age (18 thru 34=1) (35 thru 54=2) (55 thru Highest=3) INTO agegroup.
VARIABLE LABELS  agegroup 'Age group'.
VALUE LABELS agegroup
'1' '18-34'
'2' '35-54'
'3' '55+'. 
EXECUTE.

RECODE d2 (Lowest thru -1=SYSMIS)  (1 thru 4=1) (5=2) (6 thru 8=3) INTO edu.
VARIABLE LABELS  edu 'Level of education'.
VALUE LABELS edu
'1' 'Secondary or lower'
'2' 'Vocational'
'3' 'Incomplete or complete tertiary'. 
EXECUTE.


*tv stations to trust.
FREQUENCIES VARIABLES=m2
  /ORDER=ANALYSIS.

RECODE m2 (-9=SYSMIS) (-7=SYSMIS) (-3=SYSMIS) (-2=-1) (-1=-1)  (-5=-5) (-4=-4)   (301=1) (305=1) (308=1) (ELSE=0) INTO tru_tv.
VARIABLE LABELS  tru_tv 'Trusts pro-government or pro-oppositional TVs'.

VALUE LABELS tru_tv
'-5'  'Dont watch TV'
'-4' 'Dont not trust TV channels at all'
'-1' 'Dont know / Refuse to answer'
'1' 'Pro-governmental' 
'0' 'Other TVs'.
EXECUTE.


*party support progov, proopp .
RECODE p27 (-5 =2) (-1 =2) (-2=3) (301=0) (302 thru Highest=1) INTO party.
VARIABLE LABELS  party 'Closest party'.
VALUE LABELS party
'0' 'Georgian Dream'
'1' 'Other parties'
'2' 'None / Dont know' 
'3' 'Refuse to answer'. 
EXECUTE.




*multinomial. 1st. 
NOMREG main_source (BASE=FIRST ORDER=ASCENDING) BY sex edu stratum party Nwealth_ agegroup  
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
  /TABLES=main_source BY agegroup sex edu party stratum Nwealth_
  /FORMAT=AVALUE TABLES
  /CELLS= COLUMN
  /COUNT ROUND CELL.







*trust towards the media 2024


FREQUENCIES VARIABLES=p7_12
  /STATISTICS=MEDIAN
  /ORDER=ANALYSIS.



MISSING VALUES in party (-9 thru -1).

WEIGHT BY indwt.
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


MISSING VALUES in m4 (-9 thru -1).
CROSSTABS 
  /TABLES=agegroup BY m6_1 m6_2 m6_3 m6_4 m6_5 m6_6 m6_7 m6_8 m6_9 m6_999 
  /FORMAT=AVALUE TABLES 
  /CELLS=ROW 
  /COUNT ROUND CELL.


*Only FB users. 
 
IF  (m6_1 = 1 AND m6_2 <> 1 AND m6_3 <> 1 AND m6_4 <> 1 AND m6_5 <> 1 AND m6_6 <> 1 AND m6_7 <> 1
    AND m6_8 <> 1 AND m6_9 <> 1 AND m6_999 <> 1.) fb_only=m6_1.
EXECUTE.
FREQUENCIES VARIABLES=m6_1 fb_only
  /ORDER=ANALYSIS.

IF  (m6_2 = 1 AND m6_1 <> 1 AND m6_3 <> 1 AND m6_4 <> 1 AND m6_5 <> 1 AND m6_6 <> 1 AND m6_7 <> 1
    AND m6_8 <> 1 AND m6_9 <> 1 AND m6_999 <> 1.) insta_only=m6_2.
EXECUTE.

IF  (m6_4 = 1 AND m6_1 <> 1 AND m6_3 <> 1 AND m6_2 <> 1 AND m6_5 <> 1 AND m6_6 <> 1 AND m6_7 <> 1
    AND m6_8 <> 1 AND m6_9 <> 1 AND m6_999 <> 1.) youtube_only=m6_4.
EXECUTE.  

IF  (m6_5 = 1 AND m6_1 <> 1 AND m6_3 <> 1 AND m6_4 <> 1 AND m6_2 <> 1 AND m6_6 <> 1 AND m6_7 <> 1
    AND m6_8 <> 1 AND m6_9 <> 1 AND m6_999 <> 1.) tiktok_only=m6_5.
EXECUTE. 
  
FREQUENCIES VARIABLES= fb_only insta_only youtube_only tiktok_only
  /ORDER=ANALYSIS.










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







