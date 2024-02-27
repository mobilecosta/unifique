#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'


*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | WSEMPENHO  | Autor | Jader Berto                     	   |*
*+------------+------------------------------------------------------------+*
*|Data        | 03.12.2023                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Empenho do valor de Orçamento via REST                     |*
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

User Function WSEMPENHO()
Return
	
WSRESTFUL WSEMPENHO DESCRIPTION "Empenho do valor de Orçamento"

WSMETHOD POST DESCRIPTION "Empenho do valor de Orçamento na URL" WSSYNTAX "/WSEMPENHO || /WSEMPENHO/{}"

END WSRESTFUL





WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE WSEMPENHO
Local cJSON    
Local oOBJ
Local cError   := ""
Local bError   := ErrorBlock({ |oError| cError := oError:Description})
Local ret
Local cCodOrc
Local lDelEmp
Local xRet
Private cCo     
Private cOper   
Private cCc     
Private cClVl   
Private cUniOrc 
Private cEnt06

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
		lDelEmp   := oOBJ:GetJsonObject("delempenho")
		
        If !Empty(cError)
            ::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
            Return .T.
        endif

			
		DbSelectArea( 'AF1' )
		AF1->( DbSetOrder( 1 ) )

		DbSelectArea( 'AF5' )
		AF5->( DbSetOrder( 1 ) )
		
		


		If AF1->(DbSeek( xFilial("AF1") + cCodOrc ))

			AF5->(DbSeek( xFilial("AF5") + cCodOrc ))


			cCo     := '60000008'
			cOper   := '6'
			cCc     := oOBJ:GetJsonObject("centrodecusto")
			cClVl   := '010005'
			cUniOrc := '010001'
			cEnt06  := '000001'

			xRet := pcoIniLan( '900001', .T. )

			Begin Transaction

				xRet := pcoDetLan( '900001', '01', procName(), .T. )

				If !lDelEmp //Somente na Inclusão

					xRet := pcoVldLan( '900001', '01', procName()  )

					xRet := pcoDetLan( '900001', '01', procName(), .F. )
				
				EndIf

			End Transaction

			xRet := pcoFinLan( '900001' )

	
			//Rotina de Gravação AQUI
			::SetResponse('{"retorno":"OK"}')
			Return(.T.)
	
		else
				
			//Rotina de Gravação AQUI
			::SetResponse('{"retorno":"Orçamento não encontrado."}')
			Return(.T.)
		
		
		EndIf
		
	
End Sequence


 
//Restaurando bloco de erro do sistema
ErrorBlock(bError)

FreeObj(oOBJ)

Return(.T.)
//Abaixo criei esta função para testar (Washington Leao-26-02-2024)
User Function TsEmpenho(cCodOrc, lDelEmp)

	DbSelectArea( 'AF1' )
	AF1->( DbSetOrder( 1 ) )

	DbSelectArea( 'AF5' )
	AF5->( DbSetOrder( 1 ) )
		
	If AF1->(DbSeek( xFilial("AF1") + cCodOrc ))

		AF5->(DbSeek( xFilial("AF5") + cCodOrc ))

		cCo     := GetMv("FS_XCOORCA")
		cOper   := '6'
		cCc     := AF1->AF1_XCC
		cClVl   := AF1->AF1_XCLVLR
		cUniOrc := '010001'
		cEnt06  := '000001'

		xRet := pcoIniLan( '900001', .T. )

		Begin Transaction

			xRet := pcoDetLan( '900001', '01', procName(), .T. )

			If !lDelEmp //Somente na Inclusão

				xRet := pcoVldLan( '900001', '01', procName()  )

				xRet := pcoDetLan( '900001', '01', procName(), .F. )
			
			EndIf

		End Transaction

		xRet := pcoFinLan( '900001' )

		Alert("Ponto de lancamento executado")
	else
			
		//Rotina de Gravação AQUI
		Alert("Orçamento não encontrado.")
	EndIf

Return
