#include 'Protheus.ch'
/*/{Protheus.doc} PMSAJEMB
Ponto de entrada para integração do PMS com o Item Contábil.
@type function
@version  P12
@author Mateus Ramos
@since 12/19/2023
@Alterado por Washington Miranda Leão
@return variant, boolean
@ Conforme conversado hoje(15-02-24) com o João, Foi solicitado para incluir mais estes campos
@ CTD->CTD_NORMAL := "0" // 0->Nenhum, 1->Despesa,2-Receita
@ CTD->CTD_CLOBRG := "1" // 1->Obrigatório informar a Classe de Valor, 2-> Não é Obrigatório
@ CTD->CTD_ACCLVL := "1" // 1->Permite digitar a classe de valor, 2-> não permite
@CTD->CTD_XCTPMS := "1" // 1->Indica que este Item contábil veio de Projetos(PMS)
@ Foi solicitado para tirar o sinal de ponto(.), na criação do Item contábil.
/*/
User Function PMA110GERA()

Local cItem := "000000" // Faz com ue sempre tenha 6 zeros após o ITem Sintetico ex 1402 fica 140200000
Local nLen  := Len(AllTrim(AF1->AF1_XITCTB)) // Calcula o tamanho do Item contábil

	/* 
	Exemplo de como deverá calcular.
	A nova regra é o seguinte .. Pega o Item sintético e 
	concatena com a sequencia de 6 digitos e somando +1 no ultimo digito.
	Ex:
	1401
	 1401000001
	 1401000002
	 1401000003
	 Se na hora de alterar o orçamento, o usuário escolheu o item contábil sintético 1402,
	 sera concatenado 000001(Sempre somando +1 apos o digito 5)
	 criando o novo item contábil 1402000001 e assim sucessivamente.

   */

     /* Washington Leao. 22-03-2024 
	 Crio a query para verificar qual o maior número do item contabil
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
    Alert("Atenção!Item Sintético não pode ser menor que seis digitos"+cItem)
		
	Endif
	  
	Alert("Sera gerado o Item: " + cItem)

//	U_PMSITCTBPE(AF1->AF1_XITCTB, AF8->AF8_PROJET, AF8->AF8_DESCRI) //Chamada da função passando informação do projeto para criação do
	U_PMSITCTBPE(cItem,AF8->AF8_PROJET ,AF8->AF8_DESCRI) //Chamada da função passando informação do item de classe +Sequencia para criar o item de classe.

//classe sintetica + Item

	//item contábil.
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
	CTD->CTD_BLOQ   := "2" // 2->Item Não Bloqueado, 1->Item Bloqueado
	CTD->CTD_DTEXIS := dDatabase
	CTD->CTD_ITSUP  := CtbItemSup(CTD->CTD_ITEM) // // Função CtbItemSup calcula a item superior
	CTD->CTD_CLOBRG := "1" // 1->Obrigatório informar a Classe de Valor, 2-> Não é Obrigatório
	CTD->CTD_ACCLVL := "1" // 1->Permite digitar a classe de valor, 2-> não permite
	CTD->CTD_XCTPMS := "1" // Controla PMS 1-Sim, 2-Não
	CTD->CTD_XPROJE:= cprojenum // Número do Projeto gravado na tabela AF8->AF8_PROJET
	// CTD->CTD_XCATEG:=
	CTD->(MsUnLock())

Return
