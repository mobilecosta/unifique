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
    Local lRetorno := .T.
    Local _cNatureza    := "51102110012"
    Local _cItemCtb     := "0"
    Local _cCusto       := "606001"
    Local _cClasse      := "010048"

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

	// Valida centro de custos
	DbSelectArea("SED")
	DbSetOrder(1)

	If !DbSeek(xFilial("SED") + _cNatureza )
		
		cMensagem := "Natureza não localizada. Favor verifique e tente novamente." 
		
		Alert(cMensagem)
		
		RETURN .F.
	else
	   _cContaCt1 := SED->ED_CONTA 
	Endif  

	// Busca conta orçamentária através da conta contábil
	cTab := GetNextAlias()
		
	BeginSQL Alias cTab

	SELECT CT1_CONTA,
			  CT1_XCO  ,
			  AK5_XOPER
	FROM %table:CT1% CT1
	INNER JOIN %table:AK5% AK5
	   ON    CT1_FILIAL  =  %xFilial:CT1%
	   AND   AK5_FILIAL  =  %xFilial:AK5% 
	   AND   CT1.CT1_XCO = AK5.AK5_CODIGO
	WHERE CT1.CT1_CONTA = %Exp:_cContaCt1%
		AND  CT1.%notdel%
		AND  AK5.%notdel% 
	EndSQL

	If (cTab)->(!EOF()) 			

		_cOperacao := (cTab)->AK5_XOPER
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

		aRet := fSaldosDt(_cConfig,cChave,dDataRef)
		
		//Soma valores a Credito
		For x := 1 to len(aRet)
			nValorCred += aRet[x,1,1]
			nValorDeb  += aRet[x,2,1]
		Next  
		
		nSaldo := ( nValorCred - nValorDeb) 
		
		ALERT(nSaldo)
	EndIf

Return

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
