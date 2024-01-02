#include 'Protheus.ch'
/*/{Protheus.doc} PMSAJEMB
Ponto de entrada para integração do PMS com o Item Contábil.
@type function
@version  P12
@author Mateus Ramos
@since 12/19/2023
@return variant, boolean
/*/
User Function PMA110GERA()

	U_PMSITCTBPE(AF1->AF1_XITCTB, AF8->AF8_PROJET, AF8->AF8_DESCRI) //Chamada da função passando informação do projeto para criação do
	//item contábil.
Return

User Function PMSITCTBPE(cItcta,cProjnum, cProjnom)

	//Abre a tabela CTD
	DbSelectarea("CTD")
	CTD->(DbSetOrder(1))

	If CTD->(DbSeek(XFILIAL("CTD")+Alltrim(cItcta)+'.'+Alltrim(cProjnum)))
		RecLock("CTD", .F.)
		CTD->CTD_FILIAL := XFILIAL("CTD")
		CTD->CTD_ITEM   := cItcta+cProjnum
		CTD->CTD_DESC01 := cProjnom
		CTD->CTD_CLASSE := "2"
		//CTD->CTD_NORMAL := "0"
		CTD->CTD_BLOQ   := "2"
		CTD->CTD_DTEXIS := dDatabase
		CTD->(MsUnLock())
	Else
		RecLock("CTD", .T.)
		CTD->CTD_FILIAL := XFILIAL("CTD")
		CTD->CTD_ITEM   := Alltrim(cItcta)+'.'+Alltrim(cProjnum)
		CTD->CTD_DESC01 := cProjnom
		CTD->CTD_CLASSE := "2"
		//CTD->CTD_NORMAL := "0"
		CTD->CTD_BLOQ   := "2"
		CTD->CTD_DTEXIS := dDatabase
		CTD->(MsUnLock())
	EndIf

Return
