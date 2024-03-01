#include 'Protheus.ch'
/*/{Protheus.doc} PMSAJEMB
Ponto de entrada para integração do PMS com o Item Contábil.
@type function
@version  P12
@author Washington Miranda Leão
@since 23/02/2024
@Alterado por Washington Miranda Leão
@return variant, boolean
@ Conforme conversado hoje(15-02-24) com o João, Foi solicitado para incluir mais estes campos
@ CTD->CTD_NORMAL := "0" // 0->Nenhum, 1->Despesa,2-Receita
@ CTD->CTD_CLOBRG := "1" // 1->Obrigatório informar a Classe de Valor, 2-> Não é Obrigatório
@ CTD->CTD_ACCLVL := "1" // 1->Permite digitar a classe de valor, 2-> não permite
@CTD->CTD_XCTPMS := "1" // 1->Indica que este Item contábil veio de Projetos(PMS)
@ Foi solicitado para tirar o sinal de ponto(.), na criação do Item contábil.
@CTD->CTD_XPROJE:= cprojenum // Número do Projeto gravado na tabela AF8->AF8_PROJET
@CTD->CTD_XCATEG:= cCTD_XCATEG // Codigo da Categoria do Projeto 1-CRIACAO, 2-MANUTENÇÃO
@ A regra pra gravar a categoria quando é gerado o Item contábil sintético de 6 digitos é.
@ O operador do Sistema irá sempre cadastrar a categoria, somente no itém contábil de 6 digitos(110102) e
@ quando for gerado o novo itém contábil de 12 digitos a partir deste de 6 digitos(110102), será copiado o código da categoria
@ para o novo item de 12 digitos. Ex: 110102->Categoria igual a 1-Criação, quando for gerado o item contábil de 12 digitos,
@ apartir deste de 6 digitos 110102, o sistema busca o código de criação, que foi previamente cadastrado,
@ pelo usuário do sistema.

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
	 140100000001
	 140100000002
	 140100000003
	 Se na hora de alterar o orçamento, o usuário escolheu o item contábil sintético 1402,
	 sera concatenado 000001(Sempre somando +1 apos o digito 5)
	 criando o novo item contábil 140200000001 e assim sucessivamente.

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

	

	IF ! Empty(QRYCTD->CTD_ITEM) .And. AllTrim(AF1->AF1_XITCTB) <> AllTrim(QRYCTD->CTD_ITEM)
		cItem := AllTrim(Subs(QRYCTD->CTD_ITEM, Len(AllTrim(AF1->AF1_XITCTB)) + 1, Len(QRYCTD->CTD_ITEM)))
	EndIf
	cItem := Soma1(cItem)
    cItem := AllTrim(AF1->AF1_XITCTB)+cItem
	
	QRYCTD->(DbCloseArea())
    if(len(AF1->AF1_XITCTB))<=5
    	Alert("Atenção!Item Sintético não pode ser menor que seis digitos"+cItem)
	Endif
	  
	Alert("Sera gerado o Item: " + cItem) //Mostro o número do Item contábil com 12 digitos 


	U_PMSITCTBPE(cItem,AF8->AF8_PROJET ,AF8->AF8_DESCRI, AF1->AF1_XITCTB)  //Chamada da função passando informações do 
	                                                                      // item já somando+1,código do projeto,descrição,  
                                                                         // e item contábil gravado na tabela AF1->AF1_XITCTB



Return

User Function PMSITCTBPE(cItcta,cprojenum,cProjnom, cAF1_XITCTB)

Local cCTD_XCATEG := "" // Crio uma váriavel local para gravar o código da categoria 1-Criação, 2-Manutenção

	//Abre a tabela CTD
	DbSelectarea("CTD")
	CTD->(DbSetOrder(1)) // Seto a ordem 1 desta tabela (Veja na tabela SIdex a ordem)
	If CTD->(DbSeek(XFILIAL("CTD")+cAF1_XITCTB)) // Desto se foi encontrado
		cCTD_XCATEG := CTD->CTD_XCATEG // Se foi encontrado gravado em memoria  
		                               // o contéudo do campo CTD->CTD_XCATEG na variável cCTD->XCATEG
	EndIF  // Fecho a condição do If.

	If CTD->(DbSeek(XFILIAL("CTD")+Alltrim(cItcta))) // Se achou, verifico se é 
		RecLock("CTD", .F.)                          // alteração ou inclusão
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
	CTD->CTD_XCATEG:= cCTD_XCATEG
	CTD->(MsUnLock())

Return
