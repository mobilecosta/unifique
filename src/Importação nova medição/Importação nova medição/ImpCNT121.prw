#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


User Function CNT121BT()
 
    //Adicionando no array aRotina o botão   
    If Type('aRotina') == 'A'
        aAdd(aRotina,{"Imp. da Medição via CSV","U_ImpCNT121()",0,1,0,NIL,NIL,NIL})
    Endif

Return

User Function ImpCNT121()

	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}
	private cErro := ""

	DEFINE MSDIALOG oDlg TITLE " Importação de medição de contratos." From 0,0 To 15,50

	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo importar registros "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e vírgula')."},oDlg,,,,,,.T.,,,200,80)

	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')

	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImCsv(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes

/*
*======================================================================================================*
| PROGRAMA | ImCsvDt           ||                                                  |     FEITO POR     |
|----------------------------------------------------------------------------------|-------------------|
| função para Seleção do arquivo ao clicar importar                                |Michel Rocha-Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   17/10/2022  |
*======================================================================================================*
*/

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

/*
*======================================================================================================*
| PROGRAMA | ProcessCSV           ||                                               |     FEITO POR     |
|----------------------------------------------------------------------------------|-------------------|
| Função para ler os arquivos CSV                                                  |Michel Rocha-Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   17/10/2022  |
*======================================================================================================*
*/

Static Function ProcessCSV(cCaminho,oProcess)
    Local oTable       := Nil
	Local oFile        := NIL
	Local cMsgHead     := "ImportCsv()"
	Local i
	Local aRes         := {}
	Local aLines       := {}
	Local aCampos      := {}
	Local aLinha       := {}
	Local nQuant	   := 0
	Local nValUnit	   := 0
	Local nValPerc	   := 0
	Local lManterVazio := .T.
	Local lEnd         := .F.
	Private cError	   := ''
	Private lEncerra   := .F.

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

    oTable  := FWTemporaryTable():New("TMP")
	aAdd(aCampos,{"CND_CONTRA", "C" , TamSx3('CND_CONTRA')[1], })//1
	aAdd(aCampos,{"CNE_CC"    , "C" , TamSx3('CNE_CC')[1]    , })//2
	aAdd(aCampos,{"CNE_CLVL"  , "C" , TamSx3('CNE_CLVL')[1]  , })//3
	aAdd(aCampos,{"CNE_DTENT" , "C" , TamSx3('CNE_DTENT')[1] , })//4
	aAdd(aCampos,{"CNE_CONTA" , "C" , TamSx3('CNE_CONTA')[1] , })//5
	aAdd(aCampos,{"CNE_ITEMCT", "C" , TamSx3('CNE_ITEMCT')[1], })//6
	aAdd(aCampos,{"CNE_PEDTIT", "C" , TamSx3('CNE_PEDTIT')[1], })//7
	aAdd(aCampos,{"CNE_PRODUT", "C" , TamSx3('CNE_PRODUT')[1], })//8
	aAdd(aCampos,{"CNE_QUANT" , "N" , TamSx3('CNE_QUANT')[1] , })//9
	aAdd(aCampos,{"CNE_VLUNIT", "N" , TamSx3('CNE_VLUNIT')[1], })//10
	aAdd(aCampos,{"CNE_TE"    , "C" , TamSx3('CNE_TE')[1]    , })//11
 	//aAdd(aCampos,{"CNZ_ITEM"  , "C" , TamSx3('CNZ_ITEM')[1]  , })//11
	aAdd(aCampos,{"CNZ_PERC"  , "N" , TamSx3('CNZ_PERC')[1]  , })//12
	aAdd(aCampos,{"CNZ_CC"    , "C" , TamSx3('CNZ_CC')[1]    , })//13
	aAdd(aCampos,{"CNZ_CONTA" , "C" , TamSx3('CNZ_CONTA')[1] , })//14
	aAdd(aCampos,{"CNZ_ITEMCT", "C" , TamSx3('CNZ_ITEMCT')[1], })//15 
	aAdd(aCampos,{"CNZ_CLVL"  , "C" , TamSx3('CNZ_CLVL')[1]  , })//16
	oTable:SetFields(aCampos)// Adiciono os campos na tabela
	oTable:Create()// Crio a tabela no banco de dados
	DbSelectArea("TMP")

	lEncerra := FWAlertYesNo("Deseja executar o encerramento das medições?", "Atenção!")

	For i:=2 to len(aLines)
		if lEnd    //VERIFICAR SE Nï¿½O CLICOU NO BOTAO CANCELAR
			ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
			Return {}
		EndIf
		oProcess:IncRegua2("Atualizando registro " + CvalToChar(i) + " de " + cValToCHar(Len(aLines)) )
		cLinha  := aLines[i]
		If !Empty(cLinha)
			cLinha := StrTran(StrTran(cLinha, '"', ''), ",", ".")
			aLinha := Separa(cLinha, cDelimiter, lManterVazio)
			If Len(aLinha) > 0

				If ValType(aLinha[3]) == 'C'
					nQuant := Val(aLinha[3])
				EndIf

				If ValType(aLinha[4]) == 'C'
					nValUnit := Val(aLinha[4])
				EndIf

				If ValType(aLinha[12]) == 'C'
					nValPerc := Val(aLinha[12])
				EndIf

                TMP->(RecLock('TMP', .T.))
					TMP->CND_CONTRA := aLinha[1]
					TMP->CNE_PRODUT := aLinha[2]
					TMP->CNE_QUANT  := nQuant 
					TMP->CNE_VLUNIT := nValUnit
					TMP->CNE_DTENT  := DtoS(CtoD(aLinha[5]))
					TMP->CNE_CC     := aLinha[6]
					TMP->CNE_CLVL   := aLinha[7]
					TMP->CNE_CONTA  := aLinha[8]
					TMP->CNE_ITEMCT := aLinha[9]
					TMP->CNE_PEDTIT := aLinha[10]
					TMP->CNE_TE     := aLinha[11] 
	                //TMP->CNZ_ITEM   := aLinha[12]
                    TMP->CNZ_PERC   := nValPerc
                    TMP->CNZ_CC     := aLinha[13]
                    TMP->CNZ_CONTA  := aLinha[14]
                    TMP->CNZ_ITEMCT := aLinha[15]
                    TMP->CNZ_CLVL   := aLinha[16]
				TMP->(MsUnLock())
				TMP->(DbSkip())
			EndIf
		EndIf
	Next i

    If Select("TMP") > 0
	 	update()
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

Static Function Update()
    Local oModel    := Nil
    Local aMsgDeErro:= {}
    Local lRet      := .F.
    Local nLine     := 0
    Local nX

    DbSelectArea('CN9')
    CN9->(DbSetOrder(1))

    DbSelectArea('CND')
    CND->(DbSetOrder(8))

	TMP->(DbGoTop())

    While !TMP->(Eof())

    	If CN9->(DbSeek(xFilial("CN9") + TMP->CND_CONTRA))//Posicionar na CN9 para realizar a inclusão

    		//If !CND->(DbSeek(CN9->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA)))//Posicionar na CN9 para realizar a inclusão

				oModel := FWLoadModel("CNTA121")
				oModel:SetOperation(MODEL_OPERATION_INSERT)

				If(oModel:CanActivate())           
					oModel:Activate()
					oModel:SetValue("CNDMASTER","CND_CONTRA",CN9->CN9_NUMERO)// Cabeçalho da medição
								
					For nX := 1 To oModel:GetModel("CXNDETAIL"):Length() //Marca todas as planilhas
						oModel:GetModel("CXNDETAIL"):GoLine(nX)
						oModel:SetValue("CXNDETAIL","CXN_CHECK" , .T.)
					Next nX

					cContrato := TMP->CND_CONTRA

					While !TMP->(Eof()) .And. cContrato == TMP->CND_CONTRA
						nLine++
						oModel:GetModel('CNEDETAIL'):GoLine(nLine)
						oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODUT', TMP->CNE_PRODUT )
						oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT' , TMP->CNE_QUANT  )
						oModel:SetValue( 'CNEDETAIL' , 'CNE_VLUNIT', TMP->CNE_VLUNIT )
						oModel:SetValue( 'CNEDETAIL' , 'CNE_DTENT' , TMP->CNE_DTENT  )
						oModel:SetValue( 'CNEDETAIL' , 'CNE_CC'    , TMP->CNE_CC     )
						oModel:SetValue( 'CNEDETAIL' , 'CNE_CLVL'  , TMP->CNE_CLVL   )
						oModel:SetValue( 'CNEDETAIL' , 'CNE_CONTA' , TMP->CNE_CONTA  )
						oModel:SetValue( 'CNEDETAIL' , 'CNE_ITEMCT', TMP->CNE_ITEMCT )
						oModel:SetValue( 'CNEDETAIL' , 'CNE_PEDTIT', TMP->CNE_PEDTIT )
						oModel:SetValue( 'CNEDETAIL' , 'CNE_TE'    , TMP->CNE_TE     )   
						/*Os rateios abaixo serao incluidos pra corrente do modelo da CNE*/
						oModel:GetModel('CNZDETAIL'):GoLine(nLine)
                		//oModel:SetValue( "CNZDETAIL" , "CNZ_ITEM"  , TMP->CNZ_ITEM	 )
                		oModel:SetValue( "CNZDETAIL" , "CNZ_CC"    , TMP->CNZ_CC	 )
                		oModel:SetValue( "CNZDETAIL" , "CNZ_CONTA" , TMP->CNZ_CONTA	 )
                		oModel:SetValue( "CNZDETAIL" , "CNZ_CLVL"  , TMP->CNZ_CLVL	 )
                		oModel:SetValue( "CNZDETAIL" , "CNZ_ITEMCT", TMP->CNZ_ITEMCT )
                		oModel:SetValue( "CNZDETAIL" , "CNZ_PERC"  , TMP->CNZ_PERC	 ) 
						TMP->(DbSkip())
						If !TMP->(Eof()) .And. cContrato == TMP->CND_CONTRA
							oModel:GetModel('CNZDETAIL'):AddLine()
							If !Empty(TMP->CNZ_CC) .Or. !Empty(TMP->CNZ_CONTA) .Or. !Empty(TMP->CNZ_CLVL) .Or. !Empty(TMP->CNZ_ITEMCT) .Or. !Empty(TMP->CNZ_PERC)
								oModel:GetModel('CNZDETAIL'):AddLine()
							EndIf
						EndIf
					End
					nLine := 0
						
					If (oModel:VldData()) /*Valida o modelo como um todo*/
						oModel:CommitData()
					EndIf
				EndIf
				If(oModel:HasErrorMessage())
					aMsgDeErro := oModel:GetErrorMessage()
				EndIf	

			//EndIf	

			If lEncerra
				cNumMed := CND->CND_NUMMED          
				lRet := CN121Encerr(.T.) //Realiza o encerramento da medição  
			EndIf

			If ValType(oModel) == 'O'            
				oModel:DeActivate()        
			EndIf

		Else 
			cError += "O contrato "+TMP->CND_CONTRA+" não foi localizado."+CRLF
        EndIf  
    End
	TMP->(DbCloseArea())

Return


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
