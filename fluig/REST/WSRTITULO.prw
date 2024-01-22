#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'


*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | WSRTITULO  | Autor |                                	   |*
*+------------+------------------------------------------------------------+*
*|Data        | 29.11.2023                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Cadastro de Despesas via REST			 			       |*
*+------------+------------------------------------------------------------+*
*|Solicitante |                                                            |*
*+------------+------------------------------------------------------------+*
*|Partida     | WebService	                                               |*
*+------------+------------------------------------------------------------+*
*|Arquivos    |                                                            |*
*+------------+------------------------------------------------------------+*
*|             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            |*
*+-------------------------------------------------------------------------+*
*| Programador       |   Data   | Motivo da alteracao                      |*
*+-------------------+----------+------------------------------------------+*
*+-------------------+----------+------------------------------------------+*
*****************************************************************************

User Function WSRTITULO()

Return

	WSRESTFUL WSRTITULO DESCRIPTION "Serviço REST para manipulação de WSRTITULO"

		//WSDATA FIL 		As String

		WSMETHOD POST DESCRIPTION "Gravação de Título Financeiro de Despesa" WSSYNTAX "/WSRTITULO || /WSRTITULO/{}"

	END WSRESTFUL


WSMETHOD POST WSRECEIVE CODIGO WSSERVICE WSRTITULO

	Local cJSON    := Self:GetContent() // Pega a string do JSON
	Local aCab	   := {} 
	Local nValor   := 0 
	Local cNum     := ""
	Local cForn    := ""
	Local cLoja    := ""
	Local cCCusto  := ""
	Local cTipo    := "" 
	Local cRet     := ""
	Local cRetSrv  := ""

	Local nx  

	PRIVATE lMsErroAuto := .F.
	Private oJSON       := Nil

	::SetContentType("application/json; charset=UTF-8")

	oJSON := JsonObject():new()
	oJSON:fromJson(cJson)

	If ValType(oJson) == "U"
		::SetResponse('{"erro":{"mensagem": "JSON recebido com problema"}}')
		Return .T.
	ENDIF

	ConOut("WSRTITULO - JSON RECEBIDO: "+cJson)


	cNum     := Alltrim(oJson:GetJsonText("NUMTIT"))
	cParc 	 := Alltrim(oJson:GetJsonText("PARCELA"))
	cForn    := Alltrim(oJson:GetJsonText("FORNEC"))
	cLoja    := Alltrim(oJson:GetJsonText("LOJA"))
	dEmiss 	 := Alltrim(oJson:GetJsonText("EMISSAO"))
	cTipo    := Alltrim(oJson:GetJsonText("TIPO"))
	cPrefix  := Alltrim(oJson:GetJsonText("PREFIXO"))
	dVenc 	 := Alltrim(oJson:GetJsonText("VENCIMENTO"))
	cCCusto  := Alltrim(oJson:GetJsonText("CCUSTO"))
	cNaturez := Alltrim(oJson:GetJsonText("NATUREZA"))
	cClassVl := Alltrim(oJson:GetJsonText("CLASSEVL"))
	cItemCta := Alltrim(oJson:GetJsonText("ITEMCTA"))
	cObs 	 := Alltrim(oJson:GetJsonText("OBSERVACAO"))
	nValor 	 := Val(oJson:GetJsonText("VALOR")) 
	cFluig   := Alltrim(oJson:GetJsonText("FLUIG"))

	

	
	aadd( aCab ,{"E2_PREFIXO" 	, cPrefix		, Nil })
	aadd( aCab ,{"E2_NUM" 		, cNum			, Nil })
	aadd( aCab ,{"E2_FORNECE" 	, cForn			, Nil })
	aadd( aCab ,{"E2_LOJA" 		, cLoja			, Nil })
	aadd( aCab ,{"E2_PARCELA"	, cParc			, Nil })
	aadd( aCab ,{"E2_TIPO" 		, cTipo			, Nil }) 
	Aadd( aCab ,{"E2_CCUSTO"    , cCCusto		, Nil })
	Aadd( aCab ,{"E2_NATUREZ"   , cNaturez 		, Nil })
	Aadd( aCab ,{"E2_CLVL"   	, cClassVl		, Nil })
	Aadd( aCab ,{"E2_ITEMCTA"   , cItemCta		, Nil })
	aadd( aCab ,{"E2_VALOR" 	, nValor		, Nil })
	aadd( aCab ,{"E2_VENCTO" 	, cTod(dVenc)	, Nil }) 
	aadd( aCab ,{"E2_EMISSAO" 	, cTod(dEmiss)	, Nil }) 
	Aadd( aCab ,{"E2_MOEDA"		, 1				, NIL })
	Aadd( aCab ,{"E2_HIST"		, cObs			, NIL })
	Aadd( aCab ,{"E2_XFLUIG"	, cFluig		, NIL })
	//falta criar o campo E2_XFLUIG

	

	lMsErroAuto := .F.

	Begin Transaction

		MSExecAuto({|x,y,z| FINA050(x,y,z)},aCab,,3) //inclusao

		If lMsErroAuto
			DisarmTransaction()
			aErro := GetAutoGRLog( )
			For nx := 1 to Len(aErro)
				cRet += aErro[nx]+CRLF
			Next nx

			MostraErro("\spool\","WSDESPESA.log")
			cRet    := memoread("\spool\WSDESPESA.log")
			cRetSrv := '{"erro":{"mensagem": "'+cRet+'"}}'

		Else
			cRetSrv := '{mensagem: "OK"}'

		Endif

	End Transaction

	::SetResponse(cRetSrv)

Return (.T.)

/* Envelope
{  
   "NUMTIT":"999999999",
   "PARCELA":"1",
   "FORNEC":"A01342",
   "LOJA":"01",
   "EMISSAO":"01/11/2023",
   "TIPO":"NF",
   "PREFIXO":"TST",
   "VENCIMENTO":"31/12/2023",  
   "CCUSTO":"600001",
   "NATUREZA":"30353",     
   "CLASSEVL":"000000001", 
   "ITEMCTA":"0101003003",
   "OBSERVACAO":"TESTE",
   "VALOR": 1000,
   "FLUIG":"XXX"
}
*/
