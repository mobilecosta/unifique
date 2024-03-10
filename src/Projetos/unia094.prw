#Include 'Protheus.ch' 
#Include 'FWMVCDef.ch'
#Include 'MATA094.ch'
#Include "GCTXDEF.CH"

STATIC cOperID	 := "000"	  // Variavel para armazenar a operação que foi executada
STATIC oModelCT	 := NIL
STATIC aCamposC7 := {}
STATIC aCamposDBL:= {}
STATIC cFieldSC7 := ''
STATIC lLGPD	 := FindFunction("SuprLGPD") .And. SuprLGPD()

#DEFINE OP_LIB	"001" // Liberado 
#DEFINE OP_EST	"002" // Estornar
#DEFINE OP_SUP	"003" // Superior
#DEFINE OP_TRA	"004" // Transferir Superior
#DEFINE OP_REJ	"005" // Rejeitado
#DEFINE OP_BLQ	"006" // Bloqueio
#DEFINE OP_VIW	"007" // Visualizacao 

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA094()
Aprovação de Documentos
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function MATA094()

	Local oBrowse  
	Local cFiltraSCR
	Local ca097User  := RetCodUsr()
	Local lFiltroUs1 := .T.
	LOCAL xFiltroUs	
	LOCAL nx         := 0
	LOCAL aLegenda   := {}
	LOCAL aMT094LEG  := {}	
	
	If FwModeAccess("SCR") <> FwModeAccess("DBM")
		MsgAlert("Para o correto funcionamento da rotina o compartilhamento das tabelas SCR/DBM precisam estar iguais.")
	Endif
		
	//-------------------------------------------------------------------
	// Verifica se o usuario possui direito de liberacao.           
	//-------------------------------------------------------------------
	dbSelectArea("SAK")
	dbSetOrder(2)
	If !MsSeek(xFilial("SAK")+RetCodUsr())
		Help(" ",1,"A097APROV") //  Usuário não esta cadastrado como aprovador. O  acesso  e  a utilizacao desta rotina e destinada apenas aos usuários envolvidos no processo de aprovação de Pedido Compras definido pelos grupos de aprovação.
		dbSelectArea("SCR")
		dbSetOrder(1)
	Else
		If Pergunte("MTA097",.T.)
		
			//-------------------------------------------------------------------
			// Controle de Aprovacao : CR_STATUS                
			// 01 - Bloqueado p/ sistema (aguardando outros niveis) 
			// 02 - Aguardando Liberacao do usuario                 
			// 03 - Pedido Liberado pelo usuario                    
			// 04 - Pedido Bloqueado pelo usuario                   
			// 05 - Pedido Liberado por outro usuario               
			// 06 - Documento Rejeitado
			//-------------------------------------------------------------------
			dbSelectArea("SCR")
			dbSetOrder(1)		
			
			If ExistBlock("MT094LBF")
				lFiltroUs1 := ExecBlock("MT094LBF",.F.,.F.)
				
				If ValType(lFiltroUs1) == "L"     
					If !lFiltroUs1 .And. VerSenha(114)
						cFiltraSCR  := ' CR_USER=="'+ca097User
						cFilQry     := " CR_USER='"+ca097User+"' "
					Endif
				Endif    
			EndIf
			      
			If cFiltraSCR == NIL
				cFiltraSCR  := 'CR_FILIAL=="'+xFilial("SCR")+'"'+'.And.CR_USER=="'+ca097User 
			EndIf		
	   	    
			Do Case
				Case mv_par01 == 1
					cFiltraSCR += '".And.CR_STATUS=="02"'
				Case mv_par01 == 2
					cFiltraSCR += '".And.(CR_STATUS=="03".OR.CR_STATUS=="05")'
				Case mv_par01 == 3
					cFiltraSCR += '"'
				Case mv_par01 == 4
					cFiltraSCR += '".And.CR_STATUS=="04"'
				Case mv_par01 == 5
					cFiltraSCR += '".And.CR_STATUS=="06"'
				OtherWise
					cFiltraSCR += '".And.(CR_STATUS=="01".OR.CR_STATUS=="04")'
			EndCase
			
			// Ponto de entrada para filtro de usuario
			IF ExistBlock("MT094FIL" )
				xFiltroUs := ExecBlock( "MT094FIL", .F., .F. )
				IF VALTYPE(xFiltroUs) == "C"
					cFiltraSCR += " .And. " + xFiltroUs
				ElseIf VALTYPE(xFiltroUs) == "A"
					cFiltraSCR := xFiltroUs[1]			
				EndIf
			EndIf			
			
			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias('SCR')       
			                                   
			// Definição da legenda
			aAdd(aLegenda, { "CR_STATUS=='01'", "BR_AZUL" , STR0001 }) //"Blqueado (aguardando outros niveis)"
			aAdd(aLegenda, { "CR_STATUS=='02'", "DISABLE" , STR0002 }) //"Aguardando Liberacao do usuario"
			aAdd(aLegenda, { "CR_STATUS=='03'", "ENABLE"  , STR0003 }) //"Documento Liberado pelo usuario"
			aAdd(aLegenda, { "CR_STATUS=='04'", "BR_PRETO", STR0004 }) //"Documento Bloqueado pelo usuario"
			aAdd(aLegenda, { "CR_STATUS=='05'", "BR_CINZA", STR0005 }) //"Documento Liberado por outro usuario"
			aAdd(aLegenda, { "CR_STATUS=='06'", "BR_CANCEL",STR0025 }) //"Documento Rejeitado pelo usuário"
			aAdd(aLegenda, { "CR_STATUS=='07'","BR_AMARELO", STR0057 }) //"Documento Rejeitado ou Bloqueado por outro usuário"
			
			// Ponto de entrada para alterar/criar legenda/cor
			IF ExistBlock("MT094LEG" )
				IF VALTYPE( aMT094LEG := ExecBlock("MT094LEG",.F.,.F.,{aLegenda}) ) == "A"
					aLegenda := aMT094LEG
				ENDIF				
			ENDIF
			
			FOR nx := 1 TO LEN(aLegenda)
				oBrowse:AddLegend(aLegenda[nx][1], aLegenda[nx][2], aLegenda[nx][3])
			NEXT nx
			
			oBrowse:SetCacheView(.F.)
			oBrowse:DisableDetails()
			oBrowse:SetDescription(STR0006)  //"Aprovação de Documentos"
			oBrowse:SetFilterDefault(cFiltraSCR)
			obrowse:SetChgAll(.F.)
			obrowse:SetSeeAll(.F.)
			
			If ExistBlock("MT094LBF")
				lFiltroUs1 := ExecBlock("MT094LBF",.F.,.F.)
				
				If ValType(lFiltroUs1) == "L"     
					If !lFiltroUs1 .And. VerSenha(114)
						obrowse:SetChgAll(.T.)
						obrowse:SetSeeAll(.T.)
					Endif
				Endif    
			EndIf	
			
			oBrowse:Activate()		
		EndIf
	EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()  

Local aRotina := {} //Array utilizado para controlar opcao selecionada
Local aAcoes := {}
Local aOpcVIs	:= {}
Local aOpcSup	:= {}

ADD OPTION aOpcVis Title STR0027	Action 'A94Visual' 			OPERATION 2 ACCESS 0 ID OP_VIW	//"Formulário da aprovação"
ADD OPTION aOpcVis Title STR0010	Action 'A097Visual(,,2)'	OPERATION 2 ACCESS 0     		//"Documento emitido"
ADD OPTION aOpcVis Title STR0011	Action 'A097Consulta'		OPERATION 2 ACCESS 0     		//"Saldo para aprovação"

ADD OPTION aOpcSup Title STR0013	Action 'A94ExSuper'			OPERATION 4 ACCESS 0 ID OP_SUP	//"Aprovar pelo superior"
ADD OPTION aOpcSup Title STR0014	Action 'A94ExTrans'			OPERATION 4 ACCESS 0 ID OP_TRA	//"Transferir para superior"

ADD OPTION aRotina Title "Pesquisar" Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0008	Action 'A94ExLiber'			OPERATION 4 ACCESS 0 ID OP_LIB	//"Aprovar"
ADD OPTION aRotina Title STR0026	Action 'A094Rejeita'		OPERATION 4 ACCESS 0 ID OP_REJ //"Rejeitar"
ADD OPTION aRotina Title STR0028	Action  aOpcVis				OPERATION 2 ACCESS 0 			//"Visualizar"
ADD OPTION aRotina Title STR0015	Action 'A094Bloqu'			OPERATION 4 ACCESS 0 ID OP_BLQ	//"Bloquear"
ADD OPTION aRotina Title STR0012	Action 'A094VldEst'			OPERATION 5 ACCESS 0 ID OP_EST	//"Estornar"
ADD OPTION aRotina Title STR0009	Action 'A097Ausente'		OPERATION 3 ACCESS 0     		//"Pendências de subordinados"
ADD OPTION aRotina Title STR0013	Action  aOpcSup				OPERATION 4 ACCESS 0 			//"Superior"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MTA094RO")
	If ValType(aAcoes := ExecBlock( "MTA094RO", .F., .F., {aRotina}) ) == "A"
		aRotina:= aAcoes
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author leonardo.quintania

@since 27/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel := Nil
Local oStr1 := FWFormStruct(1,'SCR',{|cCampo| AllTrim(cCampo) $ "CR_FILIAL|CR_TIPO|CR_NUM|CR_TOTAL|CR_EMISSAO|CR_DATALIB|CR_OBS|CR_GRUPO|CR_ITGRP|CR_APROV|CR_STATUS"})
Local oStr2 := FWFormStruct(1,'DBL',{|cCampo| !AllTrim(cCampo) $ "DBL_GRUPO|DBL_ITEM"})
Local oStr3 := FWFormStruct(1,'SAK',{|cCampo| AllTrim(cCampo) $ "AK_NOME|AK_LIMITE|AK_TIPO"})
Local oStr4 := NIL

Local oStrDBM := FWFormStruct(1,'DBM')
Local lAlcSolCtb := SuperGetMv("MV_APRSCEC",.F.,.F.)
Local cMT094CPC  := ""
Local cCampoPC   := ""
Local cMT094CCR  := ""
Local aMT094CCR	:= {}
Local nI			:= 0
Local aFieldAgro	:= {} // Documentos do modulo Agro
Local cMoedaAtual := ""
Local aFiltroSC7  := {}
Local cCpoAddC3		:= SuperGetMv("MV_C094C3",.F.,"")

aCamposC7  := MTGETFEC("SC7","C7")
aCamposDBL := MTGETFEC("DBL","DBL")
Aeval(aCamposC7,{|a| cFieldSC7+='|'+a}) //campos da estrutura do model

If ExistBlock("MT094CPC")
    cCampoPC := ExecBlock( "MT094CPC", .f., .f.)
    cMT094CPC +=  IIF(VALTYPE(cCampoPC) == 'C',cCampoPC,'')
Endif

If ExistBlock("MT094CCR")
    cCampoPC := ExecBlock( "MT094CCR", .f., .f.)
    cMT094CCR +=  IIF(VALTYPE(cCampoPC) == 'C',cCampoPC,'')
Endif

If SCR->CR_TIPO $ 'IP|PC|AE'
	oStr4:= FWFormStruct(1,'SC7',{|cCampo| AllTrim(cCampo) $ "C7_ITEM|C7_PRODUTO|C7_DESCRI|C7_UM|C7_SEGUM|C7_QUANT|C7_PRECO|C7_TOTAL|C7_QTSEGUM|C7_VALFRE|C7_DESPESA|C7_SEGURO|C7_VALEMB|C7_VALIPI|C7_ICMSRET|C7_CODITE|C7_CODGRP"+cFieldSC7})
	oStr4:RemoveField( 'C7_DESC' )
ElseIf SCR->CR_TIPO == 'SA'
	oStr4:= FWFormStruct(1,'SCP',{|cCampo| AllTrim(cCampo) $ "CP_ITEM|CP_PRODUTO|CP_DESCRI|CP_UM|CP_SEGUM|CP_QUANT|CP_QTSEGUM"})
ElseIf SCR->CR_TIPO == 'SC'
	oStr4:= FWFormStruct(1,'SC1',{|cCampo| AllTrim(cCampo) $ "C1_ITEM|C1_PRODUTO|C1_DESCRI|C1_UM|C1_SEGUM|C1_QUANT|C1_QTSEGUM"})
ElseIf SCR->CR_TIPO $ 'IC|IR'
	oStr4:= FWFormStruct(1,'CNB',{|cCampo| AllTrim(cCampo) $ "CNB_ITEM|CNB_PRODUT|CNB_DESCRI|CNB_QUANT|CNB_VLUNIT|CNB_VLTOT|CNB_CC|CNB_CONTA|CNB_ITEMCT|CNB_CLVL"})
ElseIf SCR->CR_TIPO $ 'IM|MD'
	oStr4:= FWFormStruct(1,'CNE',{|cCampo| AllTrim(cCampo) $ "CNE_ITEM|CNE_PRODUT|CNE_QUANT|CNE_VLUNIT|CNE_VLTOT|CNE_CC|CNE_CONTA|CNE_ITEMCT|CNE_CLVL"})
ElseIf SCR->CR_TIPO $ 'NF'
	oStr4:= FWFormStruct(1,'SD1',{|cCampo| AllTrim(cCampo) $ "D1_ITEM|D1_COD|D1_QUANT|D1_VUNIT|D1_PEDIDO|D1_ITEMPC"})
Elseif SCR->CR_TIPO == "CP" //Contrato Parceria
	oStr4:= FWFormStruct(1,'SC3',{|cCampo| AllTrim(cCampo) $ "C3_ITEM|C3_PRODUTO|C3_UM|C3_SEGUM|C3_QUANT|C3_QTSEGUM" + Iif(!Empty(cCpoAddC3),"|"+ cCpoAddC3,"") })
EndIf



If !(SCR->CR_TIPO $ 'SC|SA|CT|RV|MD|A1|A2')
	//-- Campo fornecedor para tipos diferentes de SA e SC
	oStr1:AddField(STR0016															,;	// 	[01]  C   Titulo do campo  
					 STR0016															,;	// 	[02]  C   ToolTip do campo
					 "CR_FORNECE"														,;	// 	[03]  C   Id do Field
					 "C"																,;	// 	[04]  C   Tipo do campo
					 TAMSX3("A2_NOME")[1]											,;	// 	[05]  N   Tamanho do campo
					 0																	,;	// 	[06]  N   Decimal do campo
					 NIL																,;	// 	[07]  B   Code-block de validação do campo
					 NIL																,;	// 	[08]  B   Code-block de validação When do campo
					 NIL																,;	//	[09]  A   Lista de valores permitido do campo
					 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .F.																)	// 	[14]  L   Indica se o campo é virtual	
EndIf
cMoedaAtual := SuperGetMv("MV_MOEDA"+AllTrim(Str(GetAdvFval("SAK", "AK_MOEDA", xFilial("SAK")+SCR->CR_APROV, 1),2)),.F.,"2")

//Campo de Moeda na primeira área da págin, onde mostra as informações da alçada
oStr1:AddField( 	 STR0055															,;	// 	[01]  C   Titulo do campo
					 STR0055															,;	// 	[02]  C   ToolTip do campo
					 "CR_DMOEDA"														,;	// 	[03]  C   Id do Field
					 "C"																,;	// 	[04]  C   Tipo do campo
					 10																	,;	// 	[05]  N   Tamanho do campo
					 0																	,;	// 	[06]  N   Decimal do campo
					 NIL																,;	// 	[07]  B   Code-block de validação do campo
					 {||.F.}															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL																,;	//	[09]  A   Lista de valores permitido do campo
					 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {|| cMoedaAtual}													,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.																)	// 	[14]  L   Indica se o campo é virtual

// Campo de Total Virtual para não ocorrer alteração quando a moeda não a primeira
If !(SCR->CR_TIPO $ 'CT')
	oStr1:RemoveField('CR_TOTAL')

	oStr1:AddField(  STR0047															,;	// 	[01]  C   Titulo do campo
					 STR0047															,;	// 	[02]  C   ToolTip do campo
					 "CR_DTOTAL"														,;	// 	[03]  C   Id do Field
					 TamSX3("CR_TOTAL")[3]												,;	// 	[04]  C   Tipo do campo
					 TamSX3("CR_TOTAL")[1]												,;	// 	[05]  N   Tamanho do campo
					 TamSX3("CR_TOTAL")[2]												,;	// 	[06]  N   Decimal do campo
					 NIL																,;	// 	[07]  B   Code-block de validação do campo
					 {||.F.}															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL																,;	//	[09]  A   Lista de valores permitido do campo
					 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.																)	// 	[14]  L   Indica se o campo é virtual
Endif


If SCR->CR_TIPO == "NF"	
		oStr1:AddField(STR0037															,;		 
					 STR0037															,;	// 	[02]  C   ToolTip do campo
					 "CR_TPBLOQ"														,;	// 	[03]  C   Id do Field
					 "C"																,;	// 	[04]  C   Tipo do campo
					 10																	,;	// 	[05]  N   Tamanho do campo
					 0																	,;	// 	[06]  N   Decimal do campo
					 NIL																,;	// 	[07]  B   Code-block de validação do campo
					 NIL																,;	// 	[08]  B   Code-block de validação When do campo
					 NIL																,;	//	[09]  A   Lista de valores permitido do campo
					 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .F.																)	// 	[14]  L   Indica se o campo é virtual					 
EndIf

If !Empty(cMT094CCR)
	aMT094CCR := Separa(cMT094CCR,"|")
	For nI := 1 To Len(aMT094CCR)
		If !Empty(aMT094CCR[nI])
			oStr1:AddField(RetTitle(aMT094CCR[nI])											,;		 
						 	 RetTitle(aMT094CCR[nI])											,;	// 	[02]  C   ToolTip do campo
						 	 aMT094CCR[nI]													,;	// 	[03]  C   Id do Field
						 	 TamSx3(aMT094CCR[nI])[3]										,;	// 	[04]  C   Tipo do campo
						 	 TamSx3(aMT094CCR[nI])[1]										,;	// 	[05]  N   Tamanho do campo
							 TamSx3(aMT094CCR[nI])[2]										,;	// 	[06]  N   Decimal do campo
							 NIL																,;	// 	[07]  B   Code-block de validação do campo
							 NIL																,;	// 	[08]  B   Code-block de validação When do campo
							 NIL																,;	//	[09]  A   Lista de valores permitido do campo
							 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
							 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
							 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
							 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
							 .F.																)	// 	[14]  L   Indica se o campo é virtual
		Endif
	Next nI
Endif

If !Empty(cMT094CPC) .And. SCR->CR_TIPO $ "PC|IP|AE"
	aMT094CPC := Separa(cMT094CPC,"|")
	For nI := 1 To Len(aMT094CPC)
		If !Empty(aMT094CPC[nI]) .And. Upper(SubStr(aMT094CPC[nI], 1, 2)) == "C7"
			oStr4:AddField(RetTitle(aMT094CPC[nI])											,;		 
						 	 RetTitle(aMT094CPC[nI])											,;	// 	[02]  C   ToolTip do campo
						 	 aMT094CPC[nI]													,;	// 	[03]  C   Id do Field
						 	 TamSx3(aMT094CPC[nI])[3]										,;	// 	[04]  C   Tipo do campo
						 	 TamSx3(aMT094CPC[nI])[1]										,;	// 	[05]  N   Tamanho do campo
							 TamSx3(aMT094CPC[nI])[2]										,;	// 	[06]  N   Decimal do campo
							 NIL																,;	// 	[07]  B   Code-block de validação do campo
							 NIL																,;	// 	[08]  B   Code-block de validação When do campo
							 NIL																,;	//	[09]  A   Lista de valores permitido do campo
							 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
							 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
							 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
							 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
							 Iif(GetSx3Cache(aMT094CPC[nI], "X3_CONTEXT")=="V",.T.,.F.)			)	// 	[14]  L   Indica se o campo é virtual
		Endif
	Next nI
Endif

If SCR->CR_TIPO >= "A1" .AND. SCR->CR_TIPO <= "A9"  // Documentos do modulo Agro
	
	If FindFunction("OGXUtlOrig") //Identifica que esta utilizando o sigaagr				
		If OGXUtlOrig() .AND. FindFunction("OGX701AALC")	
			//Retorna um array com os dado para adicionar no oStruct
			aFieldAgro := AGRXCOM4( SCR->CR_NUM, SCR->CR_TIPO, SCR->(RECNO()) ) 
			
			For nI := 1 To Len(aFieldAgro)
				oStr1:AddField(aFieldAgro[nI][1]											,;	// 	[01]  C   Titulo do campo  
							   aFieldAgro[nI][2]											,;	// 	[02]  C   ToolTip do campo
							   aFieldAgro[nI][3]											,;	// 	[03]  C   Id do Field
							   aFieldAgro[nI][4]											,;	// 	[04]  C   Tipo do campo
							   aFieldAgro[nI][5]											,;	// 	[05]  N   Tamanho do campo
							   aFieldAgro[nI][6]											,;	// 	[06]  N   Decimal do campo
							   aFieldAgro[nI][7]											,;	// 	[07]  B   Code-block de validação do campo
							   aFieldAgro[nI][8]											,;	// 	[08]  B   Code-block de validação When do campo
							   aFieldAgro[nI][9]											,;	//	[09]  A   Lista de valores permitido do campo
							   aFieldAgro[nI][10]											,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
							   aFieldAgro[nI][11]											,;	//	[11]  B   Code-block de inicializacao do campo
							   aFieldAgro[nI][12]											,;	//	[12]  L   Indica se trata-se de um campo chave
							   aFieldAgro[nI][13]											,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
							   aFieldAgro[nI][14]											)   // 	[14]  L   Indica se o campo é virtual
			Next nI
		EndIf
	EndIf
		
EndIf

//-- Campo Saldo na Data
oStr3:AddField(STR0017															,;	// 	[01]  C   Titulo do campo 
				 STR0017															,;	// 	[02]  C   ToolTip do campo 
				 "AK_SLDDATE"														,;	// 	[03]  C   Id do Field
				 "N"																,;	// 	[04]  C   Tipo do campo
				 TAMSX3("AK_LIMITE")[1]											,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual

//-- Campo Saldo Após a Liberação
oStr3:AddField(STR0018															,;	// 	[01]  C   Titulo do campo 
				 STR0018															,;	// 	[02]  C   ToolTip do campo
				 "AK_SLDCALC"														,;	// 	[03]  C   Id do Field
				 "N"																,;	// 	[04]  C   Tipo do campo
				 TAMSX3("AK_LIMITE")[1]											,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual


oStr3:AddField(  RetTitle("DHL_LIMMIN")																,;	// 	[01]  C   Titulo do campo
				 RetTitle("DHL_LIMMIN")																,;	// 	[02]  C   ToolTip do campo
				 "DHL_LIMMIN"														,;	// 	[03]  C   Id do Field
				 TAMSX3("DHL_LIMMIN")[3]																,;	// 	[04]  C   Tipo do campo
				 TAMSX3("DHL_LIMMIN")[1]											,;	// 	[05]  N   Tamanho do campo
				 TAMSX3("DHL_LIMMIN")[2]																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 .T.																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .T.																)	// 	[14]  L   Indica se o campo é virtual

oStr3:AddField(  RetTitle("DHL_LIMMAX")																,;	// 	[01]  C   Titulo do campo
				 RetTitle("DHL_LIMMAX")																,;	// 	[02]  C   ToolTip do campo
				 "DHL_LIMMAX"														,;	// 	[03]  C   Id do Field
				 TAMSX3("DHL_LIMMAX")[3]																,;	// 	[04]  C   Tipo do campo
				 TAMSX3("DHL_LIMMAX")[1]											,;	// 	[05]  N   Tamanho do campo
				 TAMSX3("DHL_LIMMAX")[2]																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 .T.																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .T.																)	// 	[14]  L   Indica se o campo é virtual

oStr3:AddField(  RetTitle("DHL_COD")												,;	// 	[01]  C   Titulo do campo
				 RetTitle("DHL_COD")												,;	// 	[02]  C   ToolTip do campo
				 "DHL_COD"														,;	// 	[03]  C   Id do Field
				 TAMSX3("DHL_COD")[3]															,;	// 	[04]  C   Tipo do campo
				 TAMSX3("DHL_COD")[1]											,;	// 	[05]  N   Tamanho do campo
				 TAMSX3("DHL_COD")[2]																,;	// 	[06]  N   Decimal do campo
				 NIL															,;	// 	[07]  B   Code-block de validação do campo
				 NIL															,;	// 	[08]  B   Code-block de validação When do campo
				 NIL															,;	//	[09]  A   Lista de valores permitido do campo
				 .F.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL															,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
				 .T.															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .T.															)	// 	[14]  L   Indica se o campo é virtual
//Campo Moeda quando na área de informações sobre aprovar
oStr3:AddField(STR0055																	,;	// 	[01]  C   Titulo do campo
					 STR0055															,;	// 	[02]  C   ToolTip do campo
					 "AK_DMOEDA"														,;	// 	[03]  C   Id do Field
					 "C"																,;	// 	[04]  C   Tipo do campo
					 10																	,;	// 	[05]  N   Tamanho do campo
					 0																	,;	// 	[06]  N   Decimal do campo
					 NIL																,;	// 	[07]  B   Code-block de validação do campo
					 {||.F.}																,;	// 	[08]  B   Code-block de validação When do campo
					 NIL																,;	//	[09]  A   Lista de valores permitido do campo
					 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {||cMoedaAtual}													,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.																)	// 	[14]  L   Indica se o campo é virtual				 

oStr3:AddField(  RetTitle("DHL_DESCRI")												,;	// 	[01]  C   Titulo do campo
				 RetTitle("DHL_DESCRI")													,;	// 	[02]  C   ToolTip do campo
				 "DHL_DESCRI"														,;	// 	[03]  C   Id do Field
				 TAMSX3("DHL_DESCRI")[3]															,;	// 	[04]  C   Tipo do campo
				 TAMSX3("DHL_DESCRI")[1]											,;	// 	[05]  N   Tamanho do campo
				 TAMSX3("DHL_DESCRI")[2]																,;	// 	[06]  N   Decimal do campo
				 NIL															,;	// 	[07]  B   Code-block de validação do campo
				 NIL															,;	// 	[08]  B   Code-block de validação When do campo
				 NIL															,;	//	[09]  A   Lista de valores permitido do campo
				 .F.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL															,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
				 .T.															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .T.															)	// 	[14]  L   Indica se o campo é virtual

//Campo Moeda no Grid da página, quando o tipo for Solicitação de Compra ou Nota Fiscal	
If SCR->CR_TIPO $ "PC|NF|IP|SC|AE"
	oStr4:AddField(STR0055																	,;	// 	[01]  C   Titulo do campo
					 STR0055															,;	// 	[02]  C   ToolTip do campo
					 "X_DMOEDA"														,;	// 	[03]  C   Id do Field
					 "N"																,;	// 	[04]  C   Tipo do campo
					 2																	,;	// 	[05]  N   Tamanho do campo
					 0																	,;	// 	[06]  N   Decimal do campo
					 NIL																,;	// 	[07]  B   Code-block de validação do campo
					 {||.F.}																,;	// 	[08]  B   Code-block de validação When do campo
					 NIL																,;	//	[09]  A   Lista de valores permitido do campo
					 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.																)	// 	[14]  L   Indica se o campo é virtualcampo
EndIf
If SCR->CR_TIPO == "NF"
	oStr4:AddField(	RetTitle("C7_QUANT")									,;	// 	[01]  C   Titulo do campo
						RetTitle("C7_QUANT")									,;	// 	[02]  C   ToolTip do campo
						"C7_QUANT"												,;	// 	[03]  C   Id do Field
						TAMSX3("C7_QUANT")[3]									,;	// 	[04]  C   Tipo do campo
						TAMSX3("C7_QUANT")[1]									,;	// 	[05]  N   Tamanho do campo
						TAMSX3("C7_QUANT")[2]									,;	// 	[06]  N   Decimal do campo
						NIL														,;	// 	[07]  B   Code-block de validacao do campo
						NIL														,;	// 	[08]  B   Code-block de validacao When do campo
						NIL														,;	//	[09]  A   Lista de valores permitido do campo
						NIL														,;	//	[10]  L   Indica se o campo tem preenchimento obrigatorio
						NIL														,;	//	[11]  B   Code-block de inicializacao do campo
						NIL														,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL														,;	//	[13]  L   Indica se o campo pode receber valor em uma operacao de update
						NIL														)	// 	[14]  L   Indica se o campo e virtual

	oStr4:AddField(	RetTitle("C7_PRECO")									,;	// 	[01]  C   Titulo do campo
						RetTitle("C7_PRECO")									,;	// 	[02]  C   ToolTip do campo
						"C7_PRECO"												,;	// 	[03]  C   Id do Field
						TAMSX3("C7_PRECO")[3]									,;	// 	[04]  C   Tipo do campo
						TAMSX3("C7_PRECO")[1]									,;	// 	[05]  N   Tamanho do campo
						TAMSX3("C7_PRECO")[2]									,;	// 	[06]  N   Decimal do campo
						NIL														,;	// 	[07]  B   Code-block de validacao do campo
						NIL														,;	// 	[08]  B   Code-block de validacao When do campo
						NIL														,;	//	[09]  A   Lista de valores permitido do campo
						NIL														,;	//	[10]  L   Indica se o campo tem preenchimento obrigatorio
						NIL														,;	//	[11]  B   Code-block de inicializacao do campo
						NIL														,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL														,;	//	[13]  L   Indica se o campo pode receber valor em uma operacao de update
						NIL														)	// 	[14]  L   Indica se o campo e virtual

	oStr4:AddField(	RetTitle("C7_QUJE")									,;	// 	[01]  C   Titulo do campo
						RetTitle("C7_QUJE")									,;	// 	[02]  C   ToolTip do campo
						"C7_QUJE"												,;	// 	[03]  C   Id do Field
						TAMSX3("C7_QUJE")[3]									,;	// 	[04]  C   Tipo do campo
						TAMSX3("C7_QUJE")[1]									,;	// 	[05]  N   Tamanho do campo
						TAMSX3("C7_QUJE")[2]									,;	// 	[06]  N   Decimal do campo
						NIL														,;	// 	[07]  B   Code-block de validacao do campo
						NIL														,;	// 	[08]  B   Code-block de validacao When do campo
						NIL														,;	//	[09]  A   Lista de valores permitido do campo
						NIL														,;	//	[10]  L   Indica se o campo tem preenchimento obrigatorio
						NIL														,;	//	[11]  B   Code-block de inicializacao do campo
						NIL														,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL														,;	//	[13]  L   Indica se o campo pode receber valor em uma operacao de update
						NIL														)	// 	[14]  L   Indica se o campo e virtual

	oStr4:AddField(	STR0037												,;	// 	[01]  C   Titulo do campo
						STR0037												,;	// 	[02]  C   ToolTip do campo
						"DIVERG"												,;	// 	[03]  C   Id do Field
						"C"														,;	// 	[04]  C   Tipo do campo
						30														,;	// 	[05]  N   Tamanho do campo
						0														,;	// 	[06]  N   Decimal do campo
						NIL														,;	// 	[07]  B   Code-block de validacao do campo
						NIL														,;	// 	[08]  B   Code-block de validacao When do campo
						NIL														,;	//	[09]  A   Lista de valores permitido do campo
						NIL														,;	//	[10]  L   Indica se o campo tem preenchimento obrigatorio
						NIL														,;	//	[11]  B   Code-block de inicializacao do campo
						NIL														,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL														,;	//	[13]  L   Indica se o campo pode receber valor em uma operacao de update
						NIL														)	// 	[14]  L   Indica se o campo e virtual
EndIf

oModel := MPFormModel():New('MATA094',/*PreModel*/, {|oModel| A094TudoOk(oModel)}, { |oModel| A094Commit( oModel ) },/*Cancel*/)
oModel:SetDescription(STR0006)

oModel:addFields('FieldSCR',,oStr1) 
oModel:addFields('FieldSAK','FieldSCR',oStr3)

oModel:SetRelation("FieldSAK",{{"AK_FILIAL",'xFilial("SAK")'},{"AK_COD","CR_APROV"}},SAK->(IndexKey(1)))
	
If cOperID == OP_REJ
	oStr1:SetProperty( 'CR_OBS' , MODEL_FIELD_OBRIGAT,.T.)
EndIf 

If SCR->CR_TIPO $ 'IP|SA|IC|IM|IR' .Or. (SCR->CR_TIPO == 'SC' .And. lAlcSolCtb)
	oModel:addFields('FieldDBL','FieldSCR',oStr2)
	
	oModel:SetRelation("FieldDBL",{{"DBL_FILIAL",'xFilial("DBL")'},{"DBL_GRUPO","CR_GRUPO"},{"DBL_ITEM","CR_ITGRP"}},DBL->(IndexKey(1)))
	
	If SCR->CR_TIPO == "IP"
		oModel:addGrid('DBMDETAIL','FieldSCR',oStrDBM)
		oModel:addGrid('GridDoc', 'DBMDETAIL', oStr4)
		oModel:setRelation("DBMDETAIL",{{'DBM_FILIAL','xFilial("DBM")'},{"DBM_TIPO","CR_TIPO"},{"DBM_NUM", "CR_NUM"}}, DBM->(IndexKey(1)))
		oModel:SetRelation("GridDoc",{{"C7_FILIAL",'xFilial("SC7")'},{"C7_NUM","DBM_NUM"}, {"C7_ITEM", "DBM_ITEM"}},SC7->(IndexKey(1)))
		
		//Posiciona no grupo da entidade contabil
		DBL->(dbSeek(xFilial('DBL')+SCR->(CR_GRUPO+CR_ITGRP)))

		//Filtros das entidades contabeis conforme a tabela DBL
		aFiltroSC7 := {}
		Aeval(aCamposC7,{|a,i|Aadd(aFiltroSC7,{a,"'"+DBL->(FieldGet(FieldPos(aCamposDBL[i]))) +"'"} ) })
		oModel:GetModel('GridDoc'):SetLoadFilter( aFiltroSC7 )
	Else
		oModel:addGrid('GridDoc','FieldSCR',oStr4)
	Endif
	
	oModel:getModel('GridDoc'):SetOnlyQuery(.T.)
	oModel:getModel('FieldDBL'):SetOnlyQuery(.T.)
	oModel:getModel('FieldDBL'):SetDescription(STR0019)
	oModel:getModel('GridDoc'):SetDescription(STR0020)
	// Aumenta numero maximo de linha das GRID's
    oModel:GetModel( "GridDoc" ):SetMaxLine( 9999 )
ElseIf SCR->CR_TIPO $ 'PC|NF|AE|CP'
	oModel:addGrid('GridDoc','FieldSCR',oStr4)
	oModel:getModel('GridDoc'):SetOnlyQuery(.T.)
	oModel:getModel('GridDoc'):SetDescription(STR0020)
	// Aumenta numero maximo de linha das GRID's
	oModel:GetModel( "GridDoc" ):SetMaxLine( 9999 )
EndIf

CNCCfgMdl(oModel)/*Configura o modelo da CNC p/ documentos oriundos do GCT*/

oModel:SetPrimaryKey( {} ) //Obrigatorio setar a chave primaria (mesmo que vazia)

oModel:getModel('FieldSAK'):SetOnlyQuery(.T.)
oModel:getModel('FieldSCR'):SetDescription(STR0021)

//--------------------------------------
//		Validacao para nao permitir execucao de registros ja processados
//--------------------------------------
oModel:SetVldActivate( {|oModel| A094VlMod(oModel) } )

//--------------------------------------
//		Realiza carga dos grids antes da exibicao
//--------------------------------------
oModel:SetActivate( { |oModel| A094FilPrd( oModel, aFiltroSC7 ) } )

Return oModel

Static function a094Cancel()
Return(.F.)
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author leonardo.quintania

@since 27/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView  := Nil
Local oModel := FWLoadModel("MATA094")
Local oStr1  := FWFormStruct(2,'SCR',{|cCampo| AllTrim(cCampo) $ "CR_NUM|CR_TOTAL|CR_EMISSAO|CR_DATALIB|CR_OBS"})
Local oStr2  := FWFormStruct(2,'DBL',{|cCampo| !AllTrim(cCampo) $ "DBL_GRUPO|DBL_ITEM"})
Local oStr3  := FWFormStruct(2,'SAK',{|cCampo| AllTrim(cCampo) $ "AK_NOME|AK_LIMITE|AK_TIPO"})
Local oStr4  := NIL
Local lAlcSolCtb := SuperGetMv("MV_APRSCEC",.F.,.F.)
Local cMT094CPC  := ""
Local cCampoPC   := ""
Local cMT094CCR  := ""
Local aMT094CCR	:= {}
Local nI			:= 0
Local aFieldAgro	:= {} // Documentos do modulo Agro
Local afieldPro     := {} // Documentos do modulo Agro
Local cCpoAddC3		:= SuperGetMv("MV_C094C3",.F.,"") 

If ExistBlock("MT094CPC")
    cCampoPC := ExecBlock( "MT094CPC", .f., .f.)
    cMT094CPC +=  IIF(VALTYPE(cCampoPC) == 'C',cCampoPC,'')
Endif

If ExistBlock("MT094CCR")
    cCampoPC := ExecBlock( "MT094CCR", .f., .f.)
    cMT094CCR +=  IIF(VALTYPE(cCampoPC) == 'C',cCampoPC,'')
Endif

If SCR->CR_TIPO $ 'IP|PC|AE'
	oStr4:= FWFormStruct(2,'SC7',{|cCampo| AllTrim(cCampo) $ "C7_ITEM|C7_PRODUTO|C7_DESCRI|C7_UM|C7_SEGUM|C7_QUANT|C7_PRECO|C7_TOTAL|C7_QTSEGUM|C7_VALFRE|C7_DESPESA|C7_SEGURO|C7_VALEMB|C7_VALIPI|C7_ICMSRET|C7_CODITE|C7_CODGRP"})
	oStr4:RemoveField( 'C7_DESC' )
ElseIf SCR->CR_TIPO == 'SA'
	oStr4:= FWFormStruct(2,'SCP',{|cCampo| AllTrim(cCampo) $ "CP_ITEM|CP_PRODUTO|CP_DESCRI|CP_UM|CP_SEGUM|CP_QUANT|CP_QTSEGUM"})
ElseIf SCR->CR_TIPO == 'SC'
	oStr4:= FWFormStruct(2,'SC1',{|cCampo| AllTrim(cCampo) $ "C1_ITEM|C1_PRODUTO|C1_DESCRI|C1_UM|C1_SEGUM|C1_QUANT|C1_QTSEGUM"})
ElseIf SCR->CR_TIPO $ 'IC|IR'
	oStr4:= FWFormStruct(2,'CNB',{|cCampo| AllTrim(cCampo) $ "CNB_ITEM|CNB_PRODUT|CNB_DESCRI|CNB_QUANT|CNB_VLUNIT|CNB_VLTOT|CNB_CC|CNB_CONTA|CNB_ITEMCT|CNB_CLVL"})
ElseIf SCR->CR_TIPO $ 'IM'
	oStr4:= FWFormStruct(2,'CNE',{|cCampo| AllTrim(cCampo) $ "CNE_ITEM|CNE_PRODUT|CNE_QUANT|CNE_VLUNIT|CNE_VLTOT|CNE_CC|CNE_CONTA|CNE_ITEMCT|CNE_CLVL"})
ElseIf SCR->CR_TIPO $ 'NF'
	oStr4:= FWFormStruct(2,'SD1',{|cCampo| AllTrim(cCampo) $ "D1_ITEM|D1_COD|D1_QUANT|D1_VUNIT|D1_PEDIDO|D1_ITEMPC"})
Elseif SCR->CR_TIPO == "CP" //Contrato Parceria
	oStr4:= FWFormStruct(2,'SC3',{|cCampo| AllTrim(cCampo) $ "C3_ITEM|C3_PRODUTO|C3_UM|C3_SEGUM|C3_QUANT|C3_QTSEGUM" + Iif(!Empty(cCpoAddC3),"|"+ cCpoAddC3,"")})
EndIf

If !(SCR->CR_TIPO $ 'SC|SA|CT|RV|MD|IM|IR|IC|A1|A2')
	//-- Campo fornecedor para tipos diferentes de SA e SC
	oStr1:AddField("CR_FORNECE"													,;	// [01]  C   Nome do Campo
					"10"																,;	// [02]  C   Ordem
					STR0016															,;	// [03]  C   Titulo do campo//"Descrição"
					STR0016															,;	// [04]  C   Descricao do campo//"Descrição"
					NIL																	,;	// [05]  A   Array com Help
					"C"																	,;	// [06]  C   Tipo do campo
					""																	,;	// [07]  C   Picture
					NIL																	,;	// [08]  B   Bloco de Picture Var
					NIL																	,;	// [09]  C   Consulta F3
					.F.																	,;	// [10]  L   Indica se o campo é alteravel
					NIL																	,;	// [11]  C   Pasta do campo
					NIL																	,;	// [12]  C   Agrupamento do campo
					NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL																	,;	// [15]  C   Inicializador de Browse
					.T.																	,;	// [16]  L   Indica se o campo é virtual
					NIL																	,;	// [17]  C   Picture Variavel
					NIL																	)	// [18]  L   Indica pulo de linha após o campo
EndIf

//Campo de Moeda na primeira área da págin, onde mostra as informações da alçada
oStr1:AddField(		"CR_DMOEDA"															,;	// [01]  C   Nome do Campo
					"12"																,;	// [02]  C   Ordem
					STR0055																,;	// [03]  C   Titulo do campo//"Descrição"
					STR0055																,;	// [04]  C   Descricao do campo//"Descrição"
					NIL																	,;	// [05]  A   Array com Help
					"C"																	,;	// [06]  C   Tipo do campo
					"@!"																,;	// [07]  C   Picture
					NIL																	,;	// [08]  B   Bloco de Picture Var
					NIL																	,;	// [09]  C   Consulta F3
					.F.																	,;	// [10]  L   Indica se o campo é alteravel
					NIL																	,;	// [11]  C   Pasta do campo
					NIL																	,;	// [12]  C   Agrupamento do campo
					NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL																	,;	// [15]  C   Inicializador de Browse
					.T.																	,;	// [16]  L   Indica se o campo é virtual
					NIL																	,;	// [17]  C   Picture Variavel
					NIL																	)	// [18]  L   Indica pulo de linha após o campo

If !(SCR->CR_TIPO $ 'CT')
	oStr1:RemoveField('CR_TOTAL')

	oStr1:AddField(	"CR_DTOTAL"															,;	// [01]  C   Nome do Campo
					"09"																,;	// [02]  C   Ordem
					STR0047																,;	// [03]  C   Titulo do campo//"Descrição"
					STR0047																,;	// [04]  C   Descricao do campo//"Descrição"
					NIL																	,;	// [05]  A   Array com Help
					TamSx3("CR_TOTAL")[3]												,;	// [06]  C   Tipo do campo
					X3Picture("CR_TOTAL")												,;	// [07]  C   Picture
					NIL																	,;	// [08]  B   Bloco de Picture Var
					NIL																	,;	// [09]  C   Consulta F3
					.F.																	,;	// [10]  L   Indica se o campo é alteravel
					NIL																	,;	// [11]  C   Pasta do campo
					NIL																	,;	// [12]  C   Agrupamento do campo
					NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL																	,;	// [15]  C   Inicializador de Browse
					.T.																	,;	// [16]  L   Indica se o campo é virtual
					NIL																	,;	// [17]  C   Picture Variavel
					NIL																	)	// [18]  L   Indica pulo de linha após o campo
Endif

If !Empty(cMT094CCR)
	aMT094CCR := Separa(cMT094CCR,"|")
	For nI := 1 To Len(aMT094CCR)
		If !Empty(aMT094CCR[nI]) .And. Upper(SubStr(aMT094CCR[nI], 1, 2)) == "CR"
			oStr1:AddField(aMT094CCR[nI]												,;	// [01]  C   Nome do Campo
						X3Ordem(aMT094CCR[nI])											,;	// [02]  C   Ordem
						RetTitle(aMT094CCR[nI])											,;	// [03]  C   Titulo do campo//"Descrição"
						RetTitle(aMT094CCR[nI])											,;	// [04]  C   Descricao do campo//"Descrição"
						NIL																	,;	// [05]  A   Array com Help
						TamSx3(aMT094CCR[nI])[3]											,;	// [06]  C   Tipo do campo
						PesqPict("SCR",aMT094CCR[nI])										,;	// [07]  C   Picture
						NIL																	,;	// [08]  B   Bloco de Picture Var
						NIL																	,;	// [09]  C   Consulta F3
						.F.																	,;	// [10]  L   Indica se o campo é alteravel
						NIL																	,;	// [11]  C   Pasta do campo
						NIL																	,;	// [12]  C   Agrupamento do campo
						NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL																	,;	// [15]  C   Inicializador de Browse
						.T.																	,;	// [16]  L   Indica se o campo é virtual
						NIL																	,;	// [17]  C   Picture Variavel
						NIL																	)	// [18]  L   Indica pulo de linha após o campo
		Endif
	Next nI
Endif

If !Empty(cMT094CPC) .And. SCR->CR_TIPO $ "PC|IP|AE"
	aMT094CPC := Separa(cMT094CPC,"|")
	For nI := 1 To Len(aMT094CPC)
		If !Empty(aMT094CPC[nI]) .And. Upper(SubStr(aMT094CPC[nI], 1, 2)) == "C7"
			oStr4:AddField(aMT094CPC[nI]												,;	// [01]  C   Nome do Campo
						X3Ordem(aMT094CPC[nI])											,;	// [02]  C   Ordem
						RetTitle(aMT094CPC[nI])											,;	// [03]  C   Titulo do campo//"Descrição"
						RetTitle(aMT094CPC[nI])											,;	// [04]  C   Descricao do campo//"Descrição"
						NIL																	,;	// [05]  A   Array com Help
						TamSx3(aMT094CPC[nI])[3]											,;	// [06]  C   Tipo do campo
						PesqPict("SC7",aMT094CPC[nI])										,;	// [07]  C   Picture
						NIL																	,;	// [08]  B   Bloco de Picture Var
						NIL																	,;	// [09]  C   Consulta F3
						.F.																	,;	// [10]  L   Indica se o campo é alteravel
						NIL																	,;	// [11]  C   Pasta do campo
						NIL																	,;	// [12]  C   Agrupamento do campo
						NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL																	,;	// [15]  C   Inicializador de Browse
						Iif(GetSx3Cache(aMT094CPC[nI], "X3_CONTEXT")=="V",.T.,.F.)			,;	// [16]  L   Indica se o campo é virtual
						NIL																	,;	// [17]  C   Picture Variavel
						NIL																	)	// [18]  L   Indica pulo de linha após o campo
		Endif
	Next nI
Endif

If SCR->CR_TIPO >= "A1" .AND. SCR->CR_TIPO <= "A9" // Documentos do modulo Agro

    If FindFunction("OGXUtlOrig") //Identifica que esta utilizando o sigaagr				
		If OGXUtlOrig() .AND. FindFunction("OGX701AALC")	
			//Retorna um array com os dado para adicionar no oStruct
			aFieldAgro := AGRXCOM9( SCR->CR_NUM, SCR->CR_TIPO, SCR->(RECNO()) ) 
	        
            //retorna um array com os dados para realizar o property dos campos
            afieldPro  := AGRXCOM10( SCR->CR_NUM, SCR->CR_TIPO, SCR->(RECNO()) ) 

            For nI := 1 To Len(afieldPro)
                oStr1:SetProperty(afieldPro[nI][1], afieldPro[nI][2], afieldPro[nI][3])
            Next nI

            For nI := 1 To Len(aFieldAgro)
                oStr1:AddField(aFieldAgro[nI][01]	,;	// [01]  C   Nome do Campo
                               aFieldAgro[nI][02]	,;	// [02]  C   Ordem
                               aFieldAgro[nI][03]	,;	// [03]  C   Titulo do campo//"Descrição"
                               aFieldAgro[nI][04]	,;	// [04]  C   Descricao do campo//"Descrição"
                               aFieldAgro[nI][05]	,;	// [05]  A   Array com Help
                               aFieldAgro[nI][06]	,;	// [06]  C   Tipo do campo
                               aFieldAgro[nI][07]	,;	// [07]  C   Picture
                               aFieldAgro[nI][08]	,;	// [08]  B   Bloco de Picture Var
                               aFieldAgro[nI][09]	,;	// [09]  C   Consulta F3
                               aFieldAgro[nI][10]	,;	// [10]  L   Indica se o campo é alteravel
                               aFieldAgro[nI][11]	,;	// [11]  C   Pasta do campo
                               aFieldAgro[nI][12]	,;	// [12]  C   Agrupamento do campo
                               aFieldAgro[nI][13]	,;	// [13]  A   Lista de valores permitido do campo (Combo)
                               aFieldAgro[nI][14]	,;	// [14]  N   Tamanho maximo da maior opção do combo
                               aFieldAgro[nI][15]	,;	// [15]  C   Inicializador de Browse
                               aFieldAgro[nI][16]	,;	// [16]  L   Indica se o campo é virtual
                               aFieldAgro[nI][17]	,;	// [17]  C   Picture Variavel
                               aFieldAgro[nI][18]	)	// [18]  L   Indica pulo de linha após o campo
            Next nI                                                                                    
        Endif
    EndIf

EndIf

//-- Campo Saldo na Data
oStr3:AddField("AK_SLDDATE"														,;	// [01]  C   Nome do Campo
				"11"																,;	// [02]  C   Ordem
				STR0017															,;	// [03]  C   Titulo do campo
				STR0017															,;	// [04]  C   Descricao do campo
				NIL																	,;	// [05]  A   Array com Help
				"N"																	,;	// [06]  C   Tipo do campo
				PesqPict("SAK","AK_LIMITE")										,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo

//-- Campo Saldo Após a Liberação
oStr3:AddField("AK_SLDCALC"														,;	// [01]  C   Nome do Campo
				"12"																,;	// [02]  C   Ordem
				STR0018															,;	// [03]  C   Titulo do campo
				STR0018															,;	// [04]  C   Descricao do campo
				NIL																	,;	// [05]  A   Array com Help
				"N"																	,;	// [06]  C   Tipo do campo
				PesqPict("SAK","AK_LIMITE")										,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo	

oStr3:AddField("DHL_LIMMIN"														,;	// [01]  C   Nome do Campo
				"13"																,;	// [02]  C   Ordem
				RetTitle("DHL_LIMMIN")															,;	// [03]  C   Titulo do campo
				RetTitle("DHL_LIMMIN")															,;	// [04]  C   Descricao do campo
				NIL																	,;	// [05]  A   Array com Help
				TAMSX3("DHL_LIMMIN")[3]																	,;	// [06]  C   Tipo do campo
				PesqPict("DHL","DHL_LIMMAX")										,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.T.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo

oStr3:AddField("DHL_LIMMAX"														,;	// [01]  C   Nome do Campo
				"14"																,;	// [02]  C   Ordem
				RetTitle("DHL_LIMMAX")															,;	// [03]  C   Titulo do campo
				RetTitle("DHL_LIMMAX")															,;	// [04]  C   Descricao do campo
				NIL																	,;	// [05]  A   Array com Help
				TAMSX3("DHL_LIMMAX")[3]																	,;	// [06]  C   Tipo do campo
				PesqPict("DHL","DHL_LIMMAX")										,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.T.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo

oStr3:AddField("DHL_COD"														,;	// [01]  C   Nome do Campo
				"15"																,;	// [02]  C   Ordem
				RetTitle("DHL_COD")															,;	// [03]  C   Titulo do campo
				RetTitle("DHL_COD")															,;	// [04]  C   Descricao do campo
				NIL																	,;	// [05]  A   Array com Help
				TAMSX3("DHL_COD")[3]																	,;	// [06]  C   Tipo do campo
				PesqPict("DHL","DHL_COD")										,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.T.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo

//Campo Moeda quando na área de informações sobre aprovar				
oStr3:AddField("AK_DMOEDA"													,;	// [01]  C   Nome do Campo
					"12"																,;	// [02]  C   Ordem
					STR0055															,;	// [03]  C   Titulo do campo//"Descrição"
					STR0055															,;	// [04]  C   Descricao do campo//"Descrição"
					NIL																	,;	// [05]  A   Array com Help
					"C"																	,;	// [06]  C   Tipo do campo
					"@!"																	,;	// [07]  C   Picture
					NIL																	,;	// [08]  B   Bloco de Picture Var
					NIL																	,;	// [09]  C   Consulta F3
					.F.																	,;	// [10]  L   Indica se o campo é alteravel
					NIL																	,;	// [11]  C   Pasta do campo
					NIL																	,;	// [12]  C   Agrupamento do campo
					NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL																	,;	// [15]  C   Inicializador de Browse
					.T.																	,;	// [16]  L   Indica se o campo é virtual
					NIL																	,;	// [17]  C   Picture Variavel
					NIL																	)	// [18]  L   Indica pulo de linha após o campo

oStr3:AddField("DHL_DESCRI"														,;	// [01]  C   Nome do Campo
				"16"																,;	// [02]  C   Ordem
				RetTitle("DHL_DESCRI")															,;	// [03]  C   Titulo do campo
				RetTitle("DHL_DESCRI")															,;	// [04]  C   Descricao do campo
				NIL																	,;	// [05]  A   Array com Help
				TAMSX3("DHL_DESCRI")[3]																	,;	// [06]  C   Tipo do campo
				PesqPict("DHL","DHL_DESCRI")										,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.T.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo

//Campo Moeda no Grid da página, quando o tipo for Solicitação de Compra ou Nota Fiscal				
If SCR->CR_TIPO $ "PC|NF|IP|SC|AE"
	oStr4:AddField("X_DMOEDA"													,;	// [01]  C   Nome do Campo
						"11"																,;	// [02]  C   Ordem
						STR0055															,;	// [03]  C   Titulo do campo//"Descrição"
						STR0055															,;	// [04]  C   Descricao do campo//"Descrição"
						NIL																	,;	// [05]  A   Array com Help
						"N"																	,;	// [06]  C   Tipo do campo
						"@!"																	,;	// [07]  C   Picture
						NIL																	,;	// [08]  B   Bloco de Picture Var
						NIL																	,;	// [09]  C   Consulta F3
						.F.																	,;	// [10]  L   Indica se o campo é alteravel
						NIL																	,;	// [11]  C   Pasta do campo
						NIL																	,;	// [12]  C   Agrupamento do campo
						NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL																	,;	// [15]  C   Inicializador de Browse
						.T.																	,;	// [16]  L   Indica se o campo é virtual
						NIL																	,;	// [17]  C   Picture Variavel
						NIL																	)	// [18]  L   Indica pulo de linha após o campo
EndIf
If SCR->CR_TIPO == "NF"
	oStr4:AddField(	"C7_QUANT"													,;	// [01]  C   Nome do Campo
						"96"														,;	// [02]  C   Ordem
						RetTitle("C7_QUANT")										,;	// [03]  C   Titulo do campo
						RetTitle("C7_QUANT")										,;	// [04]  C   Descricao do campo
						NIL															,;	// [05]  A   Array com Help
						TAMSX3("C7_QUANT")[3]										,;	// [06]  C   Tipo do campo
						PesqPict("SC7","C7_QUANT")								,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var
						NIL															,;	// [09]  C   Consulta F3
						NIL															,;	// [10]  L   Indica se o campo e alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opcao do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						NIL															,;	// [16]  L   Indica se o campo e virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha apos o campo

	oStr4:AddField(	"C7_PRECO"													,;	// [01]  C   Nome do Campo
						"97"														,;	// [02]  C   Ordem
						RetTitle("C7_PRECO")										,;	// [03]  C   Titulo do campo
						RetTitle("C7_PRECO")										,;	// [04]  C   Descricao do campo
						NIL															,;	// [05]  A   Array com Help
						TAMSX3("C7_PRECO")[3]										,;	// [06]  C   Tipo do campo
						PesqPict("SC7","C7_PRECO")								,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var
						NIL															,;	// [09]  C   Consulta F3
						NIL															,;	// [10]  L   Indica se o campo e alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opcao do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						NIL															,;	// [16]  L   Indica se o campo e virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha apos o campo

	oStr4:AddField(	"C7_QUJE"													,;	// [01]  C   Nome do Campo
						"98"														,;	// [02]  C   Ordem
						RetTitle("C7_QUJE")										,;	// [03]  C   Titulo do campo
						RetTitle("C7_QUJE")										,;	// [04]  C   Descricao do campo
						NIL															,;	// [05]  A   Array com Help
						TAMSX3("C7_QUJE")[3]										,;	// [06]  C   Tipo do campo
						PesqPict("SC7","C7_QUJE")								,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var
						NIL															,;	// [09]  C   Consulta F3
						NIL															,;	// [10]  L   Indica se o campo e alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opcao do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						NIL															,;	// [16]  L   Indica se o campo e virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha apos o campo
	oStr4:AddField(	"DIVERG"													,;	// [01]  C   Nome do Campo
						"99"														,;	// [02]  C   Ordem
						STR0037													,;	// [03]  C   Titulo do campo
						STR0037													,;	// [04]  C   Descricao do campo
						NIL															,;	// [05]  A   Array com Help
						"C"															,;	// [06]  C   Tipo do campo
						"@X"														,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var
						NIL															,;	// [09]  C   Consulta F3
						NIL															,;	// [10]  L   Indica se o campo e alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opcao do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						NIL															,;	// [16]  L   Indica se o campo e virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha apos o campo
EndIf

SAL->(dbSetOrder(3))
SAL->(MsSeek(xFilial("SAL")+SCR->(CR_GRUPO+CR_APROV)))

If SAL->AL_LIBAPR == "V"
	oStr3:RemoveField("AK_SLDCALC")
EndIF

If lLGPD .And. !(SCR->CR_TIPO $ 'SC|SA|CT|RV|MD|IM|IR|IC|A1|A2')
	oStr1:SetProperty( "CR_FORNECE" , MVC_VIEW_OBFUSCATED , OfuscaLGPD(,"A2_NOME") )
Endif

oStr3:SetProperty( "AK_LIMITE" , MVC_VIEW_TITULO , RetTitle("DHL_LIMITE"))
oStr3:SetProperty( "AK_TIPO"   , MVC_VIEW_TITULO , RetTitle("DHL_TIPO")  )

oView := FWFormView():New()
oView:showUpdateMsg(.F.)
oView:showInsertMsg(.T.)

oView:SetModel(oModel)
oView:AddField('SCRField' , oStr1,'FieldSCR' )
oView:AddField('SAKField' , oStr3,'FieldSAK' )

If SCR->CR_TIPO $ 'IP|SA|IC|IR|IM' .Or. (SCR->CR_TIPO == 'SC' .And. lAlcSolCtb)
	oView:AddField('DBLField' , oStr2,'FieldDBL' )
	oView:AddGrid('GridDoc'   , oStr4,'GridDoc')  
ElseIf SCR->CR_TIPO $ 'PC|NF|AE|CP'
	oView:AddGrid('GridDoc'   , oStr4,'GridDoc')	
EndIf

CNCCfgView(oView)/*Configura em <oView> o submodelo da CNC p/ documentos oriundos do GCT.*/

If SCR->CR_TIPO $ 'IP|SA' .Or. (SCR->CR_TIPO == 'SC' .And. lAlcSolCtb)
	oView:CreateHorizontalBox( 'CimaSCR' , 30)
	oView:CreateHorizontalBox( 'MeioDBL' , 25)
	oView:CreateHorizontalBox( 'MeioSAK' , 20)
	oView:CreateHorizontalBox( 'BaixoDOC', 25)
ElseIf SCR->CR_TIPO $ 'IC|IR|IM'
	oView:CreateHorizontalBox( 'CimaSCR' , 34)
	oView:CreateHorizontalBox( 'MeioDBL' , 18)
	oView:CreateHorizontalBox( 'MeioSAK' , 18)
	oView:CreateHorizontalBox( 'BaixoDOC', 30)
ElseIf SCR->CR_TIPO $ 'PC|AE|CP'
	oView:CreateHorizontalBox( 'CimaSCR' , 30)
	oView:CreateHorizontalBox( 'MeioSAK' , 20)
	oView:CreateHorizontalBox( 'BaixoDOC', 50)
ElseIf SCR->CR_TIPO $ 'NF|CT|RV|MD'
	oView:CreateHorizontalBox( 'CimaSCR' , 40)
	oView:CreateHorizontalBox( 'MeioSAK' , 30)
	oView:CreateHorizontalBox( 'BaixoDOC', 30)
Else
	oView:CreateHorizontalBox( 'CimaSCR' , 50)
	oView:CreateHorizontalBox( 'MeioSAK' , 50)
EndIf

oView:SetOwnerView('SCRField','CimaSCR')
oView:EnableTitleView('SCRField' , STR0022 )//"Dados do Documento"  

oView:SetOwnerView('SAKField','MeioSAK')
oView:EnableTitleView('SAKField' , STR0023 ) //"Dados do Aprovador" 
oView:SetViewProperty('SAKField' , 'ONLYVIEW' )

If SCR->CR_TIPO $ 'IP|SA' .Or. (SCR->CR_TIPO == 'SC' .And. lAlcSolCtb)
	oView:SetOwnerView('DBLField','MeioDBL')
	oView:EnableTitleView('DBLField' , STR0019 ) //"Dados das Entidades Contábeis"
	oView:SetViewProperty('DBLField' , 'ONLYVIEW' )
	oView:SetOwnerView('GridDoc','BaixoDOC')
	oView:EnableTitleView('GridDoc' , STR0020 ) //"Itens"
	oView:SetViewProperty('GridDoc'  , 'ONLYVIEW' )
ElseIf SCR->CR_TIPO $ 'IC|IR|IM'
	oView:SetOwnerView('DBLField','MeioDBL')
	oView:EnableTitleView('DBLField' , STR0019 ) //"Dados das Entidades Contábeis"
	oView:SetViewProperty('DBLField' , 'ONLYVIEW') 
	oView:CreateFolder('FLDBAIXO','BaixoDOC')
	oView:AddSheet('FLDBAIXO','GRDITM',STR0020)
	oView:AddSheet('FLDBAIXO','GRDFOR',STR0064)//Planilhas do Contrato
	oView:CreateHorizontalBox('BOXITM',100,,,'FLDBAIXO','GRDITM')
	oView:CreateHorizontalBox('BOXFOR',100,,,'FLDBAIXO','GRDFOR')
	oView:SetOwnerView('GridDoc','BOXITM')
	oView:SetOwnerView('GridFor','BOXFOR')
	oView:SetViewProperty('GridDoc'  , 'ONLYVIEW' )
	oView:SetViewProperty('GridFor','ONLYVIEW')
ElseIf SCR->CR_TIPO $ 'PC|NF|AE|CP'
	oView:SetOwnerView('GridDoc','BaixoDOC')
	oView:EnableTitleView('GridDoc' , STR0020 ) //"Itens" 
	oView:SetViewProperty('GridDoc'  , 'ONLYVIEW' )
ElseIf SCR->CR_TIPO $ 'CT|RV|MD'
	oView:SetOwnerView('GridFor','BaixoDOC')
	oView:EnableTitleView('GridFor',STR0064)//Planilhas do Contrato
	oView:SetViewProperty('GridFor','ONLYVIEW')
ElseIf SCR->CR_TIPO >= "A1" .AND. SCR->CR_TIPO <= "A9"  // Documentos do modulo Agro
	oView:AddUserButton("Documento Emitido" ,'',{|| A097Visual(,,'2') } ) 
EndIf

oView:SetCloseOnOK({||.T.}) 

If cOperID == OP_VIW
	oView:SetViewProperty("*", "ONLYVIEW")      
EndIf 

oView:SetViewAction("ASKONCANCELSHOW", {|| a094Cancel()})

Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} A094FilPrd()
Realiza filtro para carregar os documentos com alcadas
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return .T.
/*/
//--------------------------------------------------------------------
Static Function A094FilPrd(oModel, aFiltroSC7)

Local oView		:= FWViewActive()
Local oFieldSCR	:= oModel:GetModel("FieldSCR")
Local oFieldSAK	:= oModel:GetModel("FieldSAK")
Local oModelGrid:= oModel:GetModel("GridDoc")
Local aSaldo	:= {}
Local aCamposPE	:= {}
Local cIdOption	:= cOperID
Local cAprovS	:= ""
Local cDocBkp	:= ""
Local cContra	:= ""
Local cRev		:= ""
Local cNum		:= ""
Local cPlan		:= ""
Local cItem		:= ""
Local cItemRa	:= ""
Local cCamposPE	:= ""
Local nLinha	:= 1
Local nQtdItPed := 0
Local nTamC7Num	:= TamSX3("C7_NUM")[1]
Local nTamCPNum	:= TamSX3("CP_NUM")[1]
Local nTamC1Num	:= TamSX3("C1_NUM")[1]
Local nTamF1Doc	:= TamSX3("F1_DOC")[1]
Local nTamF1Ser	:= TamSX3("F1_SERIE")[1]
Local nTamF1For	:= TamSX3("F1_FORNECE")[1]
Local nTamF1Loj	:= TamSX3("F1_LOJA")[1]
Local nTamD1Vun	:= TamSX3("D1_VUNIT")[2]
Local nX		:= 0
Local lAlcSolCtb:= SuperGetMv("MV_APRSCEC",.F.,.F.)
Local lSeek     := .F.
Local lQtd		:= .F.
Local lVlr		:= .F.
Local lTolerNeg := GetNewPar("MV_TOLENEG",.F.)
Local cTolent	:= SuperGetMV("MV_TOLENT",.F.,"1")
Local lDescTol	:= SuperGetMv("MV_DESCTOL",.F.,.F.)
Local lMt094Cpc := ExistBlock("MT094CPC")
Local aFieldAgro:= {} //
Local nI
Local nMoedaCalc:= 0			//Variável que receberá valor convertido da SCR->CR_TOTAL
Local cEntCtb	:= ""
Local cDiverg   := ''
Local lPrazo	:= .F.
Local cCpoAddC3	:= SuperGetMv("MV_C094C3",.F.,"")
Local lNfMotBloq	:= SCR->(FIELDPOS("CR_NFMOBLQ")) > 0
Local aNfMotBloq 	:= {} 
Local cItemNF 	    := ""
Local nPos		    := 0
Local lPosCrTipo    := SCR->(FieldPos("CR_TIPCOM")) > 0
Local cwhere		:= ""

SAK->(dbSetOrder(1))
SAK->(MsSeek(xFilial("SAK")+SCR->CR_APROV))

SAL->(dbSetOrder(3))
SAL->(MsSeek(xFilial("SAL")+SCR->(CR_GRUPO+CR_APROV)))

If cOperID <> OP_VIW // impede que não seja carregado a data base no campo de dataliberação somente nos casos de visualização
	oFieldSCR:LoadValue("CR_DATALIB"  , dDataBase   ) //Gatilha Data de liberação
EndIf

If cIdOption == OP_TRA .Or. cIdOption == OP_SUP 
	cAprovS:= SAK->AK_APROSUP
	If Empty(cAprovS)
		cAprovS := SAL->AL_APROSUP 
	Endif
	SAK->(dbSetOrder(1))
	SAK->(MsSeek(xFilial("SAK")+cAprovS))
	aSaldo:= MaSalAlc(cAprovS,MaAlcDtRef(cAprovS,IIF(Empty(oFieldSCR:GetValue("CR_DATALIB")),dDataBase,oFieldSCR:GetValue("CR_DATALIB")))) //Calcula saldo na data
	If ValType(oView) == 'O'
		oView:EnableTitleView('SAKField' , STR0024 ) //Dados do Superior
	EndIf
ElseIf cIdOption == OP_LIB .Or. cIdOption == OP_REJ .Or. cIdOption == OP_BLQ .Or. cIdOption == OP_VIW
	aSaldo:= MaSalAlc(SCR->CR_APROV,MaAlcDtRef(SCR->CR_APROV,IIF(Empty(oFieldSCR:GetValue("CR_DATALIB")),dDataBase,oFieldSCR:GetValue("CR_DATALIB")))) //Calcula saldo na data
	If ValType(oView) == 'O'
		oView:EnableTitleView('SAKField' , STR0023 ) //Dados do Aprovador
	EndIf
EndIf	

oFieldSAK:LoadValue("AK_NOME"		, SAK->AK_NOME   )
oFieldSAK:LoadValue("AK_LIMITE"		, SAK->AK_LIMITE )
oFieldSAK:LoadValue("AK_TIPO"		, SAK->AK_TIPO   )
oFieldSAK:LoadValue("AK_SLDDATE"  	, aSaldo[1]) //Calcula saldo na data com os dados do aprovador

If cIdOption <> OP_VIW .Or. SCR->CR_STATUS == '02'
	nMoedaCalc := xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aSaldo[2],SCR->CR_EMISSAO,TamSX3('CR_TOTAL')[2],SCR->CR_TXMOEDA)
	oFieldSAK:LoadValue( "AK_SLDCALC", oFieldSAK:GetValue("AK_SLDDATE") - nMoedaCalc ) //Realiza calculo do saldo atual, subtraindo a quantidade do documento
Else
	nMoedaCalc := SCR->CR_TOTAL
	oFieldSAK:LoadValue( "AK_SLDCALC", oFieldSAK:GetValue("AK_SLDDATE") ) //na opção de visualizacao, não ha modificacao no valor de liberação.
Endif
	
DBselectArea("DHL")
DbSetOrder(1)
DbSeek(xFilial("DHL") + SAL->AL_PERFIL)
oFieldSAK:LoadValue("DHL_COD"		, DHL->DHL_COD		)
oFieldSAK:LoadValue("DHL_DESCRI"	, DHL->DHL_DESCRI	)
oFieldSAK:LoadValue("DHL_LIMMAX"	, xMoeda(DHL->DHL_LIMMAX, DHL->DHL_MOEDA,aSaldo[2],SCR->CR_EMISSAO,TAMSX3('DHL_MOEDA')[2],SCR->CR_TXMOEDA))
oFieldSAK:LoadValue("DHL_LIMMIN"	, xMoeda(DHL->DHL_LIMMIN, DHL->DHL_MOEDA,aSaldo[2],SCR->CR_EMISSAO,TAMSX3('DHL_MOEDA')[2],SCR->CR_TXMOEDA))

If SCR->CR_TIPO $ 'IP|SA|IC|IR|IM' .Or. (SCR->CR_TIPO == 'SC' .And. lAlcSolCtb)
	//--------------------------------------
	//		Configura modelo 
	//--------------------------------------
	oModelGrid:SetNoInsertLine( .F. )
	oModelGrid:SetNoDeleteLine( .F. )
	
	//--------------------------------------
	//		Procura na tabela de Itens(DBM)
	//--------------------------------------

	If FWModeAccess("DBM",3) == 'E' // tabela em modo exclusivo
		cwhere := "% DBM.DBM_FILIAL= '" + xFilial("SC7") + "' AND  "
		cwhere += " DBM.DBM_NUM = '"    + SCR->CR_NUM    + "' AND  "
	Else
		cwhere := "% DBM.DBM_NUM = '"    + SCR->CR_NUM    + "' AND  "
	Endif
	cwhere += " DBM.DBM_ITGRP  = '" + SCR->CR_ITGRP  + "' AND  "
	If lPosCrTipo .AND.  !Empty(SCR->CR_TIPCOM)
		cwhere += " DBM.DBM_TIPCOM = '" + SCR->CR_TIPCOM + "' AND "
	Endif
	cwhere += " DBM.DBM_GRUPO  = '" + SCR->CR_GRUPO  + "' AND  "
	cwhere += " DBM.DBM_USER   = '" + SCR->CR_USER   + "' AND  "
	cwhere += " DBM.DBM_USAPRO = '" + SCR->CR_APROV  + "' AND  "
	cwhere += " DBM.D_E_L_E_T_ = ' ' %"

	BeginSQL Alias "DBMTMP"
		SELECT DBM.DBM_NUM, DBM.DBM_ITEM,DBM.DBM_ITEMRA, DBM.DBM_APROV
	   	FROM %Table:DBM% DBM
	   WHERE %Exp:cwhere% 
	EndSQL
ElseIf SCR->CR_TIPO $ 'PC|AE'
	//--------------------------------------
	//		Configura modelo 
	//--------------------------------------
	oModelGrid:SetNoInsertLine( .F. )
	oModelGrid:SetNoDeleteLine( .F. )
	
	cEntCtb := "%"+StrTran(cFieldSC7,'|',',')+"%"
	
	//--------------------------------------
	//		Procura na tabela de Itens(DBM)
	//--------------------------------------
	BeginSQL Alias "SC7TMP"
		SELECT SC7.C7_NUM,SC7.C7_ITEM, SC7.C7_PRODUTO,SC7.C7_DESCRI,SC7.C7_UM,SC7.C7_SEGUM,SC7.C7_PRECO,SC7.C7_QUANT,SC7.C7_TOTAL,SC7.C7_MOEDA,
		SC7.C7_QTSEGUM,SC7.C7_VALFRE,SC7.C7_RESIDUO,SC7.C7_DESPESA,SC7.C7_SEGURO,SC7.C7_VALEMB,SC7.C7_ITEMGRD %exp:cEntCtb%
	   	FROM %Table:SC7% SC7
	   WHERE SC7.C7_FILIAL=%xFilial:SC7% AND	SC7.C7_NUM = %Exp:SCR->CR_NUM%    AND SC7.C7_RESIDUO <> 'S' AND ;
	   SC7.%NotDel%
	EndSQL
EndIf
If SCR->CR_TIPO $ 'SC|SA'
	oFieldSCR:LoadValue("CR_DTOTAL", nMoedaCalc)
EndIf
If SCR->CR_TIPO $ 'PC|AE' 
	If SC7->(dbSeek(xFilial("SC7")+ AllTrim(SCR->CR_NUM) ) )		
		oFieldSCR:LoadValue("CR_FORNECE"  ,POSICIONE("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA ,"A2_NOME"))
		oFieldSCR:LoadValue("CR_DTOTAL", nMoedaCalc)
	EndIf
	While !SC7TMP->(EOF()) 
		If SC7->(dbSeek(xFilial("SC7")+ SC7TMP->(C7_NUM+C7_ITEM) ) )
			
			If nLinha # 1
				oModelGrid:AddLine()
			EndIf
			oModelGrid:GoLine( nLinha )
			oModelGrid:LoadValue("C7_ITEM"		, SC7TMP->C7_ITEM)
			oModelGrid:LoadValue("C7_PRODUTO" 	, SC7TMP->C7_PRODUTO )
			oModelGrid:LoadValue("C7_DESCRI"	, SC7TMP->C7_DESCRI  )
			oModelGrid:LoadValue("C7_UM"		, SC7TMP->C7_UM      )
			oModelGrid:LoadValue("C7_SEGUM"		, SC7TMP->C7_SEGUM   )
			oModelGrid:LoadValue("C7_PRECO"		, SC7TMP->C7_PRECO   )			
			oFieldSCR:LoadValue("CR_FORNECE"  ,POSICIONE("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA ,"A2_NOME"))
			oModelGrid:LoadValue("C7_QUANT"		, SC7TMP->C7_QUANT	)
			oModelGrid:LoadValue("C7_TOTAL"		, SC7TMP->C7_TOTAL	)
			oModelGrid:LoadValue("X_DMOEDA"		, SC7TMP->C7_MOEDA	)
			oModelGrid:LoadValue("C7_QTSEGUM"	, SC7TMP->C7_QTSEGUM	)
			
			oModelGrid:LoadValue("C7_VALFRE"	, SC7TMP->C7_VALFRE	)
			oModelGrid:LoadValue("C7_DESPESA"	, SC7TMP->C7_DESPESA	)
			oModelGrid:LoadValue("C7_SEGURO"	, SC7TMP->C7_SEGURO	)
			oModelGrid:LoadValue("C7_VALEMB"	, SC7TMP->C7_VALEMB	)
			If oModelGrid:HasField("C7_VALIPI")
				oModelGrid:LoadValue("C7_VALIPI",POSICIONE("SC7",1,xFilial("SC7")+SC7TMP->C7_NUM+SC7TMP->C7_ITEM,"C7_VALIPI"))
			EndIf
			If oModelGrid:HasField("C7_ICMSRET")
				oModelGrid:LoadValue("C7_ICMSRET",POSICIONE("SC7",1,xFilial("SC7")+SC7TMP->C7_NUM+SC7TMP->C7_ITEM,"C7_ICMSRET"))
			EndIf

			If oModelGrid:HasField("C7_CODGRP")
				oModelGrid:LoadValue("C7_CODGRP", IniAuxCod(SC7->C7_PRODUTO,"C7_CODGRP") )
			EndIf
			If oModelGrid:HasField("C7_CODITE")
				oModelGrid:LoadValue("C7_CODITE", IniAuxCod(SC7->C7_PRODUTO,"C7_CODITE") )
			EndIf

			If lMt094Cpc
				cCamposPE := ExecBlock("MT094CPC",.F.,.F.)
				If SC7->(DbSeek(xFilial("SC7")+SC7TMP->C7_NUM+SC7TMP->C7_ITEM)) .And. ValType(cCamposPE) == "C" .And. !Empty(cCamposPE)
					aCamposPE := Separa(cCamposPE,"|")
					For nX := 1 To Len(aCamposPE)
						If !Empty(aCamposPE[nX]) .And. Upper(SubStr(aCamposPE[nX], 1, 2)) == "C7" 
							If GetSx3Cache(aCamposPE[nX], "X3_CONTEXT") == 'V' //caso seja virtual, carrega inicializador padrão
								oModelGrid:LoadValue(aCamposPE[nX],Padr(&(GetSx3Cache(aCamposPE[nX],"X3_RELACAO")),TamSX3(aCamposPE[nX])[1]))
							Else
								oModelGrid:LoadValue(aCamposPE[nX], SC7->(&(aCamposPE[nX])))
							EndIf
						EndIf
					Next nX
				EndIf
			EndIf
			
			//Atualiza o Grid com os campos das entidades contábeis
			Aeval(aCamposC7,{|cCampo| oModelGrid:LoadValue(cCampo, SC7TMP->&cCampo) })
			
			nLinha++
		Endif
		SC7TMP->(dbSkip())
	EndDo
ElseIf SCR->CR_TIPO $ "NF"

	BeginSQL Alias "SD1TMP"
		SELECT SD1.D1_ITEM, SD1.D1_COD, SD1.D1_QUANT, SD1.D1_VUNIT, SD1.D1_PEDIDO, SD1.D1_ITEMPC, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_EMISSAO
		FROM %Table:SD1% SD1
		WHERE SD1.D1_FILIAL=%xFilial:SD1% AND ;
		SD1.D1_DOC     = %Exp:Substr(SCR->CR_NUM,1,nTamF1Doc)% AND ;
		SD1.D1_SERIE   = %Exp:Substr(SCR->CR_NUM,(nTamF1Doc+1),nTamF1Ser)% AND ;
		SD1.D1_FORNECE = %Exp:Substr(SCR->CR_NUM,(nTamF1Doc+nTamF1Ser+1),nTamF1For)% AND ;
		SD1.D1_LOJA    = %Exp:Substr(SCR->CR_NUM,(nTamF1Doc+nTamF1Ser+nTamF1For+1),nTamF1Loj)% AND ;
		SD1.%NotDel%
	EndSQL

	SF1->(DbSetOrder(1))
	If SF1->(DbSeek(xFilial("SF1")+Substr(SCR->CR_NUM,1,Len(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))))

		oFieldSCR:LoadValue("CR_FORNECE"  ,POSICIONE("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA ,"A2_NOME"))
		
		oFieldSCR:LoadValue("CR_DTOTAL", nMoedaCalc)

		if lNfMotBloq .and. !empty(SCR->CR_NFMOBLQ)
			aNfMotBloq := Separa(SCR->CR_NFMOBLQ, "|")
		endif  
		
		While !SD1TMP->(EOF())
			If nLinha # 1
				oModelGrid:AddLine()
			EndIf
			oModelGrid:GoLine( nLinha )
			oModelGrid:LoadValue("D1_ITEM"		, SD1TMP->D1_ITEM    )
			oModelGrid:LoadValue("D1_COD" 	, SD1TMP->D1_COD )
			oModelGrid:LoadValue("D1_QUANT"	, SD1TMP->D1_QUANT  )
			oModelGrid:LoadValue("D1_VUNIT"		, SD1TMP->D1_VUNIT      )
			oModelGrid:LoadValue("D1_PEDIDO"		, SD1TMP->D1_PEDIDO   ) 
			oModelGrid:LoadValue("D1_ITEMPC"		, SD1TMP->D1_ITEMPC   )
			oModelGrid:LoadValue("X_DMOEDA"			, SF1->F1_MOEDA	 )							
			SC7->(DbSetOrder(14))
			If SC7->(dbSeek(xFilEnt(xFilial("SC7"),"SC7")+Padr(SD1TMP->D1_PEDIDO,TamSX3("C7_NUM")[1])+PadR(SD1TMP->D1_ITEMPC,TamSX3("C7_ITEM")[1])))
			   	oModelGrid:LoadValue("C7_QUANT"  ,SC7->C7_QUANT)
				oModelGrid:LoadValue("C7_PRECO"		, SC7->C7_PRECO	)
				oModelGrid:LoadValue("C7_QUJE"		, SC7->C7_QUJE	)

				if lNfMotBloq .and. Len(aNfMotBloq) > 0
					cItemNF := SD1TMP->D1_ITEMPC
					nPos := aScan( aNfMotBloq, { |x| x == cItemNF+"Q" .OR. x == cItemNF+"P" .OR. x == cItemNF+"E" } )
					if nPos > 0
						cDiverg := ""
						Do CASE
							Case Substr(aNfMotBloq[nPos],5,1) == "Q"
								cDiverg = STR0039//"Quantidade"
							Case Substr(aNfMotBloq[nPos],5,1) == "P"
								cDiverg := STR0040 //"Preço"
							Case Substr(aNfMotBloq[nPos],5,1) == "E"
								cDiverg := "Prz Entrega"
						ENDCASE
						oModelGrid:LoadValue("DIVERG"  ,OemToAnsi(cDiverg))//Motivo
					else 
						oModelGrid:LoadValue("DIVERG"  ,OemToAnsi(STR0041))//OK
					endif
				else

					// Carrega o motivo do bloqueio por tolerancia de recebimento
					nQtdItPed := SC7->C7_QUANT-SC7->C7_QUJE
					lQtd := (SD1TMP->D1_QUANT > nQtdItPed) .Or. (lTolerNeg .And. (SD1TMP->D1_QUANT < nQtdItPed))
					lVlr := (SD1TMP->D1_VUNIT > xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,StoD(SD1TMP->D1_EMISSAO),nTamD1Vun,SC7->C7_TXMOEDA)) .Or. (lTolerNeg .And. (SD1TMP->D1_VUNIT < xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,SD1TMP->D1_EMISSAO,nTamD1Vun,SC7->C7_TXMOEDA)))

					If cTolent == "1"
						lPrazo := SC7->C7_DATPRF < StoD(SD1TMP->D1_EMISSAO)
					Elseif cTolent == "2"
						lPrazo := SC7->C7_DATPRF > StoD(SD1TMP->D1_EMISSAO)
					Elseif cTolent == "3" 
						lPrazo := (SC7->C7_DATPRF < StoD(SD1TMP->D1_EMISSAO)) .Or. (SC7->C7_DATPRF > StoD(SD1TMP->D1_EMISSAO))
					Endif

					cDiverg:='' 

					If lQtd .And. lVlr
						cDiverg := STR0038
					ElseIf lQtd
						cDiverg:=STR0039
					ElseIf lVlr .Or. (lDescTol .And. Round((SC7->C7_PRECO * SC7->C7_QUANT),2) > (SC7->C7_TOTAL - SC7->C7_VLDESC))
						cDiverg := STR0040
					Elseif !lPrazo
						cDiverg:=STR0041
					EndIf

					If lPrazo
						If !Empty(cDiverg)
							cDiverg+='/'
						EndIf	
						cDiverg+='Prz.Entr.'
					EndIf
					
					oModelGrid:LoadValue("DIVERG"  ,OemToAnsi(cDiverg))
				endif
			Else
				oModelGrid:LoadValue("DIVERG"  ,OemToAnsi(STR0042))
			EndIf
			nLinha++
			SD1TMP->(dbSkip())
		EndDo
	EndIf
EndIf

If SCR->CR_TIPO $ 'CP' //Contrato de Parceria
	If SC3->(dbSeek(xFilial("SC3")+ AllTrim(SCR->CR_NUM) ) )
		oFieldSCR:LoadValue("CR_FORNECE"  ,POSICIONE("SA2",1,xFilial("SA2")+SC3->C3_FORNECE+SC3->C3_LOJA ,"A2_NOME"))
		oFieldSCR:LoadValue("CR_DTOTAL", nMoedaCalc)

		oModelGrid:SetNoInsertLine( .F. )
		oModelGrid:SetNoDeleteLine( .F. )

		BeginSQL Alias "SC3TMP"
			SELECT SC3.C3_NUM,SC3.C3_ITEM, SC3.C3_PRODUTO,SC3.C3_UM,SC3.C3_SEGUM,SC3.C3_QUANT,SC3.C3_QTSEGUM
			FROM %Table:SC3% SC3
			WHERE SC3.C3_FILIAL=%xFilial:SC3% AND SC3.C3_NUM = %Exp:SCR->CR_NUM% AND ;
			SC3.%NotDel%
		EndSQL

		While !SC3TMP->(EOF()) 
			If nLinha # 1
				oModelGrid:AddLine()
			EndIf
			oModelGrid:GoLine( nLinha )
			oModelGrid:LoadValue("C3_ITEM"		, SC3TMP->C3_ITEM    )
			oModelGrid:LoadValue("C3_PRODUTO"	, SC3TMP->C3_PRODUTO  )
			oModelGrid:LoadValue("C3_UM"		, SC3TMP->C3_UM      )
			oModelGrid:LoadValue("C3_SEGUM"		, SC3TMP->C3_SEGUM   ) 
			oModelGrid:LoadValue("C3_QUANT"		, SC3TMP->C3_QUANT   )
			oModelGrid:LoadValue("C3_QTSEGUM"	, SC3TMP->C3_QTSEGUM	 )

			If !Empty(cCpoAddC3)
				aCpoAddC3 := Separa(cCpoAddC3,"|")
				If Len(aCpoAddC3) > 0 .And. SC3->(DbSeek(xFilial("SC3")+SC3TMP->C3_NUM+SC3TMP->C3_ITEM))
					For nX := 1 To Len(aCpoAddC3)
						If !Empty(aCpoAddC3[nX]) .And. Upper(SubStr(aCpoAddC3[nX], 1, 2)) == "C3"
							If GetSx3Cache(aCpoAddC3[nX], "X3_CONTEXT") == 'V' //caso seja virtual, carrega inicializador padrão
								oModelGrid:LoadValue(aCpoAddC3[nX],Padr(&(GetSx3Cache(aCpoAddC3[nX],"X3_RELACAO")),TamSX3(aCpoAddC3[nX])[1]))
							Else
								oModelGrid:LoadValue(aCpoAddC3[nX], SC3->(&(aCpoAddC3[nX])))
							EndIf
						EndIf	
					Next nX
				Endif
			Endif

			nLinha++
		
			SC3TMP->(dbSkip())
		EndDo
	EndIf
EndIf

If SCR->CR_TIPO $ 'AE' //Autorzação de Entrega
	If SC7->(dbSeek(xFilial("SC7")+ AllTrim(SCR->CR_NUM) ) )
		oFieldSCR:LoadValue("CR_FORNECE"  ,POSICIONE("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA ,"A2_NOME"))
		oFieldSCR:LoadValue("CR_DTOTAL", nMoedaCalc)
	EndIf
EndIf

If SCR->CR_TIPO == 'IP'
		
	While !DBMTMP->(EOF())
		cNum	:= PADL(DBMTMP->DBM_NUM,nTamC7Num)
		cItem	:= AllTrim(DBMTMP-> DBM_ITEM)
		cItemRa:= AllTrim(DBMTMP-> DBM_ITEMRA)

		If SC7->(dbSeek(xFilial("SC7")+ cNum + cItem ) ) .AND. ( DBMTMP->DBM_APROV == "2" )
			If cDocBkp <> cNum + cItem	
			    If oModelGrid:Length()<nLinha
					oModelGrid:AddLine()
				Endif			
				oModelGrid:GoLine( nLinha )
				oModelGrid:LoadValue("C7_ITEM"		, SC7->C7_ITEM    )
				oModelGrid:LoadValue("C7_PRODUTO" 	, SC7->C7_PRODUTO )
				oModelGrid:LoadValue("C7_DESCRI"	, SC7->C7_DESCRI  )
				oModelGrid:LoadValue("C7_UM"		, SC7->C7_UM      )
				oModelGrid:LoadValue("C7_SEGUM"		, SC7->C7_SEGUM   )
				oModelGrid:LoadValue("C7_PRECO"		, SC7->C7_PRECO   )
				oModelGrid:LoadValue("X_DMOEDA"		, SC7->C7_MOEDA	  )			
				
				oFieldSCR:LoadValue("CR_FORNECE"  ,POSICIONE("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA ,"A2_NOME"))
				oFieldSCR:LoadValue("CR_DTOTAL", nMoedaCalc)
				
				If lMt094Cpc
					cCamposPE := ExecBlock("MT094CPC",.F.,.F.)
					If SC7->(DbSeek(xFilial("SC7")+ cNum + cItem)) .And. ValType(cCamposPE) == "C" .And. !Empty(cCamposPE)
						aCamposPE := Separa(cCamposPE,"|")
						For nX := 1 To Len(aCamposPE)
							If !Empty(aCamposPE[nX]) .And. Upper(SubStr(aCamposPE[nX], 1, 2)) == "C7"
								If GetSx3Cache(aCamposPE[nX], "X3_CONTEXT") == 'V' //caso seja virtual, carrega inicializador padrão
									oModelGrid:LoadValue(aCamposPE[nX],Padr(&(GetSx3Cache(aCamposPE[nX],"X3_RELACAO")),TamSX3(aCamposPE[nX])[1]))
								Else
									oModelGrid:LoadValue(aCamposPE[nX], SC7->(&(aCamposPE[nX])))
								Endif
							EndIf
						Next nX
					EndIf
				EndIf
				
				SCH->(dbSetOrder(2)) 
				If SCH->(dbSeek(xFilial("SCH")+ cNum + cItem + cItemRa ) )
					oModelGrid:LoadValue("C7_QUANT"		, SC7->C7_QUANT	* (SCH->CH_PERC/100) )
					oModelGrid:LoadValue("C7_TOTAL"		, SC7->C7_TOTAL	* (SCH->CH_PERC/100) )
					oModelGrid:LoadValue("C7_QTSEGUM"	, SC7->C7_QTSEGUM	* (SCH->CH_PERC/100) )
					
					oModelGrid:LoadValue("C7_VALFRE"	, SC7->C7_VALFRE	* (SCH->CH_PERC/100) )
					oModelGrid:LoadValue("C7_DESPESA"	, SC7->C7_DESPESA	* (SCH->CH_PERC/100) )
					oModelGrid:LoadValue("C7_SEGURO"	, SC7->C7_SEGURO	* (SCH->CH_PERC/100) )
					oModelGrid:LoadValue("C7_VALEMB"	, SC7->C7_VALEMB	* (SCH->CH_PERC/100) )
					
					If oModelGrid:HasField("C7_VALIPI")
						oModelGrid:LoadValue("C7_VALIPI"	, SC7->C7_VALIPI	* (SCH->CH_PERC/100) )
					Endif
					
					If oModelGrid:HasField("C7_ICMSRET")
						oModelGrid:LoadValue("C7_ICMSRET"	, SC7->C7_ICMSRET	* (SCH->CH_PERC/100) )
					Endif
			
					cDocBkp:= cNum+cItem
				Else
					oModelGrid:LoadValue("C7_QUANT"		, SC7->C7_QUANT	)
					oModelGrid:LoadValue("C7_TOTAL"		, SC7->C7_TOTAL	)
					oModelGrid:LoadValue("C7_QTSEGUM"	, SC7->C7_QTSEGUM	)
					
					oModelGrid:LoadValue("C7_VALFRE"	, SC7->C7_VALFRE	)
					oModelGrid:LoadValue("C7_DESPESA"	, SC7->C7_DESPESA	)
					oModelGrid:LoadValue("C7_SEGURO"	, SC7->C7_SEGURO	)
					oModelGrid:LoadValue("C7_VALEMB"	, SC7->C7_VALEMB	)
					
					If oModelGrid:HasField("C7_VALIPI")
						oModelGrid:LoadValue("C7_VALIPI",SC7->C7_VALIPI)
					EndIf

					If oModelGrid:HasField("C7_ICMSRET")
						oModelGrid:LoadValue("C7_ICMSRET",SC7->C7_ICMSRET)
					EndIf
					
					cDocBkp:= cNum+cItem
				EndIf
				nLinha++
			Else 
				SCH->(dbSetOrder(2))
				If SCH->(dbSeek(xFilial("SCH")+ cNum + cItem + cItemRa ) )
					oModelGrid:LoadValue("C7_QUANT"		, oModelGrid:GetValue("C7_QUANT") 	 + ( SC7->C7_QUANT	*(SCH->CH_PERC/100) ) )
					oModelGrid:LoadValue("C7_TOTAL"		, oModelGrid:GetValue("C7_TOTAL") 	 + ( SC7->C7_TOTAL	*(SCH->CH_PERC/100) ) )
					oModelGrid:LoadValue("C7_QTSEGUM"	, oModelGrid:GetValue("C7_QTSEGUM") + ( SC7->C7_QTSEGUM	*(SCH->CH_PERC/100) ) )
					cDocBkp:= cNum+cItem
				EndIf
			EndIf
			
			If Len(aFiltroSC7) > 0
				For nI := 1 To Len(aFiltroSC7)
					if !(aFiltroSC7[nI,1] $ cCamposPE)
						oModelGrid:LoadValue(aFiltroSC7[nI,1],PadR(aFiltroSC7[nI,2],TamSx3(aFiltroSC7[nI,1])[1]))
					endif
				Next nI
			Endif
			
			If oModelGrid:HasField("C7_CODGRP")
				oModelGrid:LoadValue("C7_CODGRP", IniAuxCod(SC7->C7_PRODUTO,"C7_CODGRP") )
			EndIf
			If oModelGrid:HasField("C7_CODITE")
				oModelGrid:LoadValue("C7_CODITE", IniAuxCod(SC7->C7_PRODUTO,"C7_CODITE") )
			EndIf

		EndIf
		DBMTMP->(dbSkip())
	EndDo

ElseIf SCR->CR_TIPO == 'SA'

	While !DBMTMP->(EOF())
		cNum	:= PADL(DBMTMP->DBM_NUM,nTamCPNum)
		cItem	:= AllTrim(DBMTMP-> DBM_ITEM)
		cItemRa:= AllTrim(DBMTMP-> DBM_ITEMRA)

		If SCP->(dbSeek(xFilial("SCP")+ cNum + cItem ) )
			If cDocBkp <> cNum + cItem
				If nLinha # 1
					oModelGrid:AddLine()
				EndIf
				oModelGrid:GoLine( nLinha )
				oModelGrid:LoadValue("CP_ITEM"		, SCP->CP_ITEM    )
				oModelGrid:LoadValue("CP_PRODUTO" 	, SCP->CP_PRODUTO )
				oModelGrid:LoadValue("CP_DESCRI"	, SCP->CP_DESCRI  )
				oModelGrid:LoadValue("CP_UM"		, SCP->CP_UM      )
			
				SGS->(dbSetOrder(1))
				If SGS->(dbSeek(xFilial("SGS")+ cNum + cItem + cItemRa ) )
					oModelGrid:LoadValue("CP_QUANT"		, SCP->CP_QUANT	* (SGS->GS_PERC/100) )
					oModelGrid:LoadValue("CP_QTSEGUM"	, SCP->CP_QTSEGUM	* (SGS->GS_PERC/100) )
					cDocBkp:= cNum+cItem
				Else
					oModelGrid:LoadValue("CP_QUANT"		, SCP->CP_QUANT	)
					oModelGrid:LoadValue("CP_QTSEGUM"	, SCP->CP_QTSEGUM	)
					cDocBkp:= cNum+cItem
				EndIf
				nLinha++
			Else 
				SGS->(dbSetOrder(1))
				If SGS->(dbSeek(xFilial("SGS")+ cNum + cItem + cItemRa ) )
					oModelGrid:LoadValue("CP_QUANT"		, oModelGrid:GetValue("CP_QUANT") 	 + ( SCP->CP_QUANT	*(SGS->GS_PERC/100) ) )
					oModelGrid:LoadValue("CP_QTSEGUM"	, oModelGrid:GetValue("CP_QTSEGUM") + ( SCP->CP_QTSEGUM	*(SGS->GS_PERC/100) ) )
					cDocBkp:= cNum+cItem
				EndIf
			EndIf
		EndIf
		DBMTMP->(dbSkip())
	EndDo

ElseIf SCR->CR_TIPO == 'SC' .And. lAlcSolCtb

	While !DBMTMP->(EOF())
		cNum	:= PADL(DBMTMP->DBM_NUM,nTamC1Num)
		cItem	:= AllTrim(DBMTMP-> DBM_ITEM)
		cItemRa:= AllTrim(DBMTMP-> DBM_ITEMRA)

		If SC1->(dbSeek(xFilial("SC1")+ cNum + cItem ) ) .AND. ( DBMTMP->DBM_APROV == "2" )
			If cDocBkp <> cNum + cItem
				If nLinha # 1
					oModelGrid:AddLine()
				EndIf
				oModelGrid:GoLine( nLinha )
				oModelGrid:LoadValue("C1_ITEM"		, SC1->C1_ITEM    )
				oModelGrid:LoadValue("C1_PRODUTO" 	, SC1->C1_PRODUTO )
				oModelGrid:LoadValue("C1_DESCRI"	, SC1->C1_DESCRI  )
				oModelGrid:LoadValue("C1_UM"		, SC1->C1_UM      )
				oModelGrid:LoadValue("C1_SEGUM" 	, SC1->C1_SEGUM	  )
				oModelGrid:LoadValue("X_DMOEDA" 	, SC1->C1_MOEDA	  )
			
				SCX->(dbSetOrder(1))
				If SCX->(dbSeek(xFilial("SCX")+ cNum + cItem + cItemRa ) )
					oModelGrid:LoadValue("C1_QUANT"		, SC1->C1_QUANT	* (SCX->CX_PERC/100) )
					oModelGrid:LoadValue("C1_QTSEGUM"	, SC1->C1_QTSEGUM	* (SCX->CX_PERC/100) )
					cDocBkp:= cNum+cItem
				Else
					oModelGrid:LoadValue("C1_QUANT"		, SC1->C1_QUANT	)
					oModelGrid:LoadValue("C1_QTSEGUM"	, SC1->C1_QTSEGUM	)
					cDocBkp:= cNum+cItem
				EndIf
				nLinha++
			Else 
				SCX->(dbSetOrder(1))
				If SCX->(dbSeek(xFilial("SCX")+ cNum + cItem + cItemRa ) )
					oModelGrid:LoadValue("C1_QUANT"		, oModelGrid:GetValue("C1_QUANT") 	 + ( SC1->C1_QUANT	*(SCX->CX_PERC/100) ) )
					oModelGrid:LoadValue("C1_QTSEGUM"	, oModelGrid:GetValue("C1_QTSEGUM") + ( SC1->C1_QTSEGUM	*(SCX->CX_PERC/100) ) )
					cDocBkp:= cNum+cItem
				EndIf
			EndIf
		EndIf
		DBMTMP->(dbSkip())
	EndDo

ElseIf SCR->CR_TIPO $ 'IC|IR'
	While !DBMTMP->(EOF())
		cItem	:= AllTrim(DBMTMP->DBM_ITEM)
		cItemRa:= DBMTMP->DBM_ITEMRA

		If SCR->CR_TIPO = 'IC'
			cNum	:= Left(AllTrim(DBMTMP->DBM_NUM),TAMSX3('CNB_CONTRA')[1])
			cRev	:= PadR(" ",TAMSX3('CNB_REVISA')[1])
			cPlan	:= SubStr(DBMTMP->DBM_NUM,TAMSX3('CNB_CONTRA')[1]+TAMSX3('CNB_REVISA')[1]+1,TAMSX3('CNB_NUMERO')[1])
			cItem	:= AllTrim(DBMTMP->DBM_ITEM)
			CNB->(dbSetOrder(3))
			lSeek	:= CNB->(dbSeek(xFilial("CNB")+cNum+cPlan+cItem))
			lComp	:= cDocBkp <> cNum+cPlan+cItem
		ElseIf SCR->CR_TIPO = 'IR'
			cNum	:= Left(AllTrim(DBMTMP-> DBM_NUM),Len(CNB->CNB_CONTRA)+Len(CNB->CNB_REVISA))
			cRev	:= ""
			cPlan	:= SubStr(DBMTMP->DBM_NUM,Len(CNB->CNB_CONTRA)+Len(CNB->CNB_REVISA)+1,Len(CNB->CNB_NUMERO))
			cItem	:= AllTrim(DBMTMP->DBM_ITEM)
			CNB->(dbSetOrder(1))
			lSeek := CNB->(dbSeek(xFilial("CNB")+cNum+cPlan+cItem))
			lComp	:= cDocBkp <> cNum+cPlan+cItem
		EndIf
		If lSeek
			If lComp
				If nLinha # 1
					oModelGrid:AddLine()
				Else
					CNA->(dbSeek(xFilial("CNA")+CNB->(CNB_CONTRA+CNB_REVISA+CNB_NUMERO)))
					If !Empty(CNA->CNA_FORNEC)
						oFieldSCR:LoadValue("CR_FORNECE"  ,POSICIONE("SA2",1,xFilial("SA2")+CNA->(CNA_FORNEC+CNA_LJFORN),"A2_NOME"))
					Else
						oFieldSCR:LoadValue("CR_FORNECE"  ,POSICIONE("SA2",1,xFilial("SA2")+CNA->(CNA_CLIENT+CNA_LOJACL),"A2_NOME"))
					EndIf
				EndIf
				oModelGrid:GoLine( nLinha )
				oModelGrid:LoadValue("CNB_ITEM"		, CNB->CNB_ITEM   )
				oModelGrid:LoadValue("CNB_PRODUT"  , CNB->CNB_PRODUT )
				oModelGrid:LoadValue("CNB_DESCRI"	, CNB->CNB_DESCRI )
				oModelGrid:LoadValue("CNB_VLUNIT"	, CNB->CNB_VLUNIT )

				CNZ->(dbSetOrder(1)) //- CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_CODPLA+CNZ_ITCONT+CNZ_ITEM
				If CNZ->(dbSeek(xFilial("CNB")+cNum+cRev+cPlan+cItem+cItemRa))
					oModelGrid:LoadValue("CNB_QUANT"	, CNB->CNB_QUANT	* (CNZ->CNZ_PERC/100))
					oModelGrid:LoadValue("CNB_VLTOT"	, CNB->CNB_VLTOT	* (CNZ->CNZ_PERC/100))
					//- Insere na grid valores do rateio do item CNB_CC|CNB_CONTA|CNB_ITEMCT|CNB_CLVL
					oModelGrid:LoadValue("CNB_CC"		, CNZ->CNZ_CC)
					oModelGrid:LoadValue("CNB_CONTA"	, CNZ->CNZ_CONTA)
					oModelGrid:LoadValue("CNB_ITEMCT"	, CNZ->CNZ_ITEMCT)
					oModelGrid:LoadValue("CNB_CLVL"		, CNZ->CNZ_CLVL)
				Else
					oModelGrid:LoadValue("CNB_QUANT"	, CNB->CNB_QUANT	)
					oModelGrid:LoadValue("CNB_VLTOT"	, CNB->CNB_VLTOT	)
					oModelGrid:LoadValue("CNB_CC"		, CNB->CNB_CC)
					oModelGrid:LoadValue("CNB_CONTA"	, CNB->CNB_CONTA)
					oModelGrid:LoadValue("CNB_ITEMCT"	, CNB->CNB_ITEMCT)
					oModelGrid:LoadValue("CNB_CLVL"		, CNB->CNB_CLVL)
				EndIf
				nLinha++
			Else
				CNZ->(dbSetOrder(1))
				If CNZ->(dbSeek(xFilial("CNZ")+cNum+cRev+cPlan+cItem+cItemRa))
					oModelGrid:LoadValue("CNB_QUANT"		, oModelGrid:GetValue("CNB_QUANT") 	 + ( CNB->CNB_QUANT	*(CNZ->CNZ_PERC/100) ) )
					oModelGrid:LoadValue("CNB_VLTOT"		, oModelGrid:GetValue("CNB_VLTOT") 	 + ( CNB->CNB_VLTOT	*(CNZ->CNZ_PERC/100) ) )
				EndIf
			EndIf
			cDocBkp:= cNum+cPlan+cItem
		EndIf
		DBMTMP->(dbSkip())
	EndDo

ElseIf SCR->CR_TIPO $ 'IM'
	While !DBMTMP->(EOF())
		cItem	:= AllTrim(DBMTMP->DBM_ITEM)
		cItemRa:= AllTrim(DBMTMP->DBM_ITEMRA)
		cNum 	:= Left(AllTrim(DBMTMP->DBM_NUM),TAMSX3('CND_NUMMED')[1])
		cPlan	:= SubStr(DBMTMP->DBM_NUM,TAMSX3('CND_NUMMED')[1]+1,TAMSX3('CXN_NUMPLA')[1])
		cItem	:= AllTrim(DBMTMP->DBM_ITEM)

		//- CND_FILIAL+CND_NUMMED
		CND->(dbSetOrder(4))
		CND->(MsSeek(xFilial("CND")+cNum))

		cContra := CND->CND_CONTRA
		cRev	:= CnGetRevVg(cContra,CND->CND_FILCTR)

		//-CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED+CNE_ITEM
		CNE->(dbSetOrder(1))
		lSeek := CNE->(MsSeek(xFilial("CND")+cContra+cRev+cPlan+cNum+cItem))
		lComp	:= cDocBkp <> cNum+cPlan+cItem+cItemRa

		If lSeek
			If lComp
				If nLinha # 1
					oModelGrid:AddLine()
				Else
					CXN->(dbSeek(xFilial("CXN")+CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMMED+CNE_NUMERO)))
					If !Empty(CXN->CXN_FORNEC)
						oFieldSCR:LoadValue("CR_FORNECE"  ,POSICIONE("SA2",1,xFilial("SA2")+CXN->(CXN_FORNEC+CXN_LJFORN),"A2_NOME"))
					Else
						oFieldSCR:LoadValue("CR_FORNECE"  ,POSICIONE("SA2",1,xFilial("SA2")+CXN->(CXN_CLIENT+CXN_LJCLI),"A2_NOME"))
					EndIf
				EndIf
				oModelGrid:GoLine( nLinha )

				oModelGrid:LoadValue("CNE_ITEM"		, CNE->CNE_ITEM   )
				oModelGrid:LoadValue("CNE_PRODUT"  , CNE->CNE_PRODUT )
				oModelGrid:LoadValue("CNE_VLUNIT"	, CNE->CNE_VLUNIT )

				CNZ->(dbSetOrder(2))
				If CNZ->(dbSeek(xFilial("CNZ")+CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMMED)+cItem+cItemRa))
					oModelGrid:LoadValue("CNE_QUANT", CNE->CNE_QUANT	* (CNZ->CNZ_PERC/100))
					oModelGrid:LoadValue("CNE_VLTOT", CNE->CNE_VLTOT	* (CNZ->CNZ_PERC/100))
					
                    //- Insere na grid valores do rateio do item CNE_CC|CNE_CONTA|CNE_ITEMCT|CNE_CLVL
					oModelGrid:LoadValue("CNE_CC"		, CNZ->CNZ_CC)
					oModelGrid:LoadValue("CNE_CONTA"	, CNZ->CNZ_CONTA)
					oModelGrid:LoadValue("CNE_ITEMCT"	, CNZ->CNZ_ITEMCT)
					oModelGrid:LoadValue("CNE_CLVL"		, CNZ->CNZ_CLVL)
				Else
					CNZ->(dbSetOrder(1))
					If CNZ->(dbSeek(xFilial("CNZ")+CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO)+cItem+cItemRa))
						oModelGrid:LoadValue("CNE_QUANT", CNE->CNE_QUANT	* (CNZ->CNZ_PERC/100))
						oModelGrid:LoadValue("CNE_VLTOT", CNE->CNE_VLTOT	* (CNZ->CNZ_PERC/100))
					Else
						oModelGrid:LoadValue("CNE_QUANT", CNE->CNE_QUANT	)
						oModelGrid:LoadValue("CNE_VLTOT", CNE->CNE_VLTOT	)
					EndIf

					//- Insere na grid valores do rateio do item CNE_CC|CNE_CONTA|CNE_ITEMCT|CNE_CLVL
					oModelGrid:LoadValue("CNE_CC"     , CNE->CNE_CC)
					oModelGrid:LoadValue("CNE_CONTA"  , CNE->CNE_CONTA)
					oModelGrid:LoadValue("CNE_ITEMCT" , CNE->CNE_ITEMCT)
					oModelGrid:LoadValue("CNE_CLVL"   , CNE->CNE_CLVL)
				EndIf
				nLinha++
			Else
				CNZ->(dbSetOrder(2))
				If CNZ->(dbSeek(xFilial("CNZ")+CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMMED)+cItem+cItemRa))
					oModelGrid:LoadValue("CNE_QUANT", oModelGrid:GetValue("CNE_QUANT") + (CNE->CNE_QUANT * (CNZ->CNZ_PERC/100) ) )
					oModelGrid:LoadValue("CNE_VLTOT", oModelGrid:GetValue("CNE_VLTOT") + (CNE->CNE_VLTOT * (CNZ->CNZ_PERC/100) ) )
				Else
					CNZ->(dbSetOrder(1))
					If CNZ->(dbSeek(xFilial("CNZ")+CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO)+cItem+cItemRa))
						oModelGrid:LoadValue("CNE_QUANT", oModelGrid:GetValue("CNE_QUANT") + (CNE->CNE_QUANT * (CNZ->CNZ_PERC/100) ) )
						oModelGrid:LoadValue("CNE_VLTOT", oModelGrid:GetValue("CNE_VLTOT") + (CNE->CNE_VLTOT * (CNZ->CNZ_PERC/100) ) )
					EndIf
				EndIf
			EndIf
			cDocBkp:= cNum+cItem+cItemRa
		EndIf
		DBMTMP->(dbSkip())
	EndDo

ElseIf SCR->CR_TIPO >= "A1" .AND. SCR->CR_TIPO <= "A9" // Documentos do modulo Agro

    If FindFunction("OGXUtlOrig") //Identifica que esta utilizando o sigaagr				
		If OGXUtlOrig() .AND. FindFunction("OGX701AALC")
            
            //retorna campos pesquisado para atribuir valores
            aFieldAgro := AGRXCOM11(SCR->CR_NUM, SCR->CR_TIPO, SCR->(RECNO()) ) 

            For nI := 1 To Len(aFieldAgro)
                oFieldSCR:LoadValue(aFieldAgro[nI][1],aFieldAgro[nI][2])
            Next
        EndIf
    EndIf
    
EndIf


If SCR->CR_TIPO $ 'CT|RV|IC|IR' .And. ExistFunc('CNTXLFor')
	CNTXLFor( SCR->CR_NUM , oModel:GetModel('CNCDETAIL') )//Carrega as planilhas do contrato	
ElseIf SCR->CR_TIPO $ 'MD|IM' .And. ExistFunc('CNTXLForMd')
	CNTXLForMd( SCR->CR_NUM , SCR->CR_TIPO , oModel:GetModel('CNCDETAIL') )
EndIf

If SCR->CR_TIPO $ 'IP|SA|IC|IR|IM' .Or. (SCR->CR_TIPO == 'SC' .And. lAlcSolCtb)

	DBMTMP->(dbCloseArea())

	//--------------------------------------
	//		Configura permissao dos modelos
	//--------------------------------------
	oModelGrid:GoLine( 1 )
	oModelGrid:SetNoInsertLine( .T. )
	oModelGrid:SetNoDeleteLine( .T. )
ElseIf SCR->CR_TIPO $ 'PC|AE'
	SC7TMP->(dbCloseArea())
	//--------------------------------------
	//		Configura permissao dos modelos
	//--------------------------------------
	oModelGrid:GoLine( 1 )
	oModelGrid:SetNoInsertLine( .T. )
	oModelGrid:SetNoDeleteLine( .T. )
ElseIf SCR->CR_TIPO $ 'NF'
	SD1TMP->(dbCloseArea())
	//--------------------------------------
	//		Configura permissao dos modelos
	//--------------------------------------
	oModelGrid:GoLine( 1 )
	oModelGrid:SetNoInsertLine( .T. )
	oModelGrid:SetNoDeleteLine( .T. )
Elseif SCR->CR_TIPO $ 'CP'
	SC3TMP->(dbCloseArea())
	//--------------------------------------
	//		Configura permissao dos modelos
	//--------------------------------------
	oModelGrid:GoLine( 1 )
	oModelGrid:SetNoInsertLine( .T. )
	oModelGrid:SetNoDeleteLine( .T. )
EndIf

If SCR->CR_TIPO $ 'RV'
	//-- Atalho para config. dos parametros
	//-- mv_par01 - Mostra Lancamentos: S/N
	//-- mv_par02 - Aglut Lancamentos:  S/N
	//-- mv_par03 - Lancamentos Online: S/N
	SetKey(VK_F12,{|| Pergunte("CNT100",.T.)}) 
	Pergunte("CNT100",.F.)  
EndIf

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A094Commit()
Realiza gravacao manual dos campos de filtros e realiza processamento de calculos
@author Leonardo Quintania
@since 30/08/2013
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Static Function A094Commit(oModel)
Local cIdOption	:= cOperID
Local cChave	:= ""
Local cNumDoc	:= ""
Local aArea		:= SAK->(GetArea())

Local lAprovou	:= .F.
Local lRet		:= .T.
Local lFluig		:= SuperGetMV("MV_APWFECM",.F.,"1") == "1" .And. !Empty(AllTrim(GetNewPar("MV_ECMURL",""))) .And. FWWFFluig()
Local lAglFlg		:= SuperGetMV("MV_CNAGFLG",.F.,.F.)	//- Aglutinação de aprovações no Fluig

Local nTamX3		:= 0
Local nI			:= 0
Local aRetAgro		:= {} // Documentos do modulo Agro
Local oFieldSCR		:= oModel:GetModel("FieldSCR")
Local lCnAlcFlg		:= ExistBlock("CnAlcFlg")	// Função Fluig (descontinuado)	
Local lMTSoliCAT	:= ExistBlock("MTSoliCAT")	// Função Fluig (descontinuado)
Local lLowR033		:= GetRPORelease() < "12.1.033"
Local lFCnAlcFlg	:= FindFunction("CnAlcFlg")	 .And. lLowR033	
Local lFMTSoliCAT	:= FindFunction("MTSoliCAT") .And. lLowR033
Local lCommit		:= .T.

Private aFluigIR		:= {}
Private lMsErroAuto 	:= .F.

BEGIN TRANSACTION
	 If FWFormCommit(oModel)
		Do Case
			Case SCR->CR_TIPO == "NF"
				cChave := xFilial("SF1")+Substr(SCR->CR_NUM,1,Len(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				dbSelectArea("SF1")
				dbSetOrder(1)
				MsSeek(cChave)

			Case SCR->CR_TIPO == "PC" .Or. SCR->CR_TIPO == "AE"
				cChave := xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
				dbSelectArea("SC7")
				dbSetOrder(1)
				MsSeek(cChave)

			Case SCR->CR_TIPO == "CP"
				cChave := xFilial("SC3")+Substr(SCR->CR_NUM,1,len(SC3->C3_NUM))
				dbSelectArea("SC3")
				dbSetOrder(1)
				MsSeek(cChave)
				cGrupo := SC3->C3_APROV

			Case SCR->CR_TIPO == "ST"
				cChave := xFilial("NNS")+Substr(SCR->CR_NUM,1,Len(NNS->NNS_COD))
				dbSelectArea("NNS")
				dbSetOrder(1)
				MsSeek(cChave)

			CASE SCR->CR_TIPO $ "RV|IR|CT|IC"
				cNumDoc := Substr(SCR->CR_NUM,1,TAMSX3('CN9_NUMERO')[1] + TAMSX3('CN9_REVISA')[1])
				cChave 	:= xFilial("CN9")+cNumDoc
				dbSelectArea("CN9")
				dbSetOrder(1)
				MsSeek(cChave)
				cGrupo := CN9->CN9_APROV

			Case SCR->CR_TIPO $ "MD|IM"
				cNumDoc	:= Substr(SCR->CR_NUM,1,TAMSX3('CND_NUMMED')[1])
				cChave := xFilial("CND")+cNumDoc				
				
				If PosMdRevAt(cNumDoc)//Se posiciona na CND de acordo com a revisao atual
					cGrupo := CND->CND_APROV					
				Endif

			Case SCR->CR_TIPO >= "A1" .AND. SCR->CR_TIPO <= "A9" // Documentos do modulo Agro
				If FindFunction("OGXUtlOrig") //Identifica que esta utilizando o sigaagr				
					If OGXUtlOrig() .AND. FindFunction("OGX701AALC")	
				
						aRetAgro := AGRXCOM2(SCR->CR_NUM, SCR->CR_TIPO, SCR->(Recno()))			
						
						cChave := aRetAgro[3]
						If !Empty(cChave)
							dbSelectArea(aRetAgro[1])
							dbSetOrder(aRetAgro[2])
							If MsSeek(cChave)
								AGRXCOM3( SCR->CR_NUM, SCR->CR_TIPO, SCR->(Recno()), cIdOption)
							EndIf
						EndIf
						
					EndIf
				EndIf			

			Otherwise
				If !Empty(aMTAlcDoc := MTGetAlcPE(SCR->CR_TIPO))
					dbSelectArea(aMTAlcDoc[2])
					dbSetOrder(aMTAlcDoc[3])
					MsSeek(xFilial(aMTAlcDoc[2])+Substr(SCR->CR_NUM,1,Len(&(aMTAlcDoc[4]))))
				EndIf
		EndCase
				
		If cIdOption == OP_LIB //Liberação
			If SCR->CR_TIPO $ "CT|IC|RV|IR|MD|IM"
				lAprovou := GCTAlcEnt(oModelCT,MODEL_OPERATION_UPDATE,4,SCR->CR_TIPO,SCR->CR_NUM,,)

				If lAprovou .AND. SCR->CR_TIPO $ "MD|IM" .AND. MtGLastDBM(SCR->CR_TIPO,SCR->CR_NUM) .AND. SuperGetMV("MV_CNMDEAT",.F.,.F.)
					CN121Encerr(.T.)
				ElseIf (!lAprovou .And. SCR->CR_TIPO == "RV" .And. ValType(oModelCT) == "O")
					If GCTAlcErro(oModel)
						DisarmTransaction()
						lCommit := .F.
					EndIf
				EndIf
			Else
				A097ProcLib(SCR->(Recno()),2,,,,,dDataBase,oModelCT)
			EndIf
		ElseIf cIdOption == OP_REJ //Rejeição
			If SCR->CR_TIPO $ "CT|IC|RV|IR|MD|IM"
				lRet := CnRejDoc(SCR->CR_TIPO)
			Else
				MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,,SCR->CR_APROV,,SCR->CR_GRUPO,,,,dDataBase,FwFldGet("CR_OBS")}, dDataBase ,7,,,SCR->CR_ITGRP,,,,cChave)
			EndIf
		ElseIf cIdOption == OP_BLQ //Bloqueio
			A097ProcLib(SCR->(Recno()),6,,,,FwFldGet("CR_OBS"))
		Else
			SAK->(dbSetOrder(1))
			SAK->(MsSeek(xFilial("SAK")+SCR->CR_APROV))
			
			SAL->(dbSetOrder(3))
			SAL->(MsSeek(xFilial("SAK")+SCR->CR_GRUPO+SCR->CR_APROV))
			
			cAprovS:= SAK->AK_APROSUP
			If Empty(cAprovS)
				cAprovS := SAL->AL_APROSUP
			Endif

			If cIdOption == OP_SUP  //Superior
				If SCR->CR_TIPO $ "CT|IC|RV|IR|MD|IM"
					lAprovou := GCTAlcEnt(oModelCT,MODEL_OPERATION_UPDATE,4,SCR->CR_TIPO,SCR->CR_NUM,,,,,,cAprovS)

					If lAprovou .AND. SCR->CR_TIPO $ "MD|IM" .AND. MtGLastDBM(SCR->CR_TIPO,SCR->CR_NUM) .AND. SuperGetMV("MV_CNMDEAT",.F.,.F.)
						CN121Encerr(.T.)
					ElseIf (!lAprovou .And. SCR->CR_TIPO == "RV" .And. ValType(oModelCT) == "O")
						If (oModelCT:HasErrorMessage() .And. AllTrim(oModelCT:GetErrorMessage()[5]) == "CNTA300PCO")//Caso falhe em decorrência do PCO, deve cancelar a transação.
							DisarmTransaction()
						EndIf
					EndIf
				Else
					A097ProcSup(SCR->(Recno()),2,SCR->CR_TOTAL,cAprovS,SCR->CR_GRUPO,SCR->CR_OBS,SCR->CR_APROV,SCR->CR_DATALIB)
				EndIf
			Else //Transferencia Superior
				if cOperId <> OP_VIW
					A097ProcTf(SCR->(Recno()),2,cAprovS,SCR->CR_OBS,SCR->CR_DATALIB)
				endif
			EndIf
		EndIf

	EndIf
	
END TRANSACTION

If lFluig .And. !lAprovou .And. SCR->CR_TIPO $ "RV|IR"
	nTamX3 := TamSX3('CN9_NUMERO')[1]+TamSX3('CN9_REVISA')[1]
	cAprTipRev := ""

	If SCR->(CR_TIPO) != "RV" //- Alçadas para RV (vindo de aprovação de IR)
		If lCnAlcFlg
			ExecBlock("CnAlcFlg", .F., .F., {Left(SCR->CR_NUM,nTamX3),,"RV"})
		Elseif lFCnAlcFlg
			CnAlcFlg(Left(SCR->CR_NUM,nTamX3),,"RV")
		Endif
	Else //- Alçadas para IR (vindo de aprovação de RV)
		If lAglFlg
			If lCnAlcFlg
				ExecBlock("CnAlcFlg", .F., .F., {Left(SCR->CR_NUM,nTamX3),,"IR"})
			Elseif lFCnAlcFlg
				CnAlcFlg(Left(SCR->CR_NUM,nTamX3),,"IR")
			Endif
		Else
			For nI := 1 To Len(aFluigIR)
				If lMTSoliCAT
					ExecBlock("MTSoliCAT", .F., .F., {"IR",aFluigIR[nI],"CN9","CR_NUM"})
				Elseif lFMTSoliCAT
					MTSoliCAT("IR",aFluigIR[nI],"CN9","CR_NUM")
				Endif
			Next nI
		EndIf
	Endif
EndIf

RestArea(aArea)

PcoFinLan("000055")

/*/Ponto de Entrada que contém os dados do documento para customizações diversas
dos usuários /*/
If ExistBlock("MT094END")
	ExecBlock("MT094END",.F.,.F.,{(oFieldSCR:GetValue("CR_NUM")),(oFieldSCR:GetValue("CR_TIPO")),Val(Substr(cIdOption,3,1)),(oFieldSCR:GetValue("CR_FILIAL"))})
EndIf

Return lCommit

//--------------------------------------------------------------------
/*/{Protheus.doc} A094TudoOk()
Efetua validações da aprovação
@author Leonardo Quintania
@since 30/08/2013
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Static Function A094TudoOk(oModel)
Local lRet 			:= .T.
Local cIdOption		:= cOperID
Local aAglutFlg		:= {}
Local aSaldo 		:= {}
Local nSaldo 		:= 0
Local oFieldSAK 	:= oModel:GetModel("FieldSAK")
Local dDataBloq	  	:= GetNewPar("MV_ATFBLQM",CTOD("")) //Data de Bloqueio da Movimentação - MV_ATFBLQM
Local lNfLimAl	  	:= SuperGetMV ("MV_NFLIMAL", .F.,.F.)
Local nMoedaCalc  	:= 0
Local lCnVerAgFlg	:= ExistBlock('CnVerAgFlg')   // funcão descontinuada (Fluig)
Local lCnClrAgFlg	:= ExistBlock('CnClrAgFlg')   // funcão descontinuada (Fluig)
Local lLowR033		:= GetRPORelease() < "12.1.033"
Local lFCnVerAgFlg	:= FindFunction('CnVerAgFlg') .And. lLowR033
Local lFCnClrAgFlg	:= FindFunction('CnClrAgFlg') .And. lLowR033
Local cContra		:= ""

If SCR->CR_TIPO $ "PC|SC|IP|AE|A1|A2|MD|IM|CT|IC|RV|IR|CP|SA|NF"
	SAK->(dbSetOrder(1))
	If cIdOption == OP_SUP //Operação de aprovação pelo superior
		SAK->(MsSeek(xFilial("SAK")+SAK->AK_COD))
	Else 
		SAK->(MsSeek(xFilial("SAK")+SCR->CR_APROV))
	EndIf
	
	dbSelectArea("SCS")
	SCS->(dbSetOrder(2))
	aSaldo 		:= Iif(cIdOption == OP_SUP,MaSalAlc(SAK->AK_COD,dDataBase,.T.),MaSalAlc(SCR->CR_APROV,dDataBase,.T.))
	nSaldo 		:= aSaldo[1]	
	
	SAL->(dbSetOrder(3))
	SAL->(MsSeek(xFilial("SAL")+SCR->(CR_GRUPO+CR_APROV)))

    nMoedaCalc := IIF(SCR->CR_TOTAL > 0, xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aSaldo[2],SCR->CR_EMISSAO,TamSX3('CR_TOTAL')[2],SCR->CR_TXMOEDA), ;
										 xMoeda(IIF(lNfLimAl,SF1->F1_VALBRUT,0),SCR->CR_MOEDA,aSaldo[2],SCR->CR_EMISSAO,TamSX3('CR_TOTAL')[2],SCR->CR_TXMOEDA))

	If (nSaldo < nMoedaCalc .Or. oFieldSAK:GetValue("AK_SLDCALC") < 0) .AND. SAL->AL_LIBAPR <> "V" .And. cIdOption <> OP_TRA .And. cIdOption <> OP_REJ .And. cIdOption <> OP_BLQ
		lRet	:= .F.
		Help("",1,"SLDAPROV",,STR0043,1,0)
	EndIf 
EndIf

If SCR->CR_TIPO == "RV" .And. lRet
	cContra := Left(SCR->CR_NUM, Len(CN9->CN9_NUMERO) )
	
	If CN9->(MsSeek(xFilial("CN9")+ cContra + CnGetRevAt(cContra)  )) //Posiciona no contrato da aprovação
		//--Popula model da tela de contrato para ser feito validações da aprovação do contrato.
		oModelCT := FWLoadModel(If(CN9->CN9_ESPCTR == "1","CNTA300","CNTA301"))
		oModelCT:SetOperation(MODEL_OPERATION_UPDATE)
		
		A300SATpRv(Cn300RetSt("TIPREV"))		
		oModelCT:Activate()
		
		If lRet:= cn300VlCau()
			CN0->(MsSeek(xFilial("CN0")+CN9->CN9_TIPREV))
			If lRet .And. CN0->CN0_TIPO == DEF_REV_PARAL
				lRet := CN100Doc(CN9->(Recno()),{DEF_SPARA,DEF_SREVS},.F.)
			Else
				lRet := CN100Doc(CN9->(Recno()),{DEF_SREVS},.F.)
			EndIf
		EndIf
		//--Gera Base Instalada e Ordem de Servico³
		If lRet .And. SuperGetMv("MV_CNINTFS",.F.,.F.) .And. CN9->CN9_ESPCTR == '2'
			lRet := CN100BIns(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_DTASSI)
		EndIf
	EndIf
ElseIf SCR->CR_TIPO == "CT" .And. lRet
	//Verifica se existe bloqueio contábil
	If lRet := CtbValiDt(Nil, dDataBase,/*.T.*/ ,Nil ,Nil ,{"COM002"}/*,"Data de apuração bloqueada pelo calendário contábil."*/)
		If!Empty(dDataBloq) .AND. ( dDataBase <= dDataBloq)
			//Help(" ",1,"AF012ABLQM",,"Processo bloqueado pelo Calendário Contábil nesta data ou período. Caso possível altere a data de referência do processo ou contate o responsável pelo Módulo Contábil.",1,0) //"Processo bloqueado pelo Calendário Contábil nesta data ou período. Caso possível altere a data de referência do processo ou contate o responsável pelo Módulo Contábil."
			Help(" ",1,"ATFCTBBLQ") //P: Processo bloqueado pelo Calendário Contábil ou parâmetro de bloqueio nesta data ou período. S: Caso possível altere a data de referência do processo, verifique o parâmetro ou contate o responsável pelo Módulo Contábil.)
			lRet := .F.
		End
	EndIf
EndIf

If lRet .And. SCR->CR_TIPO $ "CT|IC|RV|IR" .AND. SuperGetMv("MV_CNAGFLG",.F.,.F.) 
	If lCnVerAgFlg
		aAglutFlg := ExecBlock("CnVerAgFlg", .F., .F., {SCR->CR_TIPO,SCR->CR_NUM,SCR->CR_FLUIG})
	Elseif lFCnVerAgFlg
		aAglutFlg := CnVerAgFlg(SCR->CR_TIPO,SCR->CR_NUM,SCR->CR_FLUIG)
	Endif
	
	If aAglutFlg[1]
		DO 	CASE
			CASE cIdOption == OP_LIB	//- "Liberar"
				cOption := OemToANSI(STR0008)

			CASE cIdOption == OP_REJ	//- "Rejeitar"
				cOption := OemToANSI(STR0026)

			CASE cIdOption == OP_BLQ	//- "Bloquear"
				cOption := OemToANSI(STR0015)

			CASE cIdOption == OP_SUP //- "Aprovar pelo superior"
				cOption := OemToANSI(STR0013)

			CASE cIdOption == OP_TRA //- "Transferir para superior"
				cOption := OemToANSI(STR0014)
		ENDCASE

		lRet := MSGYESNO(STR0032+" "+cOption+" "+STR0034+" "+aAglutFlg[2]+" "+STR0035+CRLF+STR0036,STR0031)

		If lRet .And. ;
		(lCnClrAgFlg .And. !ExecBlock("CnClrAgFlg", .F., .F., {SCR->CR_FLUIG})) ;
		.Or. (!lCnClrAgFlg .And. lFCnClrAgFlg .And. !CnClrAgFlg(SCR->CR_FLUIG))
			lRet := .F.
			Help("",1,"A094AGFLG")
		EndIf
	EndIf
EndIf

IF lRet .and. SCR->CR_TIPO $ "SC" .and. !IsInCallStack("MATA110")	
	If SC1->(RLock())  .OR. SC1->(eof())	
	   	SC1->(DBRUnlock())
	Else	
		Help("",1,"VLDLOCK-SC1",,STR0058+Alltrim(SC1->C1_NUM)+". "+ STR0059,1,0) // "O Documento de número: "   " Está sendo alterado por outro usuário"
		lRet := .F.
	Endif
Endif

If lRet .and. SCR->CR_TIPO $ "PC|AE|IP" .and. !IsInCallStack("MATA120")	
	If SC7->(RLock())  .OR. SC7->(eof())	
		SC7->(DBRUnlock())
	Else
		Help("",1,"VLDLOCK-SC7",,STR0058+Alltrim(SC7->C7_NUM)+". "+ STR0059,1,0) // "O Documento de número: "   " Está sendo alterado por outro usuário"
		lRet := .F.
	Endif
Endif

// Validacoes bloqueio orcamentario
If lRet .And. SCR->CR_TIPO $ "PC|IP|CP|AE|NF" .And. cOperID == OP_LIB
	If !(lRet := A094PcoLan())
		Help("",1,"PCOVLDLAN",,STR0060,1,0) // "Saldo orçamentário insuficiente para aprovação do documento."
	EndIf
EndIf

Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} A094VldSup()
Efetua validação quando superior mostrando tela de senha do superior
@author Leonardo Quintania
@since 23/10/2013
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Static Function A094VldSup(cTpCad)
Local lRet			:= .T.
Local cAprovS		:= ""
Local cOriAprov		:= ""
Local aAreaAK		:= SAK->(GetArea())
Local aAreaAL		:= SAL->(GetArea())

If cTpCad == "AK"
	SAK->(dbSetOrder(1))
	SAK->(MsSeek(xFilial("SAK")+SCR->CR_APROV))
	
	cAprovS:= SAK->AK_APROSUP

	SAK->(dbSetOrder(1))
	SAK->(MsSeek(xFilial("SAK")+cAprovS))
	cOriAprov := SAK->AK_USER
	lRet := A097Pass(cOriAprov)
Elseif cTpCad == "AL"
	SAL->(dbSetOrder(3))
	SAL->(MsSeek(xFilial("SAL")+SCR->(CR_GRUPO+CR_APROV)))
	
	cAprovS:= SAL->AL_APROSUP

	SAK->(dbSetOrder(1))
	SAK->(MsSeek(xFilial("SAK")+cAprovS))
	cOriAprov := SAK->AK_USER
	lRet := A097Pass(cOriAprov)
Endif

RestArea(aAreaAK)
RestArea(aAreaAL)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A094VlMod()
Efetua validação do modelo de dados
@author Leonardo Quintania
@since 28/08/2013
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Static Function A094VlMod(oModel)
Local lRet 		:= .T.
Local ca094User := RetCodUsr()
Local cDocAprv	:= SuperGetMV("MV_DOCAPRV", .T., "")
Local lDocVld	:= .F.	

lDocVld := SCR->CR_TIPO $ cDocAprv

If cOperId <> OP_VIW 
	If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS $ "03#05#07"
		Help(" ",1,"A097LIB")  //Este documento já foi liberado.#### Escolha outro item que não foi liberado.
		lRet := .F.
	ElseIf SCR->CR_STATUS $ "01"
		Help(" ",1,"A097BLQ") // Esta operação não poderá ser realizada pois este registro se encontra bloqueado pelo sistema
		lRet := .F.
	ElseIf SCR->CR_STATUS $ "06"
		Help(" ",1,"A094REJ") // Esta operação não poderá ser realizada pois este registro se encontra rejeitado pelo sistema
		lRet := .F.
	ElseIf AllTrim(SCR->CR_USER) != AllTrim(ca094User)
		Help(" ",1,"A094USR",,STR0061,3,0,,,,,,{STR0062,STR0063}) // "Esta operação não poderá ser realizada pois o usuário aprovador não confere com o registro selecionado." // "Selecione o registro correspondente ao" // "usuário aprovador"
		lRet := .F.
	Elseif !lDocVld .And. (SCR->CR_EMISSAO > dDataBase)
		Help("",1,"DTEMISSUP",,STR0065,1,0) // "A data de emissão do documento é superior a DataBase do Sistema."
		lRet := .F.
	EndIf
EndIf


Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A094VldEst()
Verifica se o registro pode ser estornado ou não.
@author Leonardo Quintania
@since 30/08/2013
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Function A094VldEst()
Local cIdOption := OP_EST
Local lRet	:= .T.

If SCR->CR_STATUS $ "02,06"
	Help(" ",1,"A097NOESTOR")  //Não é possivel estornar o documento selecionado.
	lRet := .F.
ElseIf SCR->CR_STATUS $ "04"
	Help(" ",1,"A097BLQ") // Esta operação não poderá ser realizada pois este registro se encontra bloqueado pelo sistema
	lRet := .F.
ElseIf SCR->CR_TIPO $ "CT|IC|RV|IR|MD|IM"
	lRet := GCTEstApr()
ElseIf SCR->CR_TIPO >= "A1" .AND. SCR->CR_TIPO <= "A9" // Documentos do modulo Agro
	If FindFunction("OGXUtlOrig") //Identifica que esta utilizando o sigaagr				
		If OGXUtlOrig() .AND. FindFunction("OGX701AALC")	
			lRet := AGRXCOM5(SCR->CR_NUM, SCR->CR_TIPO, SCR->(Recno()))
		EndIf
	EndIf			
Else
	/*/Ponto de Entrada que contém os dados do documento para customizações diversas
	dos usuários /*/
	If ExistBlock("MT094END")
		ExecBlock("MT094END",.F.,.F.,{SCR->CR_NUM,SCR->CR_TIPO,Val(Substr(cIdOption,3,1)),SCR->CR_FILIAL})
	EndIf

	A097Estorna()
EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A094Bloqu()
Efetua o bloqueio do para os demais usuarios
@author Leonardo Quintania
@since 30/08/2013
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Function A094Bloqu()

cOperID:= OP_BLQ

If SCR->CR_TIPO >= "A1" .AND. SCR->CR_TIPO <= "A9" // Documentos do modulo Agro
	If FindFunction("OGXUtlOrig") //Identifica que esta utilizando o sigaagr				
		If OGXUtlOrig() .AND. FindFunction("OGX701AALC")	
			AGRXCOM6(SCR->CR_NUM, SCR->CR_TIPO, SCR->(Recno()))	
		EndIf
	EndIf 
	
ElseIf !(SCR->CR_TIPO $ 'SA|ST|SC|PC|IP|CT|IC|RV|IR|MD|IM|AE|CP')
	Help("",1,"A094TIPO",,STR0056+SCR->CR_TIPO,1,0) //A ação "Rejeitar" não está disponível para documentos do tipo #1.
	
ElseIf SCR->CR_STATUS $ "02" 
	FWExecView (STR0015, "MATA094", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ , /*cOperatId*/ ,/*cToolBar*/,/*oModelAct*/)//"Bloqueio"

Else
	Help(" ",1,"A097BLOQ")  //Não é possivel bloquear o documento selecionado. 
EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} A94ExSuper()
Executa ExecView do MATA094 porque houve a necessidade de validar a chamada quando executava o botão de superior
@author Leonardo Quintania
@since 23/10/2013
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Function A94ExSuper()
Local lRet := .T.

cOperID:= OP_SUP

SAK->(dbSetOrder(1))
SAK->(MsSeek(xFilial("SAK")+SCR->CR_APROV))
If Empty(SAK->AK_APROSUP)
	DbSelectArea("SAL")
	SAL->(DbSetOrder(3))
	SAL->(DbSeek(xFilial("SAL")+SCR->CR_GRUPO+SCR->CR_APROV))
	If Empty(SAL->AL_APROSUP)
		Help(" ",1,"A097APSUP") //Para utilizar esta opção, o Aprovador deve ter um Aprovador Superior cadastrado.   
		lRet := .F.
	Else
		FWExecView (STR0013, "MATA094", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},{ || A094VldSup("AL") } ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ , /*cOperatId*/ ,/*cToolBar*/,/*oModelAct*/)//"Aprovar pelo superior"
	Endif
Else
	FWExecView (STR0013, "MATA094", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},{ || A094VldSup("AK") } ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ , /*cOperatId*/ ,/*cToolBar*/,/*oModelAct*/)//"Aprovar pelo superior"
EndIf

	Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} A94ExTrans()
Executa ExecView do MATA094 para o botão Transferencia de superior
@author Leonardo Quintania
@since 23/10/2013
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Function A94ExTrans()
Local lRet := .T.

cOperID:= OP_TRA

SAK->(dbSetOrder(1))
SAK->(MsSeek(xFilial("SAK")+SCR->CR_APROV))
If Empty(SAK->AK_APROSUP)
	DbSelectArea("SAL")
	SAL->(DbSetOrder(3))
	SAL->(DbSeek(xFilial("SAL")+SCR->CR_GRUPO+SCR->CR_APROV))
	If Empty(SAL->AL_APROSUP)
		Help(" ",1,"A097APSUP") //Para utilizar esta opção, o Aprovador deve ter um Aprovador Superior cadastrado.    
		lRet := .F.
	Else
		FWExecView (STR0014, "MATA094", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ ,/*cOperatId*/,/*cToolBar*/,/*oModelAct*/)//"Transferir para superior
	Endif
Else
	FWExecView (STR0014, "MATA094", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ ,/*cOperatId*/,/*cToolBar*/,/*oModelAct*/)//"Transferir para superior
EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A94ExLiber()
Executa ExecView do MATA094 para o botão Liberação
@author Leonardo Quintania
@since 23/10/2013
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Function A94ExLiber()
Local lRet        := .T.
Local cAliasSC7   := ''
Local cGrupo      := ''
Local cDocAprv	  := SuperGetMV("MV_DOCAPRV", .T., "")
Local lDocVld	  := .F.

lDocVld := SCR->CR_TIPO $ cDocAprv

If ExistBlock("MT094LOK")
	lRet := ExecBlock("MT094LOK",.F.,.F.)
	If ValType(lRet) # 'L'
		lRet := .T.
	Endif
EndIf

If !lDocVld .And. (SCR->CR_EMISSAO > dDataBase)
	lRet := .F.
	Help("",1,"DTEMISSUP",,STR0065,1,0) // "A data de emissão do documento é superior a DataBase do Sistema."
EndIf

If lRet

	PcoIniLan("000055")

	cOperID:= OP_LIB
	If SCR->CR_TIPO = 'PC' .and.  Empty(SCR->CR_GRUPO)
		cAliasSC7 := GetNextAlias()
		cQuery := "SELECT C7_APROV , C7_NUM , C7_FILIAL FROM  " +RetSqlname("SC7")+ "  WHERE C7_NUM ="+"'" + SCR->CR_NUM +"'" + "AND C7_FILIAL ="+"'"+SCR->CR_FILIAL+"'"+" AND D_E_L_E_T_ <> '*' "  	 
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)	
		dbSelectArea(cAliasSC7)	
		
		Do While ( !Eof() .And. C7_FILIAL == xFilial("SC7") .And. AllTrim(C7_NUM) == AllTrim(SCR->CR_NUM) )
			cQuery := "UPDATE "+RetSqlname("SCR")		
			cQuery += " SET CR_GRUPO = "+"'"+C7_APROV+"'"
			cQuery += " WHERE CR_FILIAL ='"+xFilial("SCR")+"' AND "
			cQuery += " CR_NUM ='"+C7_NUM+"' AND "
			cQuery += " D_E_L_E_T_ <> '*' "  	 
			TcSqlExec(cQuery)		
			cGrupo := C7_APROV
			Exit		
			(cAliasSC7)->(dbSkip())
		EndDo	
	EndIf
		
	FWExecView (STR0006, "MATA094", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ , /*cOperatId*/ ,/*cToolBar*/,/*oModelAct*/)//"Superior"

	PcoFreeBlq("000055")

Endif
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} A094Rejeita()
Rejeita a solicitação de transferência.
@author Raphael Augustos
@since 17/03/2014
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Function A094Rejeita()
Local lRet := .T.

cOperID := OP_REJ
lRet := A097LibVal("MATA094")

//posto antes da validação para nao precisar alterar o IF original
If lRet .And. SCR->CR_TIPO >= "A1" .AND. SCR->CR_TIPO <= "A9" // Documentos do modulo Agro
	If FindFunction("OGXUtlOrig") //Identifica que esta utilizando o sigaagr				
		If OGXUtlOrig() .AND. FindFunction("OGX701AALC")	
			lRet := AGRXCOM7(SCR->CR_NUM, SCR->CR_TIPO, SCR->(Recno()))	
		EndIf
	EndIf
ElseIf lRet .And. !(SCR->CR_TIPO $ 'SA|ST|SC|PC|IP|CT|IC|RV|IR|MD|IM|AE|CP')
	lRet := .F.
	Help("",1,"A094TIPO",,I18N(STR0030,{SCR->CR_TIPO}),1,0) //A ação "Rejeitar" não está disponível para documentos do tipo #1.
EndIf

If lRet
	FWExecView (STR0026, "MATA094", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ , "004",/*cToolBar*/,/*oModelAct*/)//"Superior"
EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} A94Visual()
Executa ExecView do MATA094 porque houve a necessidade de validar a chamada quando executava o botão de visualizacao
@author Andre Anjos
@since 23/10/2013
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Function A94Visual()
Local lRet := .T.

cOperID:= OP_VIW

FWExecView (STR0027, "MATA094", MODEL_OPERATION_UPDATE) //"Visualizar"

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A094PcoLan()
Validacoes de bloqueio orcamentario.
@author Carlos Capeli
@since 28/12/2016
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Static Function A094PcoLan()

Local aArea    := GetArea()
Local aAreaSC7 := SC7->(GetArea())
Local ca094User:= RetCodUsr()
Local cName    := ""
Local lA097PCO := ExistBlock("A097PCO")
Local lLanPCO  := .T.	//-- Podera ser modificada pelo PE A097PCO
Local lVldPCO  := .T.	//-- verifica se ja foi feito o lancamento no pco
Local lRet     := .T.

If lA097PCO
	cName   := UsrRetName(ca094User)
	lLanPCO := ExecBlock("A097PCO",.F.,.F.,{SC7->C7_NUM,cName,lLanPCO})
EndIf

IF SCR->CR_TIPO == "PC" .Or. SCR->CR_TIPO == "AE" .Or. SCR->CR_TIPO == "IP"
	lVldPCO := !A094VrfLan(SC7->C7_FILIAL,SC7->C7_NUM,SCR->CR_TIPO)
ENDIF

If lLanPCO .and. lVldPCO

	If SCR->CR_TIPO == "PC" .Or. SCR->CR_TIPO == "AE" .Or. SCR->CR_TIPO == "IP"
		dbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek(xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM)))
	EndIf
	If  lRet := PcoVldLan('000055','02','MATA097')
		If SCR->CR_TIPO == "NF"
			dbSelectArea("SF1")
		ElseIf SCR->CR_TIPO == "PC" .Or. SCR->CR_TIPO == "AE" .Or. SCR->CR_TIPO == "IP"
			While lRet .And. !Eof() .And. SC7->C7_FILIAL+Substr(SC7->C7_NUM,1,len(SC7->C7_NUM)) == xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
				lRet := PcoVldLan("000055","01","MATA097")
				dbSelectArea("SC7")
				dbSkip()
			EndDo
		ElseIf SCR->CR_TIPO == "CP"
			dbSelectArea("SC3")
		EndIf
	EndIf 
	If !lRet
		PcoFreeBlq("000055")
	EndIf

EndIf

RestArea(aAreaSC7)
RestArea(aArea)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} SetOper()
Altera o conteudo da variavel estatica cOperid

@author jose.delmondes
@since 15/12/2017
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Function A094SetOp( cId )
	cOperID	:= cId
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} A094VrfLan()
Verifica se o pedido já existiram aprovações para o pedido e 
consequentemente gravações de lançamentos na tabela AKD 
@author Wesley Lossani
@since 30/12/2020
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Static Function A094VrfLan(cFilSCR,cNum,cTipo)
Local lRet 		:= .F. 
Local aAreaSCR	:= SCR->(GetArea())

Default cFilSCR := cFilAnt
Default cNum	:= ""
Default cTipo 	:= ""


dbSelectArea("SCR")
SCR->(DbSetOrder(1))
//CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL                                                                                                                               
If SCR->(DbSeek(cFilSCR+cTipo+cNum))
	While  !lRet .and. !Eof() .and. cFilSCR == SCR->CR_FILIAL .and. cTipo == SCR->CR_TIPO .and. cNum == AllTrim(SCR->CR_NUM )
		lRet := AllTrim(SCR->CR_STATUS) == '03' .and. !Empty(SCR->CR_DATALIB)
		SCR->(DbSkip())
	EndDo
EndIf

RestArea(aAreaSCR)
Return lRet

/*/{Protheus.doc} CNCCfgMdl
	Configura em <oModel> o submodelo dos Fornecedores/Clientes do Contrato(CNCDETAIL)
@author philipe.pompeu
@since 12/01/2022
@return oModel, objeto, instância de MPFormModel
/*/
Static Function CNCCfgMdl(oModel)
	Local oStr5 	:= NIL
	Local nTipoCtr	:= 0

	If (SCR->CR_TIPO $ 'CT|IC|RV|IR|MD|IM')
		nTipoCtr := CNTXAlcTp( SCR->CR_NUM , SCR->CR_TIPO )
				
		If nTipoCtr == 1
			oStr5 := FwFormStruct(1,'CNC',{|cCampo| Alltrim(cCampo)+'|' $ "CNC_CODIGO|CNC_LOJA|CNC_NOME|"})
		Else
			oStr5 := FwFormStruct(1,'CNC',{|cCampo| Alltrim(cCampo)+'|' $ "CNC_CLIENT|CNC_LOJACL|CNC_NOMECL|"})
		EndIf
		
		oStr5:AddField(  STR0044															,;	// 	[01]  C   Titulo do campo  
						STR0044															,;	// 	[02]  C   ToolTip do campo
						'CNC_NUMPLA'														,;	// 	[03]  C   Id do Field
						'C'																,;	// 	[04]  C   Tipo do campo
						TAMSX3("CNA_NUMERO")[1]											,;	// 	[05]  N   Tamanho do campo
						0																	,;	// 	[06]  N   Decimal do campo
						NIL																,;	// 	[07]  B   Code-block de validação do campo
						NIL																,;	// 	[08]  B   Code-block de validação When do campo
						NIL																,;	//	[09]  A   Lista de valores permitido do campo
						.F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						NIL																,;	//	[11]  B   Code-block de inicializacao do campo
						NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.F.																)	// 	[14]  L   Indica se o campo é virtual
		
		oStr5:AddField(  STR0045															,;	// 	[01]  C   Titulo do campo  
						STR0045															,;	// 	[02]  C   ToolTip do campo
						'CNC_TIPPLA'														,;	// 	[03]  C   Id do Field
						'C'																,;	// 	[04]  C   Tipo do campo
						TAMSX3("CNA_TIPPLA")[1]											,;	// 	[05]  N   Tamanho do campo
						0																	,;	// 	[06]  N   Decimal do campo
						NIL																,;	// 	[07]  B   Code-block de validação do campo
						NIL																,;	// 	[08]  B   Code-block de validação When do campo
						NIL																,;	//	[09]  A   Lista de valores permitido do campo
						.F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						NIL																,;	//	[11]  B   Code-block de inicializacao do campo
						NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.F.																)	// 	[14]  L   Indica se o campo é virtual
						
		oStr5:AddField(  STR0046															,;	// 	[01]  C   Titulo do campo  
						STR0046															,;	// 	[02]  C   ToolTip do campo
						'CNC_DESCRI'														,;	// 	[03]  C   Id do Field
						'C'																,;	// 	[04]  C   Tipo do campo
						TAMSX3("CNA_DESCRI")[1]											,;	// 	[05]  N   Tamanho do campo
						0																	,;	// 	[06]  N   Decimal do campo
						NIL																,;	// 	[07]  B   Code-block de validação do campo
						NIL																,;	// 	[08]  B   Code-block de validação When do campo
						NIL																,;	//	[09]  A   Lista de valores permitido do campo
						.F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						NIL																,;	//	[11]  B   Code-block de inicializacao do campo
						NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.F.																)	// 	[14]  L   Indica se o campo é virtual
						
		oStr5:AddField(  STR0047															,;	// 	[01]  C   Titulo do campo  
						STR0047															,;	// 	[02]  C   ToolTip do campo
						'CNC_VLTOT'														,;	// 	[03]  C   Id do Field
						'N'																,;	// 	[04]  C   Tipo do campo
						TAMSX3("CNA_VLTOT")[1]												,;	// 	[05]  N   Tamanho do campo
						TAMSX3("CNA_VLTOT")[2]												,;	// 	[06]  N   Decimal do campo
						NIL																,;	// 	[07]  B   Code-block de validação do campo
						NIL																,;	// 	[08]  B   Code-block de validação When do campo
						NIL																,;	//	[09]  A   Lista de valores permitido do campo
						.F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						NIL																,;	//	[11]  B   Code-block de inicializacao do campo
						NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.F.																)	// 	[14]  L   Indica se o campo é virtual
		
		oStr5:AddField(  STR0048															,;	// 	[01]  C   Titulo do campo  
						STR0048															,;	// 	[02]  C   ToolTip do campo
						'CNC_DIASV'														,;	// 	[03]  C   Id do Field
						'N'																,;	// 	[04]  C   Tipo do campo
						5																	,;	// 	[05]  N   Tamanho do campo
						0																	,;	// 	[06]  N   Decimal do campo
						NIL																,;	// 	[07]  B   Code-block de validação do campo
						NIL																,;	// 	[08]  B   Code-block de validação When do campo
						NIL																,;	//	[09]  A   Lista de valores permitido do campo
						.F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						NIL																,;	//	[11]  B   Code-block de inicializacao do campo
						NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.F.																)	// 	[14]  L   Indica se o campo é virtual
		
		oStr5:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
		
		oModel:AddGrid('CNCDETAIL','FieldSCR',oStr5)
		oModel:GetModel('CNCDETAIL'):SetOnlyQuery(.T.)
		oModel:GetModel('CNCDETAIL'):SetOptional(.T.)
		
		If SCR->CR_TIPO $ 'IM'
			oModel:GetModel("GridDoc"):GetStruct():SetProperty("CNE_QUANT",MODEL_FIELD_OBRIGAT,.F.)
		ElseIf SCR->CR_TIPO $ 'IC|IR'
			oModel:GetModel("GridDoc"):GetStruct():SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
		EndIf
	EndIf
Return

/*/{Protheus.doc} CNCCfgView
	Configura em <oView> o submodelo dos Fornecedores/Clientes do Contrato(CNCDETAIL)
@author philipe.pompeu
@since 12/01/2022
@return oView, objeto, instância de FWFormView
/*/
Static Function CNCCfgView(oView)
	Local oStr5		:= NIL
	Local nTipoCtr	:= 0

	If SCR->CR_TIPO $ 'CT|RV|IC|IR|MD|IM'		
		nTipoCtr := CNTXAlcTp( SCR->CR_NUM , SCR->CR_TIPO )		
		
		If nTipoCtr == 1
			oStr5 := FwFormStruct(2,'CNC',{|cCampo| Alltrim(cCampo)+'|' $ "CNC_CODIGO|CNC_LOJA|CNC_NOME|"})
		Else
			oStr5 := FwFormStruct(2,'CNC',{|cCampo| Alltrim(cCampo)+'|' $ "CNC_CLIENT|CNC_LOJACL|CNC_NOMECL|"})
		EndIf
		
		oStr5:AddField( 'CNC_NUMPLA'														,;	// [01]  C   Nome do Campo
						'12'																,;	// [02]  C   Ordem
						STR0044																,;	// [03]  C   Titulo do campo//"Descrição"
						STR0049     														,;	// [04]  C   Descricao do campo//"Descrição"
						NIL																	,;	// [05]  A   Array com Help
						'C'																	,;	// [06]  C   Tipo do campo
						'@!'																,;	// [07]  C   Picture
						NIL																	,;	// [08]  B   Bloco de Picture Var
						NIL																	,;	// [09]  C   Consulta F3
						.F.																	,;	// [10]  L   Indica se o campo é alteravel
						NIL																	,;	// [11]  C   Pasta do campo
						NIL																	,;	// [12]  C   Agrupamento do campo
						NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL																	,;	// [15]  C   Inicializador de Browse
						.T.																	,;	// [16]  L   Indica se o campo é virtual
						NIL																	,;	// [17]  C   Picture Variavel
						NIL																	)	// [18]  L   Indica pulo de linha após o campo
					
		oStr5:AddField( 'CNC_TIPPLA'														,;	// [01]  C   Nome do Campo
						'13'																,;	// [02]  C   Ordem
						STR0045																,;	// [03]  C   Titulo do campo//"Descrição"
						STR0050				     											,;	// [04]  C   Descricao do campo//"Descrição"
						NIL																	,;	// [05]  A   Array com Help
						'C'																	,;	// [06]  C   Tipo do campo
						'@!'																,;	// [07]  C   Picture
						NIL																	,;	// [08]  B   Bloco de Picture Var
						NIL																	,;	// [09]  C   Consulta F3
						.F.																	,;	// [10]  L   Indica se o campo é alteravel
						NIL																	,;	// [11]  C   Pasta do campo
						NIL																	,;	// [12]  C   Agrupamento do campo
						NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL																	,;	// [15]  C   Inicializador de Browse
						.T.																	,;	// [16]  L   Indica se o campo é virtual
						NIL																	,;	// [17]  C   Picture Variavel
						NIL																	)	// [18]  L   Indica pulo de linha após o campo
						
		oStr5:AddField( 'CNC_DESCRI'														,;	// [01]  C   Nome do Campo
						'14'																,;	// [02]  C   Ordem
						STR0046																,;	// [03]  C   Titulo do campo//"Descrição"
						STR0051      									 					,;	// [04]  C   Descricao do campo//"Descrição"
						NIL																	,;	// [05]  A   Array com Help
						"C"																	,;	// [06]  C   Tipo do campo
						"@!"																,;	// [07]  C   Picture
						NIL																	,;	// [08]  B   Bloco de Picture Var
						NIL																	,;	// [09]  C   Consulta F3
						.F.																	,;	// [10]  L   Indica se o campo é alteravel
						NIL																	,;	// [11]  C   Pasta do campo
						NIL																	,;	// [12]  C   Agrupamento do campo
						NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL																	,;	// [15]  C   Inicializador de Browse
						.T.																	,;	// [16]  L   Indica se o campo é virtual
						NIL																	,;	// [17]  C   Picture Variavel
						NIL																	)	// [18]  L   Indica pulo de linha após o campo

		oStr5:AddField( 'CNC_VLTOT'															,;	// [01]  C   Nome do Campo
						'15'																,;	// [02]  C   Ordem
						STR0047																,;	// [03]  C   Titulo do campo//"Descrição"
						STR0047				     											,;	// [04]  C   Descricao do campo//"Descrição"
						NIL																	,;	// [05]  A   Array com Help
						"N"																	,;	// [06]  C   Tipo do campo
						PesqPict("CNA","CNA_VLTOT")											,;	// [07]  C   Picture
						NIL																	,;	// [08]  B   Bloco de Picture Var
						NIL																	,;	// [09]  C   Consulta F3
						.F.																	,;	// [10]  L   Indica se o campo é alteravel
						NIL																	,;	// [11]  C   Pasta do campo
						NIL																	,;	// [12]  C   Agrupamento do campo
						NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL																	,;	// [15]  C   Inicializador de Browse
						.T.																	,;	// [16]  L   Indica se o campo é virtual
						NIL																	,;	// [17]  C   Picture Variavel
						NIL																	)	// [18]  L   Indica pulo de linha após o campo
						
		oStr5:AddField( 'CNC_DIASV'															,;	// [01]  C   Nome do Campo
						'16'																,;	// [02]  C   Ordem
						STR0048																,;	// [03]  C   Titulo do campo//"Descrição"
						STR0052						     									,;	// [04]  C   Descricao do campo//"Descrição"
						NIL																	,;	// [05]  A   Array com Help
						"N"																	,;	// [06]  C   Tipo do campo
						'@E 99,999'                                    						,;	// [07]  C   Picture
						NIL																	,;	// [08]  B   Bloco de Picture Var
						NIL																	,;	// [09]  C   Consulta F3
						.F.																	,;	// [10]  L   Indica se o campo é alteravel
						NIL																	,;	// [11]  C   Pasta do campo
						NIL																	,;	// [12]  C   Agrupamento do campo
						NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL																	,;	// [15]  C   Inicializador de Browse
						.T.																	,;	// [16]  L   Indica se o campo é virtual
						NIL																	,;	// [17]  C   Picture Variavel
						NIL																	)	// [18]  L   Indica pulo de linha após o campo
		
		oView:AddGrid('GridFor',oStr5,'CNCDETAIL')
	EndIf
Return
