#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'


*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | WSALTORC  | Autor | Jader Berto                     	   |*
*+------------+------------------------------------------------------------+*
*|Data        | 03.12.2023                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Devolve Valor Empenhado/Status Orçamento Cancelado via REST|*
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

User Function WSALTORC()
Return
	
WSRESTFUL WSALTORC DESCRIPTION "Devolve Valor Empenhado/ Status Orçamento Cancelado"

WSMETHOD POST DESCRIPTION "Devolve Valor Empenhado/ Status Orçamento Cancelado na URL" WSSYNTAX "/WSALTORC || /WSALTORC/{}"

END WSRESTFUL





WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE WSALTORC
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
			Return .T.
		endif

		

		cCodOrc	  := oOBJ:GetJsonObject("codorc")
		cStatus	  := oOBJ:GetJsonObject("status")
		
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
					If (cStatus $ ("EM_APROVACAO, CANCELADO, APROVADO"))
	            		If !Empty(cError)
							::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
							Return .T.
						Else
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



FreeObj(oOBJ)

Return(.T.)

