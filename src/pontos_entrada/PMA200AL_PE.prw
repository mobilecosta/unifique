#include 'Protheus.ch'
/*/{Protheus.doc} PMSAJEMB
Ponto de entrada para integra��o do PMS com o Item Cont�bil.
@type function
@version  P12
@author Mateus Ramos
@since 12/19/2023
@Alterado por Washington Miranda Le�o
@return variant, boolean
@ Conforme conversado hoje(15-02-24) com o Jo�o, Foi solicitado para incluir mais estes campos
@ CTD->CTD_NORMAL := "0" // 0->Nenhum, 1->Despesa,2-Receita
@ CTD->CTD_CLOBRG := "1" // 1->Obrigat�rio informar a Classe de Valor, 2-> N�o � Obrigat�rio
@ CTD->CTD_ACCLVL := "1" // 1->Permite digitar a classe de valor, 2-> n�o permite
@CTD->CTD_XCTPMS := "1" // 1->Indica que este Item cont�bil veio de Projetos(PMS)
@ Foi solicitado para tirar o sinal de ponto(.), na cria��o do Item cont�bil.
/*/
User Function PMA110GERA()

	U_PMSITCTBPE(AF1->AF1_XITCTB, AF8->AF8_PROJET, AF8->AF8_DESCRI) //Chamada da fun��o passando informa��o do projeto para cria��o do

	//item cont�bil.
Return

User Function PMSITCTBPE(cItcta,cProjnum, cProjnom)

	//Abre a tabela CTD
	DbSelectarea("CTD")
	CTD->(DbSetOrder(1))

	If CTD->(DbSeek(XFILIAL("CTD")+Alltrim(cItcta)+Alltrim(cProjnum)))
		RecLock("CTD", .F.)
		CTD->CTD_FILIAL := XFILIAL("CTD")
		CTD->CTD_ITEM   := Alltrim(cItcta)+Alltrim(cProjnum)
		CTD->CTD_CLASSE := "2" // 2->Analitico
		CTD->CTD_NORMAL := "0" // 0->Nenhum, 1->Despesa,2-Receita
		CTD->CTD_DESC01 := cProjnom
		CTD->CTD_BLOQ   := "2" // 2->Item N�o Bloqueado, 1->Item Bloqueado
		CTD->CTD_DTEXIS := dDatabase
		CTD->CTD_ITSUP  := CtbItemSup(CTD->CTD_ITEM) // // Fun��o CtbItemSup calcula a item superior
		CTD->CTD_CLOBRG := "1" // 1->Obrigat�rio informar a Classe de Valor, 2-> N�o � Obrigat�rio
        CTD->CTD_ACCLVL := "1" // 1->Permite digitar a classe de valor, 2-> n�o permite
        CTD->CTD_XCTPMS := "1" // Controla PMS 1-Sim, 2-N�o
		
		CTD->(MsUnLock())
	Else
		RecLock("CTD", .T.)
		CTD->CTD_FILIAL := XFILIAL("CTD")
		CTD->CTD_ITEM   := Alltrim(cItcta)+Alltrim(cProjnum)
		CTD->CTD_CLASSE := "2" // 2->Analitico
		CTD->CTD_NORMAL := "0" // 0->Nenhum, 1->Despesa,2-Receita
		CTD->CTD_DESC01 := cProjnom
		CTD->CTD_BLOQ   := "2" // 2->Item N�o Bloqueado, 1->Item Bloqueado
		CTD->CTD_DTEXIS := dDatabase
		CTD->CTD_ITSUP  := CtbItemSup(CTD->CTD_ITEM) // // Fun��o CtbItemSup calcula a item superior
		CTD->CTD_CLOBRG := "1" // 1->Obrigat�rio informar a Classe de Valor, 2-> N�o � Obrigat�rio
        CTD->CTD_ACCLVL := "1" // 1->Permite digitar a classe de valor, 2-> n�o permite
        CTD->CTD_XCTPMS := "1" // Controla PMS 1-Sim, 2-N�o
		
		CTD->(MsUnLock())
	EndIf

Return
