#Include 'TOTVS.ch' 
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} UNIA094()
Aprovação de Projetos
@author Leonardo Quintania
@since 01/03/2024
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User Function UNIA094()

	Local oBrowse  
	Local cFiltraSCR
	Local ca097User  := RetCodUsr()
	LOCAL nx         := 0
	LOCAL aLegenda   := {}
	
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
			dbSelectArea("ZZR")
			dbSetOrder(1)		
			      
			If cFiltraSCR == NIL
				cFiltraSCR  := 'ZZR_FILIAL=="'+xFilial("SCR")+'"'+'.And.ZZR_USER=="'+ca097User 
			EndIf		
	   	    
			Do Case
				Case mv_par01 == 1
					cFiltraSCR += '".And.ZZR_STATUS=="02"'
				Case mv_par01 == 2
					cFiltraSCR += '".And.(ZZR_STATUS=="03".OR.CR_STATUS=="05")'
				Case mv_par01 == 3
					cFiltraSCR += '"'
				Case mv_par01 == 4
					cFiltraSCR += '".And.ZZR_STATUS=="04"'
				Case mv_par01 == 5
					cFiltraSCR += '".And.ZZR_STATUS=="06"'
				OtherWise
					cFiltraSCR += '".And.(ZZR_STATUS=="01".OR.ZZR_STATUS=="04")'
			EndCase
			
			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias('ZZR')
			                                   
			// Definição da legenda
			aAdd(aLegenda, { "ZZR_STATUS=='01'", "BR_AZUL" , "Bloqueado (aguardando outros niveis)" }) 
			aAdd(aLegenda, { "ZZR_STATUS=='02'", "DISABLE" , "Aguardando Liberacao do usuario" }) 
			aAdd(aLegenda, { "ZZR_STATUS=='03'", "ENABLE"  , "Documento Liberado pelo usuario" }) 
			aAdd(aLegenda, { "ZZR_STATUS=='04'", "BR_PRETO", "Documento Bloqueado pelo usuario" }) 
			aAdd(aLegenda, { "ZZR_STATUS=='05'", "BR_CINZA", "Documento Liberado por outro usuario" }) 
			aAdd(aLegenda, { "ZZR_STATUS=='06'", "BR_CANCEL","Documento Rejeitado pelo usuário" }) 
			aAdd(aLegenda, { "ZZR_STATUS=='07'","BR_AMARELO", "Documento Rejeitado ou Bloqueado por outro usuário" })
			
			FOR nx := 1 TO LEN(aLegenda)
				oBrowse:AddLegend(aLegenda[nx][1], aLegenda[nx][2], aLegenda[nx][3])
			NEXT nx
			
			oBrowse:SetCacheView(.F.)
			oBrowse:DisableDetails()
			oBrowse:SetDescription("Aprovação de Documentos")  
			oBrowse:SetFilterDefault(cFiltraSCR)
			obrowse:SetChgAll(.F.)
			obrowse:SetSeeAll(.F.)
			
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

ADD OPTION aRotina TITLE "Aprovar"    ACTION "u_uni094apv()" 	OPERATION 4 ACCESS 0

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
Local oStr1 := FWFormStruct(1,'ZZR')
Local oStr3 := FWFormStruct(1,'SAK')

oModel := MPFormModel():New('UNIX094',/*PreModel*/, {|oModel| A094TudoOk(oModel)}, { |oModel| A094Commit( oModel ) },/*Cancel*/)
oModel:SetDescription("Aprovacao Projeto")

oModel:addFields('FieldZZR',,oStr1) 
oModel:addFields('FieldSAK','FieldSCR',oStr3)

oModel:SetRelation("FieldSAK",{{"AK_FILIAL",'xFilial("SAK")'},{"AK_COD","CR_APROV"}},SAK->(IndexKey(1)))

oModel:SetPrimaryKey( {} ) //Obrigatorio setar a chave primaria (mesmo que vazia)

oModel:getModel('FieldSAK'):SetOnlyQuery(.T.)
oModel:getModel('FieldSCR'):SetDescription("Aprovacao Projeto")

Return oModel

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
Local oModel := FWLoadModel("UNIA094")
Local oStr1  := FWFormStruct(2,'ZZR')
Local oStr3  := FWFormStruct(2,'SAK')

oView := FWFormView():New()
oView:showUpdateMsg(.F.)
oView:showInsertMsg(.T.)

oView:SetModel(oModel)
oView:AddField('SCRField' , oStr1,'FieldSCR' )
oView:AddField('SAKField' , oStr3,'FieldSAK' )

oView:SetOwnerView('SCRField','CimaSCR')
oView:EnableTitleView('SCRField' , "Dados do Documento" )

oView:SetOwnerView('SAKField','MeioSAK')
oView:EnableTitleView('SAKField' , "Dados do Aprovador" )
oView:SetViewProperty('SAKField' , 'ONLYVIEW' )

oView:SetCloseOnOK({||.T.}) 

Return oView

User Function UN94GAPV(cAF8_PROJET, nTotal)

Local cGrpAPV := SuperGetMV("MV_UNIGPRJ",, "000001")

M->ZZR_STATUS := "02"	// Pendente

SAL->(DbSetOrder(1))		// AL_FILIAL + AL_COD + AL_ITEM
SAL->(DbSeek(xFilial() + cGrpAPV))
While SAL->AL_FILIAL == xFilial("SAL") .AND. SAL->AL_COD == cGrpAPV .AND. ! SAL->(Eof())
	ZZR->(RecLock("ZZR", .T.))
	ZZR->ZZR_FILIAL := xFilial("ZZR")
	ZZR->ZZR_PROJET := cAF8_PROJET
	ZZR->ZZR_USER   := SAL->AL_USER
	ZZR->ZZR_APROV  := SAL->AL_APROV
	ZZR->ZZR_GRUPO  := SAL->AL_COD
	ZZR->ZZR_ITGRP  := SAL->AL_ITEM
	ZZR->ZZR_NIVEL  := SAL->AL_NIVEL
	ZZR->ZZR_STATUS := M->ZZR_STATUS
	ZZR->ZZR_DATA   := dDataBase
	ZZR->ZZR_HORA   := Time()
	ZZR->ZZR_TOTAL  := nTotal
	ZZR->(MsUnLock())

	M->ZZR_STATUS := "01"	// Aguardando nivel anterior

	SAL->(DbSkip())
EndDo

Return
