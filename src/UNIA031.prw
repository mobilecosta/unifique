#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "rwmake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} UNIA031
DESC:função de usuário que busca todos os itens do ativos não classi-
ficados e faz a claasificação manual dos mesmo.
Obs.: Não existe EXECAUTO para rotina ATFA240.PRW, por este motivo
está sendo tratado dessa forma!.

@sample		UNIA031()
@return 	NIL
@author		João E. Lopes
@since		02/07/2019
@version 	P12
@example    UNIA031()
/*/
//--------------------------------------------------------------------

User Function UNIA031()

	//Private cPerg		:= "UNIA031"
	Local aPergs := {}
	Private nomeprog	:= "UNIA031"

	//ValidPerg()
	//Pergunte(cPerg,.F.)


	aAdd(aPergs, {1, "N. Fiscal de     ?", Space(TamSX3('F1_DOC')[01]),  "",             ".T.",        "SD1", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "N. Fiscal Até    ?", Space(TamSX3('F1_DOC')[01]),  "",             ".T.",        "SD1", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Cod. do Bem de   ?", Space(TamSX3('N1_CBASE')[01]),  "",             ".T.",        "SN1", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Cod. do Bem até  ?", Space(TamSX3('N1_CBASE')[01]),  "",             ".T.",        "SN1", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Item do Bem de   ?", Space(TamSX3('N1_ITEM')[01]),  "",             ".T.",        "   ", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Item do Bem Até  ?", Space(TamSX3('N1_ITEM')[01]),  "",             ".T.",        "   ", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Da Filial        ?", Space(TamSX3('N1_FILIAL')[01]),  "",             ".T.",        "SM0", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Até Filial       ?", Space(TamSX3('N1_FILIAL')[01]),  "",             ".T.",        "SM0", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "CFs Orig. Frete  ?", Space(50),  "",             ".T.",        "   ", ".T.", 80,  .T.})


	@ 200,30 TO 400,530 DIALOG oDlg TITLE "Classificação de Ativos Imobilizados automática         "
	@ 10,010 SAY " Esta rotina tem por obejtivo automatizar o processso de classificação do Bem de "
	@ 20,010 SAY " Ativo Imobilizado.    		                                                   "
	@ 30,010 SAY "                                                                                 "
	@ 40,010 SAY " Preencher CFs Orig. Frete separados por '/' Exemplo: 1551/2551/                 "
	@ 50,010 SAY " Uso Exclusivo - Unifique.                                                       "

	//@ 080,050 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)
	@ 080,050 BMPBUTTON TYPE 05 ACTION ParamBox(aPergs, "Informe os parâmetros")
	@ 080,100 BMPBUTTON TYPE 01 ACTION Processa( {|| Start() } )
	@ 080,150 BMPBUTTON TYPE 02 ACTION Close(oDlg)

	ACTIVATE DIALOG oDlg CENTERED

Return
//--------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
DESC: Função para criar as perguntas utilizadas na rotina UNIA031.prw
@sample		ValidPerg()
@return 	NIL
@author		João E. Lopes
@since		02/07/2019
@version 	P12
@example    UNIA031()
/*/
//--------------------------------------------------------------------
Static Function ValidPerg()

	Local i	:= 0
	Local j	:= 0

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}

	AADD(aRegs,{cPerg,"01","N. Fiscal de     ?","","","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SD1","","","",""})
	AADD(aRegs,{cPerg,"02","N. Fiscal Até    ?","","","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SD1","","","",""})
	AADD(aRegs,{cPerg,"03","Cod. do Bem de   ?","","","mv_ch3","C",10,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SN1","","","",""})
	AADD(aRegs,{cPerg,"04","Cod. do Bem até  ?","","","mv_ch4","C",10,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SN1","","","",""})
	AADD(aRegs,{cPerg,"05","Item do Bem de   ?","","","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","   ","","","",""})
	AADD(aRegs,{cPerg,"06","Item do Bem Até  ?","","","mv_ch6","C",04,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","   ","","","",""})
	AADD(aRegs,{cPerg,"07","Da Filial        ?","","","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","",""})
	AADD(aRegs,{cPerg,"08","Até Filial       ?","","","mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","",""})
	AADD(aRegs,{cPerg,"09","CFs Orig. Frete  ?","","","mv_ch9","C",50,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","   ","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} Start
DESC: Executa a classificação do bem de Ativo Imobilizado
@sample		Start()
@return 	NIL
@author		João E. Lopes
@since		02/07/2019
@version 	P12
@example    Start()
/*/
//--------------------------------------------------------------------

Static Function Start()

	// Areas utilizadas na rotinas
	Local _aBkp    := GetArea()
	Local _aSD1    := SD1->(GetArea())
	Local _aSN1    := SD1->(GetArea())
	Local _aSN3    := SD1->(GetArea())
	Local _aSNG    := SD1->(GetArea())
	Local _aZDM    := ZDM->(GetArea())
	Local _aFNG    := FNG->(GetArea())

	// Declaração das variáveis
	Local _cFilD    := ""
	Local _cFilA    := ""
	Local _cCBaseD  := ""
	Local _cCBaseA  := ""
	Local _cNFD     := ""
	Local _cNFA     := ""

	Local _dTClass  := "" // data de classificação
	Local _cContaC  := "" // conta contábil
	Local _cContaCa  := "" // conta contábil
	Local _cGrupBem := "" // grupo de bem no cadastro do produto
	Local _cUtiPatr := "" // utiliza patrimonio
	Local _nVSCiap  := 0  // Valor com CIAP
	Local _nVCCiap  := 0  // Valor sem CIAP
	Local _nValOrig := 0  // Valor Original
	Local _nTx1Depr := 0  // Taxa depreciação moeda 1
	Local _nTx2Depr := 0
	Local _nTx3Depr := 0
	Local _nTx4Depr := 0
	Local _nTx5Depr := 0
	Local _cTipo    := ""
	Local _cTx1DEpr1:= ""
	Local _cGrupo1  := ""
	Local _cFilSN1  := ""  // filial SN1
	Local _cHistor  := ""  // Histórico
	Local lRetOk    := .T.
	Local lTemCiap  := .F. // se tem Ciap
	Local lFrete    := .F. // Notas de Frete

	Local _cNFFrete  := ""
	Local _cDescric  := ""
	Local _cCBaseOri := ""
	Local _cItemNew  := ""
	Local _cCFsOriF  := FormatIn(MV_PAR09,'/')
	Local _nQtdeOri  := 0
	Local _cNFOrig   := ""
	Local _cObserv   := ""
	Local _cPlacaAI  := ""
	Local _cTES      := ""
	Local _cDesmATV  := ""
	Local _cFiltI10  := SuperGetMV("MV_UNITP10")

	Local cUserName  := LogUserName()

	_cNFD     := alltrim(MV_PAR01)
	_cNFA     := alltrim(MV_PAR02)
	_cCBaseD  := alltrim(MV_PAR03)
	_cCBaseA  := alltrim(MV_PAR04)
	_cItemD   := alltrim(MV_PAR05)
	_cItemA   := alltrim(MV_PAR06)
	_cFilD    := alltrim(MV_PAR07)
	_cFilA    := alltrim(MV_PAR08)
	_dTClass  := dDataBase

	If Select("TATIV") <> 0
		dbSelectArea("TATIV")
		dbCloseArea()
	Endif

	BEGINSQL ALIAS "TATIV"
		SELECT N1_FILIAL, N1_DESCRIC, N1_PRODUTO, N1_PATRIM, N1_CBASE, N1_ITEM, N1_AQUISIC, N1_QUANTD, N1_BAIXA, 
		N1_NFISCAL, N1_NSERIE, N1_FORNEC, N1_LOJA, N1_STATUS, N1_CODCIAP, N1_GRUPO, N1_UTIPATR, N1_VLAQUIS,
		N1_CODCIAP, N1_PRODUTO, N1_QUANTD, N1_NFITEM
		FROM %table:SN1% SN1
		WHERE N1_FILIAL BETWEEN %exp:_cFilD% AND %exp:_cFilA%   
		AND SN1.%notdel% 
		AND N1_STATUS = 0
		AND N1_NFISCAL BETWEEN %exp:_cNFD% AND %exp:_cNFA%   
		AND N1_CBASE   BETWEEN %exp:_cCBaseD% AND %exp:_cCBaseA%   
		AND N1_ITEM    BETWEEN %exp:_cItemD% AND %exp:_cItemA%   
		ORDER BY N1_FILIAL, N1_NFISCAL 
	ENDSQL

	dbSelectArea("TATIV")
	TATIV->(DBGoTop())

	If Eof()
		ApMsgStop("Não existem itens do Ativo a serem Classificados!", "UNIA031A")
		lRetOk	:= .F.
	EndIf

	While !TATIV->(EOF())

		dbSelectArea("SN1")

		dbSetOrder( 1 ) 	//N1_FILIAL+N1_CBASE+N1_ITEM
		If dbSeek(TATIV->N1_FILIAL+TATIV->N1_CBASE+TATIV->N1_ITEM)
			_cFilSN1  := TATIV->N1_FILIAL
			_nQtdeOri := TATIV->N1_QUANTD // Qtde Classificação

			//Busca a conta contábil do produto.
			_cContaC  := Posicione("SD1",1,_cFilSN1+TATIV->N1_NFISCAL + TATIV->N1_NSERIE + TATIV->N1_FORNEC + TATIV->N1_LOJA + TATIV->N1_PRODUTO + TATIV->N1_NFITEM,"D1_CONTA")
			_cGrupBem := Posicione("SB1",1,xFilial("SB1")+Posicione("SD1",1,_cFilSN1+TATIV->N1_NFISCAL + TATIV->N1_NSERIE + TATIV->N1_FORNEC + TATIV->N1_LOJA + TATIV->N1_PRODUTO + TATIV->N1_NFITEM,"D1_COD"),"B1_ZGRUBEM")
			_cTES     := Posicione("SD1",1,_cFilSN1+TATIV->N1_NFISCAL + TATIV->N1_NSERIE + TATIV->N1_FORNEC + TATIV->N1_LOJA + TATIV->N1_PRODUTO + TATIV->N1_NFITEM,"D1_TES")
			_cTpCompl := Posicione("SF1",1,_cFilSN1+TATIV->N1_NFISCAL + TATIV->N1_NSERIE + TATIV->N1_FORNEC + TATIV->N1_LOJA ,"F1_TPCOMPL")
			_cCcusto  := Posicione("SD1",1,_cFilSN1+TATIV->N1_NFISCAL + TATIV->N1_NSERIE + TATIV->N1_FORNEC + TATIV->N1_LOJA + TATIV->N1_PRODUTO + TATIV->N1_NFITEM,"D1_CC")
			_cItemCta  := Posicione("SD1",1,_cFilSN1+TATIV->N1_NFISCAL + TATIV->N1_NSERIE + TATIV->N1_FORNEC + TATIV->N1_LOJA + TATIV->N1_PRODUTO + TATIV->N1_NFITEM,"D1_ITEMCTA")

			// Verifica se desmembra o Ativo.
			_cDesmATV := Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_BENSATF")

			If Alltrim(_cDesmATV) ="1" .AND. TATIV->N1_QUANTD = 1
				_nVSCiap  := ROUND(Posicione("SD1",1,_cFilSN1+TATIV->N1_NFISCAL + TATIV->N1_NSERIE + TATIV->N1_FORNEC + TATIV->N1_LOJA + TATIV->N1_PRODUTO + TATIV->N1_NFITEM,"((D1_TOTAL+D1_ICMSCOM+D1_ICMSRET+D1_VALIPI+D1_VALFRE-D1_VALDESC)/TATIV->N1_QUANTD)"),2)
				_nVCCiap  := ROUND(Posicione("SD1",1,_cFilSN1+TATIV->N1_NFISCAL + TATIV->N1_NSERIE + TATIV->N1_FORNEC + TATIV->N1_LOJA + TATIV->N1_PRODUTO + TATIV->N1_NFITEM,"((D1_TOTAL-D1_VALICM+D1_VALIPI+D1_VALFRE-D1_VALDESC)/TATIV->N1_QUANTD)"),2)
			Else
				_nVSCiap  := Posicione("SD1",1,_cFilSN1+TATIV->N1_NFISCAL + TATIV->N1_NSERIE + TATIV->N1_FORNEC + TATIV->N1_LOJA + TATIV->N1_PRODUTO + TATIV->N1_NFITEM,"D1_TOTAL+D1_ICMSCOM+D1_ICMSRET+D1_VALIPI+D1_VALFRE-D1_VALDESC")
				_nVCCiap  := Posicione("SD1",1,_cFilSN1+TATIV->N1_NFISCAL + TATIV->N1_NSERIE + TATIV->N1_FORNEC + TATIV->N1_LOJA + TATIV->N1_PRODUTO + TATIV->N1_NFITEM,"D1_TOTAL-D1_VALICM+D1_VALIPI+D1_VALFRE-D1_VALDESC")
			Endif

			//alert("tipo de Compl: " + _cTpCompl)

			// Se codigo de CIAP estiver preenchido na SN1 - Nota com CIAP
			If !Empty(TATIV->N1_CODCIAP)
				lTemCiap := .T.
			EndIf

			// Tratamento notas de Frete - classificação CTEs --------------------------------------------------------------------------------------------------------------------------------------------------
			If _cTpCompl == "3"
				lFrete := .T.

				If Select("TCTE") <> 0
					dbSelectArea("TCTE")
					dbCloseArea()
				Endif

				cQuery1 := "%" + _cCFsOriF + "%"

				BEGINSQL ALIAS "TCTE"
					SELECT F8_FILIAL, F8_NFDIFRE, F8_SEDIFRE, F8_NFORIG, 
					D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, 
					D1_LOCAL, D1_QUANT, D1_TIPO, N1_CBASE, N1_ITEM, D1_CONTA, D1_CF  
					FROM %table:SF8% SF8
					INNER JOIN %table:SD1% SD1 ON  D1_FILIAL = F8_FILIAL AND  D1_DOC = F8_NFORIG   AND D1_TP='AI' AND SD1.%notdel% AND D1_FORNECE = F8_FORNECE  AND D1_LOJA = F8_LOJA 
					INNER JOIN %table:SN1% SN1 ON  N1_FILIAL = D1_FILIAL AND  D1_DOC = N1_NFISCAL  AND SN1.%notdel% AND D1_COD = N1_PRODUTO
					WHERE SF8.%notdel% 
					AND F8_NFDIFRE = %exp:TATIV->N1_NFISCAL% 
					AND F8_SEDIFRE = %exp:TATIV->N1_NSERIE% 
					AND D1_COD =  %exp:TATIV->N1_PRODUTO% 
					AND D1_CF IN %Exp:cQuery1%
				ENDSQL

				dbSelectArea("TCTE")
				dbGoTop()
				//ALERT("DOC+SERIE: " + TCTE->F8_NFDIFRE+TCTE->F8_SEDIFRE)

				_cNFFrete  := TCTE->F8_NFDIFRE
				_cDescric  := "FRETE CTE: "+TCTE->F8_NFDIFRE+" "
				_cCBaseOri := TCTE->N1_CBASE
				_nItemNew  := (Val(TCTE->N1_ITEM)+1)
				_nQtdeOri  := TCTE->D1_QUANT
				_cNFOrig   := TCTE->F8_NFORIG

				// Conta contábil da nota original.
				_cContaC   := Posicione("SD1",1,TCTE->F8_FILIAL + TCTE->D1_DOC + TCTE->D1_SERIE + TCTE->D1_FORNECE + TCTE->D1_LOJA + TCTE->D1_COD,"D1_CONTA")
				//_cGrupBem  := Posicione("SB1",2,xFilial("SB1")+Posicione("SD1",1,TCTE->F8_FILIAL + TCTE->D1_DOC + TCTE->D1_SERIE + TCTE->D1_FORNECE + TCTE->D1_LOJA + TCTE->D1_COD,"D1_COD"),"B1_ZGRUBEM")
				_cGrupBem := Posicione("SB1",1,xFilial("SB1")+Posicione("SD1",1,_cFilSN1+TATIV->N1_NFISCAL + TATIV->N1_NSERIE + TATIV->N1_FORNEC + TATIV->N1_LOJA + TATIV->N1_PRODUTO + TATIV->N1_NFITEM,"D1_COD"),"B1_ZGRUBEM")
				//ALERT("Conta Contabil: " + _cContaC)

			EndIf

			//Final do tratamento para notas de frete. --------------------------------------------------------------------------------------------------------------------------------------------------

			//Só faz a classificação de notas de origem existir na base para notas de frete
			If empty(_cNFFrete) .AND. lFrete

				MsgAlert("Não é possivel classificar o BEM: "+ ALLTRIM(TATIV->N1_CBASE) +" NF: " +ALLTRIM(TATIV->N1_NFISCAL) + ", Nota Fiscal original não é de Ativo ou CFOP não se enquadra com o Ativo!")
				_cObserv := "NFe Nao e de Ativo/ CFOP nao se enquadra"
				lRetOk	:= .F.
				//Exit
			Else

				If Select("TSNG") <> 0
					dbSelectArea("TSNG")
					dbCloseArea()
				Endif

				BEGINSQL ALIAS "TSNG"
					SELECT NG_FILIAL, NG_GRUPO, NG_CCONTAB, NG_CDEPREC, NG_CCDEPR, NG_UTIPATR,
					NG_TXDEPR1, NG_TXDEPR2, NG_TXDEPR3, NG_TXDEPR4, NG_TXDEPR5, NG_ZCTADEP, NG_ZCTAACM, FNG_HISTOR, FNG_TIPO, FNG_GRUPO, FNG_TXDEP1				
					FROM %table:SNG% SNG
					LEFT JOIN %table:FNG% FNG ON FNG_FILIAL = NG_FILIAL AND  NG_GRUPO = FNG_GRUPO AND FNG.%notdel%  
					WHERE SNG.%notdel% 
					//AND NG_FILIAL = %exp:_cFilSN1%
					//AND NG_CCONTAB = %exp:_cContaC%
					AND NG_GRUPO = %exp:_cGrupBem%
					ORDER BY NG_FILIAL, NG_GRUPO
				ENDSQL

				dbSelectArea("TSNG")
				dbGoTop()
				while TSNG->(!eof())

					// Alimenta variaveis para gravar SN3
					_cFilSNG  := TSNG->NG_FILIAL
					_cUtiPatr := TSNG->NG_UTIPATR
					_cContaCa := TSNG->NG_CCONTAB
					_cCDeprec := TSNG->NG_CDEPREC
					_cCCDepr  := TSNG->NG_CCDEPR
					_cGrupo   := TSNG->NG_GRUPO
					//_nTx1Depr := TSNG->NG_TXDEPR1
					_nTx1Depr := TSNG->FNG_TXDEP1
					_nTx2Depr := TSNG->NG_TXDEPR2
					_nTx3Depr := TSNG->NG_TXDEPR3
					_nTx4Depr := TSNG->NG_TXDEPR4
					_nTx5Depr := TSNG->NG_TXDEPR5
					_cHistor  := TSNG->FNG_HISTOR
					_cTipo    := TSNG->FNG_TIPO
					_cGrupo1  := TSNG->FNG_GRUPO
					_cTx1DEpr1:= TSNG->FNG_TXDEP1
					_cCDepDesp:= TSNG->NG_ZCTADEP
					_cCDeprAcm:= TSNG->NG_ZCTAACM


					dbSelectArea("SN3")
					dbSetOrder( 1 ) 	//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
					If dbSeek(_cFilSN1+TATIV->N1_CBASE+TATIV->N1_ITEM)
						_nValOrig := SN3->N3_VORIG1

						// Verifica se o Grupo está vazio!
						If !Empty(_cGrupo)

							// Verifica se o Histórico está cadastrado.
							If !Empty(_cHistor)

								//alert("Valor Original: " + cValtoChar(_nValOrig))
								//alert("Valor com CIAP: " + cValtoChar(_nVCCiap))
								//alert("Valor sem CIAP: " + cValtoChar(_nVSCiap))

								// Valida valores -- Caso houver divirgência - Classificação deve ser manual.
								//If ( ( lTemCiap .AND. ( ROUND(_nValOrig,0) = ROUND(_nVCCiap,0))) .OR. (!lTemCiap .AND. ( ROUND(_nValOrig,0) = ROUND(_nVSCiap,0))) )

								If Substr(TATIV->N1_CBASE,1,2)$("AD|AI|PV")
									_cPlacaAI := TATIV->N1_CBASE
								Else
									_cPlacaAI := ""
								EndIf

								// Atualiza tabela SN1
								RecLock("SN1",.F.)
								SN1->N1_GRUPO   := _cGrupo
								SN1->N1_STATUS  := '1'
								SN1->N1_DTCLASS := _dTClass
								SN1->N1_UTIPATR := _cUtiPatr
								SN1->N1_VLAQUIS := _nValOrig
								SN1->N1_PLACA   := _cPlacaAI // Atualiza a Placa com o Código Base.
								MsUnlock()

								dbSelectArea("SN3")
								dbSetOrder( 1 ) 	//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
								If dbSeek(_cFilSN1+TATIV->N1_CBASE+TATIV->N1_ITEM+TSNG->FNG_TIPO)

									// Atualiza tabela SN3
									RecLock("SN3",.F.)
									SN3->N3_CCONTAB := _cContaCa
									SN3->N3_CDEPREC := _cCDeprec
									SN3->N3_CCDEPR  := _cCCDepr
									SN3->N3_TXDEPR1 := _cTx1DEpr1
									SN3->N3_TXDEPR2 := _nTx2Depr
									SN3->N3_TXDEPR3 := _cTx1DEpr1
									SN3->N3_TXDEPR4 := _nTx4Depr
									SN3->N3_TXDEPR5 := _nTx5Depr
									SN3->N3_AQUISIC := SN3->N3_DINDEPR
									SN3->N3_HISTOR  := _cHistor
									MsUnlock()
								else

									IF _cFilSN1 <> _cFiltI10
										// Inclui tipo 10 na SN3
										RecLock("SN3",.T.)
										SN3->N3_FILIAL  := SN1->N1_FILIAL
										SN3->N3_CBASE   := SN1->N1_CBASE
										SN3->N3_ITEM    := SN1->N1_ITEM
										SN3->N3_TIPO    := _cTipo
										SN3->N3_HISTOR  := _cHistor
										SN3->N3_TPSALDO := '1'
										SN3->N3_TPDEPR  := '1'
										SN3->N3_BAIXA  := '0'
										SN3->N3_DINDEPR := SN1->N1_AQUISIC
										SN3->N3_VORIG1  := _nValOrig
										SN3->N3_CCONTAB := _cContaCa
										SN3->N3_CDEPREC := _cCDepDesp
										SN3->N3_CCDEPR  := _cCDeprAcm
										SN3->N3_CCUSTO  := _cCcusto
										SN3->N3_CUSTBEM := _cCcusto
										SN3->N3_SUBCCON := _cItemCta
										SN3->N3_TXDEPR1 := _cTx1DEpr1
										SN3->N3_TXDEPR2 := _nTx2Depr
										SN3->N3_TXDEPR3 := _cTx1DEpr1
										SN3->N3_TXDEPR4 := _nTx4Depr
										SN3->N3_TXDEPR5 := _nTx5Depr
										SN3->N3_CALCDEP := '0'
										SN3->N3_SEQ     := '002'
										SN3->N3_FILORIG := SN1->N1_FILIAL
										SN3->N3_AQUISIC := SN1->N1_AQUISIC
										SN3->N3_RATEIO  := '2'
										SN3->N3_ATFCPR  := '2'
										SN3->N3_INTP    := '2'
										MsUnlock()

										// Inclui tipo 10 na SN4
										RecLock("SN4",.T.)
										SN4->N4_FILIAL  := SN3->N3_FILIAL
										SN4->N4_CBASE   := SN3->N3_CBASE
										SN4->N4_ITEM    := SN3->N3_ITEM
										SN4->N4_TIPO    := _cTipo
										SN4->N4_OCORR   := '05'
										SN4->N4_TIPOCNT := '1'
										SN4->N4_DATA	:= SN3->N3_AQUISIC
										SN4->N4_QUANTD  := SN1->N1_QUANTD
										SN4->N4_VLROC1  := _nValOrig
										SN4->N4_NOTA    := SN1->N1_NFISCAL
										SN4->N4_SERIE   := SN1->N1_NSERIE
										SN4->N4_SEQ     := SN3->N3_SEQ
										SN4->N4_CCUSTO  := _cCcusto
										SN4->N4_SUBCTA := _cItemCta
										//SN4->N4_IDMOV   :=
										SN4->N4_CALCPIS := SN1->N1_CALCPIS
										SN4->N4_LA      := 'N'
										SN4->N4_ORIGEM  := 'ATFA012'
										SN4->N4_LP      := '801'
										SN4->N4_TPSALDO := SN3->N3_TPSALDO
										//SN4->N4_HORA    :=
										MsUnlock()
									ENDIF

								Endif

								// Se a Nota for CTe- irá atualizar o Cod.Base, Item e Descricao
								If _cTpCompl == "3"

									RecLock("SN1",.F.)
									SN1->N1_CBASE   := _cCBaseOri
									SN1->N1_ITEM    := STRZERO(_nItemNew,4)
									SN1->N1_DESCRIC := ALLTRIM(_cDescric) +" "+ ALLTRIM(SN1->N1_DESCRIC)
									SN1->N1_QUANTD  := _nQtdeOri
									SN1->N1_PLACA   := _cPlacaAI // Atualiza a Placa com o Código Base.
									MsUnlock()

									// Atualiza tabela SN3
									RecLock("SN3",.F.)
									SN3->N3_CBASE := _cCBaseOri
									SN3->N3_ITEM  :=  STRZERO(_nItemNew,4)
									SN3->N3_CCONTAB := _cContaCa
									SN3->N3_CDEPREC := _cCDeprec
									SN3->N3_CCDEPR  := _cCCDepr
									SN3->N3_TXDEPR1 := _cTx1DEpr1
									SN3->N3_TXDEPR2 := _nTx2Depr
									SN3->N3_TXDEPR3 := _cTx1DEpr1
									SN3->N3_TXDEPR4 := _nTx4Depr
									SN3->N3_TXDEPR5 := _nTx5Depr
									SN3->N3_AQUISIC := SN3->N3_DINDEPR
									SN3->N3_HISTOR  := _cHistor
									MsUnlock()

									// Atualiza tabela SN4
									RecLock("SN4",.F.)

									SN4->N4_FILIAL  := SN3->N3_FILIAL
									SN4->N4_CBASE   := _cCBaseOri
									SN4->N4_ITEM    := STRZERO(_nItemNew,4)
									SN4->N4_TIPO    := '01'
									SN4->N4_OCORR   := '05'
									SN4->N4_TIPOCNT := '1'
									SN4->N4_DATA	:= SN3->N3_AQUISIC
									SN4->N4_QUANTD  := SN1->N1_QUANTD
									SN4->N4_VLROC1  := _nValOrig
									SN4->N4_NOTA    := SN1->N1_NFISCAL
									SN4->N4_SEQ     := SN3->N3_SEQ
									SN4->N4_CALCPIS := SN1->N1_CALCPIS
									SN4->N4_LA      := 'N'
									SN4->N4_ORIGEM  := 'ATFA012'
									SN4->N4_LP      := '801'
									SN4->N4_TPSALDO := SN3->N3_TPSALDO
									MsUnlock()

									IF _cFilSN1 <> _cFiltI10
										// Inclui tipo 10 na SN3
										RecLock("SN3",.T.)
										SN3->N3_FILIAL  := SN1->N1_FILIAL
										SN3->N3_CBASE   := SN1->N1_CBASE
										SN3->N3_ITEM    := SN1->N1_ITEM
										SN3->N3_TIPO    := '10'
										SN3->N3_HISTOR  := 'DEPRECIACAO DO MES (CONTAB.)'
										SN3->N3_TPSALDO := '1'
										SN3->N3_TPDEPR  := '1'
										SN3->N3_BAIXA  := '0'
										SN3->N3_DINDEPR := SN1->N1_AQUISIC
										SN3->N3_VORIG1  := _nValOrig
										SN3->N3_CCONTAB := _cContaCa
										SN3->N3_CDEPREC := _cCDepDesp
										SN3->N3_CCDEPR  := _cCDeprAcm
										SN3->N3_CCUSTO  := _cCcusto
										SN3->N3_CUSTBEM := _cCcusto
										SN3->N3_SUBCCON := _cItemCta
										SN3->N3_TXDEPR1 := Posicione("FNG",1,xFilial("FNG") + _cGrupBem+'10', "FNG_TXDEP1")
										SN3->N3_TXDEPR2 := Posicione("FNG",1,xFilial("FNG") + _cGrupBem+'10', "FNG_TXDEP1")
										SN3->N3_TXDEPR3 := Posicione("FNG",1,xFilial("FNG") + _cGrupBem+'10', "FNG_TXDEP1")
										SN3->N3_TXDEPR4 := Posicione("FNG",1,xFilial("FNG") + _cGrupBem+'10', "FNG_TXDEP1")
										SN3->N3_TXDEPR5 := Posicione("FNG",1,xFilial("FNG") + _cGrupBem+'10', "FNG_TXDEP1")
										SN3->N3_CALCDEP := '0'
										SN3->N3_SEQ     := '002'
										SN3->N3_FILORIG := SN1->N1_FILIAL
										SN3->N3_AQUISIC := SN1->N1_AQUISIC
										SN3->N3_RATEIO  := '2'
										SN3->N3_ATFCPR  := '2'
										SN3->N3_INTP    := '2'
										MsUnlock()

										// Inclui tipo 10 na SN4
										RecLock("SN4",.T.)
										SN4->N4_FILIAL  := SN3->N3_FILIAL
										SN4->N4_CBASE   := SN3->N3_CBASE
										SN4->N4_ITEM    := SN3->N3_ITEM
										SN4->N4_TIPO    := '10'
										SN4->N4_OCORR   := '05'
										SN4->N4_TIPOCNT := '1'
										SN4->N4_DATA	:= SN3->N3_AQUISIC
										SN4->N4_QUANTD  := SN1->N1_QUANTD
										SN4->N4_VLROC1  := _nValOrig
										SN4->N4_NOTA    := SN1->N1_NFISCAL
										SN4->N4_SERIE   := SN1->N1_NSERIE
										SN4->N4_SEQ     := SN3->N3_SEQ
										SN4->N4_CCUSTO  := _cCcusto
										SN4->N4_SUBCTA := _cItemCta
										//SN4->N4_IDMOV   :=
										SN4->N4_CALCPIS := SN1->N1_CALCPIS
										SN4->N4_LA      := 'N'
										SN4->N4_ORIGEM  := 'ATFA012'
										SN4->N4_LP      := '801'
										SN4->N4_TPSALDO := SN3->N3_TPSALDO
										//SN4->N4_HORA    :=
										MsUnlock()

									ENDIF

								EndIf

								//Else
								//	MsgAlert("Valor Original x Valor classificação do BEM: "+ ALLTRIM(TATIV->N1_CBASE) +" NF: " +ALLTRIM(TATIV->N1_NFISCAL) + "divirgente, Nao é possivel classificação automática!")
								//	_cObserv := "Valores com Divirgencias - Ver TES"
								//	lRetOk := .F.
								//EndIf
							Else
								MsgAlert("Histórico não cadastrado para o Grupo de Bens:"+ alltrim(_cGrupo) + " da filial:"+ alltrim(_cFilSNG) + " , Favor vincular um histórico ao grupo em questão!, Nao é possivel classificação automática!")
								_cObserv := "Sem Historico cadastrado para o Grupo"
								lRetOk := .F.
							EndIf
						Else
							MsgAlert("Conta Contábil: "+ alltrim(_cContaC) + " Não pertence a um Grupo de Ativo, Nao é possivel classificação automática!")
							_cObserv := "C.Contabil nao pertence grupo Ativo"
							lRetOk := .F.
						EndIf

					EndIf
					TSNG->(dbSkip())
				enddo
			Endif

		EndIf

		// Grava Logs da Classificação Automatica.
		dbSelectArea("ZDM")
		dbSetOrder(1) //ZDM_FILIAL+ZDM_NUMNF+ZDM_SERIE

		If Empty(_cObserv)
			_cObserv := "Classificacao OK!"
		EndIf

		RecLock("ZDM",.T.)
		ZDM->ZDM_FILIAL   := TATIV->N1_FILIAL
		ZDM->ZDM_NUMNF    := TATIV->N1_NFISCAL
		ZDM->ZDM_SERIE    := TATIV->N1_NSERIE
		ZDM->ZDM_FORN     := TATIV->N1_FORNEC
		ZDM->ZDM_LOJA     := TATIV->N1_LOJA
		ZDM->ZDM_PROD     := TATIV->N1_PRODUTO
		ZDM->ZDM_CBASE    := TATIV->N1_CBASE
		ZDM->ZDM_QUANTD   := _nQtdeOri
		ZDM->ZDM_VORIG1   := _nValOrig
		ZDM->ZDM_TPCMPL   := _cTpCompl
		ZDM->ZDM_NFORIG   := _cNFOrig
		ZDM->ZDM_USER     := cUserName
		ZDM->ZDM_DATA     := DATE()
		ZDM->ZDM_HORAC    := TIME()
		ZDM->ZDM_ROTINA   := 'UNIA031'
		ZDM->ZDM_OBS      := _cObserv
		MsUnlock()

		TATIV->(DBSkip())
	Enddo

	//Mensagem
	If lRetOk
		MsgAlert("Classificação dos BENS processada com Sucesso!")
	EndIf

	RestArea(_aSN1)
	RestArea(_aSN3)
	RestArea(_aSNG)
	RestArea(_aSD1)
	RestArea(_aZDM)
	RestArea(_aBkp)
	RestArea(_aFNG)

Return lRetOk
//----------------------------------------------------------------------------------------------------------------------
