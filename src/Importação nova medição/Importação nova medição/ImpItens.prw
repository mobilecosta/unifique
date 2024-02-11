#Include 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
 
/*/{Protheus.doc} ImpCNTA121
Importação de itens para o grid do contrato
@type   : User Function
@author : Rivaldo Junior | Cod.ERP
@since  : 18/01/2024
@return : return, return_type, return_description
/*/
User Function ImpItens()

	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}
	private cErro := ""

	DEFINE MSDIALOG oDlg TITLE " Importação de itens para o grid do contrato." From 0,0 To 15,50

	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo importar dados "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e vírgula')."},oDlg,,,,,,.T.,,,200,80)

	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')

	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImCsv(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes

/*======================================================================================================*
| PROGRAMA | ImCsv           ||                                                    |     FEITO POR     |
|----------------------------------------------------------------------------------|-------------------|
| função para Seleção do arquivo ao clicar importar                                |Rivaldo Jr - Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   18/01/2024  |
*======================================================================================================*/
Static Function ImCsv(cCaminho)

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

/*=====================================================================================================*
| PROGRAMA | ProcessCSV           ||                                               |     FEITO POR     |
|----------------------------------------------------------------------------------|-------------------|
| Função para ler os arquivos CSV                                                  |Rivaldo Jr - Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   18/01/2024  |
*======================================================================================================*/
Static Function ProcessCSV(cCaminho,oProcess)
	Local oFile        As Object
	Local cMsgHead     := "ImportCsv()"
	Local i
	Local aRes         As Array
	Local aLines       As Array
	Local aLinha       As Array
	Local lManterVazio := .T.
	Local lEnd         := .F.
    Local oModel       := FWLoadModel("CNTA300")
    Local oGrid    	   As Object 
	Private cError	   := ''
	Private lEncerra   := .F.

    oGrid := oModel:GetModel("CNBDETAIL")
	oModel:SetOperation(4)
	oModel:Activate()
	DbSelectArea('SB1')
	DbSelectArea('SF4')
	DbSelectArea('CT1')
	DbSelectArea('CTD')
	DbSelectArea('CTT')
	DbSelectArea('CTH')

	oFile := FWFileReader():New(cCaminho)
	If !oFile:Open()
		ApMsgStop("Não foi possível efetuar a leitura do arquivo." + cArq, cMsgHead)
		Return aRes
	EndIf
	aLines := oFile:GetAllLines()
	if lEnd //VERIFICAR SE Nï¿½O CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
		Return aRes
	EndIf
	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	For i:=3 to len(aLines)
		if lEnd    //VERIFICAR SE Nï¿½O CLICOU NO BOTAO CANCELAR
			ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
			Return {}
		EndIf
		oProcess:IncRegua2("Incluindo itens no grid " + CvalToChar(i) + " de " + cValToCHar(Len(aLines)-2) )
		cLinha  := aLines[i]
		If !Empty(cLinha)
			cLinha := StrTran(StrTran(cLinha, '"', ''), ",", ".")
			aLinha := Separa(cLinha, cDelimiter, lManterVazio)
			If Len(aLinha) > 0

				If SB1->(MsSeek(xFilial("SB1")+AllTrim(aLinha[1])))
					oGrid:GoLine(i-2)

					oGrid:SetValue("CNB_PRODUT", aLinha[1]) 				// PRODUTO

					If ValType(aLinha[2]) == 'C'
                        aLinha[2] := Val(aLinha[2])
					EndIf
					oGrid:SetValue("CNB_VLUNIT", aLinha[2]) 				// VALOR UNITARIO

					If !Empty(aLinha[3])
						oGrid:SetValue("CNB_DESC", aLinha[3]) 				// DESCONTO (%)
					EndIf

					If !Empty(aLinha[4])
						oGrid:SetValue("CNB_DTPREV", CtoD(aLinha[4])) 		// DATA ENTREGA
					EndIf

					If !Empty(aLinha[5])
						If CT1->(MsSeek(xFilial("CT1")+AllTrim(aLinha[5]))) // CONTA CONTABIL
							oGrid:SetValue("CNB_CONTA", aLinha[5]) 				
						EndIf
					EndIf

					If !Empty(aLinha[6])
						If CTD->(MsSeek(xFilial("CTD")+AllTrim(aLinha[6]))) // ITEM CONTABIL
							oGrid:SetValue("CNB_ITEMCT", aLinha[6])
						EndIf
					EndIf

					If !Empty(aLinha[7])
						If SF4->(MsSeek(xFilial("SF4")+AllTrim(aLinha[7]))) // TES
							oGrid:SetValue("CNB_TE"	   , aLinha[7])
						EndIf
					EndIf

					If !Empty(aLinha[8])
						If CTT->(MsSeek(xFilial("CTT")+AllTrim(aLinha[8]))) // CENTRO DE CUSTO
							oGrid:SetValue("CNB_CC"  , aLinha[8])
						EndIf
					EndIf

					If !Empty(aLinha[9])
						If CTH->(MsSeek(xFilial("CTH")+AllTrim(aLinha[9]))) // CLASSE DE VALOR
							oGrid:SetValue("CNB_CLVL"  , aLinha[9])
						EndIf
					EndIf

					If !Empty(aLinha[10])
						oGrid:SetValue("CNB_TABPRC"  , aLinha[10]) 			// TABELA DE PRECO
					EndIf

					If !Empty(aLinha[11])
						oGrid:SetValue("CNB_EC05DB"  , aLinha[11]) 			// ENTIDADE 5 DEBITO
					EndIf
					If !Empty(aLinha[12])
						oGrid:SetValue("CNB_EC05CR"  , aLinha[12]) 			// ENTIDADE 5 CRÉDITO
					EndIf
					If !Empty(aLinha[13])
						oGrid:SetValue("CNB_EC06DB"  , aLinha[13]) 			// ENTIDADE 6 DEBITO
					EndIf
					If !Empty(aLinha[14])
						oGrid:SetValue("CNB_EC06CR"  , aLinha[14]) 			// ENTIDADE 6 CRÉDITO
					EndIf

					//oGrid:SetValue("CNB_ITEMCT", aLinha[6])
					If i < len(aLines)
						oGrid:AddLine()
					EndIf
				Else 
					cError += "O produto "+AllTrim(aLinha[1])+" na linha "+cValToCHar(i)+" não foi encontrado no protheus."+CRLF
				EndIf
			EndIf
		EndIf
	Next i
	lRet := oModel:VldData()
	If lRet
		lRet := oModel:CommitData()
	EndIf

	If !lRet
		aErro := oModel:GetErrorMessage()
		cError := "Erro: " +  AllToChar( aErro[4]  ) + "-" + AllToChar( aErro[9]  ) + "- Erro:" + AllToChar( aErro[5] + "-"+aErro[6])
	EndIf


    oGrid:GoLine(1)

	oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")
	
	If empty(cError)
		FWAlertSuccess("Processo finalizado","Importação CSV concluida")
	Else
		FWAlertWarning("Processo finalizado com observações, alguns produtos não foram localizados no grid da medição.","Importação CSV concluida")
		zMsgLog(cError,"Observações na importação",1, .F.)
	EndIf

Return aRes


Static Function zMsgLog(cMsg, cTitulo, nTipo, lEdit)
	Local lRetMens := .F.
	Local oDlgMens
	Local oBtnOk, cTxtConf := ""
	Local oBtnCnc, cTxtCancel := ""
	Local oBtnSlv
	Local oFntTxt := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)  
	Local oMsg
	//Local nIni:=1
	//Local nFim:=50
	Default cMsg    := "..."
	Default cTitulo := "zMsgLog"
	Default nTipo   := 1 // 1=Ok; 2= Confirmar e Cancelar
	Default lEdit   := .F.

	//Definindo os textos dos botões
	If(nTipo == 1)
		cTxtConf:='&Ok'
	Else
		cTxtConf:='&Confirmar'
		cTxtCancel:='C&ancelar'
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

		//Senão, cria os botões OK e Cancelar
	ElseIf(nTipo==2)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
		@ 137, 144 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
	EndIf

	//Botão de Salvar em Txt
	@ 127, 004 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 051, 019 ACTION (fSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
	ACTIVATE MSDIALOG oDlgMens CENTERED

Return lRetMens


Static Function fSalvArq(cMsg, cTitulo)
	Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
	Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
	Local lOk      := .T.
	Local cTexto   := ""

	//Pegando o caminho do arquivo
	cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
	//Se o nome não estiver em branco
	If !Empty(cFileNom)
		//Teste de existência do diretório
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		End
		//Montando a mensagem
		cTexto := "Função   - "+ FunName()       + CRLF
		cTexto += "Usuário  - "+ cUserName       + CRLF
		cTexto += "Data     - "+ dToC(dDataBase) + CRLF
		cTexto += "Hora     - "+ Time()          + CRLF
		cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg
		//Testando se o arquivo já existe
		If File(cFileNom)
			lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
		End
		If lOk
			MemoWrite(cFileNom, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
		EndIf
	EndIf
Return
