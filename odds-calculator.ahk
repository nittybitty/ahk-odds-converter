#NoEnv
#SingleInstance Force
SetBatchLines, -1

; Decimal Odds Section
Gui, Add, Text, x10 y10 w100, Decimal Odds:
Gui, Add, Edit, x120 y8 w150 vDecimalOdds gConvertDecimal
Gui, Add, Text, x10 y40 w280 h25 vResultDecimal

; Separator
Gui, Add, Text, x10 y70 w280 h1 0x10

; Prediction Market Section
Gui, Add, Text, x10 y80 w110, Prediction Market `%:
Gui, Add, Edit, x120 y78 w150 vPredictionPct gConvertPrediction
Gui, Add, Text, x10 y110 w280 h25 vResultPrediction

; Separator
Gui, Add, Text, x10 y140 w280 h1 0x10

; American Odds Section
Gui, Add, Text, x10 y150 w110, American Odds:
Gui, Add, Edit, x120 y148 w150 vAmericanOdds gConvertAmerican
Gui, Add, Text, x10 y180 w280 h40 vResultAmerican

Gui, Show, w300 h230, Odds Calculator
Return

ConvertDecimal:
    Gui, Submit, NoHide
    if (DecimalOdds = "" || DecimalOdds <= 1.0) {
        GuiControl,, ResultDecimal,
        return
    }
    
    ; Calculate implied probability
    ImpliedProb := Round((1 / DecimalOdds) * 100, 2)
    
    if (DecimalOdds >= 2.0) {
        American := Round((DecimalOdds - 1) * 100)
        GuiControl,, ResultDecimal, American: +%American% | Implied: %ImpliedProb%`%
    } else {
        American := Round(-100 / (DecimalOdds - 1))
        GuiControl,, ResultDecimal, American: %American% | Implied: %ImpliedProb%`%
    }
Return

ConvertPrediction:
    Gui, Submit, NoHide
    if (PredictionPct = "" || PredictionPct <= 0 || PredictionPct >= 100) {
        GuiControl,, ResultPrediction,
        return
    }
    
    ; Convert percentage to probability (0-1)
    Probability := PredictionPct / 100
    
    ; Convert to decimal odds
    DecimalFromProb := Round(1 / Probability, 2)
    
    ; Convert to American odds
    if (DecimalFromProb >= 2.0) {
        American := Round((DecimalFromProb - 1) * 100)
        GuiControl,, ResultPrediction, % "American: +" . American . " | Decimal: " . DecimalFromProb
    } else {
        American := Round(-100 / (DecimalFromProb - 1))
        GuiControl,, ResultPrediction, American: %American% | Decimal: %DecimalFromProb%
    }
Return

ConvertAmerican:
    Gui, Submit, NoHide
    if (AmericanOdds = "" || AmericanOdds = 0) {
        GuiControl,, ResultAmerican,
        return
    }
    
    ; Convert American to decimal and probability
    if (AmericanOdds > 0) {
        ; Positive odds (underdog)
        DecimalCalc := (AmericanOdds / 100) + 1
        ImpliedProb := Round((100 / (AmericanOdds + 100)) * 100, 2)
    } else {
        ; Negative odds (favorite)
        AbsAmerican := Abs(AmericanOdds)
        DecimalCalc := (100 / AbsAmerican) + 1
        ImpliedProb := Round((AbsAmerican / (AbsAmerican + 100)) * 100, 2)
    }
    
    DecimalCalc := Round(DecimalCalc, 2)
    GuiControl,, ResultAmerican, Decimal: %DecimalCalc% | Implied Prob: %ImpliedProb%`%
Return

GuiClose:
ExitApp
