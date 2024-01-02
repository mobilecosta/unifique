#Include "Protheus.ch"

/*/{Protheus.doc} ADSAli2J
Função que retonar o objeto JSON com cabeçalho e dados conforme o alias da tabela informada.
@type   : User Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
@param  : cAlias, characters, tabela.
/*//*
User Function ADSTab2J(cAlias,lRecno,lLegend)

    Local cJSON     := ""
    Local nCount    := 0
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

Return oJSON*/

/*/{Protheus.doc} ADSAScan
Função para realizar o scan no header através do campo.
@type   : User Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
@param  : aHeader, array, cabeçalho.
@param 	: cField, characters, campo a ser pesquisado.
@param 	: lEqual, logical, se a pesquisa é exata.
@return : nPos, numeric, posição encontrada.
/*//*
User Function ADSAScan(aHeader,cField,lEqual)

	Local nPos 		:= 0
	Default lEqual 	:= .T.

	If lEqual
		nPos := AScan(aHeader,{|x| AllTrim(x["Campo"]) == AllTrim(cField)})
	Else
		nPos := AScan(aHeader,{|x| AllTrim(cField) $ AllTrim(x["Campo"])})
	EndIf

Return nPos*/

/*/{Protheus.doc} ADSGetP
Função utilizada para coletar o caminho no SX1.
@type   : User Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
@return : lOK, logical, se está OK.
/*/
User Function ADSGetP()

	Local cPath := ""
	Local lOk	:= .F.

	cPath := cGetFile("","Selecione o caminho",0,"C:\",.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY,.F.,.T.)

	If ExistDir(cPath)
		&(ReadVar()) := cPath
		lOk := .T.
	EndIf

Return lOk

/*/{Protheus.doc} ADSCNAB
Função para retornar o JSON com a configuração do CNAB.
@type   : User Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
@return : oJSON, object, configuração do CNAB.
/*/
User Function ADSCNAB()

	Local cJSON	:= ""
	Local oJSON := Nil

	cJSON := '{'
	cJSON += '	"CNAB": ['
	cJSON += '		{"Campo": "BANCO","Inicio": 1,"Tamanho": 3},'
	cJSON += '		{"Campo": "AGENC","Inicio": 53,"Tamanho": 5},'
	cJSON += '		{"Campo": "CONTA","Inicio": 59,"Tamanho": 12},'
	cJSON += '		{"Campo": "DATA","Inicio": 143,"Tamanho": 8},'
	cJSON += '		{"Campo": "VALOR","Inicio": 151,"Tamanho": 18},'
	cJSON += '		{"Campo": "TIPO","Inicio": 169,"Tamanho": 1},'
	cJSON += '		{"Campo": "CATLAN","Inicio": 170,"Tamanho": 3},'
	cJSON += '		{"Campo": "HIST","Inicio": 177,"Tamanho": 25},'
	cJSON += '		{"Campo": "DOC","Inicio": 202,"Tamanho": 39}'
	cJSON += '	]'
	cJSON += '}'

	// Cria JSON de retorno.
    oJSON := JsonObject():New()
	// Realiza o parser do JSON.
    oJSON:FromJson(cJSON)

Return oJSON

/*/{Protheus.doc} ADSInArr
Função para inicializar a linha do array.
@type   : User Function
@author : Paulo Felipe
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@version: 1.00
@param  : oJSON, object, json com header e detail.
/*/
User Function ADSInArr(oJSON)

	Local nHeader := 0

	For nHeader := 1 To Len(oJSON["Header"])
		Do Case
			Case oJSON["Header"][nHeader]["Tipo"] == "C"
				ATail(oJSON["Data"])[nHeader] := ""
			Case oJSON["Header"][nHeader]["Tipo"] == "N"
				ATail(oJSON["Data"])[nHeader] := 0
			Case oJSON["Header"][nHeader]["Tipo"] == "L"
				ATail(oJSON["Data"])[nHeader] := .F.
			OtherWise
				ATail(oJSON["Data"])[nHeader] := Nil
		End
	Next nHeader

Return