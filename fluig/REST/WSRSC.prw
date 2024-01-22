#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'


*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | WSRSC  | Autor |  			                               |*
*+------------+------------------------------------------------------------+*
*|Data        | 05.12.2023                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Manutenção de Solicitação de Compras via REST              |*
*+------------+------------------------------------------------------------+*
*|Solicitante |                                                            |*
*+------------+------------------------------------------------------------+*
*|Partida     | WebService                                                 |*
*+------------+------------------------------------------------------------+*
*|Arquivos    |                                                            |*
*+------------+------------------------------------------------------------+*
*|             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            |*
*+-------------------------------------------------------------------------+*
*| Programador       |   Data   | Motivo da alteracao                      |*
*+-------------------+----------+------------------------------------------+* 
*+-------------------+----------+------------------------------------------+*
*****************************************************************************

User Function WSRSC()

Return

	WSRESTFUL WSRSC DESCRIPTION "Serviço REST para inclusão de SC"

		//WSDATA OP               As String
		//WSDATA FIL              As String
		//WSDATA NUMSC            As String

		//WSMETHOD GET DESCRIPTION "Serviço para manutenção na Solicitação de Compras na URL" WSSYNTAX "/WSRESTSC || /WSRESTSC/{}"

		WSMETHOD POST DESCRIPTION "Serviço para inclusão de Solicitação de Compras na URL" WSSYNTAX "/WSRSC || /WSRSC/{}"

	END WSRESTFUL

WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE WSRSC
	Local cJSON    		:= Self:GetContent() // Pega a string do JSON
	Local cJsonRet 		:= ""

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .F.
	Private lAutoErrNoFile 	:= .T.
	Private oParseJSON 		:= Nil
	Private oOBJ            := Nil

	::SetContentType("application/json; charset=UTF-8")

	ConOut("WSRSC - JSON RECEBIDO: "+cJson)


	//ConOut("WSRESTSC -> Json recebido: "+cJson)
	If Empty(cJson)
		cJsonRet := '{"RETORNO": "ERRO", "MENSAGEM":"REQUISICAO JSON VAZIA, VERIFIQUE"}'
		::SetResponse(cJsonRet)
		Return(.T.)
	Endif

	oOBJ  := JsonObject():new()
	oOBJ:fromJson(cJSON)

//	cFilAnt := UPPER(Self:FIL)

	//SRSF 04/02/2022 - Retirado RpcSetEnv("03" , "01", , , ,"WSRESTSC",,,,,)

	cJsonRet := fIncSC()

	::SetResponse(cJsonRet)

Return(.T.)

Static Function fIncSC()
	Local cJSON       := ""
	Local nIdxItem    := 0
	//Local nIdxRateio  := 0
	Local nAux        := 0

	Local aCabSC      := {}
	Local aItensSC    := {}
	//Local aRateioCX   := {}
	Local aErrPCAuto  := {}
	Local nTamItem    := TamSX3("C1_ITEM")[1]
	//Local nTamRateio  := TamSX3("CX_ITEM")[1]

	Local cC1_NUM     := GetSxeNum("SC1","C1_NUM")
	Local cC1_SOLICIT := oOBJ:GetJsonObject("C1_SOLICIT") 
	Local dC1_EMISSAO := Ctod(oOBJ:GetJsonObject("C1_EMISSAO"))  
	Local cCODCOMPR   := oOBJ:GetJsonObject("CCODCOMPR") 
	Local cC1_FILENT  := oOBJ:GetJsonObject("C1_FILENT") 


	Local oItens      := Nil
	//Local oRateio     := Nil

	Private cUserName := cC1_SOLICIT

	ConOut("WSRSC -> Solicitante: "+cC1_SOLICIT)

	//GetSxeNum("SC1","C1_NUM")

	//SRSF 11/11/2021 - ConOut("Solicitante: "+cC1_SOLICIT)

	PswOrder(2)
	if !PswSeek(cC1_SOLICIT,.T.)
		cJSON := '{"RETORNO": "ERRO", "MENSAGEM":"SOLICITANTE '+cC1_SOLICIT+' NAO LOCALIZADO"}'
		Return(cJSON)
	EndIf

	//cabeçalho
	Aadd(aCabSC,{"C1_NUM" 	 , cC1_NUM})
	Aadd(aCabSC,{"C1_SOLICIT", cC1_SOLICIT})
	Aadd(aCabSC,{"C1_EMISSAO", dC1_EMISSAO}) 
	Aadd(aCabSC,{"C1_CODCOMP", cCODCOMPR  }) 
	Aadd(aCabSC,{"C1_FILENT" , cC1_FILENT }) 

	//Itens
	oItens  := JsonObject():new()
	oItens  := oOBJ:GetJsonObject("ITEM")

	For nIdxItem := 1 To Len(oItens)

		oItens[nIdxItem]:toJSON()
		aLinhaC1 := {}

 		//cC1_OBS := oItens[nIdxItem]:GetJsonText("C1_OBS")
		//If cC1_OBS = Null

		aadd(aLinhaC1,{"C1_ITEM"    ,StrZero(nIdxItem,nTamItem)                    		,Nil})
		aadd(aLinhaC1,{"C1_PRODUTO" ,Alltrim(oItens[nIdxItem]:GetJsonText("C1_PRODUTO")),Nil})
		aadd(aLinhaC1,{"C1_QUANT"   ,Val(oItens[nIdxItem]:GetJsonText("C1_QUANT"))      ,Nil})
		aadd(aLinhaC1,{"C1_CC"      ,oItens[nIdxItem]:GetJsonText("C1_CC")  			,Nil})
		//aadd(aLinhaC1,{"C1_OBS"     ,oItens[nIdxItem]:GetJsonText("C1_OBS")   			,Nil})
		aadd(aLinhaC1,{"C1_CLVL"    ,oItens[nIdxItem]:GetJsonText("C1_CLVL")  			,Nil})
		aadd(aLinhaC1,{"C1_APROV"    ,"L"									  			,Nil})
		aadd(aLinhaC1,{"C1_DATPRF"   ,Ctod(oItens[nIdxItem]:GetJsonText("C1_DATPRF"))   ,Nil}) 
 
		aadd(aItensSC,aLinhaC1)

	Next

	//	ConOut("WSRESTSC -> EXECAUTO SEM RATEIO")
	MSExecAuto({|w,x,y,z| MATA110(w,x,y,,,z)},aCabSC,aItensSC,3)

	CONOUT("PASSEI PELO EXECAUTO - LINHA 149")

	If !lMsErroAuto
		ConfirmSX8()
		cJSON := '{"RETORNO": "OK", "MENSAGEM":"' + cC1_NUM + '"}'
		CONOUT("EXECAUTO NÃO DEU ERRO - LINHA 154")

	Else
		RollBackSX8()
		cJSON := '{"RETORNO": "ERRO", "MENSAGEM":"'
		aErrPCAuto := GETAUTOGRLOG()
		For nAux := 1 to Len(aErrPCAuto)
			cJSON += NoAcento(Alltrim(aErrPCAuto[nAux])) + CRLF
		Next
		cJSON += "USUARIO: "+RetCodUsr()
		cJSON += '"}'
		CONOUT("EXECAUTO DEU ERRO - LINHA 165")
	EndIf

Return(cJSON)

/*
{
    "C1_XFLUIG" : 216,
    "C1_FILENT" : "010001",
    "C1_SOLICIT" : "pedro.ramos",
    "C1_EMISSAO" : "11/12/2023",
    "CCODCOMPR" : "002",
    "ITEM" : [ 
		{
      "C1_PRODUTO" : "GG0000198",
      "C1_QUANT" : "1",
      "C1_CC" : "301001",
      "C1_CLVL" : "010068",
      "C1_DATPRF" : "28/12/2023"
    } 
	]
}
*/
