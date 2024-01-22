#Include "protheus.ch"
#Include "TOTVS.CH"
#Include "TopConn.CH"
#INCLUDE "TBICONN.CH"
#Include 'parmtype.ch'
#Include 'RestFul.ch'

*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | WFFluig  | Autor | Jader Berto                      	   |*
*+------------+------------------------------------------------------------+*
*|Data        | 09.12.2023                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Classe para Criar/Movimentar processo no Fluig             |*
*+------------+------------------------------------------------------------+*
*|Solicitante |                                                            |*
*+------------+------------------------------------------------------------+*
*|Partida     | WFFluig 	                                               |*
*+------------+------------------------------------------------------------+*
*|Arquivos    |                                                            |*
*+------------+------------------------------------------------------------+*
*|             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            |*
*+-------------------------------------------------------------------------+*
*| Programador       |   Data   | Motivo da alteracao                      |*
*+-------------------+----------+------------------------------------------+*
*|                   |          |                                          |*
*+-------------------+----------+------------------------------------------+*
*****************************************************************************

CLASS WFFluig
	
	DATA cEndFluig 
	DATA cToken	  
	DATA cConsKey 
	DATA cCSecret 
	DATA cAToken
	DATA cTSecret



	METHOD New() CONSTRUCTOR
	METHOD START(cProcess, cAtivId, cComment ) 
    METHOD MOVE(cProcess, cIdFluig, cState) 

ENDCLASS



//-----------------------------------------------------------------
METHOD New() CLASS WFFluig


Return Self



//Metodo para iniciar um Fluxo no Fluig
METHOD START(cProcess, cAtivId, cTokApp, cComment) Class WFFluig
Local cIdFluig
Local oClientFluig
Local jBody
Local oRet
Local cResp := UsrRetName(RetCodUsr())

    cEndFluig  := Alltrim(SuperGetMV("MV_SRFLUIG",.F.,'http://10.252.15.2:8080'))
    cConsKey   := Alltrim(SuperGetMV("MV_XCKEY"  ,.F.,'AceitaCaixinhaUnifique'))
    cCSecret   := Alltrim(SuperGetMV("MV_XCSECRE",.F.,'Caixinha foi aceita'))	
    cAToken	   := Alltrim(SuperGetMV("MV_XATOKEN",.F.,'47eb811d-1ed0-458f-bde0-396a6f2fa042'))	
    cTSecret   := Alltrim(SuperGetMV("MV_XTSECRE",.F.,'50791173-24bd-4fb4-93e6-943893db1aed87ca6271-1bde-4d86-a6ea-9245f8ecbb3d'))


    cURL := cEndFluig + "/process-management/api/v2/processes/"+cProcess+"/start"


    oClientFluig := FWoAuth1Fluig():New(cConsKey, cCSecret, cEndFluig,  "")
    oClientFluig:cSecretToken   := cTSecret
    oClientFluig:cToken         := cAToken


    jBody := JsonObject():New()
    jBody["targetState"]       := cAtivId
    jBody["targetAssignee"]    := cTokApp
    jBody["comment"]           := cComment
    
    cResult := oClientFluig:post(cURL, "", jBody:toJson(), , @cResp, .t.)

    fwJsonDeserialize(cResult, @oRet)
    
    cIdFluig := cValToChar(oRet:processInstanceId)

Return cIdFluig






//Metodo para iniciar um Fluxo no Fluig
METHOD MOVE(cProcess, cTokApp, cIdFluig, cState, oObjForm) Class WFFluig
Local cIdFluig
Local oClientFluig
Local jBody
Local oRet
Local lRet  := .F.
Local cResp := UsrRetName(RetCodUsr())

    cEndFluig  := Alltrim(SuperGetMV("MV_SRFLUIG",.F.,'http://10.252.15.2:8080'))
    //cToken	   := Alltrim(SuperGetMV("MV_SRTOKEN",.F.,'tokenunifique'))	
    cConsKey   := Alltrim(SuperGetMV("MV_XCKEY"  ,.F.,'AceitaCaixinhaUnifique'))
    cCSecret   := Alltrim(SuperGetMV("MV_XCSECRE",.F.,'Caixinha foi aceita'))	
    cAToken	   := Alltrim(SuperGetMV("MV_XATOKEN",.F.,'47eb811d-1ed0-458f-bde0-396a6f2fa042'))	
    cTSecret   := Alltrim(SuperGetMV("MV_XTSECRE",.F.,'50791173-24bd-4fb4-93e6-943893db1aed87ca6271-1bde-4d86-a6ea-9245f8ecbb3d'))

    cURL := cEndFluig + "/process-management/api/v2/requests/"+cIdFluig+"/move"


    oClientFluig := FWoAuth1Fluig():New(cConsKey, cCSecret, cEndFluig,  "")
    oClientFluig:cSecretToken   := cTSecret
    oClientFluig:cToken         := cAToken


    jBody := JsonObject():New()
    jBody["targetState"]           := cState
    jBody["subProcessTargetState"] := 0
    jBody["assignee"]              := cTokApp
    jBody["asManager"]             := .F.

    If Type("oObjForm") == "U"
        jBody["formFields"] := oObjForm
    EndIf
     
    cResult := oClientFluig:post(cURL, "", jBody:toJson(), , @cResp, .t.)

    fwJsonDeserialize(cResult, @oRet)
    
    If "nextState" $ cResult
        lRet := cValToChar(oRet:nextState) == cState
    else
        Help('',1,'Erro no Fluig',,fTraduz(oRet:message),1,0)
    EndIf

Return lRet



Static Function fTraduz(cText)
Local cRet := ""
Local cURL := ""
Local cJson      := ""
Local cGetParms  := ""
Local cHeaderGet := ""
Local nTimeOut   := 500
Local aHeadStr   := {"Content-Type: application/json"}
Local oObjJson   := Nil
Local cLingIN    := "EN"
Local cLingOUT   := "PT"


	cText := Replace(Replace(cText," ","%20"),CHR(10),"%20")
	cURL := "https://translation.googleapis.com/language/translate/v2?q="+cText+"&target="+cLingOUT+"&source="+cLingIN+"&key=AIzaSyBbafUjQWu-4Ny3GV8cCQxV1tszxm_bD5M"


	//Utiliza HTTPGET para retornar os dados da Receita Federal
	cJson := HttpGet(cURL, cGetParms, nTimeOut, aHeadStr, @cHeaderGet )
	
	memowrite("\chatbot\returno_traducao.json", cJson)

	//Transformando a string JSON em Objeto
	If FWJsonDeserialize(cJson,@oObjJson)

		/*
		If oObjJson:responseStatus == 200

			cRet := oObjJson:RESPONSEDATA:translatedText

		EndIf
		*/

		cRet := oObjJson:data:translations[1]:translatedText

	EndIf

	If Empty(cRet)
		cRet := cText
	EndIf

	cRet := DecodeUTF8(cRet)
	
Return cRet
