#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} ImpCSV
Função de Importação CSV para inclusão de Medições
@type function
@author Cod.ERP Tecnologia
/*/

User Function ImpCSV()
	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}
	Private cErro 	:= ""
	DEFINE MSDIALOG oDlg TITLE "Importação CSV " From 0,0 To 15,50
	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo importar as informações de uma planilha"+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e virgula')."},oDlg,,,,,,.T.,,,200,80)
	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')
	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImpD21(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)
	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes

/*/{Protheus.doc} ImpD21
Função que busca o arquivo CSV.
@type function
@author Cod.ERP Tecnologia
/*/
Static Function ImpD21(cCaminho)
	Local oProcess  := nil
	Local aRes      := nil
	Default cIdPlan := "1"
	Default cArq    := ""
	Default cDelimiter := ";"

	If Empty(cCaminho)
		MsgInfo("Selecione um arquivo",)
		Return
	ElseIf !File(cCaminho)
		MsgInfo("Arquivo não localizado","Atenção")
		Return
	Else
		oDlg:End()
		oProcess := MsNewProcess():New({|lEnd| aRes:= ProcessCSV(cCaminho,@oProcess)  },"Extraindo dados da planilha CSV","Efetuando a leitura do arquivo CSV...", .T.)
		oProcess:Activate()
	EndIf

Return aRes

/*/{Protheus.doc} ProcessCSV
Função que realiza a leitura do arquivo CSV.
@type function
@author Cod.ERP Tecnologia
/*/
Static Function ProcessCSV(cCaminho,oProcess)

	Local i
	Local aRes      := {}
	Local aLines    := {}
	Local cMsgHead  := "ImportCsv()"
	Local oFile     := NIL
	Local aLinha    := {}
	Local lManterVazio := .T.
	Local lEnd         := .F.
	Private cMsg:= ""

	oFile := FWFileReader():New(cCaminho)
	If oFile:Open() = .F.
		ApMsgStop("não foi possivel efetuar a leitura do arquivo." + cArq, cMsgHead)
		Return aRes
	EndIf
	aLines := oFile:GetAllLines()
	If lEnd = .T.   //VERIFICAR SE Nï¿½O CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usuario." + cArq, cMsgHead)
		Return aRes
	EndIf
	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	For i:=2 to len(aLines)
		If lEnd = .T.    //VERIFICAR SE NÃO CLICOU NO BOTAO CANCELAR
			ApMsgStop("Processo cancelado pelo usuario." + cArq, cMsgHead)
			Return {}
		EndIf
		oProcess:IncRegua2("Atualizando registro " + CvalToChar(i) + " de " + cValToCHar(Len(aLines)) )
		cLinha  := aLines[i]
		If Empty(cLinha) = .F.
			cLinha := StrTran(StrTran(cLinha, '"', ''), ",", ".")
			aLinha := Separa(cLinha, cDelimiter, lManterVazio)
			If Len(aLinha) > 0
				Update(aLinha[1],aLinha[2],i)//alterar aqui
			EndIf
		EndIf
	Next i
	oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")
	If !Empty(cErro)
		MSGINFO(cErro,"Falha na importação")
	Else
		MsgInfo("Operação concluida com sucesso!")
	EndIf
	if !Empty(cMsg)
		zMsgLog(cMsg, "Log de Produtos não encontrados",1,)
	endif
Return aRes

/*/{Protheus.doc} Update
@type function
@author Cod.ERP Tecnologia
/*/
Static Function Update(cCodProd,cRemMapa,nX)
	Local oModel	:= Nil
	Local cCodCTR	:= "CNTA121EXEMP002"
	Local cNumMed	:= ""
	Local lRet		:= .F.	
	
	CN9->(DbSetOrder(1))
		
	If CN9->(DbSeek(xFilial("CN9") + cCodCTR))//Posicionar na CN9 para realizar a inclusÃ£o
		oModel := FWLoadModel("CNTA121")
		
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If(oModel:CanActivate())			
			oModel:Activate()
			oModel:SetValue("CNDMASTER","CND_CONTRA"	,CN9->CN9_NUMERO)
			oModel:SetValue("CNDMASTER","CND_RCCOMP"	,"1")//Selecionar competÃªncia
			
			oModel:SetValue("CXNDETAIL","CXN_CHECK"	, .T.)//primeiro grid

			oModel:GetModel('CNEDETAIL'):GoLine(1)//segundo grid
			oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT' 	, 1)			
			
			If (oModel:VldData()) /*Valida o modelo como um todo*/
				oModel:CommitData()
			EndIf
		EndIf
		
		If!(oModel:HasErrorMessage())
			cNumMed := CND->CND_NUMMED			
			oModel:DeActivate()			
			lRet := CN121Encerr(.T.) //Realiza o encerramento da medicao					
		EndIf
	EndIf	
Return

/*/{Protheus.doc} zMsgLog
Função para construção do log.
@type function
@author Cod.ERP Tecnologia
/*/
Static Function zMsgLog(cMsg, cTitulo, nTipo, lEdit)
	Local lRetMens := .F.
	Local oDlgMens
	Local oBtnOk, cTxtConf := ""
	Local oBtnCnc, cTxtCancel := ""
	Local oBtnSlv
	Local oFntTxt := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
	Local oMsg
	Default cMsg    := "..."
	Default cTitulo := "zMsgLog"
	Default nTipo   := 1 // 1=Ok; 2= Confirmar e Cancelar
	Default lEdit   := .F.

	//Definindo os textos dos botões
	If(nTipo == 1)
		cTxtConf:='ok'
	Else
		cTxtConf:='Confirmar'
		cTxtCancel:='Cancelar'
	EndIf

	//Criando a janela centralizada com os botões
	DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL
	//Get com o Log
	@ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
	If !lEdit
		oMsg:lReadOnly := .T.
	EndIf

	//Se for Tipo 1, cria somente o botão OK
	If (nTipo==1)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL

		//Senao, cria os botões OK e Cancelar
	ElseIf(nTipo==2)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
		@ 137, 144 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
	EndIf

	//botão de Salvar em Txt
	@ 127, 004 BUTTON oBtnSlv PROMPT "Salvar em .txt" SIZE 051, 019 ACTION (fSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
	ACTIVATE MSDIALOG oDlgMens CENTERED

Return lRetMens

/*/{Protheus.doc} fSalvArq
Função para salvar o txt do log
@type function
@author Cod.ERP Tecnologia
/*/
Static Function fSalvArq(cMsg, cTitulo)
	Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
	Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
	Local lOk      := .T.
	Local cTexto   := ""
	//Pegando o caminho do arquivo
	cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
	//Se o nome nÃ£o estiver em branco
	If !Empty(cFileNom)
		//Teste de existÃªncia do diretÃ³rio
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("Diretorio nao existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		End
		//Montando a mensagem
		cTexto := "Funcao   - "+ FunName()       + CRLF
		cTexto += "Usuario  - "+ cUserName       + CRLF
		cTexto += "Data     - "+ dToC(dDataBase) + CRLF
		cTexto += "Hora     - "+ Time()          + CRLF
		cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg
		//Testando se o arquivo jÃ¡ existe
		If File(cFileNom)
			lOk := MsgYesNo("Arquivo ja existe, deseja substituir?", "Atencao")
		End
		If lOk
			MemoWrite(cFileNom, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atencao")
		EndIf
	EndIf
Return
