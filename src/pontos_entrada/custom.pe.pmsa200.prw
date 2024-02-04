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
    Local lRetorno 	 := .T.
	Local nX  	     := 0
    Local _cItemCtb  := ""
    Local _cCusto    := ""
    Local _cClasse   := ""
	Local _cContaAK5 := SuperGetMv("ES_XFLUIGCO", , '60000008')
	Local _cOperacao := ""
	Local _cTpSaldo  := "OR"
	Local cChave     := ""
	Local _cConfig   := "BL"
	Local _cNivel    := "01" 
	Local nValorCred := 0
	Local nValorDeb  := 0
	Local nSaldo     := 0

	DbSelectArea("AF1")		// AF1_FILIAL + AF1_ORCAME
	DbSetOrder(1)
	If ! DbSeek(AF8->(AF8_FILIAL + AF8_ORCAME))
		cMensagem := "Orçamento [" + AllTrim(AF8->AF8_ORCAME) + "] não localizado informado no projeto não localizado." 
		Alert(cMensagem)
		
		RETURN .F.
	EndIf

    _cItemCtb := AF1->AF1_XITCTB
    _cCusto   := AF1->AF1_XCC
    _cClasse  := AF1->AF1_XCLVLR

	DbSelectArea("CTD")
	DbSetOrder(1)

	// Valida o Item Contábil
	If !DbSeek(xFilial("CTD") + _cItemCtb )
		cMensagem := "Item contábil não localizado. Favor verifique e tente novamente." 
		Alert(cMensagem)
		
		RETURN .F.
	Endif  

	// Valida o Item Classe de valor

	DbSelectArea("CTH")
	DbSetOrder(1)

	If !DbSeek(xFilial("CTH") + _cClasse )
		cMensagem := "Classe contábil não localizado. Favor verifique e tente novamente." 
		Alert(cMensagem)
		
		RETURN .F.
	Endif  

	// Valida centro de custos
	DbSelectArea("CTT")
	DbSetOrder(1)

	If !DbSeek(xFilial("CTT") + _cCusto )
		cMensagem := "Classe contábil não localizado. Favor verifique e tente novamente." 
		Alert(cMensagem)
		
		RETURN .F.
	Endif  

	// Busca conta orçamentária
	AK5->(DbSetOrder(1))	// AK5_FILIAL + AK5_CODIGO
	If AK5->(DbSeek(xFilial() + _cContaAK5))
		_cOperacao := AK5->AK5_XOPER
		_cTpSaldo  := "OR"
		
		cChave := " "

		DbSelectArea("AKW")
		DbSetOrder(1)

		If DbSeek(xFilial("AKW") + _cConfig + _cNivel  )

			While !eof() .And. AKW->AKW_FILIAL = xFilial("AKW") .AND. AKW->AKW_COD == _cConfig 

					If AKW->AKW_ALIAS == "CTH"
						cChave := Padr(_cClasse   ,AKW->AKW_TAMANH)
					ElseIf AKW->AKW_ALIAS == "CTT"
						cChave += Padr(_cCusto    ,AKW->AKW_TAMANH)
					ElseIf AKW->AKW_ALIAS == "CTD"
						cChave += Padr(_cItemCtb  ,AKW->AKW_TAMANH)
					ElseIf AKW->AKW_ALIAS == "AKF"
						cChave += Padr(_cOperacao ,AKW->AKW_TAMANH)
					ElseIf AKW->AKW_ALIAS == "AL2"
						cChave += Padr(_cTpSaldo  ,AKW->AKW_TAMANH)
					Endif
					
				AKW->(DbSkip())
		   
		   Enddo

		Endif

		aRet := fSaldosDt(_cConfig,cChave,dDataBase)
		
		//Soma valores a Credito
		For nX := 1 to len(aRet)
			nValorCred += aRet[nX,1,1]
			nValorDeb  += aRet[nX,2,1]
		Next  
		
		nSaldo := ( nValorCred - nValorDeb) 
		If nSaldo == 0
			M->AF8_FASE := "05"

			ALERT("Saldo: " + Trans(nSaldo, "@E 9,999,999,999,999.99"))
		Else
			ALERT("Mudança de fase OK !")
		EndIF
	Else
		ALERT("Operação não localizada !")
	EndIf

Return lRetorno

*************************************************
static function fSaldosDt(cCubo,cChave,dDataRef)
*************************************************

Local aRetSld := {}

DbSelectArea("AKT")
DbSetOrder(1)
    
If DbSeek(xFilial("AKT") + cCubo + cChave )
    aAdd(aRetSld ,PcoRetSld(AKT->AKT_CONFIG,AKT->AKT_CHAVE,dDataRef))
Endif   
// tem que tratar o tipos TE  e CT  e somar ao saldo  OR
RETURN aRetSld
