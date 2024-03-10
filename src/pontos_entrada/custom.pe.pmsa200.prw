//-------------------------------------------------------------------
/*/{Protheus.doc} PMA210FR
DESC: Ponto de entrada na finalização na alteração da fase - Função PMS200Fase
	If lOk
		If ExistBlock("PMA200GRV")
			lOk := ExecBlock("PMA200GRV",.F.,.F.)
		EndIf
	EndIf

@sample		PMA200GRV()
@return 	NIL
@author		Mobile/Washington
@since		31/01/2024
@version 	P12
/*/
//--------------------------------------------------------------------
USER FUNCTION PMA200GRV
	Local aArea      := GetArea()
	Local nValorAF9  := 0
	Local nValorAF1  := 0

	DbSelectArea("AF1")		// AF1_FILIAL + AF1_ORCAME
	DbSetOrder(1)
	If ! DbSeek(AF8->(AF8_FILIAL + AF8_ORCAME))
		cMensagem := "Orçamento [" + AllTrim(AF8->AF8_ORCAME) + "] não localizado informado no projeto não localizado." 
		Alert(cMensagem)
		
		RETURN .F.
	EndIf

	nValorAF1 := AF1->AF1_XVALOR
	DbSelectArea("AF9")
	DbSetOrder(1)
	DbSeek(xFilial() + AF8->AF8_PROJET)

	WHILE AF9->AF9_FILIAL = xFilial("AF9") .And. AF9->AF9_PROJET = AF8->AF8_PROJET .And.;
		! AF9->(Eof())
		nValorAF9 += AF9->AF9_CUSTO
		AF9->(DbSkip())
	EndDo

	If nValorAF1 < nValorAF9
		M->AF8_FASE := "05"

		U_UN94GAPV(AF8->AF8_PROJET, nValorAF9)
		ALERT("Projeto enviado para aprovação !")
	Endif  
	RestArea(aArea)

Return .T.
