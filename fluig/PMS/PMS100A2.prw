#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'

*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | PMA110GERA  | Autor | Jader Berto                      	   |*
*+------------+------------------------------------------------------------+*
*|Data        | 07.12.2023                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Ponto de Entrada na Alteração de Fase do Orçamentos        |*
*+------------+------------------------------------------------------------+*
*|Solicitante |                                                            |*
*+------------+------------------------------------------------------------+*
*|Partida     | PMSA100 	                                               |*
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

User Function PMS100A2 ()
Local oFluig
Local IdFluig := ""
Local lRet	  := .F.
Local jForm
Local nTotal  := 0
Local aArea   := GetArea()

	DbSelectArea("AF1")
	AF1->(DbSetOrder(1))

	DbSelectArea("AF2")
	AF2->(DbSetOrder(1))

    If AF1->AF1_FASE == "05"

		If AF2->(DbSeek(xFilial("AF2") + AF1->AF1_ORCAME))
			While AF2->(!EOF()) .AND. AF2->AF2_FILIAL = AF1->AF1_FILIAL .AND. AF2->AF2_ORCAME = AF1->AF1_ORCAME

				nTotal += AF2->AF2_TOTAL

			AF2->(DbSkip())
			End

			Reclock("AF1", .F.)
				AF1->AF1_XVALOR := nTotal
			AF1->(MsUnlock())
		else
			RestArea(aArea)
			Help('',1,'Erro de estrutura',,"Estrutura do Orçamento não encontrada.",1,0)
			Return lRet
		End
		oFluig := WFFluig():New()
		
		//Cria Fluxo		
		IdFluig :=	Alltrim(AF1->AF1_XFLUIG)		// oFluig:START("wf_solicitacao_de_projeto", "204", "admin", "Iniciado Pelo Protheus")


		//---Instrução necessária somente quando precisar enviar alguma informação
		jForm := JsonObject():New()
		jForm["statusorcamento"] := AF1->AF1_FASE
		jForm["valorOrcamento"]  := nTotal
		//----------------------------------------------------------------------


		//Altera Status do Fluxo
		lRet := oFluig:MOVE("wf_solicitacao_de_projeto", "tokenunifique", IdFluig, "19", jForm)


    EndIf

	RestArea(aArea)

Return lRet


