#INCLUDE "Protheus.Ch"
#INCLUDE 'TOTVS.CH'


/*/{Protheus.doc} ImpEntCb
description
Importação de Entidades Contábeis
@type function
@version
@author Helton.Silva
@since 08/12/2023
@return variant, return_description
/*/
User Function ImpEntCb()

	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}

	DEFINE MSDIALOG oDlg TITLE "Importação CSV" From 0,0 To 15,50

	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo importar registros "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e Vírgula')."},oDlg,,,,,,.T.,,,200,80)

	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')

	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, , .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImpTvInc(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes

Static Function ImpTvInc(cCaminho)

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


Static Function ProcessCSV(cCaminho,oProcess)
	Local nX
	Local cMsgHead  	:= "ICsvNat()"
	Local aRes     		:= {}
	Local aLines  		:= {}
	Local aLinha    	:= {}
	Local oFile     	As Object
	Local lManterVazio 	:= .T.
	Local lEnd         	:= .F.
	Local aCampos :={}
	Private cError		:= ''
	Private lMsErroAuto := .F.
	Private oTable		As Object

	oFile := FWFileReader():New(cCaminho)
	If !oFile:Open()
		ApMsgStop("Não foi possivel efetuar a leitura do arquivo." + cArq, cMsgHead)
		Return aRes
	EndIf
	aLines := oFile:GetAllLines()

	if lEnd //VERIFICAR SE NAO CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
		Return aRes
	EndIf

	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	oTable  := FWTemporaryTable():New("TMP")
	aAdd(aCampos,{"DBL_FILIAL", "C" , TamSx3('DBL_FILIAL')[1] , })//1
	aAdd(aCampos,{"DBL_GRUPO" , "C" , TamSx3('DBL_GRUPO')[1]  , })//2
	aAdd(aCampos,{"DBL_CC"    , "C" , TamSx3('DBL_CC'   )[1]  , })//3
	aAdd(aCampos,{"DBL_CONTA" , "C" , TamSx3('DBL_CONTA')[1]  , })//4
	aAdd(aCampos,{"DBL_ITEMCT", "C" , TamSx3('DBL_ITEMCT')[1] , })//5
	aAdd(aCampos,{"DBL_CLVL"  , "C" , TamSx3('DBL_CLVL')[1]   , })//6

	oTable:SetFields(aCampos)// Adiciono os campos na tabela
	oTable:Create()// Crio a tabela no banco de dados
	DbSelectArea("TMP")


	For nX:=2 to len(aLines)
		if lEnd //VERIFICAR SE NAO CLICOU NO BOTAO CANCELAR
			ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
			Return {}
		EndIf
		oProcess:IncRegua2("Atualizando registro " + CvalToChar(nX) + " de " + cValToCHar(Len(aLines)) )
		cLinha  := aLines[nX]
		If !Empty(cLinha) //.And. !Empty(StrTran(cLinha,';',''))
			cLinha := StrTran(StrTran(cLinha, '"', ''), ",", ".")
			aLinha := Separa(cLinha, cDelimiter, lManterVazio)
			If Len(aLinha) > 0
               TMP->(RecLock('TMP', .T.))
					TMP->DBL_FILIAL := aLinha[1]
					TMP->DBL_GRUPO  := aLinha[2]
					TMP->DBL_CC     := aLinha[3]
					TMP->DBL_CONTA  := aLinha[4]
					TMP->DBL_ITEMCT := aLinha[5]
					TMP->DBL_CLVL   := aLinha[6]
				TMP->(MsUnLock())
				TMP->(DbSkip())			
			EndIf
		EndIf
	Next

    If Select("TMP") > 0
	 	cError := update()
		TMP->(DbCLoseArea())
	else
		oFile:Close()
	ENDIF

	oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")
	
	If empty(cError)
		FWAlertSuccess("Processo finalizado","Importação CSV concluida")
	Else
		FWAlertError("Processo finalizado","Falha na importação")
		zMsgLog(cError,"Falha na importação",1, .F.)
	EndIf

Return aRes


Static Function Update( )
    Local oModel    := Nil
    Local aMsgDeErro:= {}
	Local cGrupo    := ''
	Local nLine     := 1
	Local cError    := ""

    DbSelectArea('SAL')
    SAL->(DbSetOrder(1))
	
	TMP->(DbGoTop())

	While TMP->(!Eof())

		cGrupo := TMP->DBL_GRUPO
		
		If SAL->(DbSeek(xfilial('SAL')+cGrupo))//Posicionar na DHL para realizar a inclusão
			
			oModel := FWLoadModel("MATA114")
			oModel:SetOperation(4)
			
			If(oModel:CanActivate())           
				oModel:Activate()

				oModel:SetValue("ModelSAL" ,"AL_COD"     , SAL->AL_COD ) // Grupo
				oModel:SetValue("ModelSAL" ,"AL_DESC"    , SAL->AL_DESC  ) // Descrição

				nLine := 1

				While SAL->(!Eof()) .And. SAL->AL_COD == cGrupo

					oModel:GetModel('DetailSAL'):GoLine(nLine)
					oModel:SetValue("DetailSAL","AL_APROV"   , SAL->AL_APROV    )
					oModel:SetValue("DetailSAL","AL_PERFIL"  , SAL->AL_PERFIL	)
					oModel:SetValue("DetailSAL","AL_ITEM"    , SAL->AL_ITEM     ) // Item
					oModel:SetValue("DetailSAL","AL_NIVEL"   , SAL->AL_NIVEL   ) // Nivel

					SAL->(DbSkip())

					If SAL->(!Eof()) .And. SAL->AL_COD == cGrupo
						nLine++
						oModel:GetModel('DetailSAL'):AddLine()
					EndIf
				End

				nLine := 1
				cItem := "01"
				While TMP->(!Eof()) .And. TMP->DBL_GRUPO == cGrupo
					oModel:GetModel('DetailDBL'):GoLine(nLine)
					oModel:SetValue("DetailDBL","DBL_FILIAL" , TMP->DBL_FILIAL	)
					oModel:SetValue("DetailDBL","DBL_GRUPO"  , TMP->DBL_GRUPO	)
					oModel:SetValue("DetailDBL","DBL_ITEM"   , cItem        	)
					oModel:SetValue("DetailDBL","DBL_CC"     , TMP->DBL_CC	    )
					oModel:SetValue("DetailDBL","DBL_CONTA"  , TMP->DBL_CONTA	)
					oModel:SetValue("DetailDBL","DBL_ITEMCT" , TMP->DBL_ITEMCT	)
					oModel:SetValue("DetailDBL","DBL_CLVL"   , TMP->DBL_CLVL	)

					TMP->(DbSkip())
					cItem := SOMA1(cItem)

					If TMP->(!Eof()) .And. TMP->DBL_GRUPO == cGrupo
						nLine++
						oModel:GetModel('DetailDBL'):AddLine()
					EndIf
				End

				If (oModel:VldData()) /*Valida o modelo como um todo*/
					oModel:CommitData()
				EndIf
			EndIf
			
			If(oModel:HasErrorMessage())
				aMsgDeErro := oModel:GetErrorMessage()

				cError += cValToChar(aMsgDeErro[4]) + ' - '
				cError += cValToChar(aMsgDeErro[5]) + ' - '
				cError += cValToChar(aMsgDeErro[6])

			EndIf
			
			oModel:DeActivate()          
		Else
			cError += "O Grupo de Aprovação Não foi Encontrado "+cGrupo+" - Linha "+CRLF
		EndIf  
	End

Return cError

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
