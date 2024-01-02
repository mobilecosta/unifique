#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "Directry.ch"

/*/{Protheus.doc} ADSConcA
Programa principal para a conciliação automática.
@type   : User Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
/*/
User Function ADSConcA()

	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	// Define a tabela de dados.
	oBrowse:SetAlias("Z0C")
	// Nome do fonte onde esta a função MenuDef.
	oBrowse:SetMenuDef("ADSConcA")
	// Descrição do browse.
	oBrowse:SetDescription("Conciliação Automática")
	// Desabilita opção Ambiente do menu Ações Relacionadas.
   	oBrowse:SetAmbiente(.F.)
	// Desabilita opção WalkThru do menu Ações Relacionadas.
   	oBrowse:SetWalkThru(.F.)
	// Legendas.
	oBrowse:AddLegend("Empty(Z0C->Z0C_CONC)"	,"BR_VERMELHO"	,"Não conciliado")
	oBrowse:AddLegend("!Empty(Z0C->Z0C_CONC)"	,"BR_VERDE"		,"Conciliado")
	// Desabilita a exibição dos detalhes do registro posicionado.
	oBrowse:DisableDetails()
	// Ativação da classe.
	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Retorna as opções do menu da rotina.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
@return : aRotina, array, opções do menu.
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "" 			ACTION "" 			OPERATION MODEL_OPERATION_VIEW 		ACCESS 0 // Este item em branco serve para mater a ordem das opções de forma correta.
	ADD OPTION aRotina TITLE "" 			ACTION "" 			OPERATION MODEL_OPERATION_VIEW 		ACCESS 0 // Este item em branco serve para mater a ordem das opções de forma correta.
	ADD OPTION aRotina TITLE "Importar" 	ACTION "U_ADSConcM" OPERATION MODEL_OPERATION_INSERT 	ACCESS 0
	ADD OPTION aRotina TITLE "Conciliar" 	ACTION "U_ADSConcM" OPERATION MODEL_OPERATION_UPDATE	ACCESS 0

Return aRotina

/*/{Protheus.doc} ADSConcM
Função para realizar as manutenções conforme a opção selecionada no menu.
@type   : User Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
@param  : cAlias, characters, alias.
@param  : nRecno, numeric, recno.
@param  : nOpc, numeric, opção.
/*/
User Function ADSConcM(cAlias,nRecno,nOpc)

	Local aParam		:= {}
	Local aPerg			:= {}
	Private cCadastro 	:= "Conciliação Automática"

	If nOpc == MODEL_OPERATION_INSERT
		TNewProcess():New("ADSConcA";
						,"Importação do Extrato de Conta Corrente para Conciliação Bancária";
						,{|oProc| ImpFile(oProc)};
						,"Este programa irá realizar a importação do extrato da conta corrente para posterior conciliação automática.";
						,"ADSCONCA")
	Else
		AAdd(aPerg,{1,"Data De"	,dDataBase					,"@D","Empty(MV_PAR02) .Or. MV_PAR01 <= MV_PAR02"	,""		,".T.",50																	,.T.})
		AAdd(aPerg,{1,"Data Até",dDataBase					,"@D","MV_PAR02 >= MV_PAR01"						,""		,".T.",50																	,.T.})
		AAdd(aPerg,{1,"Banco"	,CriaVar("E5_BANCO",.F.)	,"@D",""											,"SA6"	,".T.",CalcFieldSize("D",TamSX3("E5_BANCO")[1],TamSX3("E5_BANCO")[2],"")	,.F.})
		AAdd(aPerg,{1,"Agência"	,CriaVar("E5_AGENCIA",.F.)	,"@D",""											,""		,".F.",CalcFieldSize("D",TamSX3("E5_AGENCIA")[1],TamSX3("E5_AGENCIA")[2],""),.F.})
		AAdd(aPerg,{1,"Conta"	,CriaVar("E5_CONTA",.F.)	,"@D",""											,""		,".F.",CalcFieldSize("D",TamSX3("E5_CONTA")[1],TamSX3("E5_CONTA")[2],"")	,.F.})

		If ParamBox(aPerg,"Conciliação Bancária",aParam,,,,,,,,.F.)
			ManutConcA(aParam)
		EndIf
	EndIf

Return

/*/{Protheus.doc}
Função para importar os dados do arquivo e gravá-los na tabela.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
/*/
Static Function ImpFile(oProc)

	Local aAreaZ0C	:= Z0C->(GetArea())
	Local aFiles	:= {}
	Local nFile		:= 0
	Private oJTable := U_ADSTab2J("Z0C")

	MV_PAR01 := AllTrim(MV_PAR01)
	// Coleta todos arquivos da pasta.
	aFiles := Directory(MV_PAR01 + "EXT_*.RET")

	Z0C->(DBSetOrder(2))

	oProc:SetRegua1(Len(aFiles))
	For nFile := 1 To Len(aFiles)
		If !Z0C->(DBSeek(xFilial("Z0C") + Upper(aFiles[nFile][F_NAME])))
			oProc:IncRegua1("Processando arquivo: " + aFiles[nFile][F_NAME])
			ReadFile(aFiles[nFile],oProc)
		Else
			ShowHelpDlg("IsImp",{"Arquivo já importado: " + AllTrim(aFiles[nFile][F_NAME])},1,{},0)
		EndIf
	Next nFile

	RestArea(aAreaZ0C)

	WriteData(oProc)

Return

/*/{Protheus.doc} ReadFile
Função responsável por ler o arquivo e estrutura os dados conforme a tabela de configurações.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 10/09/2019
@version: 1.00
@param  : aFile, array, estrutura do arquivo.
@param  : oProc, object, obejo de processamento.
/*/
Static Function ReadFile(aFile,oProc)

	Local aLines	:= {}
	Local cField	:= ""
	Local cLine		:= ""
	Local nField	:= 0
	Local nLine		:= 0
	Local oFile		:= Nil
	Local oJCNAB 	:= U_ADSCNAB()

	oFile := FWFileReader():New(MV_PAR01 + aFile[F_NAME])

	If oFile:Open()
		aLines := oFile:GetAllLines()
		oFile:Close()

		oProc:SetRegua2(Len(aLines))
		For nLine := 1 To Len(aLines)
			oProc:IncRegua2("Coletando dados da linha: " + cValToChar(nLine))
			cLine := aLines[nLine]

			// Somente registros detalhe.
			If SubStr(cLine,8,1) == "3"
				// Nova linha.
				AAdd(oJTable["Data"],Array(Len(oJTable["Header"])))

				// Informa dados referente a importação.
				ATail(oJTable["Data"])[U_ADSAScan(oJTable["Header"],"Z0C_FILE")] := Upper(aFile[F_NAME])
				ATail(oJTable["Data"])[U_ADSAScan(oJTable["Header"],"Z0C_USER")] := cUserName
				ATail(oJTable["Data"])[U_ADSAScan(oJTable["Header"],"Z0C_DTIMP")] := Date()
				ATail(oJTable["Data"])[U_ADSAScan(oJTable["Header"],"Z0C_LINE")] := cLine

				For nField := 1 To Len(oJCNAB["CNAB"])
					// Coleta o campo e conteúdo conforme o CNAB.
					cField := "Z0C_" + oJCNAB["CNAB"][nField]["Campo"]
					cValue := SubStr(cLine,oJCNAB["CNAB"][nField]["Inicio"],oJCNAB["CNAB"][nField]["Tamanho"])
					// Armazena o conteúdo no JSON da tabela.
					ATail(oJTable["Data"])[U_ADSAScan(oJTable["Header"],cField)] := CToType(cValue,oJTable["Header"][U_ADSAScan(oJTable["Header"],cField)])
				Next nField
			EndIf
		Next nLine
	Else
		ShowHelpDlg("NoOpen",{"Não foi possível abrir o arquivo informado."},1,{"Tente novamente."},1)
	EndIf

	FreeObj(oFile)

Return

/*/{Protheus.doc} CToType
Função para converter o dado de characters para o tipo informado.
@type 	: Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since	: 23/11/2019
@version: 1.0
@param	: cValue, characters, valor em caracter que será convertido.
@param	: oHeader, object, JSON do header do dado que será convertido.
@return	: xConvVal, undefined, dado convertido.
/*/
Static Function CToType(cValue,oHeader)

	Local xConvVal := Nil

	Do Case
		// Número.
		Case oHeader["Tipo"] == "N"
			xConvVal := Val(cValue)/(10^oHeader["Decimal"])
		// Data.
		Case oHeader["Tipo"] == "D"
			xConvVal := SToD(Right(cValue,4) + SubStr(cValue,3,2) + Left(cValue,2))
		// Lógico.
		Case oHeader["Tipo"] == "L"
			xConvVal := Upper(AllTrim(cValue)) == ".T."
		// Outro.
		OtherWise
			If AllTrim(oHeader["Campo"]) $ "Z0C_AGENC|Z0C_CONTA"
				// Tratativa para Caixa.
				If AllTrim(oHeader["Campo"]) == "Z0C_CONTA" .And. cValue == "003000000690"
					xConvVal := "690"
				ElseIf AllTrim(oHeader["Campo"]) == "Z0C_AGENC"
					xConvVal := StrZero(Val(cValue),4)
				Else
					xConvVal := cValToChar(Val(cValue))
				EndIf
			Else
				xConvVal := Upper(AllTrim(cValue))
			EndIf
	EndCase

Return xConvVal

/*/{Protheus.doc} WriteData
Função para persistir os dados lidos do arquivo.
@type 	: Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since	: 23/11/2019
@version: 1.0
@param  : oProc, object, obejo de processamento.
/*/
Static Function WriteData(oProc)

	Local nCol	:= 0
	Local nLine := 0
	Local nPos	:= 0

	oProc:SetRegua1(1)
	oProc:IncRegua1("Gravando informações")

	Begin Transaction
		oProc:SetRegua2(Len(oJTable["Data"]))
		For nLine := 1 To Len(oJTable["Data"])
			oProc:IncRegua2("Registros processados: " + cValToChar(nLine))

			RecLock("Z0C",.T.)
				For nCol := 1 To Len(oJTable["Header"])
					// Se o campo for encontrado, grava o seu conteúdo.
					If (nPos := Z0C->(FieldPos(oJTable["Header"][nCol]["Campo"]))) > 0 .And. !Empty(oJTable["Data"][nLine][nCol])
						Z0C->(FieldPut(nPos,oJTable["Data"][nLine][nCol]))
					EndIf
				Next nCol
				// Informa filial posicionada.
				Z0C->Z0C_FILIAL := xFilial("Z0C")
			Z0C->(MsUnlock())
			//Verifica se é taxa e realiza a gravação no SE5
			If Z0C->Z0C_CATLAN $ "105" .OR. SubStr(Z0C->Z0C_HIST,1,3) == 'TAR'
				GeraTaxa(Z0C->Z0C_DATA, "M1", Z0C->Z0C_VALOR, "20106001", Z0C->Z0C_BANCO, Z0C->Z0C_AGENC, Z0C->Z0C_CONTA, Z0C->Z0C_DOC, Z0C->Z0C_HIST)
			Endif
			//Fim
		Next nLine
	End Transaction

Return

/*/{Protheus.doc} ManutConcA
Função para manutenção da conciliação automática.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
@param	: aParam, array, parâmetros de filtro.
/*/
Static Function ManutConcA(aParam)

	Local aSizeMain := FWGetDialogSize(oMainWnd)
	Local bCancel	:= {|| IIf(MsgYesNo("Deseja realmente sair?","Sair"),oDlg:End(),Nil)}
	Local bConfirm	:= {|| IIf(MsgYesNo("Confirma a conciliação automática?","Gravar"),FwMsgRun(,{|| GrvConcA(),oDlg:End()},"Processando","Gravando alterações..."),Nil)}
	Local oDlg 		:= Nil
	Local oLayer	:= Nil
	Local oPnBco	:= Nil
	Local oPnExt	:= Nil
	Local oPnSE5	:= Nil
	Local oSize		:= Nil
	Private oJBco 	:= U_ADSTab2J("Z0C",.F.,.T.)
	Private oJExt 	:= U_ADSTab2J("Z0C",.T.,.T.)
	Private oJSE5 	:= U_ADSTab2J("SE5",.T.,.T.)

	// Tela principal.
	oDlg := TDialog():New(aSizeMain[1],aSizeMain[2],aSizeMain[3],aSizeMain[4],,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,,,.F.)

	oDlg:lEscClose := .F.

	// Calcula coordenadas.
	oSize := FWDefSize():New(.T.,,,oDlg)
	oSize:lLateral := .F.
	oSize:AddObject("ALL",100,100,.T.,.T.)
	oSize:lProp := .T.
	oSize:Process()

	// Cria painel para poder utilizar enchoice bar.
	aCoord := {oSize:GetDimension("ALL","LININI"),oSize:GetDimension("ALL","COLINI"),oSize:GetDimension("ALL","XSIZE"),oSize:GetDimension("ALL","YSIZE")}
	oPnAll := TPanel():New(aCoord[1],aCoord[2],"",oDlg,,,,CLR_BLACK,CLR_WHITE,aCoord[3],aCoord[4])

	// Layer principal.
	oLayer := FWLayer():New()
	oLayer:Init(oPnAll,.F.)

	// Divisões superior.
	oLayer:AddLine("UP",30,.F.)

	// Cria o painel de bancos.
	oLayer:AddCollumn("UP",100,.F.,"UP")
	oLayer:AddWindow("UP","oPnBco","Bancos",100,.F.,.T.,{||},"UP",{||})
	oPnBco := oLayer:GetWinPanel("UP","oPnBco","UP")

	// Cria divisão inferior.
	oLayer:AddLine("DOWN",70,.F.)

	// Cria o painel de extrato da conta corrente.
	oLayer:AddCollumn("LEFT",50,.F.,"DOWN")
	oLayer:AddWindow("LEFT","oPnExt","Extrato da Conta Corrente",100,.F.,.T.,{||},"DOWN",{||})
	oPnExt := oLayer:GetWinPanel("LEFT","oPnExt","DOWN")

	// Cria o painel para as movimentações bancárias.
	oLayer:AddCollumn("RIGHT",50,.F.,"DOWN")
	oLayer:AddWindow("RIGHT","oPnSE5","Movimentações Bancárias",100,.F.,.T.,{||},"DOWN",{||})
	oPnSE5 := oLayer:GetWinPanel("RIGHT","oPnSE5","DOWN")

	// Monta paineis.
	FWMsgRun(,{|| DrawnPn(oPnBco,oPnExt,oPnSE5,aParam)},"Carregando","Carregando informações...")

	// Exibe dialog.
	oDlg:Activate(,,,.T.,,,{|| EnchoiceBar(oDlg,bConfirm,bCancel)})

Return

/*/{Protheus.doc} DrawnPn
Função para montar os painéis.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
@param  : oPnBco, object, painel.
@param  : oPnExt, object, painel.
@param  : oPnSE5, object, painel.
@param	: aParam, array, parâmetros de filtro.
/*/
Static Function DrawnPn(oPnBco,oPnExt,oPnSE5,aParam)

	Local aFields := {}

	InitVar(aParam)

	/*/
		Painel: Bancos.
	/*/
	aFields := {"Z0C_BANCO","Z0C_AGENC","Z0C_CONTA","Z0C_XVLRTOT","Z0C_XVLRCONC","Z0C_XSALDO"}

	// Monta grid.
	oJBco["Grid"] := TCBrowse():New(0,0,0,0,,,,oPnBco,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	oJBco["Grid"]:Align := CONTROL_ALIGN_ALLCLIENT
	oJBco["Grid"]:SetArray(oJBco["Data"])
	// Ação ao trocar de linha.
	oJBco["Grid"]:bSeekChange := {|| FWMsgRun(,{|| ChangeLine(.T.)},"Processando","Atualizando grid")}
	// Adiciona colunas.
	oJBco["Grid"]:AddColumn(TCColumn():New(oJBco["Header"][U_ADSAScan(oJBco["Header"],"Z0C_XLEG")]["Titulo"],{|| LoadBitmap(GetResources(),oJBco["Grid"]:aArray[oJBco["Grid"]:nAt][U_ADSAScan(oJBco["Header"],"Z0C_XLEG")])},,,,,,.T.))
	AEVal(aFields,{|x| oJBco["Grid"]:AddColumn(TCColumn():New(&('oJBco["Header"][U_ADSAScan(oJBco["Header"],"' + x + '")]["Titulo"]'),&('{|| oJBco["Grid"]:aArray[oJBco["Grid"]:nAt][U_ADSAScan(oJBco["Header"],"' + x + '")]}')))})

	/*/
		Painel: Extrato da Conta Corrente.
	/*/
	aFields := {"Z0C_DATA","Z0C_VALOR","Z0C_TIPO","Z0C_HIST"}

	// Monta grid.
	oJExt["Grid"] := TCBrowse():New(0,0,0,0,,,,oPnExt,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	oJExt["Grid"]:Align := CONTROL_ALIGN_ALLCLIENT
	oJExt["Grid"]:SetArray(oJExt["Data"])
	// Ação ao trocar de linha.
	oJExt["Grid"]:bSeekChange := {|| FWMsgRun(,{|| ChangeLine()},"Processando","Atualizando grid")}
	// Adiciona colunas.
	oJExt["Grid"]:AddColumn(TCColumn():New(oJExt["Header"][U_ADSAScan(oJExt["Header"],"Z0C_XLEG")]["Titulo"],{|| LoadBitmap(GetResources(),oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_XLEG")])},,,,,,.T.))
	AEVal(aFields,{|x| oJExt["Grid"]:AddColumn(TCColumn():New(&('oJExt["Header"][U_ADSAScan(oJExt["Header"],"' + x + '")]["Titulo"]'),&('{|| oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"' + x + '")]}')))})

	/*/
		Painel: Movimentações Bancárias.
	/*/
	aFields := {"E5_PREFIXO","E5_NUMERO","E5_PARCELA","E5_TIPO","E5_CLIFOR","E5_LOJA","E5_NATUREZ","E5_VALOR","E5_HISTOR"}

	// Monta grid.
	oJSE5["Grid"] := TCBrowse():New(0,0,0,0,,,,oPnSE5,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	oJSE5["Grid"]:Align := CONTROL_ALIGN_ALLCLIENT
	oJSE5["Grid"]:SetArray(oJSE5["Data"])
	oJSE5["Grid"]:bLDblClick := {|| FWMsgRun(,{|| MarkDesm()},"Processando","Conciliando registro.")}
	// Adiciona colunas.
	oJSE5["Grid"]:AddColumn(TCColumn():New(oJSE5["Header"][U_ADSAScan(oJSE5["Header"],"E5_XLEG")]["Titulo"],{|| LoadBitmap(GetResources(),oJSE5["Grid"]:aArray[oJSE5["Grid"]:nAt][U_ADSAScan(oJSE5["Header"],"E5_XLEG")])},,,,,,.T.))
	AEVal(aFields,{|x| oJSE5["Grid"]:AddColumn(TCColumn():New(&('oJSE5["Header"][U_ADSAScan(oJSE5["Header"],"' + x + '")]["Titulo"]'),&('{|| oJSE5["Grid"]:aArray[oJSE5["Grid"]:nAt][U_ADSAScan(oJSE5["Header"],"' + x + '")]}')))})

	FWMsgRun(,{|| ConcAut()},"Processando","Realizando conciliação automática")

	UpdSldBco()

	FWMsgRun(,{|| ChangeLine(.T.)},"Processando","Atualizando grid")

Return

/*/{Protheus.doc} InitVar
Função para inicializar as variáveis.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
@param	: aParam, array, parâmetros de filtro.
/*/
Static Function InitVar(aParam)

	Local cAlias	:= GetNextAlias()
	Local cWhereSE5	:= ""
	Local cWhereZ0C	:= ""
	Local nField	:= 0

	// Adiciona campos para totais da conciliação.
	AAdd(oJBco["Header"],JSONObject():New())
	ATail(oJBco["Header"])["Titulo"]	:= "Valor Total"
    ATail(oJBco["Header"])["Campo"]		:= "Z0C_XVLRTOT"
	ATail(oJBco["Header"])["Picture"]	:= "@E 9,999,999,999,999.99"
    ATail(oJBco["Header"])["Tamanho"]	:= 16
	ATail(oJBco["Header"])["Decimal"]	:= 2
	ATail(oJBco["Header"])["Tipo"]		:= "N"

	AAdd(oJBco["Header"],JSONObject():New())
	ATail(oJBco["Header"])["Titulo"]	:= "Valor Conciliado"
    ATail(oJBco["Header"])["Campo"]		:= "Z0C_XVLRCONC"
	ATail(oJBco["Header"])["Picture"]	:= "@E 9,999,999,999,999.99"
    ATail(oJBco["Header"])["Tamanho"]	:= 16
	ATail(oJBco["Header"])["Decimal"]	:= 2
	ATail(oJBco["Header"])["Tipo"]		:= "N"

	AAdd(oJBco["Header"],JSONObject():New())
	ATail(oJBco["Header"])["Titulo"]	:= "Saldo"
    ATail(oJBco["Header"])["Campo"]		:= "Z0C_XSALDO"
	ATail(oJBco["Header"])["Picture"]	:= "@E 9,999,999,999,999.99"
    ATail(oJBco["Header"])["Tamanho"]	:= 16
	ATail(oJBco["Header"])["Decimal"]	:= 2
	ATail(oJBco["Header"])["Tipo"]		:= "N"

	AAdd(oJBco["Data"],Array(Len(oJBco["Header"])))
	U_ADSInArr(oJBco)

	// Adiciona campo de RECNO da SE5 para o extrato bancário.
	AAdd(oJExt["Header"],JSONObject():New())
	ATail(oJExt["Header"])["Titulo"]	:= "Recno SE5"
    ATail(oJExt["Header"])["Campo"]		:= "Z0C_XRECE5"
	ATail(oJExt["Header"])["Picture"]	:= "@E 9,999,999,999,999,999"
    ATail(oJExt["Header"])["Tamanho"]	:= 16
	ATail(oJExt["Header"])["Decimal"]	:= 0
	ATail(oJExt["Header"])["Tipo"]		:= "N"

	cWhereSE5 += "%"
	cWhereZ0C += "%"
	If !Empty(aParam[3])
		cWhereSE5 += "AND E5_BANCO = '" + aParam[3] + "'"
		cWhereZ0C += "AND Z0C_BANCO = '" + aParam[3] + "'"
	Else
		cWhereSE5 += "AND E5_BANCO != '" + aParam[3] + "'"
		cWhereZ0C += "AND Z0C_BANCO != '" + aParam[3] + "'"
	EndIf
	If !Empty(aParam[4])
		cWhereSE5 += "AND E5_AGENCIA = '" + aParam[4] + "'"
		cWhereZ0C += "AND Z0C_AGENC = '" + aParam[4] + "'"
	Else
		cWhereSE5 += "AND E5_AGENCIA != '" + aParam[4] + "'"
		cWhereZ0C += "AND Z0C_AGENC != '" + aParam[4] + "'"
	EndIf
	If !Empty(aParam[5])
		cWhereSE5 += "AND E5_CONTA = '" + aParam[5] + "'"
		cWhereZ0C += "AND Z0C_CONTA = '" + aParam[5] + "'"
	Else
		cWhereSE5 += "AND E5_CONTA != '" + aParam[5] + "'"
		cWhereZ0C += "AND Z0C_CONTA != '" + aParam[5] + "'"
	EndIf
	cWhereSE5 += "%"
	cWhereZ0C += "%"

	BeginSQL Alias cAlias
		Column Z0C_DATA As Date

		SELECT
			Z0C.*
		FROM
			%Table:Z0C% Z0C
		WHERE
				Z0C_FILIAL = %xFilial:Z0C%
			AND Z0C_DATA BETWEEN %Exp:aParam[1]% AND %Exp:aParam[2]%
			AND Z0C_CONC = %Exp:CriaVar("Z0C_CONC",.F.)%
			AND Z0C.%NotDel%
			%Exp:cWhereZ0C%
	EndSQL

	If !(cAlias)->(EOF())
		While !(cAlias)->(EOF())
			// Inicializa o array.
			AAdd(oJExt["Data"],Array(Len(oJExt["Header"])))
			U_ADSInArr(oJExt)
			ATail(oJExt["Data"])[U_ADSAScan(oJExt["Header"],"Z0C_XLEG")] := "DISABLE"
			ATail(oJExt["Data"])[U_ADSAScan(oJExt["Header"],"Z0C_REC_WT")] := (cAlias)->R_E_C_N_O_

			For nField := 1 To Len(oJExt["Header"])
				If (cAlias)->(FieldPos(oJExt["Header"][nField]["Campo"])) > 0
					ATail(oJExt["Data"])[nField] := (cAlias)->(FieldGet((cAlias)->(FieldPos(oJExt["Header"][nField]["Campo"]))))
				EndIf
			Next nField
			(cAlias)->(DBSkip())
		End
	Else
		AAdd(oJExt["Data"],Array(Len(oJExt["Header"])))
		U_ADSInArr(oJExt)
		ATail(oJExt["Data"])[U_ADSAScan(oJExt["Header"],"Z0C_XLEG")] := "DISABLE"
	EndIf
	(cAlias)->(DBCloseArea())

	cAlias := GetNextAlias()

	BeginSQL Alias cAlias
		Column E5_DATA As Date

		SELECT
			SE5.*
		FROM
			%Table:SE5% SE5
		WHERE
				E5_FILIAL BETWEEN %Exp:CriaVar("E5_FILIAL",.F.)% AND %Exp:Replicate("Z",TamSX3("E5_FILIAL")[1])%
			AND E5_DATA BETWEEN %Exp:aParam[1]% AND %Exp:aParam[2]%
			AND E5_RECONC = %Exp:CriaVar("E5_RECONC",.F.)%
			AND E5_TIPODOC NOT IN ("JR","J2","TL","DC","D2","MT","M2","CM","C2","CP","BA","V2")
			AND E5_SITUACA != "C"
			AND (E5_MOEDA NOT IN ("C1","C2","C3","C4","C5","CH") OR E5_NUMCHEQ != %Exp:CriaVar("E5_NUMCHEQ",.F.)% OR E5_TIPODOC IN ("TR","TE"))
			AND SE5.%NotDel%
			%Exp:cWhereSE5%
	EndSQL

	If !(cAlias)->(EOF())
		While !(cAlias)->(EOF())
			// Inicializa o array.
			AAdd(oJSE5["Data"],Array(Len(oJSE5["Header"])))
			U_ADSInArr(oJSE5)
			ATail(oJSE5["Data"])[U_ADSAScan(oJSE5["Header"],"E5_XLEG")] := "LBNO"
			ATail(oJSE5["Data"])[U_ADSAScan(oJSE5["Header"],"E5_REC_WT")] := (cAlias)->R_E_C_N_O_

			For nField := 1 To Len(oJSE5["Header"])
				If (cAlias)->(FieldPos(oJSE5["Header"][nField]["Campo"])) > 0
					ATail(oJSE5["Data"])[nField] := (cAlias)->(FieldGet((cAlias)->(FieldPos(oJSE5["Header"][nField]["Campo"]))))
				EndIf
			Next nField
			(cAlias)->(DBSkip())
		End
	Else
		AAdd(oJSE5["Data"],Array(Len(oJSE5["Header"])))
		U_ADSInArr(oJSE5)
		ATail(oJSE5["Data"])[U_ADSAScan(oJSE5["Header"],"E5_XLEG")] := "LBNO"
	EndIf
	(cAlias)->(DBCloseArea())

Return


/*/{Protheus.doc} UpdSldBco
Função para atualizar o saldo conciliador por banco.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 24/11/2019
@version: 1.00
/*/
Static Function UpdSldBco()

	Local nLine	:= 0
	Local nPos	:= 0

	oJBco["Data"] := {}

	For nLine := 1 To Len(oJExt["Data"])
		If (nPos := AScan(oJBco["Data"],{|x| x[U_ADSAScan(oJExt["Header"],"Z0C_BANCO")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_BANCO")];
										.And. x[U_ADSAScan(oJExt["Header"],"Z0C_AGENC")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_AGENC")];
										.And. x[U_ADSAScan(oJExt["Header"],"Z0C_CONTA")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_CONTA")]})) == 0
			AAdd(oJBco["Data"],Array(Len(oJBco["Header"])))
			U_ADSInArr(oJBco)
			nPos := Len(oJBco["Data"])
			oJBco["Data"][nPos][U_ADSAScan(oJBco["Header"],"Z0C_XLEG")] := "DISABLE"
			oJBco["Data"][nPos][U_ADSAScan(oJBco["Header"],"Z0C_BANCO")] := oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_BANCO")]
			oJBco["Data"][nPos][U_ADSAScan(oJBco["Header"],"Z0C_AGENC")] := oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_AGENC")]
			oJBco["Data"][nPos][U_ADSAScan(oJBco["Header"],"Z0C_CONTA")] := oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_CONTA")]
			oJBco["Data"][nPos][U_ADSAScan(oJBco["Header"],"Z0C_XVLRTOT")] := 0
			oJBco["Data"][nPos][U_ADSAScan(oJBco["Header"],"Z0C_XVLRCONC")] := 0
			oJBco["Data"][nPos][U_ADSAScan(oJBco["Header"],"Z0C_XSALDO")] := 0
		EndIf

		oJBco["Data"][nPos][U_ADSAScan(oJBco["Header"],"Z0C_XVLRTOT")] += oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_VALOR")]
		If oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_CONC")] == 'x'
			oJBco["Data"][nPos][U_ADSAScan(oJBco["Header"],"Z0C_XVLRCONC")] += oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_VALOR")]
		Else
			oJBco["Data"][nPos][U_ADSAScan(oJBco["Header"],"Z0C_XSALDO")] += oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_VALOR")]
		EndIf
	Next nLine

	// Atualiza legenda.
	For nLine := 1 To Len(oJBco["Data"])
		If oJBco["Data"][nLine][U_ADSAScan(oJBco["Header"],"Z0C_XVLRTOT")] == oJBco["Data"][nLine][U_ADSAScan(oJBco["Header"],"Z0C_XVLRCONC")]
			oJBco["Data"][nLine][U_ADSAScan(oJBco["Header"],"Z0C_XLEG")] := "ENABLE"
		EndIf
	Next nLine

	If Empty(oJBco["Data"])
		AAdd(oJBco["Data"],Array(Len(oJBco["Header"])))
		U_ADSInArr(oJBco)
		ATail(oJBco["Data"])[U_ADSAScan(oJBco["Header"],"Z0C_XLEG")] := "DISABLE"
		ATail(oJBco["Data"])[U_ADSAScan(oJBco["Header"],"Z0C_XVLRTOT")] := 0
		ATail(oJBco["Data"])[U_ADSAScan(oJBco["Header"],"Z0C_XVLRCONC")] := 0
		ATail(oJBco["Data"])[U_ADSAScan(oJBco["Header"],"Z0C_XSALDO")] := 0
	EndIf

	oJBco["Grid"]:SetArray(oJBco["Data"])
	oJBco["Grid"]:Refresh()

Return

/*/{Protheus.doc} ChangeLine
Função para atualizar grids ao trocar de linha.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 24/11/2019
@version: 1.00
@param	: lAll, logical, se atualiza tudo.
/*/
Static Function ChangeLine(lAll)

	Local aTemp 	:= {}
	Local nLine		:= 0
	Local nPos		:= 0
	Default lAll	:= .F.

	If lAll
		For nLine := 1 To Len(oJExt["Data"])
			If oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_BANCO")] == oJBco["Grid"]:aArray[oJBco["Grid"]:nAt][U_ADSAScan(oJBco["Header"],"Z0C_BANCO")];
				.And. oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_AGENC")] == oJBco["Grid"]:aArray[oJBco["Grid"]:nAt][U_ADSAScan(oJBco["Header"],"Z0C_AGENC")];
				.And. oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_CONTA")] == oJBco["Grid"]:aArray[oJBco["Grid"]:nAt][U_ADSAScan(oJBco["Header"],"Z0C_CONTA")]

				AAdd(aTemp,AClone(oJExt["Data"][nLine]))
			EndIf
		Next nLine

		If Empty(aTemp)
			AAdd(aTemp,Array(Len(oJExt["Header"])))
			ATail(aTemp)[U_ADSAScan(oJExt["Header"],"Z0C_XLEG")] := "DISABLE"
		EndIf

		oJExt["Grid"]:SetArray(aTemp)
		oJExt["Grid"]:Refresh()
	EndIf

	aTemp := {}
	// Ignora os lançamentos de estorno.
	If !(oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_CATLAN")] $ "103|204")
		// Se houver movimentação bancária marcada, traz apenas ela, do contrário, traz todas as que atendem a característica.
		If oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_XRECE5")] != 0;
			.And. (nPos := AScan(oJSE5["Data"],{|x| x[U_ADSAScan(oJSE5["Header"],"E5_REC_WT")] == oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_XRECE5")]})) > 0
			AAdd(aTemp,AClone(oJSE5["Data"][nPos]))
			// Exibe os títulos que compõem o lote.
			If !Empty(oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_LOTE")]) .And. AllTrim(oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_NATUREZ")]) == "NATMOVR"
				For nLine := 1 To Len(oJSE5["Data"])
					If oJSE5["Data"][nLine][U_ADSAScan(oJSE5["Header"],"E5_LOTE")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_LOTE")];
						.And. oJSE5["Data"][nLine][U_ADSAScan(oJSE5["Header"],"E5_RECPAG")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_RECPAG")];
						.And. oJSE5["Data"][nLine][U_ADSAScan(oJSE5["Header"],"E5_REC_WT")] != oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_REC_WT")]
						AAdd(aTemp,AClone(oJSE5["Data"][nLine]))
					EndIf
				Next nLine
			EndIf
		Else
			For nLine := 1 To Len(oJSE5["Data"])
				// Somente relaciona se os critérios de data, banco, agência, conta, valor e tipo forem atendidos ainda não havendo itens marcados para o registro do extrato.
				If oJSE5["Data"][nLine][U_ADSAScan(oJSE5["Header"],"E5_DATA")] == oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_DATA")];
					.And. oJSE5["Data"][nLine][U_ADSAScan(oJSE5["Header"],"E5_BANCO")] == oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_BANCO")];
					.And. oJSE5["Data"][nLine][U_ADSAScan(oJSE5["Header"],"E5_AGENCIA")] == oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_AGENC")];
					.And. oJSE5["Data"][nLine][U_ADSAScan(oJSE5["Header"],"E5_CONTA")] == oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_CONTA")];
					.And. oJSE5["Data"][nLine][U_ADSAScan(oJSE5["Header"],"E5_VALOR")] == oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_VALOR")];
					.And. oJSE5["Data"][nLine][U_ADSAScan(oJSE5["Header"],"E5_RECPAG")] == IIf(oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_TIPO")] == 'D','P','R');
					.And. AScan(oJExt["Data"],{|x| x[U_ADSAScan(oJExt["Header"],"Z0C_XRECE5")] == oJSE5["Data"][nLine][U_ADSAScan(oJSE5["Header"],"E5_REC_WT")]}) == 0
					AAdd(aTemp,AClone(oJSE5["Data"][nLine]))
				EndIf
			Next nLine
		EndIf
	EndIf

	If Empty(aTemp)
		AAdd(aTemp,Array(Len(oJSE5["Header"])))
		ATail(aTemp)[U_ADSAScan(oJSE5["Header"],"E5_XLEG")] := "LBNO"
	EndIf

	oJSE5["Grid"]:SetArray(aTemp)
	oJSE5["Grid"]:Refresh()

Return

/*/{Protheus.doc} ConcAut
Função que realiza a conciliação automática conforme os critérios.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 24/11/2019
@version: 1.00
/*/
Static Function ConcAut()

	Local nLine 	:= 0
	Local nPos		:= 0
	Local nPosLote 	:= 0

	For nLine := 1 To Len(oJExt["Data"])
		// Ingora registros do tipo estorno e que não há duplicidade.
		If !(oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_CATLAN")] $ "103|204");
			.And. (nPos := AScan(oJSE5["Data"],{|x| x[U_ADSAScan(oJSE5["Header"],"E5_DATA")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_DATA")];
													.And. x[U_ADSAScan(oJSE5["Header"],"E5_BANCO")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_BANCO")];
													.And. x[U_ADSAScan(oJSE5["Header"],"E5_AGENCIA")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_AGENC")];
													.And. x[U_ADSAScan(oJSE5["Header"],"E5_CONTA")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_CONTA")];
													.And. x[U_ADSAScan(oJSE5["Header"],"E5_VALOR")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_VALOR")];
													.And. x[U_ADSAScan(oJSE5["Header"],"E5_RECPAG")] == IIf(oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_TIPO")] == 'D','P','R');
													.And. x[U_ADSAScan(oJSE5["Header"],"E5_XLEG")] == "LBNO"})) > 0
			oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_XLEG")] := "LBOK"
			// Filtra novamente a partir do item encontrado, pois deixa desmarcado se encontrar outro com as mesmas características.
			If AScan(oJSE5["Data"],{|x| x[U_ADSAScan(oJSE5["Header"],"E5_DATA")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_DATA")];
										.And. x[U_ADSAScan(oJSE5["Header"],"E5_BANCO")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_BANCO")];
										.And. x[U_ADSAScan(oJSE5["Header"],"E5_AGENCIA")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_AGENC")];
										.And. x[U_ADSAScan(oJSE5["Header"],"E5_CONTA")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_CONTA")];
										.And. x[U_ADSAScan(oJSE5["Header"],"E5_VALOR")] == oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_VALOR")];
										.And. x[U_ADSAScan(oJSE5["Header"],"E5_RECPAG")] == IIf(oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_TIPO")] == 'D','P','R');
										.And. x[U_ADSAScan(oJSE5["Header"],"E5_XLEG")] == "LBNO"}) > 0
				oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_XLEG")] := "LBNO"
				oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_XLEG")] := "BR_AMARELO"
			Else
				// Seleciona os títulos que compõem o lote, notar que o campo XLEG recebe outra legenda, para controle interno.
				If !Empty(oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_LOTE")]) .And. AllTrim(oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_NATUREZ")]) == "NATMOVR"
					While (nPosLote := AScan(oJSE5["Data"],{|x| x[U_ADSAScan(oJSE5["Header"],"E5_LOTE")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_LOTE")];
													.And. x[U_ADSAScan(oJSE5["Header"],"E5_RECPAG")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_RECPAG")];
													.And. x[U_ADSAScan(oJSE5["Header"],"E5_REC_WT")] != oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_REC_WT")];
													.And. x[U_ADSAScan(oJSE5["Header"],"E5_XLEG")] != "BR_AZUL"})) > 0
						oJSE5["Data"][nPosLote][U_ADSAScan(oJSE5["Header"],"E5_XLEG")] := "BR_AZUL"
					End
				EndIf
				// Atualiza status para conciliado no extrato.
				oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_XLEG")] := "ENABLE"
				oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_CONC")] := 'x'
				oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_XRECE5")] := oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_REC_WT")]
			EndIf
		EndIf
	Next nLine

Return

/*/{Protheus.doc} MarkDesm
Função para marcar/desmarcar a conciliação.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 27/11/2019
@version: 1.00
/*/
Static Function MarkDesm()

	Local nPos		:= 0
	Local nPosLote	:= 0
	Local nRecno	:= 0

	// Coleta a posição no array principal, ignorando os lançamentos de estorno.
	If	!(oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_CATLAN")] $ "103|204");
		.And. (nPos := AScan(oJSE5["Data"],{|x| x[U_ADSAScan(oJSE5["Header"],"E5_REC_WT")] == oJSE5["Grid"]:aArray[oJSE5["Grid"]:nAt][U_ADSAScan(oJSE5["Header"],"E5_REC_WT")]})) > 0
		// Só permite desmarcar quando houver mais de uma movimentação bancária relacionada a linha do extrato.
		If oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_XLEG")] == "LBOK";
			.And. AScan(oJSE5["Data"],{|x| x[U_ADSAScan(oJSE5["Header"],"E5_DATA")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_DATA")];
											.And. x[U_ADSAScan(oJSE5["Header"],"E5_BANCO")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_BANCO")];
											.And. x[U_ADSAScan(oJSE5["Header"],"E5_AGENCIA")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_AGENCIA")];
											.And. x[U_ADSAScan(oJSE5["Header"],"E5_CONTA")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_CONTA")];
											.And. x[U_ADSAScan(oJSE5["Header"],"E5_VALOR")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_VALOR")];
											.And. x[U_ADSAScan(oJSE5["Header"],"E5_RECPAG")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_RECPAG")];
											.And. x[U_ADSAScan(oJSE5["Header"],"E5_REC_WT")] != oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_REC_WT")]}) > 0
			oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_XLEG")] := "LBNO"
			// Atualiza status para não conciliado no extrato.
			If (nPos := AScan(oJExt["Data"],{|x| x[U_ADSAScan(oJExt["Header"],"Z0C_REC_WT")] == oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_REC_WT")]})) > 0
				oJExt["Data"][nPos][U_ADSAScan(oJExt["Header"],"Z0C_XLEG")] := "BR_AMARELO"
				oJExt["Data"][nPos][U_ADSAScan(oJExt["Header"],"Z0C_CONC")] := CriaVar("Z0C_CONC",.F.)
				oJExt["Data"][nPos][U_ADSAScan(oJExt["Header"],"Z0C_XRECE5")] := 0
			EndIf
		// Só permite marcar quando houver mais de uma movimentação bancária relacionada a linha do extrato.
		ElseIf oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_XLEG")] == "LBNO";
			.And. AScan(oJSE5["Data"],{|x| x[U_ADSAScan(oJSE5["Header"],"E5_DATA")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_DATA")];
										.And. x[U_ADSAScan(oJSE5["Header"],"E5_BANCO")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_BANCO")];
										.And. x[U_ADSAScan(oJSE5["Header"],"E5_AGENCIA")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_AGENCIA")];
										.And. x[U_ADSAScan(oJSE5["Header"],"E5_CONTA")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_CONTA")];
										.And. x[U_ADSAScan(oJSE5["Header"],"E5_VALOR")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_VALOR")];
										.And. x[U_ADSAScan(oJSE5["Header"],"E5_RECPAG")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_RECPAG")];
										.And. x[U_ADSAScan(oJSE5["Header"],"E5_REC_WT")] != oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_REC_WT")]}) > 0
			oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_XLEG")] := "LBOK"
			// Seleciona os títulos que compõem o lote, notar que o campo XLEG recebe outra legenda, para controle interno.
			If !Empty(oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_LOTE")]) .And. AllTrim(oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_NATUREZ")]) == "NATMOVR"
				While (nPosLote := AScan(oJSE5["Data"],{|x| x[U_ADSAScan(oJSE5["Header"],"E5_LOTE")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_LOTE")];
												.And. x[U_ADSAScan(oJSE5["Header"],"E5_RECPAG")] == oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_RECPAG")];
												.And. x[U_ADSAScan(oJSE5["Header"],"E5_REC_WT")] != oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_REC_WT")];
												.And. x[U_ADSAScan(oJSE5["Header"],"E5_XLEG")] != "BR_AZUL"})) > 0
					oJSE5["Data"][nPosLote][U_ADSAScan(oJSE5["Header"],"E5_XLEG")] := "BR_AZUL"
				End
			EndIf
			nRecno := oJSE5["Data"][nPos][U_ADSAScan(oJSE5["Header"],"E5_REC_WT")]
			// Atualiza status para conciliado no extrato.
			If (nPos := AScan(oJExt["Data"],{|x| x[U_ADSAScan(oJExt["Header"],"Z0C_REC_WT")] == oJExt["Grid"]:aArray[oJExt["Grid"]:nAt][U_ADSAScan(oJExt["Header"],"Z0C_REC_WT")]})) > 0
				oJExt["Data"][nPos][U_ADSAScan(oJExt["Header"],"Z0C_XLEG")] := "ENABLE"
				oJExt["Data"][nPos][U_ADSAScan(oJExt["Header"],"Z0C_CONC")] := 'x'
				oJExt["Data"][nPos][U_ADSAScan(oJExt["Header"],"Z0C_XRECE5")] := nRecno
			EndIf
		EndIf
	EndIf

	// Atualiza grids.
	UpdSldBco()
	FWMsgRun(,{|| ChangeLine(.T.)},"Processando","Atualizando grid")

Return

/*/{Protheus.doc} GrvConcA
Função para gravar as alterações realizadas na conciliação.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 30/11/2019
@version: 1.00
/*/
Static Function GrvConcA()

	Local cKey	:= ""
	Local nLine := 0

	DBSelectArea("SE5")
	SE5->(DBSetOrder(5))

	DBSelectArea("Z0C")

	For nLine := 1 To Len(oJExt["Data"])
		If oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_XRECE5")] > 0
			SE5->(DBGoTo(oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_XRECE5")]))

			GrvConcPad(SE5->E5_RECONC,oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_CONC")])

			// Concilia os títulos que compõem o agrupador.
			If !Empty(SE5->E5_LOTE) .And. AllTrim(SE5->E5_NATUREZ) == "NATMOVR"
				cKey := SE5->(E5_FILIAL + E5_LOTE)
				SE5->(DBSkip())
				While !SE5->(EOF()) .And. SE5->(E5_FILIAL + E5_LOTE) == cKey
					GrvConcPad(SE5->E5_RECONC,oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_CONC")])
					SE5->(DBSkip())
				End
			EndIf
			// Persiste alterações na tabela.
			Z0C->(DBGoTo(oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_REC_WT")]))
			RecLock("Z0C",.F.)
				Z0C->Z0C_CONC := oJExt["Data"][nLine][U_ADSAScan(oJExt["Header"],"Z0C_CONC")]
			Z0C->(MsUnlock())
		EndIf
	Next nLine

Return

/*/{Protheus.doc} GrvConcPad
Função para realizar a conciliação padrão.
@type   : Static Function
@author : Paulo Felipe
@since  : 02/12/2019
@version: 1.00
@param  : cOldConc, characters, conciliação anterior.
@param  : cNewConc, characters, conciliação atual.
/*/
Static Function GrvConcPad(cOldConc,cNewConc)

	Local cIdProc	:= ""
	Local cKeyFK5	:= ""
	Local nValTit	:= 0

	DBSelectArea("FKA")
	FKA->(DBSetOrder(3))

	// Posiciona a FKA com base no IDORIG da SE5 posicionada.
	If SE5->E5_TABORI == "FK1"
		FKA->(DBSeek(SE5->(E5_FILIAL + "FK1" + E5_IDORIG)))
	ElseIf SE5->E5_TABORI == "FK2"
		FKA->(DBSeek(SE5->(E5_FILIAL + "FK2" + E5_IDORIG)))
	Else
		FKA->(DBSeek(SE5->(E5_FILIAL + "FK5" + E5_IDORIG)))
	EndIf

	cIdProc := FKA->FKA_IDPROC

	FKA->(DBSetOrder(2))
	IF FKA->(DBSeek(FKA->FKA_FILIAL + cIdProc))
		cKeyFK5 := CriaVar("FKA_FILIAL",.F.) + CriaVar("FKA_IDORIG",.F.)
		While FKA->(!EOF()) .And. FKA->FKA_IDPROC == cIdProc
			If FKA->FKA_TABORI == "FK5"
				cKeyFK5 := FKA->(FKA_FILIAL + FKA_IDORIG)
			EndIf
			FKA->(DBSkip())
		End
	EndIf

	DBSelectArea("FK5")
	FK5->(DBSetOrder(1))
	If FK5->(DBSeek(cKeyFK5))
		Reclock("FK5",.F.)
			FK5->FK5_DTCONC := IIf(!Empty(cNewConc),dDataBase,CToD("//"))
		FK5->(MsUnlock())
	EndIf

	Reclock("SE5", .F.)
		SE5->E5_RECONC := cNewConc
	SE5->(MsUnlock())

	// Processo para atualização do saldo bancário.
	If Empty(cOldConc) .And. !Empty(cNewConc)
		If Alltrim(SE5->E5_TIPODOC) $ "TR|BD"
			nValTit := SE5->E5_VALOR
			aAreaSE5 := SE5->(GetArea())
			SE5->(DBSetOrder(2))
			If SE5->(DBSeek(SE5->(E5_FILIAL + "I2" + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + DTOS(E5_DATA) + E5_CLIFOR + E5_LOJA + E5_SEQ)))
				nValTit += SE5->E5_VALOR
			EndIf
			RestArea(aAreaSE5)

			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,nValTit,IIF(SE5->E5_RECPAG == "P","-","+"),.T.,.F.)
		Else
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,IIF(SE5->E5_RECPAG == "P","-","+"),.T.,.F.)
		EndIf
	ElseIf !Empty(cOldConc) .And. Empty(cNewConc)
		If Alltrim(SE5->E5_TIPODOC) $ "TR|BD"
			nValTit := SE5->E5_VALOR
			aAreaSE5 := SE5->(GetArea())
			SE5->(DBSetOrder(2))
			If SE5->(DBSeek(SE5->(E5_FILIAL + "I2" + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + DTOS(E5_DATA) + E5_CLIFOR + E5_LOJA + E5_SEQ)))
				nValTit += SE5->E5_VALOR
			EndIf
			RestArea(aAreaSE5)

			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,nValTit,IIF(SE5->E5_RECPAG == "P","+","-"),.T.,.F.)
		Else
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,IIF(SE5->E5_RECPAG == "P","+","-"),.T.,.F.)
		EndIf
	EndIf

Return

/*/{Protheus.doc} GrvConcPad
Função para realizar a gravaçao das taxas.
@type   : Static Function
@author : Walter Rodrigo
@since  : 08/12/2023
@version: 1.00
@param  : dDataInfo, cMoeda, nValor, cNatureza, cBanco, cAgencia, cConta, cHistorico
/*/
Static Function GeraTaxa(dDataInfo, cMoeda, nValor, cNatureza, cBanco, cAgencia, cConta, cDocumen, cHistorico)
	
	Local aFINA100 := {}
	Private lMsErroAuto := .F.
	
	aFINA100 := { {"E5_DATA"    , dDataInfo                 , Nil},;
				  {"E5_MOEDA"   , cMoeda                    , Nil},;
				  {"E5_VALOR"   , nValor                    , Nil},;
				  {"E5_NATUREZ" , cNatureza                 , Nil},;
				  {"E5_BANCO"   , cBanco                    , Nil},;
				  {"E5_AGENCIA" , cAgencia                  , Nil},;
				  {"E5_CONTA"   , cConta                    , Nil},;
				  {"E5_BENEF"   , "Tarifa automatica"       , Nil},;
				  {"E5_DOCUMEN" , cDocumen                  , Nil},;
				  {"E5_HISTOR"  , "Tarifa aut." + cHistorico, Nil}}

	MSExecAuto({|x,y,z| FinA100(x,y,z)}, 0, aFINA100, 3)

	If lMsErroAuto
		MostraErro()
	EndIf
Return
