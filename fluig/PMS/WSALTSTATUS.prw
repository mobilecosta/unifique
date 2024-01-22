#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'


*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | WSALTSTATUS  | Autor | Jader Berto                     	   |*
*+------------+------------------------------------------------------------+*
*|Data        | 03.12.2023                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Alteração de Status via REST 			 			       |*
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

User Function WSALTSTATUS()
Return
	
WSRESTFUL WSALTSTATUS DESCRIPTION "Alteração de Status"

WSMETHOD POST DESCRIPTION "Alteração de Status na URL" WSSYNTAX "/WSALTSTATUS || /WSALTSTATUS/{}"

END WSRESTFUL





WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE WSALTSTATUS
Local cJSON    
Local oOBJ
Local cError   := ""
Local bError   := ErrorBlock({ |oError| cError := oError:Description})
Local ret
Local cCodOrc
Local cStatus


//Inicio a utilização da tentativa
Begin Sequence

	::SetContentType("application/json; charset=iso-8859-1")
	
		cJSON    := DecodeUTF8(Self:GetContent())

		// –> Deserializa a string JSON
		oOBJ := JsonObject():new()

		ret := oOBJ:fromJson(cJSON)

		If !Empty(cError)
			::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
			RpcClearEnv()
			Return .T.
		endif

				
		cCodOrc	  := oOBJ:GetJsonObject("codorc")
		cStatus   := oOBJ:GetJsonObject("status")
		
        If !Empty(cError)
            ::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
            Return .T.
        Else
            //Rotina de Gravação AQUI
			
			DbSelectArea("AF1")
			AF1->(DbSetOrder(1))

			If AF1->(DbSeek(xFilial("AF1") + cCodOrc))
					
				If !Empty(cError)
					::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
					Return .T.
				Else
					If (cStatus $ ("EM_ATUALIZACAO, CANCELADO, APROVADO, EM_APROVACAO"))
	            		If !Empty(cError)
							::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
							Return .T.
						Else
							If cStatus == "EM_ATUALIZACAO"
							   cStatus := "01"
							ElseIf cStatus == "APROVADO"
							   cStatus := "02"
							ElseIf cStatus == "CANCELADO"
							   cStatus := "03"
							ElseIf cStatus == "EM_APROVACAO"
							   cStatus := "05"
							EndIf
							Reclock("AF1", .F.)
								AF1->AF1_FASE   := cStatus
							AF1->(MsUnlock())
							::SetResponse('{"retorno":"OK"}')
						EndIf
					else
						::SetResponse('{"retorno":"Status incorreto. Apenas EM_APROVACAO, CANCELADO ou APROVADO."}')
						Return .T.					
					EndIf
				EndIf

			else
            	::SetResponse('{"retorno":"Orçamento não encontrado."}')
            	Return .T.				
			EndIf

        EndIf

	
End Sequence


 
//Restaurando bloco de erro do sistema
ErrorBlock(bError)

RpcClearEnv()


FreeObj(oOBJ)

Return(.T.)

