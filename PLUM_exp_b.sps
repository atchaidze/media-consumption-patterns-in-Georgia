* Encoding: UTF-8.
COMPUTE Exp_B = EXP(Estimate).
COMPUTE Lower = EXP(LowerBound).
COMPUTE Upper = EXP(UpperBound).
FORMATS Exp_B Lower Upper (F8.3).
EXECUTE.
