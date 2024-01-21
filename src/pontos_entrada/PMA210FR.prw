#Include 'totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PMA210FR
DESC: Ponto de entrada na finalização da revisão
ExecBlock("PMA210FR", .F., .F., {lGravaOK})

@sample		pma210FR()
@return 	NIL
@author		Mobile/Washington
@since		21/01/2024
@version 	P12
/*/
//--------------------------------------------------------------------

User Function pma210FR()

IF PARAMIXB[1]
	RecLock("AF8",.F.)
	AF8->AF8_FASE := "05"
	AF8->(MsUnLock())
EndIf

Return
