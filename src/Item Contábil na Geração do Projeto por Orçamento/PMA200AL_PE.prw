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

Local cItem := "000000" // Faz com ue sempre tenha 6 zeros ap�s o ITem Sintetico ex 1402 fica 140200000
Local nLen  := Len(AllTrim(AF1->AF1_XITCTB)) // Calcula o tamanho do Item cont�bil

	/* 
	Exemplo de como dever� calcular.
	A nova regra � o seguinte .. Pega o Item sint�tico e 
	concatena com a sequencia de 6 digitos e somando +1 no ultimo digito.
	Ex:
	1401
	 1401000001
	 1401000002
	 1401000003
	 Se na hora de alterar o or�amento, o usu�rio escolheu o item cont�bil sint�tico 1402,
	 sera concatenado 000001(Sempre somando +1 apos o digito 5)
	 criando o novo item cont�bil 1402000001 e assim sucessivamente.

   */

     /* Washington Leao. 22-03-2024 
	 Crio a query para verificar qual o maior n�mero do item contabil
       Exemplo de registros gravados na tabela CTD                                 
     */

	BeginSQL Alias "QRYCTD"
	   SELECT MAX(CTD_ITEM) AS CTD_ITEM
		 FROM %Table:CTD% CTD
	    WHERE CTD_FILIAL = %xfilial:CTD% 
		  AND SUBSTRING(CTD_ITEM, 1, %Exp:nLen%) = %Exp:AllTrim(AF1->AF1_XITCTB)%
		  AND %NotDel%	
   EndSQL

	// 1401000003

	IF ! Empty(QRYCTD->CTD_ITEM) .And. AllTrim(AF1->AF1_XITCTB) <> AllTrim(QRYCTD->CTD_ITEM)
		cItem := AllTrim(Subs(QRYCTD->CTD_ITEM, Len(AllTrim(AF1->AF1_XITCTB)) + 1, Len(QRYCTD->CTD_ITEM)))
	EndIf
	cItem := Soma1(cItem)
    cItem := AllTrim(AF1->AF1_XITCTB)+cItem
	
	QRYCTD->(DbCloseArea())
    if(len(AF1->AF1_XITCTB))<=5
    Alert("Aten��o!Item Sint�tico n�o pode ser menor que seis digitos"+cItem)
		
	Endif
	  
	Alert("Sera gerado o Item: " + cItem)

//	U_PMSITCTBPE(AF1->AF1_XITCTB, AF8->AF8_PROJET, AF8->AF8_DESCRI) //Chamada da fun��o passando informa��o do projeto para cria��o do
	U_PMSITCTBPE(cItem,AF8->AF8_PROJET ,AF8->AF8_DESCRI) //Chamada da fun��o passando informa��o do item de classe +Sequencia para criar o item de classe.

//classe sintetica + Item

	//item cont�bil.
Return

User Function PMSITCTBPE(cItcta,cprojenum,cProjnom)

	//Abre a tabela CTD
	DbSelectarea("CTD")
	CTD->(DbSetOrder(1))

	If CTD->(DbSeek(XFILIAL("CTD")+Alltrim(cItcta)))
		RecLock("CTD", .F.)
	Else
		RecLock("CTD", .T.)
	EndIf
	CTD->CTD_FILIAL := XFILIAL("CTD")
	CTD->CTD_ITEM   := Alltrim(cItcta)
	CTD->CTD_CLASSE := "2" // 2->Analitico
	CTD->CTD_NORMAL := "0" // 0->Nenhum, 1->Despesa,2-Receita
	CTD->CTD_DESC01 := cProjnom
	CTD->CTD_BLOQ   := "2" // 2->Item N�o Bloqueado, 1->Item Bloqueado
	CTD->CTD_DTEXIS := dDatabase
	CTD->CTD_ITSUP  := CtbItemSup(CTD->CTD_ITEM) // // Fun��o CtbItemSup calcula a item superior
	CTD->CTD_CLOBRG := "1" // 1->Obrigat�rio informar a Classe de Valor, 2-> N�o � Obrigat�rio
	CTD->CTD_ACCLVL := "1" // 1->Permite digitar a classe de valor, 2-> n�o permite
	CTD->CTD_XCTPMS := "1" // Controla PMS 1-Sim, 2-N�o
	CTD->CTD_XPROJE:= cprojenum // N�mero do Projeto gravado na tabela AF8->AF8_PROJET
	// CTD->CTD_XCATEG:=
	CTD->(MsUnLock())

Return
