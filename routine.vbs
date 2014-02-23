'Variables available on this screen can be declared and initialized here.
Dim MsgBox_Open
Dim proceed
Dim message
Dim cRepeat
Dim screenOpen


'Procedures available on this screen can be implemented here


'This procedure is executed just once when this screen is open.
Sub Screen_OnOpen()

        $httpAC1_ViewReport = "http://localhost/mta-mexico/AC/GenInfo/Mexico/" & $Str( $TND.sqlAC1_ixTest )
        
End Sub

'This procedure is executed continuously while this screen is open.
Sub Screen_WhileOpen()


'****************************************
'Stop Button Visible
'Final Else displays stop button
If( $TND.fAC1_TestREIInProgress = 0 ) Then
        $btnAC1_StopVisible = 0
ElseIf( $TND.fAC1_TestREIStop = 1 ) Then
        $btnAC1_StopVisible = 0
ElseIf( $TND.fAC1_TestREIStart = 0 ) Then
        $btnAC1_StopVisible = 0
Else
        $btnAC1_StopVisible = 1
End If

'****************************************
'Start Button Visible
'Final Else displays start button
If( $btnAC1_StopVisible = 1 ) Then
        $btnAC1_StartVisible = 0
ElseIf( $TND.fAC1_TestREIStop = 1 ) Then
        $btnAC1_StartVisible = 0
        'Need at least one subtest selected
ElseIf( $TND.fAC1_Test01RT1Selected = 0 And $TND.fAC1_Test02PVTSelected = 0 And $TND.fAC1_Test03SCTSelected = 0 And $TND.fAC1_Test04RFTSelected = 0 And $TND.fAC1_Test05RSTSelected = 0 And $TND.fAC1_Test06HRTSelected = 0 And $TND.fAC1_Test07RT2Selected = 0 And $TND.fAC1_Test09NLSSelected = 0) Then
        $btnAC1_StartVisible = 0
ElseIf( $TND.opfAC1_BlowerRun  = 1 ) Then
        $btnAC1_StartVisible = 0
ElseIf( $TND.dblAC1_RPMFinal > 10 ) Then
        $btnAC1_StartVisible = 0
ElseIf( $TND.eAC1_ErrorsPresent = 1 Or $TND.wAC1_WarningsPresent = 1 ) Then
        $btnAC1_StartVisible = 0
ElseIf( $TND.fAC1_HMIStart = 1 ) Then
        $btnAC1_StartVisible = 0
Else
        $btnAC1_StartVisible = 1
End If

'****************************************
'fStatusPassed
If( $TND.fAC1_TestREIFinished = 1 And $TND.fAC1_TestREIStop = 0 ) Then
        $fAC1_StatusPassed = 1
Else
        $fAC1_StatusPassed = 0
End If

'****************************************
'fStatusFailed
If( $TND.fAC1_TestREIStop = 1 ) Then
        $fAC1_StatusFailed = 1
Else
        $fAC1_StatusFailed = 0
End If

If $TND.fAC1_TestREIStop = 0 Then

        '****************************************
        'Short Circuit Popup
        screenOpen = $IsScreenOpen("AC1_SCT_POPUP")
        If  screenOpen = 0 Then
                If( $TND.wAC1_ShortCircuitAmps_Delta = 1 Or $TND.wAC1_ShortCircuitAmps_Limits = 1 ) Then
                        $Open("AC1_SCT_POPUP")
                End If
        End If
        
        '****************************************
        'Rated Flux / No Load Saturation Test Popup
        screenOpen = $IsScreenOpen("AC1_RFT_POPUP")
        If  screenOpen = 0 Then
                If( $TND.wAC1_RatedFlux_Delta = 1 Or $TND.wAC1_RatedFlux_Limits = 1 ) Then
                        $Open("AC1_RFT_POPUP")
                End If
        End If
        
        '****************************************
        'Repeat Test Popup
        cRepeat = currentRepeatCount( $TND.sqlAC1_ixSubTestType )
        $cRepeatScr = cRepeat
        If( MsgBox_Open = 0 And cRepeat < 0 And $TND.fAC1_TestREIContinue = 0)  And $TND.fAC1_Test02PVTInProgress = 0 And $TND.fAC1_Test03SCTInProgress = 0 And $TND.fAC1_Test04RFTInProgress = 0 And $TND.fAC1_Test09NLSInProgress = 0 Then
                MsgBox_Open = 1
                message = $TND.asAC1_SubTestType & " is outside the ETI criteria!" & vbCrLf
                message = message & "This test has been performed " & $Str(Abs(cRepeat)) & " time(s)" & vbCrLf
                message = message & "Do you want to repeat the test again?"
        
        
                proceed = MsgBox( message, vbQuestion + vbYesNo + vbSystemModal, "Repeat test?" )
                If proceed = vbYes Then
                        turnOnRepeat( $TND.sqlAC1_ixSubTestType )
                        MsgBox_Open = 0
                Else
                        turnOffRepeat( $TND.sqlAC1_ixSubTestType )
                        MsgBox_Open = 0
                End If
        End If
End If


        '********************
        'Under Temperature Warning
        If $IsScreenOpen("AC1_UNDER_TEMP") = 1 And $TND.wAC1_Temperature = 0 Then
                $Close("AC1_UNDER_TEMP")
        ElseIf $IsScreenOpen("AC1_UNDER_TEMP") = 0 And $TND.wAC1_Temperature = 1 Then
                $Open("AC1_UNDER_TEMP")
        End If

End Sub

'This procedure is executed just once when this screen is closed.
Sub Screen_OnClose()

End Sub