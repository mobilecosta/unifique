#INCLUDE "Protheus.Ch"
#INCLUDE 'TOTVS.CH'


/*/{Protheus.doc} ImpGPApv
description
Importação de Grupo de Aprovação
@type function
@version
@author Helton.Silva
@since 08/12/2023
@return variant, return_description
/*/
User Function ImpGPApv()

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
	Private cError		:= ''
	Private lMsErroAuto := .F.
	Private oTable		As Object

	oFile := FWFileReader():New(cCaminho)
	If !oFile:Open()
		ApMsgStop("Não foi possvel efetuar a leitura do arquivo." + cArq, cMsgHead)
		Return aRes
	EndIf
	aLines := oFile:GetAllLines()

	if lEnd //VERIFICAR SE NO CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
		Return aRes
	EndIf

	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	For nX:=2 to len(aLines)
		if lEnd //VERIFICAR SE NO CLICOU NO BOTAO CANCELAR
			ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
			Return {}
		EndIf
		oProcess:IncRegua2("Atualizando registro " + CvalToChar(nX) + " de " + cValToCHar(Len(aLines)) )
		cLinha  := aLines[nX]
		If !Empty(cLinha) .And. !Empty(StrTran(cLinha,';',''))
			cLinha := StrTran(StrTran(cLinha, '"', ''), ",", ".")
			aLinha := Separa(cLinha, cDelimiter, lManterVazio)
			If Len(aLinha) > 0
                Update(aLinha[1],aLinha[2],aLinha[3],aLinha[4],aLinha[5],aLinha[6],aLinha[7],aLinha[8],aLinha[9],aLinha[10],aLinha[11],aLinha[12],aLinha[13],aLinha[14],aLinha[15],aLinha[16],nX)
			EndIf
		EndIf
	Next

    oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")

	If empty(cError)
		FWAlertSuccess("Processo finalizado","Importação CSV concluida")
	Else
		FWAlertError("Processo finalizado","Falha na importação")
		//AutoGRLog(cError)
		zMsgLog(cError,"Falha na importação",1, .F.)
	EndIf

	//MsgInfo("Processo finalizado.")

Return aRes



Static Function Update( cFil, cCod, cDescri, cItem, cAprov,cPerfil,cUser,cNivel,cAproSup,cUserSup,cTpAprov,cLimite,cLib,cItemPed,cDocTitn,cDocPrj,nLinha)
    Local oModel    := Nil
    Local aMsgDeErro:= {}

    DbSelectArea('SAL')
    SAL->(DbSetOrder(1))
    If !SAL->(DbSeek(xfilial('SAL')+cCod))//Posicionar na SAL para realizar a inclusão

        oModel := FWLoadModel("MATA114")
        oModel:SetOperation(3)
		
        If(oModel:CanActivate())           
            oModel:Activate()
            oModel:SetValue("ModelSAL","AL_COD"    , cCod	)
            oModel:SetValue("ModelSAL","AL_DESC"   , cDescri	)
            oModel:SetValue("ModelSAL","AL_DOCIP"  , IIF(cItemPed=='.T.',.T.,.F.))

            oModel:SetValue("DetailSAL","AL_ITEM" 	 , cItem)
            oModel:SetValue("DetailSAL","AL_APROV"  , cAprov)
            oModel:SetValue("DetailSAL","AL_PERFIL" , cPerfil)
            //oModel:SetValue("DetailSAL","AL_DESC" , cDescri)
            //oModel:SetValue("DetailSAL","AL_NOME" , 	Nome)

            oModel:SetValue("DetailSAL","AL_USER"  , cUser)
            oModel:SetValue("DetailSAL","AL_NIVEL"  , cNivel)
            oModel:SetValue("DetailSAL","AL_APROSUP", cAproSup)
            oModel:SetValue("DetailSAL","AL_USERSUP", cUserSup)
            oModel:SetValue("DetailSAL","AL_LIBAPR" , cTpAprov)
            oModel:SetValue("DetailSAL","AL_AUTOLIM", cLimite)
            oModel:SetValue("DetailSAL","AL_TPLIBER", cLib)
           	oModel:SetValue("DetailSAL","AL_XDOCTIT", cDocTitn)  
        	oModel:SetValue("DetailSAL","AL_XDOCPRJ", cDocPrj)


            If (oModel:VldData()) /*Valida o modelo como um todo*/
                oModel:CommitData()
            EndIf
        EndIf
		 
        If(oModel:HasErrorMessage())
            aMsgDeErro := oModel:GetErrorMessage()
			cError += "Nao foi possivel cadastrar o Grupo de Aprovação "+cCod+" - Linha "+cValToCHar(nLinha)+CRLF
        EndIf
		
		oModel:DeActivate()                         
    Else
		cError += "Grupo de Aprovação ja cadastrado "+cCod+" - Linha "+cValToCHar(nLinha)+CRLF
    EndIf  

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
