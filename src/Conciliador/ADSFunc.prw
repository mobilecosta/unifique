#Include "Protheus.ch"

/*/{Protheus.doc} ADSAli2J
Função que retonar o objeto JSON com cabeçalho e dados conforme o alias da tabela informada.
@type   : User Function
@author : Paulo Felipe
@since  : 10/09/2019
@version: 1.00
@param  : cAlias, characters, tabela.
/*/
User Function ADSTab2J(cAlias,lRecno,lLegend)

    Local cJSON     := ""
	Local oJSON		:= Nil
	Default lRecno	:= .F.
	Default lLegend	:= .F.

	DBSelectArea("SX3")
    SX3->(DBSetOrder(1))
 
	// Posiciona na SX3 através do nome. 
	If SX3->(DBSeek(cAlias))
		// Se adiciona o campo para legenda.
		If lLegend
			oJSON := JSONObject():New()
            oJSON["Titulo"]		:= ""
            oJSON["Campo"]      := PrefixoCpo(cAlias) + "_XLEG"
			oJSON["Picture"]    := "@BMP"
            oJSON["Tamanho"]    := 2
            oJSON["Decimal"]    := 0
			oJSON["Valid"]    	:= ""
			oJSON["Usado"]    	:= ""
            oJSON["Tipo"]       := "C"
            oJSON["F3"]     	:= ""
			oJSON["Context"]    := ""
			oJSON["Combo"]   	:= ""
			oJSON["Relacao"] 	:= "'BR_AZUL'"
			oJSON["When"]   	:= ".F."
			oJSON["Visual"]   	:= "V"
			oJSON["VldUser"]   	:= ""
			oJSON["PictVar"]   	:= ""
			oJSON["Obrigat"] 	:= .F.
			// Coleta o JSON.
            cJSON += IIf(Empty(cJSON),"",",") + oJSON:ToJson()
			// Limpa memória.
            FreeObj(oJSON)
		EndIf

		While !SX3->(EOF()) .And. cAlias == SX3->X3_ARQUIVO
			oJSON := JSONObject():New()
            oJSON["Titulo"]		:= AllTrim(X3Titulo())
            oJSON["Campo"]      := AllTrim(SX3->X3_CAMPO)
			oJSON["Picture"]    := AllTrim(SX3->X3_PICTURE)
            oJSON["Tamanho"]    := SX3->X3_TAMANHO
            oJSON["Decimal"]    := SX3->X3_DECIMAL
			oJSON["Valid"]    	:= SX3->X3_VALID
			oJSON["Usado"]    	:= SX3->X3_USADO
            oJSON["Tipo"]       := AllTrim(SX3->X3_TIPO)
            oJSON["F3"]     	:= SX3->X3_F3
			oJSON["Context"]	:= SX3->X3_CONTEXT
			oJSON["Combo"]   	:= X3CBox()
			oJSON["Relacao"] 	:= SX3->X3_RELACAO
			oJSON["When"]   	:= SX3->X3_WHEN
			oJSON["Visual"]   	:= SX3->X3_VISUAL
			oJSON["VldUser"]   	:= SX3->X3_VLDUSER
			oJSON["PictVar"]   	:= SX3->X3_PICTVAR
			oJSON["Obrigat"] 	:= Left(Bin2Str(SX3->X3_OBRIGAT),1) == "x"
			// Coleta o JSON.
            cJSON += IIf(Empty(cJSON),"",",") + oJSON:ToJson()
			// Limpa memória.
            FreeObj(oJSON)

			SX3->(DBSkip())
		End

		// Se adiciona o campo para recno.
		If lRecno
			oJSON := JSONObject():New()
            oJSON["Titulo"]		:= "Recno"
            oJSON["Campo"]      := PrefixoCpo(cAlias) + "_REC_WT"
			oJSON["Picture"]    := "@E"
            oJSON["Tamanho"]    := 16
            oJSON["Decimal"]    := 0
			oJSON["Valid"]    	:= ""
			oJSON["Usado"]    	:= ""
            oJSON["Tipo"]       := "N"
            oJSON["F3"]     	:= ""
			oJSON["Context"]    := ""
			oJSON["Combo"]   	:= ""
			oJSON["Relacao"] 	:= ""
			oJSON["When"]   	:= ".F."
			oJSON["Visual"]   	:= "V"
			oJSON["VldUser"]   	:= ""
			oJSON["PictVar"]   	:= ""
			oJSON["Obrigat"] 	:= .F.
			// Coleta o JSON.
            cJSON += IIf(Empty(cJSON),"",",") + oJSON:ToJson()
			// Limpa memória.
            FreeObj(oJSON)
		EndIf

		// Insere o restante do JSON para fazer o parser.
		cJSON := Stuff(cJSON,1,0,'{"Header": [') + "], ";
                            + '"Data": [],';
							+ '"Grid": ""}'

		// Cria JSON de retorno.
		oJSON := JSONObject():New()
		// Realiza o parser do JSON.
		If !Empty(oJSON:FromJson(cJSON))
			ShowHelpDlg("Parser",{"Não foi possível realizar o parser do JSON de retorno."},1,{""},0)
		EndIf
	EndIf

Return oJSON


/*/{Protheus.doc} ADSQry2J
Função que retonar o objeto JSON com cabeçalho e dados conforme o alias da query informada.
@type   : User Function
@author : Paulo Felipe
@since  : 10/09/2019
@version: 1.00
@param 	: cAlias, characters, alias da query.
@return : oJSON, object, JSON.
/*/
User Function ADSQry2J(cAlias)

	Local aData     := {}
    Local aStruct   := {}
    Local cErrPsr   := ""
    Local cJSON     := ""
    Local nCount    := 0
	Local oJSON		:= Nil

	// Coleta os campos que compõe a query.
    aStruct := (cAlias)->(DBStruct())

    DBSelectArea("SX3")
    SX3->(DBSetOrder(2))

    For nCount := 1 To Len(aStruct)
		// Posiciona na SX3 através do nome. 
        If SX3->(DBSeek(aStruct[nCount][1]))
            oJSON := JSONObject():New()
			oJSON["Titulo"]		:= AllTrim(X3Titulo())
            oJSON["Campo"]      := AllTrim(SX3->X3_CAMPO)
			oJSON["Picture"]    := AllTrim(SX3->X3_PICTURE)
            oJSON["Tamanho"]    := SX3->X3_TAMANHO
            oJSON["Decimal"]    := SX3->X3_DECIMAL
			oJSON["Valid"]    	:= SX3->X3_VALID
			oJSON["Usado"]    	:= SX3->X3_USADO
            oJSON["Tipo"]       := AllTrim(SX3->X3_TIPO)
            oJSON["F3"]     	:= SX3->X3_F3
			oJSON["Context"]    := SX3->X3_CONTEXT
			oJSON["Combo"]   	:= X3CBox()
			oJSON["Relacao"] 	:= SX3->X3_RELACAO
			oJSON["When"]   	:= SX3->X3_WHEN

			// Coleta o JSON.
            cJSON += IIf(Empty(cJSON),"",",") + oJSON:ToJson()
			// Limpa memória.
            FreeObj(oJSON)
        EndIf
    Next nCount
    
	// Insere o restante do JSON para fazer o parser.
    cJSON := Stuff(cJSON,1,0,'{"Header": [') + "], ";
                            + '"Data": [],';
							+ '"Grid": ""}'

	// Cria JSON de retorno.
    oJSON := JSONObject():New()

	// Realiza o parser do JSON.
    If !Empty(cErrPsr := oJSON:FromJson(cJSON))
        ShowHelpDlg("Parser",{"Não foi possível realizar o parser do JSON de retorno."},1,{""},0)
    Else
        While !(cAlias)->(EOF())
			// Inicializa o array.
            AAdd(aData,Array(Len(oJSON["Header"])))

            For nCount := 1 To Len(oJSON["Header"])
                ATail(aData)[nCount] := (cAlias)->(FieldGet((cAlias)->(FieldPos(oJSON["Header"][nCount]["Campo"]))))
            Next nCount
            (cAlias)->(DBSkip())
        End
        oJSON["Data"] := AClone(aData)
    EndIf   

    FreeObj(aData)

Return oJSON

/*/{Protheus.doc} ADSAScan
(long_description)
@type   : User Function
@author : Paulo Felipe
@since  : 10/09/2019
@version: 1.00
@param  : aHeader, array, cabeçalho.
@param 	: cField, characters, campo a ser pesquisado.
@param 	: lEqual, logical, se a pesquisa é exata.
@return : nPos, numeric, posição encontrada.
/*/
User Function ADSAScan(aHeader,cField,lEqual)

	Local nPos 		:= 0
	Default lEqual 	:= .T.

	If lEqual
		nPos := AScan(aHeader,{|x| AllTrim(x["Campo"]) == AllTrim(cField)})
	Else
		nPos := AScan(aHeader,{|x| AllTrim(cField) $ AllTrim(x["Campo"])})
	EndIf

Return nPos

/*/{Protheus.doc} ADSAllTb
Função para coletar a estrutura das tabelas gerando um único JSON.
@type   : User Function
@author : Paulo Felipe
@since  : 15/09/2019
@version: 1.00
@param	: aTables, array, tabelas para coletar informações.
/*/
User Function ADSAllTb(aTables)

	Local cJSON 	:= ""
	Local nTable	:= 0
	Local oJSON		:= Nil
	Default aTables := {"ZR7","ZR8","ZRA","ZRB","ZRD","ZRE","ZRF","ZRH","ZRK","ZRQ","ZRR","ZRT"}

	// Gera a estrutura de cebeçaladminho e itens das tabelas para gerar um único JSON.
	For nTable := 1 To Len(aTables)
		cJSON += '"' + aTables[nTable] + '": '
		oJSON := U_ADSTab2J(aTables[nTable],.T.,.T.)
		cJSON += oJSON:ToJson() + IIf(nTable != Len(aTables),",","")
		FreeObj(oJSON)
	Next nTable

	cJSON := "{" + cJSON + "}"

	oJSON := JSONObject():New()
	// Realiza o parser do JSON.
	If !Empty(oJSON:FromJson(cJSON))
		ShowHelpDlg("Parser",{"Não foi possível realizar o parser do JSON de retorno."},1,{""},0)
	EndIf

Return oJSON

/*/{Protheus.doc} ADSGetF
Função utilizada para coletar o arquivo no SX1.
@type   : User Function
@author : Paulo Felipe
@since  : 22/09/2019
@version: 1.00
@return : lOK, logical, se está OK.
/*/
User Function ADSGetF()
	
	Local cFile := ""
	Local lOk	:= .F.

	cFile := cGetFile("TXT |*.txt| CSV |*.csv|","Selecione o Arquivo",0,"C:\",.F.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.F.,.T.)

	If !Empty(cFile)
		&(ReadVar()) := cFile
		lOk := .T.
	EndIf

Return lOk

/*/{Protheus.doc} ADSX2Nam
Função para coletar o nome da tabela informada.
@type   : User Function
@author : Paulo Felipe
@since  : 24/09/2019
@version: 1.00
@param  : cAlias, characters, alias.
@return : cName, characters, nome da tabela.
/*/
User Function ADSX2Nam(cAlias)
	
	Local cName := ""

	SX2->(DBSetOrder(1))
	If SX2->(MsSeek(cAlias))
		cName := AllTrim(Capital(Lower(X2NOME())))
	EndIf

Return cName

/*/{Protheus.doc} ADSGetDt
Função para filtrar e coletar os dados conforme o arquivo.
@type   : User Function
@author : Paulo Felipe
@since  : 15/09/2019
@version: 1.00
@param  : cAlias, characters, tabela.
@param  : cFileMD5, characters, arquivo em MD5.
@param  : oJSON, object, JSON.
@param  : lOnlyPend, logical, somente itens pendentes.
/*/
User Function ADSGetDt(cAlias,cFileMD5,oJSON,lOnlyPend)

	Local cFilter 		:= ""
	Local cStatus		:= ""
	Local nCount		:= 0
	Default lOnlyPend	:= .F.

	cFilter := PrefixoCpo(cAlias) + "_XNAMD5 = '" + cFileMD5 + "'"
	// Somente itens pendentes, exceto na ZRA.
	If lOnlyPend .And. cAlias != "ZRA"
		cFilter += " AND " + PrefixoCpo(cAlias) + "_XSTAT != 'I'"
	EndIf

	DBSelectArea(cAlias)
	(cAlias)->(DBSetFilter({|| &("@" + cFilter)},"@" + cFilter))
	(cAlias)->(DBGoTop())

	While !(cAlias)->(EOF())		
		// Inicializa o array.
		AAdd(oJSON["Data"],Array(Len(oJSON["Header"]) + 1))
		// Delete.
		ATail(ATail(oJSON["Data"])) := .F.

		For nCount := 1 To Len(oJSON["Header"])
			ATail(oJSON["Data"])[nCount] := (cAlias)->(FieldGet((cAlias)->(FieldPos(oJSON["Header"][nCount]["Campo"]))))
		Next nCount

		// Informa o recno se houver.
		If U_ADSAScan(oJSON["Header"],PrefixoCpo(cAlias) + "_REC_WT") > 0
			ATail(oJSON["Data"])[U_ADSAScan(oJSON["Header"],PrefixoCpo(cAlias) + "_REC_WT")] := (cAlias)->(Recno())
		EndIf

		// Informa legenda se houver.
		If U_ADSAScan(oJSON["Header"],PrefixoCpo(cAlias) + "_XLEG") > 0
			cStatus := ATail(oJSON["Data"])[U_ADSAScan(oJSON["Header"],PrefixoCpo(cAlias) + "_XSTAT")]
			ATail(oJSON["Data"])[U_ADSAScan(oJSON["Header"],PrefixoCpo(cAlias) + "_XLEG")] := IIf(Empty(cStatus),"BR_AZUL",IIf(cStatus == "E","BR_VERMELHO","BR_VERDE"))
		EndIf

		(cAlias)->(DBSkip())
	End
	
	(cAlias)->(DBClearFilter())
	(cAlias)->(DBGoTop())

Return

/*/{Protheus.doc} ADSNewMt
Função para gerar um novo sequencial da SRA.
@type   : User Function
@author : Paulo Felipe
@since  : 27/09/2019
@version: 1.00
@return : cNewMat, characters, novo código de matrícula.
/*/
User Function ADSNewMt()

	Local cAlias	:= GetNextAlias()
	Local cNewMat 	:= ""

	BeginSQL Alias cAlias
		SELECT
			MAX(RA_MAT) AS MAT
		FROM
			%Table:SRA% SRA
		WHERE
				RA_FILIAL = %xFilial:SRA%
			AND SRA.%NotDel%
	EndSQL

	cNewMat := Soma1((cAlias)->MAT)
	
	(cAlias)->(DBCloseArea())

Return cNewMat

/*/{Protheus.doc} ADSImpSt
Função para retornar o status de importação do arquivo.
@type   : User Function
@author : Paulo Felipe
@since  : 09/10/2019
@version: 1.00
@param  : param, param_type, param_descr
@return : return, return_type, return_description
/*/
User Function ADSImpSt(cNaMD5)

	Local aStatus	:= {}
	Local aTables 	:= {"ZR7","ZR8","ZRA","ZRB","ZRD","ZRE","ZRF","ZRH","ZRK","ZRQ","ZRR","ZRT"}
	Local cAlias	:= GetNextAlias()
	Local cPref		:= ""
	Local cQuery	:= ""
	Local cStatus	:= ""
	Local nTable	:= 0

	For nTable := 1 To Len(aTables)
		// Ignora tabela de transferência.
		If aTables[nTable] == "ZRE"
			Loop
		EndIf

		cPref := PrefixoCpo(aTables[nTable]) + "_"

		cQuery := " SELECT DISTINCT" + CRLF
		cQuery += "		" + cPref + "XSTAT AS STATUS" + CRLF
		cQuery += "	FROM " + CRLF
		cQuery += 		RetSqlName(aTables[nTable]) + " TAB " + CRLF
		cQuery += "	WHERE " + CRLF
		cQuery += 			cPref + "FILIAL = '" + xFilial(aTables[nTable]) + "' " + CRLF
		cQuery += "		AND " + cPref + "XNAMD5 = '" + cNaMD5 + "' " + CRLF
		cQuery += "		AND TAB.D_E_L_E_T_ = ' ' " + CRLF
		DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

		While !(cAlias)->(EOF())
			If AScan(aStatus,(cAlias)->STATUS) == 0
				AAdd(aStatus,(cAlias)->STATUS)
			EndIf
			(cAlias)->(DBSkip())
		End
		(cAlias)->(DBCloseArea())
	Next nTable

	// Contém erros, retorna como pendente.
	If AScan(aStatus,"E") > 0
		cStatus := "E"
	// Não contém erros e contem integrado, retorna como importado.
	ElseIf AScan(aStatus,"I") > 0 .And. AScan(aStatus," ") == 0
		cStatus := "I"
	// Não tem erros nem integrados, retorna como não processado.
	Else
		cStatus := CriaVar("ZF1_STATUS",.F.)
	EndIf

Return cStatus
