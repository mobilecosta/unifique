#include 'Protheus.ch'
/*/{Protheus.doc} PMSAJEMB
Ponto de entrada para integra��o do PMS com o Item Cont�bil.
@type function
@version  P12
@author Washington Miranda Le�o
@since 23/02/2024
@Alterado por Washington Miranda Le�o
@return variant, boolean
@ Conforme conversado hoje(15-02-24) com o Jo�o, Foi solicitado para incluir mais estes campos
@ CTD->CTD_NORMAL := "0" // 0->Nenhum, 1->Despesa,2-Receita
@ CTD->CTD_CLOBRG := "1" // 1->Obrigat�rio informar a Classe de Valor, 2-> N�o � Obrigat�rio
@ CTD->CTD_ACCLVL := "1" // 1->Permite digitar a classe de valor, 2-> n�o permite
@CTD->CTD_XCTPMS := "1" // 1->Indica que este Item cont�bil veio de Projetos(PMS)
@ Foi solicitado para tirar o sinal de ponto(.), na cria��o do Item cont�bil.
@CTD->CTD_XPROJE:= cprojenum // N�mero do Projeto gravado na tabela AF8->AF8_PROJET
@CTD->CTD_XCATEG:= cCTD_XCATEG // Codigo da Categoria do Projeto 1-CRIACAO, 2-MANUTEN��O
@ A regra pra gravar a categoria quando � gerado o Item cont�bil sint�tico de 6 digitos �.
@ O operador do Sistema ir� sempre cadastrar a categoria, somente no it�m cont�bil de 6 digitos(110102) e
@ quando for gerado o novo it�m cont�bil de 12 digitos a partir deste de 6 digitos(110102), ser� copiado o c�digo da categoria
@ para o novo item de 12 digitos. Ex: 110102->Categoria igual a 1-Cria��o, quando for gerado o item cont�bil de 12 digitos,
@ apartir deste de 6 digitos 110102, o sistema busca o c�digo de cria��o, que foi previamente cadastrado,
@ pelo usu�rio do sistema.

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
	 140100000001
	 140100000002
	 140100000003
	 Se na hora de alterar o or�amento, o usu�rio escolheu o item cont�bil sint�tico 1402,
	 sera concatenado 000001(Sempre somando +1 apos o digito 5)
	 criando o novo item cont�bil 140200000001 e assim sucessivamente.

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

	

	IF ! Empty(QRYCTD->CTD_ITEM) .And. AllTrim(AF1->AF1_XITCTB) <> AllTrim(QRYCTD->CTD_ITEM)
		cItem := AllTrim(Subs(QRYCTD->CTD_ITEM, Len(AllTrim(AF1->AF1_XITCTB)) + 1, Len(QRYCTD->CTD_ITEM)))
	EndIf
	cItem := Soma1(cItem)
    cItem := AllTrim(AF1->AF1_XITCTB)+cItem
	
	QRYCTD->(DbCloseArea())
    if(len(AF1->AF1_XITCTB))<=5
    	Alert("Aten��o!Item Sint�tico n�o pode ser menor que seis digitos"+cItem)
	Endif
	  
	Alert("Sera gerado o Item: " + cItem) //Mostro o n�mero do Item cont�bil com 12 digitos 


	U_PMSITCTBPE(cItem,AF8->AF8_PROJET ,AF8->AF8_DESCRI, AF1->AF1_XITCTB)  //Chamada da fun��o passando informa��es do 
	                                                                      // item j� somando+1,c�digo do projeto,descri��o,  
                                                                         // e item cont�bil gravado na tabela AF1->AF1_XITCTB



Return

User Function PMSITCTBPE(cItcta,cprojenum,cProjnom, cAF1_XITCTB)

Local cCTD_XCATEG := "" // Crio uma v�riavel local para gravar o c�digo da categoria 1-Cria��o, 2-Manuten��o

	//Abre a tabela CTD
	DbSelectarea("CTD")
	CTD->(DbSetOrder(1)) // Seto a ordem 1 desta tabela (Veja na tabela SIdex a ordem)
	If CTD->(DbSeek(XFILIAL("CTD")+cAF1_XITCTB)) // Desto se foi encontrado
		cCTD_XCATEG := CTD->CTD_XCATEG // Se foi encontrado gravado em memoria  
		                               // o cont�udo do campo CTD->CTD_XCATEG na vari�vel cCTD->XCATEG
	EndIF  // Fecho a condi��o do If.

	If CTD->(DbSeek(XFILIAL("CTD")+Alltrim(cItcta))) // Se achou, verifico se � 
		RecLock("CTD", .F.)                          // altera��o ou inclus�o
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
	CTD->CTD_XCATEG:= cCTD_XCATEG
	CTD->(MsUnLock())

Return
