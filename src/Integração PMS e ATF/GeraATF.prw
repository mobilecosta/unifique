#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

#DEFINE  CABECALHO "N1_CBASE/N1_ITEM/N1_AQUISIC/N1_DESCRIC/N1_QUANTD/N1_CHAPA/N1_PATRIM/N1_GRUPO/"
#DEFINE  Itens "N3_CBASE/N3_ITEM/N3_TIPO/N3_BAIXA/N3_HISTOR/N3_CCONTAB/N3_CUSTBEM/N3_CDEPREC/N3_CDESP/N3_CCORREC/N3_DINDEPR/N3_VORIG1/N3_TXDEPR1/N3_VORIG2/N3_TXDEPR2/N3_VORIG3/N3_TXDEPR3/N3_VORIG4/N3_TXDEPR4/N3_VORIG5/N3_SUBCCON/N3_CLVLCON/N3_TXDEPR5/"

Static __lClassifica:= .F.
Static __lCopia:= .F.

/*////////////////////////////////////////////////////////////////////////////////*/
/*@nomeFunction: 	  				U_GeraATF()						   	 		  */ 
/*--------------------------------------------------------------------------------*/ 
/*							FunÁ„o de Montagem da Tela MVC	 				  	  */ 
/*					Chamando funÁ„o de para Inclus„o de Bem no Ativo Fixo  		  */ 
/*					  													 	      */ 
/*--------------------------------------------------------------------------------*/ 
/*@author: 						Pedro Almeida - CodERP							  */ 
/*@since: 				    	  	   22/11/2023								  */ 
/*////////////////////////////////////////////////////////////////////////////////*/

User Function GeraATF()
	Local aArea   := GetArea()
	Local aButtons := {{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.T.,"Confirmar"},;
		{.T.,"Fechar"},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,NIl}}
	cBkp := FunName()

	DbSelectArea('SN1')

	SN1->(DbSetOrder(1))

	SetFunName('ATFA012')
	
	Pergunte("AFA012",.F.)

	oModel := FWLoadModel("ATFA012")
	oModel:SetOperation(MODEL_OPERATION_INSERT)

	oModel:Activate(.T.)
	oModel:LoadValue("SN1MASTER","N1_CBASE", AF8->AF8_PROJET)
	oModel:LoadValue("SN1MASTER","N1_QUANTD", POSICIONE('AFC',1,xFilial('AFC')+AFC->AFC_PROJET ,"AFC_QUANT"))
	oModel:LoadValue("SN1MASTER","N1_AQUISIC",ddatabase)
	oModel:LoadValue("SN1MASTER","N1_FILIAL",xFilial('SN1'))
	oModel:LoadValue("SN1MASTER","N1_DESCRIC",AF8->AF8_DESCRI)

	//oModel:LoadValue("SN3DETAIL","N3_HISTOR",' ')//passar os valores corretos quando obtiver os campos certos
	//oModel:LoadValue("SN3DETAIL","N3_VORIG1",' ')
	//oModel:LoadValue("SN3DETAIL","N3_DTBAIXA",' ')
	//oModel:LoadValue("SN3DETAIL","N3_HISTOR",' ')

	FWExecView("Inclus„o de Bem - Revis„o","GeraATF",3,,{|| .T.},,72,aButtons,,,,oModel)
	oModel:DeActivate()

	SetFunName(cBkp)
	RestArea(aArea)
Return

/*////////////////////////////////////////////////////////////////////////////////*/ 
/*@nomeFunction: 	  					ModelDef()							   	  */ 
/*--------------------------------------------------------------------------------*/ 
/*							   Modelo do cabecalho e grid		  				  */ 
/*--------------------------------------------------------------------------------*/ 
/*@author: 						Pedro Almeida - CodERP							  */ 
/*@since: 				    	  	   22/11/2023								  */ 
/*////////////////////////////////////////////////////////////////////////////////*/ 
Static Function ModelDef()
	Local oModel   := Nil
	Local oStPai   := FWFormStruct( 1, 'SN1' )
	Local oStFilho := FWFormStruct( 1, 'SN3' )

	oModel := MPFormModel():New("MGeraATF", /*{|oModel| MDMVlPre( oModel ) }bPre*/, /*{|oModel| MDMVlPos( oModel ) }/*bPos*/,/*{||ComplZZ3( Self ) }bCommit*/,/*bCancel*/)
	oModel:AddFields('SN1MASTER',/*cOwner*/,oStPai)
	oModel:SetDescription("Inclus„o de Bem no Ativo Fixo")
	oModel:AddGrid('SN3DETAIL','SN1MASTER',oStFilho,, , , ,)
	oModel:SetDescription("Inclus„o de Bem no Ativou Fixo")
	oModel:SetPrimaryKey({})

	oModel:GetModel('SN1MASTER'):SetDescription('TÌtulo')
	oModel:GetModel('SN3DETAIL'):SetDescription('Saldos e Valores')

Return oModel


/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					ViewDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*							  ExibiÁao do cabecalho e grid		  				  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Pedro Almeida - CodERP							  */ *
/*@since: 				    	  	   22/11/2023								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *

Static Function ViewDef()
	Local oView     := Nil
	Local oModel    := FWLoadModel('GeraATF')
	Local oStPai 	:= FWFormStruct( 2, 'SN1' )
	Local oStFilho 	:= FWFormStruct( 2, 'SN3' )

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	//Adicionando os campos do cabeùalho e o grid dos filhos
	oView:AddField('VIEW_CAB', oStPai ,'SN1MASTER')
	oView:AddGrid('VIEW_DET', oStFilho ,'SN3DETAIL')
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',70)
	oView:CreateHorizontalBox('GRID',30)
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_DET','GRID')

Return oView
