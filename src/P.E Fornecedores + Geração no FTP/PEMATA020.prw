#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDEF.CH'
#INCLUDE "topconn.ch"
#include 'tbiconn.ch'



#define MB_OK                       0
#define MB_OKCANCEL                 1
#define MB_YESNO                    4
#define MB_ICONHAND                 16
#define MB_ICONQUESTION             32
#define MB_ICONEXCLAMATION          48
#define MB_ICONASTERISK             64

#define X_NEWLINE  chr(13)+chr(10)

/*/{Protheus.doc} CUSTOMERVENDOR
Ponto de entrada da rotina EXEMPLO_MVC_PE (MVC)

@author TSC678 - CHRISTIAN DANIEL COSTA
@since 00/00/0000
@see http://tdn.totvs.com/pages/releaseview.action?pageId=208345968
/*/

/*
IDs dos Pontos de Entrada
-------------------------

MODELPRE 			Antes da altera?ß?£o de qualquer campo do modelo. (requer retorno l??gico)
MODELPOS 			Na valida?ß?£o total do modelo (requer retorno l??gico)

FORMPRE 			Antes da altera?ß?£o de qualquer campo do formul?°rio. (requer retorno l??gico)
FORMPOS 			Na valida?ß?£o total do formul?°rio (requer retorno l??gico)

FORMLINEPRE 		Antes da altera?ß?£o da linha do formul?°rio GRID. (requer retorno l??gico)
FORMLINEPOS 		Na valida?ß?£o total da linha do formul?°rio GRID. (requer retorno l??gico)

MODELCOMMITTTS 		Apos a grava?ß?£o total do modelo e dentro da transa?ß?£o
MODELCOMMITNTTS 	Apos a grava?ß?£o total do modelo e fora da transa?ß?£o

FORMCOMMITTTSPRE 	Antes da grava?ß?£o da tabela do formul?°rio
FORMCOMMITTTSPOS 	Apos a grava?ß?£o da tabela do formul?°rio

FORMCANCEL 			No cancelamento do bot?£o.

BUTTONBAR 			Para acrescentar botoes a ControlBar

MODELVLDACTIVE 		Para validar se deve ou nao ativar o Model

Parametros passados para os pontos de entrada:
PARAMIXB[1] - Objeto do formul?°rio ou model, conforme o caso.
PARAMIXB[2] - Id do local de execu?ß?£o do ponto de entrada
PARAMIXB[3] - Id do formul?°rio

Se for uma FORMGRID
PARAMIXB[4] - Linha da Grid
PARAMIXB[5] - Acao da Grid

*/


User Function CUSTOMERVENDOR()
	Local aParam    := PARAMIXB
	Local oObj      := ''
	Local cIdPonto  := ''
	Local cIdModel  := ''
	Local cClasse   := ''
	Local cAgencia  := ""
	Local lRet		:=	.T.
	Local cEmail    := SA2->A2_EMAIL
	Local cHistor   := ""
	Local lHistor 	:= .F.			//Tratativa para uso de campo customizado A2_HISTORI (para caso haja posterior criação do campo)

	Local aNewDadosFor  := {}
	Local aDifDadosFor  := {}

	Local nn
	Public nFilial := CFILANT

	If SA2->(FieldPos("A2_HISTORI")) > 0
		cHistor := SA2->A2_HISTORI
		lHistor := .T.
	EndIf

	oObj		:= aParam[1]
	cIdPonto	:= aParam[2]
	cIdModel	:= aParam[3]
	cClasse		:= oObj:ClassName()
	nOpc        := oObj:GetOperation()

	cAgencia	:= AllTrim(M->A2_AGENCIA)
	cConta		:= AllTrim(M->A2_NUMCON)
	cDgAgen		:= AllTrim(M->A2_ZDVAG)
	cDgCont		:= AllTrim(M->A2_ZDVCC)

	IF cIdModel == 'SA2MASTER'
			IF (oObj:GetOperation() == 4) /*.AND. FUNNAME() <> "OGFAT005" .AND. FUNNAME() <> "RQ07A05" */ .AND. FUNNAME() <> "RPC"// NA ALTERAÇÃO
				//Memoriza as informações antigas auditadas
				IF Len(aOldDadosFor) == 0
					aadd(aOldDadosFor,{ 'A2_NOME'		, SA2->A2_NOME		, .F. } )
					aadd(aOldDadosFor,{ 'A2_END'    	, SA2->A2_END		, .F. } )
					aadd(aOldDadosFor,{ 'A2_NR_END'    	, SA2->A2_NR_END    , .F. } )
					aadd(aOldDadosFor,{ 'A2_BAIRRO' 	, SA2->A2_BAIRRO	, .F. } )

					aadd(aOldDadosFor,{ 'A2_MUN'		, SA2->A2_MUN	    , .F. } )
					aadd(aOldDadosFor,{ 'A2_COD_MUN'    , SA2->A2_COD_MUN  , .F. } )

					aadd(aOldDadosFor,{ 'A2_EST'		, SA2->A2_EST		, .F. } )
					aadd(aOldDadosFor,{ 'A2_CEP'		, SA2->A2_CEP		, .F. } )
					aadd(aOldDadosFor,{ 'A2_EMAIL'		, SA2->A2_EMAIL		, .F. } )
					aadd(aOldDadosFor,{ 'A2_NREDUZ'	    , SA2->A2_NREDUZ	, .F. } )
					aadd(aOldDadosFor,{ 'A2_TIPO'	    , SA2->A2_TIPO	    , .F. } )

					aadd(aOldDadosFor,{ 'A2_INSCR'	    , SA2->A2_INSCR 	, .F. } )
					aadd(aOldDadosFor,{ 'A2_INSCRM'     , SA2->A2_INSCRM 	, .F. } )
					aadd(aOldDadosFor,{ 'A2_CGC'	    , SA2->A2_CGC	 	, .F. } )

					aadd(aOldDadosFor,{ 'A2_CONTATO'	, SA2->A2_CONTATO	, .F. } )
					aadd(aOldDadosFor,{ 'A2_DDD'		, SA2->A2_DDD		, .F. } )
					aadd(aOldDadosFor,{ 'A2_TEL'		, SA2->A2_TEL		, .F. } )
					aadd(aOldDadosFor,{ 'A2_EMAIL'		, SA2->A2_EMAIL		, .F. } )

					aadd(aOldDadosFor,{ 'A2_BANCO'		, SA2->A2_BANCO     , .F. } )
					aadd(aOldDadosFor,{ 'A2_AGENCIA'	, SA2->A2_AGENCIA	, .F. } )
					aadd(aOldDadosFor,{ 'A2_DVAGE'	    , SA2->A2_DVAGE	    , .F. } )
					aadd(aOldDadosFor,{ 'A2_NUMCON'	    , SA2->A2_NUMCON    , .F. } )
					aadd(aOldDadosFor,{ 'A2_DVCTA'	    , SA2->A2_DVCTA     , .F. } )
					aadd(aOldDadosFor,{ 'A2_NATUREZ'    , SA2->A2_NATUREZ   , .F. } )
					aadd(aOldDadosFor,{ 'A2_COND'	    , SA2->A2_COND      , .F. } )
					aadd(aOldDadosFor,{ 'A2_CONTA'	    , SA2->A2_CONTA     , .F. } )

					aadd(aOldDadosFor,{ 'A2_MSBLQL'		, SA2->A2_MSBLQL	, .F. } )
				Endif
			Endif
		Endif

	//'Chamada na valida?ß?£o total do modelo (MODELPOS).'
	If  cIdPonto ==  'MODELPOS'


		//MsgInfo("AG:"+cAgencia + "|"+M->A2_NUMCON+"| DGA:"+M->A2_ZDVAG+"| DGC:"+M->A2_ZDVCC+"|" ,"Digito em branco")

		/*If (cAgencia != "" .OR. cConta  != "")
			If (cDgCont  == "")
				Help(NIL, 1, "ATEN«?O", NIL, "Digito em branco!", 1, 1, NIL, NIL, NIL, NIL, NIL, {"Faltou preencher o Digito da Conta ou Digito da Agencia!"})

				//MsgInfo("Faltou preencher o Digito da Conta ou Digito da Agencia","Digito em branco")
				lRet := .F.
			EndIf
		EndIF

		//Validação do E-mail
		If ! Isemail(Alltrim(M->A2_EMAIL))
			MessageBox("E-mail "+Alltrim(M->A2_EMAIL)+" incorreto!","PEMATA020",MB_ICONHAND)
			lRet := .F.
		Endif*/

		// Antes da altera?ß?£o de qualquer campo do modelo.
	ElseIf cIdPonto ==  'MODELPRE'
		// Antes da altera?ß?£o de qualquer campo do formul?°rio.
	ElseIf cIdPonto ==  'FORMPRE'
		//Chamada na valida?ß?£o total do formul?°rio (FORMPOS)
	ElseIf cIdPonto ==  'FORMPOS'
		//Chamada na pre valida?ß?£o da linha do formul?°rio (FORMLINEPRE)
	ElseIf cIdPonto ==  'FORMLINEPRE'
		//Chamada na valida?ß?£o da linha do formul?°rio (FORMLINEPOS)
	ElseIf cIdPonto ==  'FORMLINEPOS'
	ElseIf cIdPonto ==  'MODELCOMMITTTS'

		If lRet
			GravaCV0(nOpc) // Função para gravar e atualizar a entidade contábil
		EndIf


	ElseIf cIdPonto ==  'MODELCOMMITNTTS'
		//Chamada apos a grava?ß?£o da tabela do formul?°rio (FORMCOMMITTTSPOS)

		// Se for Filial SYGO 3401 não gera Termo
		If nOpc == 3  .AND.  M->A2_TIPO <>'F' .AND. nFilial != "3401"
			FWMsgRun(, {||  U_UNIR245R()  },"Termo de Conduta","Gerando termo de conduta")
		EndIf

		//tentar colocar aqui

		//Antes da grava?ß?£o da tabela do formul?°rio


		IF (oObj:GetOperation() == 4) .AND. /*FUNNAME() <> "OGFAT005" .AND. FUNNAME() <> "RQ07A05" .AND.*/  FUNNAME() <> "RPC"// NA ALTERAÇÃO

			// se alterar a ordem altere em MALTFOR no MODELCOMMITTTS abaixo

			aadd(aNewDadosFor,{ 'A2_NOME'		, oObj:GetModel("SA2MASTER"):GetValue("A2_NOME")	, .F. } )
			aadd(aNewDadosFor,{ 'A2_END'    	, oObj:GetModel("SA2MASTER"):GetValue("A2_END")		, .F. } )
			aadd(aNewDadosFor,{ 'A2_NR_END'    	, oObj:GetModel("SA2MASTER"):GetValue("A2_NR_END")  , .F. } )
			aadd(aNewDadosFor,{ 'A2_BAIRRO' 	, oObj:GetModel("SA2MASTER"):GetValue("A2_BAIRRO")	, .F. } )

			aadd(aNewDadosFor,{ 'A2_MUN'		, oObj:GetModel("SA2MASTER"):GetValue("A2_MUN")	   	, .F. } )
			aadd(aNewDadosFor,{ 'A2_COD_MUN'	, oObj:GetModel("SA2MASTER"):GetValue("A2_COD_MUN")	, .F. } )

			aadd(aNewDadosFor,{ 'A2_EST'		, oObj:GetModel("SA2MASTER"):GetValue("A2_EST")  , .F. } )
			aadd(aNewDadosFor,{ 'A2_CEP'		, oObj:GetModel("SA2MASTER"):GetValue("A2_CEP")	    , .F. } )
			aadd(aNewDadosFor,{ 'A2_EMAIL'		, oObj:GetModel("SA2MASTER"):GetValue("A2_EMAIL")	, .F. } )
			aadd(aNewDadosFor,{ 'A2_NREDUZ'	    , oObj:GetModel("SA2MASTER"):GetValue("A2_NREDUZ")	, .F. } )
			aadd(aNewDadosFor,{ 'A2_TIPO'	    , oObj:GetModel("SA2MASTER"):GetValue("A2_TIPO")    , .F. } )

			aadd(aNewDadosFor,{ 'A2_INSCR'	    , oObj:GetModel("SA2MASTER"):GetValue("A2_INSCR")   , .F. } )
			aadd(aNewDadosFor,{ 'A2_INSCRM'	    , oObj:GetModel("SA2MASTER"):GetValue("A2_INSCRM")  , .F. } )
			aadd(aNewDadosFor,{ 'A2_CGC'	    , oObj:GetModel("SA2MASTER"):GetValue("A2_CGC")	 	, .F. } )

			aadd(aNewDadosFor,{ 'A2_CONTATO'	, oObj:GetModel("SA2MASTER"):GetValue("A2_CONTATO")	, .F. } )
			aadd(aNewDadosFor,{ 'A2_DDD'		, oObj:GetModel("SA2MASTER"):GetValue("A2_DDD")		, .F. } )
			aadd(aNewDadosFor,{ 'A2_TEL'		, oObj:GetModel("SA2MASTER"):GetValue("A2_TEL")		, .F. } )
			aadd(aNewDadosFor,{ 'A2_EMAIL'		, oObj:GetModel("SA2MASTER"):GetValue("A2_EMAIL")	, .F. } )

			aadd(aNewDadosFor,{ 'A2_BANCO'		, oObj:GetModel("SA2MASTER"):GetValue("A2_BANCO")	, .F. } )
			aadd(aNewDadosFor,{ 'A2_AGENCIA'	, oObj:GetModel("SA2MASTER"):GetValue("A2_AGENCIA")	, .F. } )
			aadd(aNewDadosFor,{ 'A2_DVAGE'		, oObj:GetModel("SA2MASTER"):GetValue("A2_DVAGE")	, .F. } )
			aadd(aNewDadosFor,{ 'A2_NUMCON'		, oObj:GetModel("SA2MASTER"):GetValue("A2_NUMCON")	, .F. } )
			aadd(aNewDadosFor,{ 'A2_DVCTA'		, oObj:GetModel("SA2MASTER"):GetValue("A2_DVCTA")	, .F. } )
			aadd(aNewDadosFor,{ 'A2_NATUREZ'	, oObj:GetModel("SA2MASTER"):GetValue("A2_NATUREZ")	, .F. } )
			aadd(aNewDadosFor,{ 'A2_COND'		, oObj:GetModel("SA2MASTER"):GetValue("A2_COND")	, .F. } )
			aadd(aNewDadosFor,{ 'A2_CONTA'		, oObj:GetModel("SA2MASTER"):GetValue("A2_CONTA")	, .F. } )

			aadd(aNewDadosFor,{ 'A2_MSBLQL'		, oObj:GetModel("SA2MASTER"):GetValue("A2_MSBLQL")	, .F. } )

			If Len(aNewDadosFor) <> Len(aOldDadosFor)
				Final("Favor entrar em contato com o TI")
			Endif
			aDifDadosFor := {}


			//SX3->(dbSetOrder(2))
			For nn := 1 To Len(aNewDadosFor)

				If nn == 1
					Aadd( aDifDadosFor, {'Campo','Conteudo Anterior','Novo Conteudo'} )
				Endif
				If aNewDadosFor[nn][2] <> aOldDadosFor[nn][2]
					//SX3->(dbSeek(aNewDadosFor[nn][1]))
					Aadd( aDifDadosFor,{ GetSX3Cache(aNewDadosFor[nn][1], "X3_TITULO"), aOldDadosFor[nn][2], aNewDadosFor[nn][2] } )
				Endif

			Next nn

			If Len(aDifDadosFor) > 1

				aFornece     := {}
				Aadd( aFornece, { 'Codigo','Nome do Fornecedor',IIF(oObj:GetModel("SA2MASTER"):GetValue("A2_TIPO")='J','CNPJ','CNPJ') } )
				Aadd( aFornece, { oObj:GetModel("SA2MASTER"):GetValue("A2_COD"), oObj:GetModel("SA2MASTER"):GetValue("A2_NOME"), Transform(oObj:GetModel("SA2MASTER"):GetValue("A2_CGC"),PesqPict("SA2","A2_CGC")) } )

				aDados1	:= { aFornece, aDifDadosFor }
				Enviaemail()

				If SA2->(FieldPos("A2_ZDATALT")) > 0
					If RecLock("SA2",.F.)
						SA2->A2_ZDATALT := Date()
						SA2->(MsUnlock())
					EndIf
				EndIf

			Endif
			aNewDadosFor := aOldDadosFor := aDifDadosFor := Nil
		Endif

	ElseIf cIdPonto ==  'FORMCOMMITTTSPRE'

		// Se for Filial SYGO 3401 não gera Termo
		If nOpc == 4 .AND. M->A2_EMAIL <> cEmail  .AND.  M->A2_TIPO <>'F' .AND. nFilial != "3401" //alteração do e-mail
			FWMsgRun(, {||  U_UNIR245R()  },"Termo de Conduta","Gerando termo de conduta")
		EndIf

		If lHistor
			If nOpc == 4 .AND. M->A2_HISTORI <> cHistor .AND. SA2->(FieldPos("A2_ZNOTA")) > 0 //.AND. !Empty(M->A2_HISTOR) //alteração do histórico
				If Empty(cHistor) // 1o historico
					M->A2_ZNOTA:=  DTOC(Date())+" - "+ UsrRetName(RetCodUsr()) +":"+M->A2_HISTORI
				Else
					M->A2_ZNOTA:= Rtrim(M->A2_ZNOTA)+  X_NEWLINE + DTOC(Date())+" - "+;
						UsrRetName(RetCodUsr()) +":"+M->A2_HISTORI +  X_NEWLINE
				Endif

				RecLock('SA2',.F.)
				SA2->A2_ZNOTA := M->A2_ZNOTA
				MsUnlock()
			Endif
		EndIf


	ElseIf cIdPonto ==  'FORMCOMMITTTSPOS'
		// Chamada no Bot?£o Cancelar (MODELCANCEL).
	ElseIf cIdPonto ==  'MODELCANCEL'
		// Adicionando Botao na Barra de Botoes (BUTTONBAR)
	ElseIf cIdPonto ==  'BUTTONBAR'
		// Chamada na valida?ß?£o da ativa?ß?£o do Model.
	ElseIf cIdPonto ==  'MODELVLDACTIVE'
		// Este ponto nao ?© nativo do MVC ?© preciso cria-lo no MENUDEF da aplicacao

		//USADO PARA VALIDAR SE HOUVE ALTERAÇÃO NOS DADOS
		IF oObj:GetOperation() == 4
			Public aOldDadosFor := {}
		ENDIF
	ElseIf cIdPonto ==  'MENUDEF'
	EndIf
Return lRet



/*/{Protheus.doc} Enviaemail
description
@type function
@version
@author raul.santos
@since 12/12/2022
@return variant, return_description
/*/
Static Function Enviaemail()

	Local aNewDados := ParamIxb

	/*
	MV_RELAUTH – Servidor de e-mail necessita de Autenticação?
    MV_EMCONTA – Indica qual conta utilizada para envio de e-mails automáticos pelo sistema.
    MV_RELSERV – Nome do servidor de envio de e-mail utilizado nos relatórios.
	MV_RELAPSW. Definição :Senha da conta de e-mail para autenticação SMTP */

    Private _cCodUser  := RetCodUsr()
	Private _cNomeUser := Rtrim(UsrFullName(_cCodUser))


	Private	_cSmtpSrv 	:= AllTrim(GetMv('MV_RELSERV')),;
		_cAccount 	:= AllTrim(GetMv('MV_EMCONTA')),;
		_cPassSmtp	:= AllTrim(GetMv('MV_RELAPSW')),;
		_cSmtpError	:= '',;
		_lOk		:= .f.,;
		_cTitulo 	:= OemToAnsi('Alteração Cadastro: '+Rtrim(SA2->A2_NOME)+' Usuário:'+_cNomeUser),;
		_cTo		:= USRRETMAIL(RETCODUSR()),;
		cBCC        := ' ',;
		_cFrom		:= "sistema.protheus@redeunifique.com.br;",;
		cMsg		:= '',;
		_lReturn	:= .f. 

	Private _cToAud := GETMV('UN_AUDFORN')

	_cTo := IF(!Empty(_cToAud ), _cToAud, _cTo )
	//USRRETMAIL(RETCODUSR())

	cMsg := '<html><title></title><body>'
	cMsg += '<table borderColor="#0099cc" height="29" cellSpacing="1" width="846" borderColorLight="#0099cc" border=1>'
	cMsg += '  <tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="806"'
	cMsg += '    borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
	cMsg += '    <p align="center"><FONT face="Courier New" color="#ffffff" size="4">'
	cMsg += '    <b>Alteração de dados cadastrais do fornecedor</b></font></p></td></tr>'
	cMsg += '  <tr><td align="left" width="806" height="32"><p align="left"><b>    '

	cMsg += MontaTabelaHTML(aDados1[1], .T., "105%")
	cMsg += MontaTabelaHTML(aDados1[2], .T., "105%")

	cMsg += '</b></p></td></tr>'
	cMsg += '</table><br>'

	CONNECT SMTP SERVER _cSmtpSrv ACCOUNT _cAccount PASSWORD _cPassSmtp RESULT _lOk
	ConOut('Conectando com o Servidor SMTP')

	If	( _lOk )
		ConOut('Enviando o e-mail')
		SEND MAIL FROM _cFrom TO _cTo BCC cBCC SUBJECT _cTitulo BODY cMsg RESULT _lOk
		ConOut('De........: ' + _cFrom)
		ConOut('Para......: ' + _cTo)
		ConOut('Assunto...: ' + _cTitulo)
		ConOut('Status....: Enviado com Sucesso')
		If	( ! _lOk )
			GET MAIL ERROR _cSmtpError
			ConOut(_cSmtpError)
			_lReturn := .f.
		EndIf
		DISCONNECT SMTP SERVER
		ConOut('Desconectando do Servidor')

		_lReturn := .t.

	Else
		GET MAIL ERROR _cSmtpError
		ConOut(_cSmtpError)
		_lReturn := .f.
	EndIf

Return _lReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCV0
Função para gravar e atualizar a entidade contábil
@return     
@author     Rivaldo Jr. | Cod.ERP
@version    12.1.17 / Superior
@since      01/Nov/2023/*/
//-------------------------------------------------------------------
Static Function GravaCV0(nOpc)

	DbSelectArea("CV0")
	CV0->(DbSetOrder(1))
	
	If nOpc == 3 // Inclusão

		CV0->(RecLock("CV0", .T.))
			CV0->CV0_FILIAL  := xFilial("CV0")
			CV0->CV0_PLANO   := "05"
			CV0->CV0_ITEM    := GetSxeNum("CV0","CV0_ITEM")
			CV0->CV0_CODIGO  := "F"+SA2->(A2_COD+A2_LOJA)
			CV0->CV0_DESC    := AllTrim(SA2->A2_NOME)
			CV0->CV0_BLOQUE  := 'N'
			CV0->CV0_CLASSE  := '2'//Analitica
			CV0->CV0_NORMAL  := '2'//Credora
			CV0->CV0_DTIEXI  := dDataBase 
		CV0->(MsUnlock())

	ElseIf nOpc == 4 // Alteração

		If CV0->(DbSeek(xFilial("CV0")+"05"+"F"+SA2->(A2_COD+A2_LOJA)))
			CV0->(RecLock("CV0", .F.))
				CV0->CV0_FILIAL  := CV0->CV0_FILIAL
				CV0->CV0_PLANO   := CV0->CV0_PLANO 
				CV0->CV0_ITEM    := CV0->CV0_ITEM  
				CV0->CV0_CODIGO  := "F"+SA2->(A2_COD+A2_LOJA)
				CV0->CV0_DESC    := AllTrim(SA2->A2_NOME)
				CV0->CV0_BLOQUE  := CV0->CV0_BLOQUE
				CV0->CV0_CLASSE  := CV0->CV0_CLASSE
				CV0->CV0_NORMAL  := CV0->CV0_NORMAL
				CV0->CV0_DTIEXI  := CV0->CV0_DTIEXI
			CV0->(MsUnlock())
		EndIf

	ElseIf nOpc == 5 // Exclusão

		If CV0->(DbSeek(xFilial("CV0")+"05"+"F"+SA2->(A2_COD+A2_LOJA)))  
			CV0->(RecLock("CV0", .F.))
				CV0->(DbDelete())
			CV0->(MsUnlock())
		EndIf

	EndIf

Return 
