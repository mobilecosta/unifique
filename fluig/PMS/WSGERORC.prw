#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'


*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | WSGERORC  | Autor | Jader Berto                      	   |*
*+------------+------------------------------------------------------------+*
*|Data        | 03.12.2023                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Orçamento via REST      				 			       |*
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
*|                   |          |                                          |*
*+-------------------+----------+------------------------------------------+*
*****************************************************************************

User Function WSGERORC()
Return
	
WSRESTFUL WSGERORC DESCRIPTION "Geração de Orçamentos"

WSMETHOD POST DESCRIPTION "Geração de Orçamentos na URL" WSSYNTAX "/WSGERORC || /WSGERORC/{}"

END WSRESTFUL





WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE WSGERORC
Local cJSON    
Local oOBJ
Local cError   := ""
Local bError   := ErrorBlock({ |oError| cError := oError:Description})
Local ret
Local cCODMUN
Local cDecri
Local cProjeto
Local cSolicit
Local cNumOrc
Local cFluig
Local cCCusto


//Inicio a utilização da tentativa
Begin Sequence

	::SetContentType("application/json; charset=iso-8859-1")
	
		cJSON    := DecodeUTF8(Self:GetContent())

		// –> Deserializa a string JSON
		oOBJ := JsonObject():new()

		ret := oOBJ:fromJson(cJSON)

		If !Empty(cError)
			::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
			Return .T.
		endif

		
	
				
		//cCCUSTO	   := oOBJ:GetJsonObject("ccusto")
		cCODMUN    := oOBJ:GetJsonObject("codmun")
		//cOBS	   := oOBJ:GetJsonObject("obs")
		//dDTAPROV   := CTOD(oOBJ:GetJsonObject("dtaprov"))
		cDecri	   := oOBJ:GetJsonObject("descricao")
		cProjeto   := oOBJ:GetJsonObject("projeto")
		cSolicit   := oOBJ:GetJsonObject("solicitante")
		cFluig	   := oOBJ:GetJsonObject("idfluig")
		cCCusto    := oOBJ:GetJsonObject("centrodecusto")
		
		If !Empty(cError)
			::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
			Return .T.
		Else
			//Rotina de Gravação AQUI
			DbSelectArea("CC2")
			CC2->(DbSetOrder(1))

			If CC2->(DbSeek(xFilial("CC2") + cCODMUN))

				DbSelectArea("AF1")
				AF1->(DbSetOrder(1))

				DbSelectArea("AF5")
				AF5->(DbSetOrder(1))

				cNumOrc := GetSxeNum("AF1", "AF1_ORCAME")
				Reclock("AF1", .T.)
					AF1->AF1_ORCAME := cNumOrc
					AF1->AF1_VERSAO := "001"
					AF1->AF1_DESCRI := cDecri
					AF1->AF1_XCMUN  := CC2->CC2_CODMUN'
					AF1->AF1_XMUN	:= CC2->CC2_MUN
					AF1->AF1_XUF    := CC2->CC2_EST
					AF1->AF1_DATA   := Date()
					AF1->AF1_NOMPRJ := cProjeto		 
					AF1->AF1_FASE   := "01"
					AF1->AF1_TPORC  := "0001"
					AF1->AF1_MASCAR := "2222222222"
					AF1->AF1_TRUNCA := "1"
					AF1->AF1_RECALC := "2"
					AF1->AF1_AUTCUS := "1"
					AF1->AF1_CTRUSR := "2"
					AF1->AF1_ENTIDA := "1"
					AF1->AF1_XTALC  := "1"
					AF1->AF1_XRESPO := cSolicit
					AF1->AF1_XFLUIG := cFluig
					AF1->AF1_XCC	:= cCCusto
					

					AF1->(ConfirmSx8())
				AF1->(MsUnlock())

				Reclock("AF5", .T.)
					AF5->AF5_ORCAME := cNumOrc
					AF5->AF5_EDT 	:= cNumOrc
					AF5->AF5_NIVEL  := "001"
					AF5->AF5_DESCRI := cDecri
					AF5->AF5_UM		:= "UN"
					AF5->AF5_QUANT  := 1
					AF5->AF5_VERSAO := "001"
				AF5->(MsUnlock())

				If !Empty(cError)
					::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
					Return .T.
				Else
					::SetResponse('{"retorno":"OK", "orcamento":"'+cNumOrc+'"}')
				EndIf

			else
				::SetResponse('{"retorno":"Código de Município '+cCODMUN+' não identificado."}')
				Return .T.				
			EndIf

		EndIf

	
End Sequence


 
//Restaurando bloco de erro do sistema
ErrorBlock(bError)

RpcClearEnv()


FreeObj(oOBJ)

Return(.T.)



User Function XVLDORC()
Local lRet := .T.

	If M->AF1_FASE # "05"
		HELP( " ",1,"Permitido apenas alterar para EM APROVAÇÃO." )
		lRet := .F.
	EndIf

Return lRet
