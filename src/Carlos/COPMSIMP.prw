#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'
#INCLUDE "XMLXFUN.CH"
#Include "fileio.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE ENTER Chr(13) + Chr(10)
#DEFINE X3Tit       1
#DEFINE X3Campo     2
#DEFINE X3Picture   3
#DEFINE X3Tam	    4
#DEFINE X3Dec	    5
#DEFINE X3Valid     6
#DEFINE X3Usado     7
#DEFINE X3Tipo      8
#DEFINE X3F3        9
#DEFINE X3Context   10
#DEFINE X3CBox      11
#DEFINE X3Relacao   12
#DEFINE X3WHEN 		13
#DEFINE X3Visual	14
#DEFINE X3VldUser	15
#DEFINE X3PicVar	16
#DEFINE X3Obrig	    17
#DEFINE X3NIVEL	    18
#DEFINE X3FOLDER    19
#DEFINE X3Ordem     20
#DEFINE X3Descric   21

User Function COPMSIMP()

	Private oModal
	Private aRet	:= {}
	Private oProcess

	// verifica se o projeto nao esta reservado
	If AF8->AF8_PRJREV=="1" .And. AF8->AF8_STATUS<>"2" .And. GetNewPar("MV_PMSRBLQ","N")=="S"
		Aviso("Gerenciamento de Revisoes","Este projeto nao se encontra em revisao. Para realizar uma alteracao no projeto, deve-se primeiro Iniciar uma revisao no projeto atraves do Gerenciamento de Revisoes.",{"Fechar"},2)
		Return
	EndIf

	oModal  := FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:setTitle("Estrutura do Projeto - "+Alltrim(AF8->AF8_PROJET))

	//Seta a largura e altura da janela em pixel
	oModal:setSize(140, 200)

	oModal:createDialog()
	oModal:addButton("Fechar",{||oModal:OOWNER:END() }) //"Cancelar"

	// Define a mensagem que será exibida na caixa de diálogo da rotina
	cMsg := "Essa rotina tem por objetivo: " + CRLF
	cMsg := cMsg + "Efetuar a importação dos dados existentes na planilha."
	
	TSay():New(1, 1, {|| cMsg}, oModal:getPanelMain(),,,,,, .T.,,, 200, 40,,,,,, .T.)

	oModal:addButton("Importar Planilha", {|| oProcess := MsNewProcess():New( {|| fImport() }, 'Importação' , 'Aguarde...' , .F. ), oProcess:Activate() },;
		"Importar", , .T., .F., .T., )

	oModal:Activate()

Return

static function fImport()

	Local nI, nZ
	Local lRet := .T.
	Local aMark  := {;
		{"ORIGEM"	, "C", 50, 0},;
		{"PROJET"	, "C", 30, 0},;
		{"REVISA"	, "C", 10, 0},;
		{"OBS"	, "M", 10, 0};
		}

	Private cTitulo1	:= "Selecione o arquivo"
	Private cExtens		:= "Arquivo XML | *.xml"
	Private aRet       := {}
	Private cWorkSheet := ""
	Private cCPOAut	   := "AF9_FILIAL#AF9_PROJET#AF9_REVISA#AF9_CALEND#AF9_NIVEL"
	Private cTabela	   := ""
	Private aEdt	   := {}
	Private aTarefa	   := {}
	Private aProduto   := {}
	Private aRecurso   := {}
	Private aDespesa   := {}

	cCPOAut	   := cCPOAut + "#AFA_FILIAL#AFA_PROJET#AFA_REVISA#AFA_MOEDA"
	cCPOAut	   := cCPOAut + "#AFB_FILIAL#AFB_PROJET#AFB_REVISA#AFB_MOEDA"
	cCPOAut	   := cCPOAut + "#AFC_FILIAL#AFC_PROJET#AFC_REVISA#AFC_CALEND#AFC_NIVEL"

	cFileOpen := cGetFile(cExtens,cTitulo1,0,,.F.,GETF_LOCALHARD,.F.,.F.)
	if len(alltrim(cFileOpen)) == 0
		return
	elseif !file(cFileOpen)
		msgAlert("Arquivo " + cFileOpen + " não localizado")
		return
	endif

	oTmpTrb := FWTemporaryTable():New( "fMark" )
	oTmpTrb:SetFields(aMark)
	oTmpTrb:Create()


	For nZ := 1 to 5

		Do Case
			Case nZ == 1
				cWorkSheet := "EDT"
				cTabela	   := "AFC"
			Case nZ == 2
				cWorkSheet := "TAREFAS"
				cTabela	   := "AF9"
			Case nZ == 3
				cWorkSheet := "PRODUTOS"
				cTabela	   := "AFA"
			Case nZ == 4
				cWorkSheet := "DESPESAS"
				cTabela	   := "AFB"
			Case nZ == 5
				cWorkSheet := "RECURSOS"
				cTabela	   := "AFA"
		EndCase

		aRet  := {}
		aRet := EXPXML(cFileOpen,cWorkSheet)

		If Len(aRet) > 0

			If Len(aRet[1]) > 0 .and. Len(aRet[3]) > 0

				If Len(aRet[1]) != Len(aRet[3])
					MsgAlert("Os campos em branco devem ser preenchidos com espaço!")
					lRet := .F.
				else
					nQtde:= 0
					For nI := 1 to Len(aRet[3])
						If nQtde != 0 .and. Len(aRet[3][nI]) != nQtde
							MsgAlert("Quantidade de registros entre as colunas não confere!")
							lRet := .F.
							Exit
						Endif
						nQtde := Len(aRet[3][nI])
					Next nI
				Endif
				If lRet
					ProcDados(aRet)
				Endif
			EndIf
		else
			MsgAlert("Dados não encontrados para importação!")
			lRet := .F.
		Endif
	Next nZ

	oModal:OOWNER:END()

	If lRet
		If Len(aEdt) > 0 .and. Len(aTarefa) > 0
			dbSelectArea("fMark")
			fMark->(dbGotop())
			If fMark->(!EOF())
				Aviso("Importação","Importação não realizada. Favor analisar o Log e efetuar o ajuste.",{"Fechar"},2)
				Processa({|| IMPEXC() },"Gerando Relatorio de Log...")
			Else

				lRet := U_COPMSGRV(aEdt, aTarefa, aProduto, aDespesa, aRecurso)

				If lRet
					Aviso("Importação","Importação efetuada com sucesso.",{"Fechar"},2)
					PMS410Dlg("AF8",AF8->(Recno()),6)
				else
					dbSelectArea("fMark")
					fMark->(dbGotop())
					If fMark->(!EOF())
						Aviso("Importação","Importação não realizada. Favor analisar o Log e efetuar o ajuste.",{"Fechar"},2)
						Processa({|| IMPEXC() },"Gerando Relatorio de Log...")
					Endif
				Endif
			Endif
		Else
			Aviso("Sheet","As Sheets EDT e Tarefas devem ser preenchidas. Trata-se de dados obrigatórios para importação.",{"Fechar"},2)
		Endif
	Endif

	If oTmpTrb <> Nil
		oTmpTrb:Delete()
		oTmpTrb := Nil
	Endif

return

Static Function EXPXML(cXMLFile, cWorkSheet)
	Local cError   := ""
	Local cWarning := ""
	Local oXml := NIL
	Local lRet := .T.
	Local nSize := 0
	Local nHandle := 0
	Local cBuffer := ""
	Local aLinha := {}
	Local ni := 0
	Local nx := 0
	Local cData := ""
	Local aDados := {}
	Local aRet := {}
	Local nLinha := 0
	Local aValor := {}

	nHandle := FOpen(cXMLFile,FO_READ+FO_SHARED)

	If nHandle < 0
		cError := str(FError())
		aAdd(aErros,{cXMLFile,"Erro ao abrir arquivo: ( " + cError + CHR(13)+CHR(10), ")" + GFERetFError(FError())})
		lRet := .F.

	EndIf

	If lRet
		nSize := FSeek(nHandle,FS_SET,FS_END)
		FSeek(nHandle,0)
		FRead(nHandle,@cBuffer,nSize)

		oXML  := XmlParser( cBuffer , "_", @cError, @cWarning)
		FClose(nHandle)
		nHandle   := -1

	EndIF

	aLinha := XmlArray(oXML,{"_WORKBOOK","_WORKSHEET"})
	For ni := 1 to Len(aLinha)
		If XmlChildEx(aLinha[ni],"_SS_NAME") != NIL
			If Upper(Alltrim(cWorkSheet)) $ Upper(Alltrim(aLinha[ni]:_SS_NAME:TEXT)) 
				cWorkSheet := Upper(Alltrim(aLinha[ni]:_SS_NAME:TEXT)) 
				If Len(aLinha) > 0
					aLinha := XmlArray(aLinha[ni],{"_TABLE","_ROW"})
					Exit
				Else
					aLinha := XmlArray(oXML,{"_WORKBOOK","_WORKSHEET","_TABLE","_ROW"})
					Exit
				EndIf
			Endif
		Endif
	Next ni
	nLinha := 0

	For ni := 2 To Len(aLinha)//Segunda linha deve iniciar com o nome tecnico dos campos Ex.: AFC_EDT
		If ni == 2
			aDados := XmlArray(aLinha[ni],{"_CELL"})
			For nx := 1 To Len(aDados)
				cData := XmlValid(aDados[nx],{"_DATA"})
				Aadd(aRet,cData)
			Next nx
		ElseIf ni >= 3
			nLinha++
			aDados := XmlArray(aLinha[ni],{"_CELL"})
			For nx := 1 To Len(aDados)
				If ni == 3
					Aadd(aValor,{})
				EndIf
				cData := XmlValid(aDados[nx],{"_DATA"})
				Aadd(aValor[nx],cData)
			Next nx
		EndIf
	Next ni

Return {aRet,nLinha,aValor}

Static Function XmlArray(oTEMP,aNode)
	Local lContinua := .T.
	Local nCont     := 0
	Local nFCont    := 0
	Local oXML      := oTEMP
	Local aDados	:= {}

	nFCont := Len(aNode)
	For nCont := 1 to nFCont
		If ValType( XmlChildEx( oXML,aNode[nCont]  ) ) == 'O'
			oXML :=  XmlChildEx( oXML,aNode[nCont]  )
		ElseIF ValType( XmlChildEx( oXML,aNode[nCont]  ) ) == 'A'
			aDados :=  XmlChildEx( oXML,aNode[nCont]  )
			Exit
		Else
			lContinua := .F.
		EndIf
	Next nCont

Return aDados

Static Function XmlValid(oTEMP,aNode)
	Local lContinua := .T.
	Local cReturn   := ""
	Local nCont     := 0
	Local nFCont    := 0
	Local oXML      := oTEMP

	nFCont := Len(aNode)
	For nCont := 1 to nFCont
		If ValType( XmlChildEx( oXML,aNode[nCont]  ) ) == 'O'
			oXML :=  XmlChildEx( oXML,aNode[nCont]  )
		Else
			lContinua := .F.
		EndIf

		If lContinua
			If nCont == nFCont
				cReturn := &("oXML:TEXT")
			EndIf
		Else
			Exit
		EndIf

	Next nCont

Return cReturn

Static Function ProcDados(aRet)

	Local aDados := {}
	Local nI, nX, nZ

	Private aSX3 := SNRetSx3(cTabela)

	nRegs := Len(aRet[3][1])

	oProcess:IncRegua1()
	oProcess:IncRegua1("Processando os Dados. Aguarde...")

	oProcess:SetRegua2(len(aRet[3][1]))

	For nX := 1 to nRegs
		For nZ := 1 to Len(aRet[3])
			If /*!Empty(aRet[3][nZ][nX]) .and.*/ !Alltrim(aRet[1][nZ]) $ cCPOAut
				npos := aScan( aSX3,{|x| Alltrim(x[2])==Alltrim(aRet[1][nZ])})
				cConteudo := aRet[3][nZ][nX]//Upper(AllTrim(NoAcento(aRet[3][nZ][nX])) )
				IF npos > 0
					If aSX3[nPos][8]=="D" .and. ValType(cConteudo) != "D"
						cConteudo := CTOD("  /  /    ")
						cConteudo := CTOD(aRet[3][nZ][nX])
						If cConteudo == CTOD("  /  /    ") .or. cConteudo != CTOD(aRet[3][nZ][nX])
							cConteudo := CTOD(SUBSTRING(aRet[3][nZ][nX],9,2)+"/"+SUBSTRING(aRet[3][nZ][nX],6,2)+"/"+SUBSTRING(aRet[3][nZ][nX],1,4))
						Endif
					ElseIf aSX3[nPos][8]=="N" .and. ValType(cConteudo) != "N"
						cConteudo := Val(StrTran(cConteudo,",","."))
					Endif
					aAdd(aDados, {aRet[1][nZ], cConteudo, Nil})
				Endif
			Endif
		Next nZ
		If Len(aDados) > 0

			//Validação de campos obrigatórios
			For nI := 1 To Len(aSX3)
				IF X3Obrigat( aSX3[nI,2] )//X3_OBRIGAT
					npos := aScan( aDados,{|x| Alltrim(x[1])==Alltrim(aSX3[nI,2])})
					IF npos == 0
						If !Alltrim(aSX3[nI,2]) $ cCpoAut
							cLog := "O Campo "+Alltrim(aSX3[nI,2])+" é obrigatório. Necessario o preenchimento para importação!"
							GERLOG(cWorkSheet, cLog)
							lRet := .F.
						Endif
					ElseIf Empty(aDados[nPos][2])
						If !Alltrim(aSX3[nI,2]) $ cCpoAut
							cLog := "O Campo "+Alltrim(aSX3[nI,2])+" é obrigatório. Necessario o preenchimento para importação!"
							GERLOG(cWorkSheet, cLog)
							lRet := .F.
						Endif
					Endif
				Endif
			Next nI

			Do Case
			Case cWorkSheet $ "EDT"
				aAdd(aEdt, aDados)
			Case cWorkSheet $ "TAREFAS" 
				aAdd(aTarefa, aDados)
			Case cWorkSheet $ "PRODUTOS" 
				aAdd(aProduto, aDados)
			Case cWorkSheet $ "DESPESAS" 
				aAdd(aDespesa, aDados)
			Case cWorkSheet $ "RECURSOS" 
				aAdd(aRecurso, aDados)
			EndCase
			aDados := {}
		Endif
		oProcess:IncRegua2()
	Next nX
Return

User Function COPMSGRV(aEdt, aTarefa, aProduto, aDespesa, aRecurso)

	Local aArea := GetArea()
	Local nX, nY, nZ
	Local aAFC 	:= {}
	Local aAF9 	:= {}
	Local aAFA1 := {}
	Local aAFA2 := {}
	Local aAFB	:= {}
	Local lRet  := .T.

	private lMsErroAuto	:=	.F.
	Begin Transaction

		oProcess:IncRegua1()
		oProcess:IncRegua1("Gravando os Dados. Aguarde...")

		oProcess:SetRegua2(len(aTarefa))

		For nX := 1 to Len(aEdt)

			aAFC  	:= {}
			cNivTrf := ""
			nOpcx 	:= 3

			aAdd(aAFC, {"AFC_FILIAL", xFilial("AFC")	, Nil})
			aAdd(aAFC, {"AFC_PROJET", AF8->AF8_PROJET	, Nil})
			aAdd(aAFC, {"AFC_REVISA", AF8->AF8_REVISA	, Nil})
			aAdd(aAFC, {"AFC_CALEND", AF8->AF8_CALEND	, Nil})

			For nZ := 1 to Len(aEdt[nX])
				aadd(aAFC, aEdt[nX][nZ])
			Next nZ

			nPosAFC := ascan(aAFC, {|x| Alltrim(x[1]) == "AFC_EDT"} )

			If nPosAFC > 0
				cEdt := aAFC[nPosAFC][2]
				dbSelectArea("AFC")
				dbSetOrder(1)
				If dbSeek(xFilial("AFC")+AF8->(AF8_PROJET+AF8_REVISA)+cEdt)
					nOpcx := 4
					cNivTrf := AFC->AFC_NIVEL
				else
					nPosAFC := ascan(aAFC, {|x| Alltrim(x[1]) == "AFC_EDTPAI"} )
					If nPosAFC > 0
						dbSelectArea("AFC")
						dbSetOrder(1)
						If dbSeek(xFilial("AFC")+AF8->(AF8_PROJET+AF8_REVISA)+aAFC[nPosAFC][2])
							cNivTrf := PRXNIV("AFC", aAFC[nPosAFC][2])
						else
							lRet := .F.
							GERLOG("EDT", 'EDT Pai '+Alltrim(aAFC[nPosAFC][2])+' não existente no projeto')
						Endif
					else
						lRet := .F.
						GERLOG("EDT", 'Campo AFC_EDTPAI obrigatório e não localizado na planilha')
					Endif
				Endif
			else
				lRet := .F.
				GERLOG("EDT", 'Campo AFC_EDT obrigatório e não localizado na planilha')
			Endif

			If ascan(aAFC, {|x| Alltrim(x[1]) == "AFC_DESCRI"} ) == 0
				lRet := .F.
				GERLOG("EDT", 'Campo AFC_DESCRI obrigatório e não localizado na planilha')
			Endif

			aAdd(aAFC, {"AFC_NIVEL", cNivTrf			, Nil})

			If lRet
				lMsErroAuto := .F.
				PMSA201(nOpcx,,,,aAFC,)

				If lMsErroAuto
					lRet := .F.
					cPath 		:= GetSrvProfString("Startpath","")
					cArquivo	:= "Erro_PMSA201_"+dtos(Date())+Left(time(),2)+Right(time(),2)
					MostraErro(cPath,cArquivo + ".txt")
					cLogMSErr 	:= MemoRead(cPath+cArquivo+".txt")
					GERLOG('Gravação dos dados', cLogMSErr)
					MostraErro()
				Endif
			Endif
		Next nX

		If lRet
			For nX := 1 to Len(aTarefa)

				aAF9  := {}
				aAFA1 := {}
				aAFA2 := {}
				aAFB  := {}

				cNivTrf := ""
				nOpcx 	:= 3

				aAdd(aAF9, {"AF9_FILIAL", xFilial("AF9")	, Nil})
				aAdd(aAF9, {"AF9_PROJET", AF8->AF8_PROJET	, Nil})
				aAdd(aAF9, {"AF9_REVISA", AF8->AF8_REVISA	, Nil})
				aAdd(aAF9, {"AF9_CALEND", AF8->AF8_CALEND	, Nil})

				For nZ := 1 to Len(aTarefa[nX])
					aadd(aAF9, aTarefa[nX][nZ])
				Next nZ

				nPosAF9 := ascan(aAF9, {|x| Alltrim(x[1]) == "AF9_TAREFA"} )

				If nPosAF9 > 0
					cTarefa := aAF9[nPosAF9][2]
					dbSelectArea("AF9")
					dbSetOrder(1)
					If dbSeek(xFilial("AF9")+AF8->(AF8_PROJET+AF8_REVISA)+cTarefa)
						nOpcx := 4
						cNivTrf := AF9->AF9_NIVEL
					else
						nPosAF9 := ascan(aAF9, {|x| Alltrim(x[1]) == "AF9_EDTPAI"} )
						If nPosAF9 > 0
							dbSelectArea("AFC")
							dbSetOrder(1)
							If dbSeek(xFilial("AFC")+AF8->(AF8_PROJET+AF8_REVISA)+aAF9[nPosAF9][2])
								cNivTrf := PRXNIV("AF9", aAFC[nPosAF9][2])
							else
								lRet := .F.
								GERLOG("TAREFAS", 'EDT Pai '+Alltrim(aAF9[nPosAF9][2])+' não existente no projeto')
							Endif
						else
							lRet := .F.
							GERLOG("TAREFAS", 'Campo AF9_EDTPAI obrigatório e não localizado na planilha')
						Endif
					Endif
				else
					lRet := .F.
					GERLOG("TAREFAS", 'Campo AF9_TAREFA obrigatório e não localizado na planilha')
				Endif

				aAdd(aAF9, {"AF9_NIVEL", cNivTrf			, Nil})


				If Len(aProduto) > 0
					For nY := 1 to Len(aProduto)
						aDados := {}

						nPosAFA := ascan(aProduto[nY], {|x| Alltrim(x[1]) == "AFA_TAREFA"} )
						nPosAF9 := ascan(aAF9, {|x| Alltrim(x[1]) == "AF9_TAREFA"} )

						If nPosAFA > 0 .and. nPosAF9 > 0
							If Alltrim(aProduto[nY][nPosAFA][2]) == Alltrim(aAF9[nPosAF9][2])
								aAdd(aDados, {"AFA_FILIAL", xFilial("AF9")	, Nil})
								aAdd(aDados, {"AFA_PROJET", AF8->AF8_PROJET	, Nil})
								aAdd(aDados, {"AFA_REVISA", AF8->AF8_REVISA	, Nil})
								For nZ := 1 to Len(aProduto[nY])
									aadd(aDados, aProduto[nY][nZ])
								Next nZ

								aadd(aAFA1, aDados)

								nPosPrd := ascan(aDados, {|x| Alltrim(x[1]) == "AFA_PRODUT"} )
								If nPosPrd == 0
									lRet := .F.
									GERLOG("PRODUTOS", 'Campo AFA_PRODUT obrigatório e não localizado na planilha')
								Else
									dbSelectArea("SB1")
									dbSetOrder(1)
									If !(dbSeek(xFilial("SB1")+aDados[nPosPrd][2]))
										lRet := .F.
										GERLOG("PRODUTOS", 'Produto '+Alltrim(aDados[nPosPrd][2])+' não encontrado no cadastro')
									Endif
								Endif
							Endif
						else
							lRet := .F.
							GERLOG("PRODUTOS", 'Campo AFA_TAREFA obrigatório e não localizado na planilha')
						Endif
					Next nZ
				Endif

				If Len(aRecurso) > 0
					For nY := 1 to Len(aRecurso)
						aDados := {}

						nPosAFA := ascan(aRecurso[nY], {|x| Alltrim(x[1]) == "AFA_TAREFA"} )
						nPosAF9 := ascan(aAF9, {|x| Alltrim(x[1]) == "AF9_TAREFA"} )

						If nPosAFA > 0 .and. nPosAF9 > 0
							If Alltrim(aRecurso[nY][nPosAFA][2]) == Alltrim(aAF9[nPosAF9][2])
								aAdd(aDados, {"AFA_FILIAL", xFilial("AF9")	, Nil})
								aAdd(aDados, {"AFA_PROJET", AF8->AF8_PROJET	, Nil})
								aAdd(aDados, {"AFA_REVISA", AF8->AF8_REVISA	, Nil})
								For nZ := 1 to Len(aRecurso[nY])
									aadd(aDados, aRecurso[nY][nZ])
								Next nZ

								aadd(aAFA2, aDados)

								nPosRec := ascan(aDados, {|x| Alltrim(x[1]) == "AFA_RECURS"} )
								If nPosRec == 0
									lRet := .F.
									GERLOG("RECURSOS", 'Campo AFA_RECURS obrigatório e não localizado na planilha')
								Else
									dbSelectArea("AE8")
									dbSetOrder(1)
									If !(dbSeek(xFilial("AE8")+aDados[nPosRec][2]))
										lRet := .F.
										GERLOG("RECURSOS", 'Recurso '+Alltrim(aDados[nPosRec][2])+' não encontrado no cadastro')
									Endif
								Endif
							Endif
						else
							lRet := .F.
							GERLOG("RECURSOS", 'Campo AFA_TAREFA obrigatório e não localizado na planilha')
						Endif
					Next nZ
				Endif

				If Len(aDespesa) > 0
					For nY := 1 to Len(aDespesa)
						aDados := {}

						nPosAFB := ascan(aDespesa[nY], {|x| Alltrim(x[1]) == "AFB_TAREFA"} )
						nPosAF9 := ascan(aAF9, {|x| Alltrim(x[1]) == "AF9_TAREFA"} )

						If nPosAFB > 0 .and. nPosAF9 > 0
							If Alltrim(aDespesa[nY][nPosAFB][2]) == Alltrim(aAF9[nPosAF9][2])
								aAdd(aDados, {"AFB_FILIAL", xFilial("AF9")	, Nil})
								aAdd(aDados, {"AFB_PROJET", AF8->AF8_PROJET	, Nil})
								aAdd(aDados, {"AFB_REVISA", AF8->AF8_REVISA	, Nil})
								For nZ := 1 to Len(aDespesa[nY])
									aadd(aDados, aDespesa[nY][nZ])
								Next nZ
								If ascan(aDados, {|x| Alltrim(x[1]) == "AFB_ITEM"} ) == 0
									cItem := StrZero(nY, TamSX3("AFB_ITEM")[1])
									aAdd(aDados, {"AFB_ITEM", cItem, Nil})
								Endif
								If ascan(aDados, {|x| Alltrim(x[1]) == "AFB_MOEDA"} ) == 0
									aAdd(aDados, {"AFB_MOEDA", 1, Nil})
								Endif
								If ascan(aDados, {|x| Alltrim(x[1]) == "AFB_ACUMUL"} ) == 0
									aAdd(aDados, {"AFB_ACUMUL", "3", Nil})
								Endif
								If ascan(aDados, {|x| Alltrim(x[1]) == "AFB_ALOC"} ) == 0
									aAdd(aDados, {"AFB_ALOC", 0, Nil})
								Endif

								aadd(aAFB, aDados)

								nPosDes := ascan(aDados, {|x| Alltrim(x[1]) == "AFB_TIPOD"} )
								If nPosDes == 0
									lRet := .F.
									GERLOG("DESPESAS", 'Campo AFB_TIPOD obrigatório e não localizado na planilha')
								Else
									aSX5 := FWGetSX5( "FD", aDados[nPosDes][2] )
									If Len(aSX5) == 0
										lRet := .F.
										GERLOG("DESPESAS", 'Despesa '+Alltrim(aDados[nPosDes][2])+' não encontrado no cadastro')
									Endif
								Endif

								nPosDtPrf := ascan(aDados, {|x| Alltrim(x[1]) == "AFB_DATPRF"} )
								If nPosDtPrf == 0
									lRet := .F.
									GERLOG("DESPESAS", 'Campo AFB_DATPRF obrigatório e não localizado na planilha')
								else
									If Empty(aDados[nPosDtPrf][2])
										lRet := .F.
										GERLOG("DESPESAS", 'Campo AFB_DATPRF obrigatório. Necessario o preenchimento para importação')
									Endif
								Endif
							Endif
						else
							lRet := .F.
							GERLOG("DESPESAS", 'Campo AFB_TAREFA obrigatório e não localizado na planilha')
						Endif
					Next nZ
				Endif

				If lRet

					lMsErroAuto	:=	.F.
					PMSA203(nOpcx,,,aAF9,IIF(Len(aAFA1)>0,aAFA1,),/*IIF(Len(aAFB)>0,aAFB,)*/,,,IIF(Len(aAFA2)>0,aAFA2,),,,,)

					If lMsErroAuto
						lRet := .F.
						cPath 		:= GetSrvProfString("Startpath","")
						cArquivo	:= "Erro_PMSA203_"+dtos(Date())+Left(time(),2)+Right(time(),2)
						MostraErro(cPath,cArquivo + ".txt")
						cLogMSErr 	:= MemoRead(cPath+cArquivo+".txt")
						GERLOG('Gravação dos dados', cLogMSErr)
					else
						//Trativa devido a erro apresentado na rotina padrão
						If len(aAFB) > 0
							For nY := 1 to Len(aAFB)
								nPosTar := ascan(aAFB[nY], {|x| Alltrim(x[1]) == "AFB_TAREFA"} )
								cTarefa := AvKey(aAFB[nY][nPosTar][2],"AFB_TAREFA")
								nPosItem:= ascan(aAFB[nY], {|x| Alltrim(x[1]) == "AFB_ITEM"} )
								cItem   := AvKey(aAFB[nY][nPosItem][2],"AFB_ITEM")
								//AFB_FILIAL+AFB_PROJET+AFB_REVISA+AFB_TAREFA+AFB_ITEM
								dbSelectArea("AFB")
								dbSetOrder(1)
								If dbSeek(xFilial("AFB")+AF8->(AF8_PROJET+AF8_REVISA)+cTarefa+cItem)
									RecLock("AFB",.F.)
								else
									RecLock("AFB",.T.)
								Endif
								For nZ := 1 To Len(aAFB[nY])
									_cNomeCpo := 'AFB->'+aAFB[nY][nZ][1]
									Replace &(_cNomeCpo) With aAFB[nY][nZ][2]
								Next nI
								MsUnlock()

								dbSelectArea("AF9")
								dbSetOrder(1)
								If dbSeek(xFilial("AF9")+AF8->(AF8_PROJET+AF8_REVISA)+cTarefa)
									aRetCus			:= PmsAF9CusTrf(2)
									nPercBDI		:= IIf(AF9->AF9_BDI <> 0,AF9->AF9_BDI,PmsGetBDIPad('AFC',AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_EDTPAI, AF9->AF9_UTIBDI ) )
									RecLock("AF9",.F.)
									AF9->AF9_CUSTO	:= aRetCus[1]
									AF9->AF9_CUSTO2	:= aRetCus[2]
									AF9->AF9_CUSTO3	:= aRetCus[3]
									AF9->AF9_CUSTO4	:= aRetCus[4]
									AF9->AF9_CUSTO5	:= aRetCus[5]
									If ! (aRetCus[1] == 0 .And. AF9->AF9_VALBDI <> 0 ) .and.  nPercBDI <> 0
										AF9->AF9_VALBDI:= aRetCus[1]*nPercBDI/100
									EndIf
									AF9->AF9_TOTAL := aRetCus[1]+AF9->AF9_VALBDI
									MsUnlock()
								Endif
							Next nZ
						Endif
					Endif
				Endif

				oProcess:IncRegua2()

			Next nX
		Endif

		If !lRet
			DisarmTransaction()
			RestArea(aArea)
			Return(lRet)
		Endif

	End Transaction

	RestArea(aArea)

Return (lRet)

Static Function PRXNIV(cTabela, cEDTPai)

	Local cNivTrf := ""

	If cTabela == "AFC"
		cQuery := " SELECT "
		cQuery += " 	AFC_NIVEL AS NIVATU "
		cQuery += " FROM "+RetSqlName("AFC")+" AFC "
		cQuery += " WHERE "
		cQuery += " 	AFC_FILIAL = '"+xFilial("AFC")+"' AND "
		cQuery += " 	AFC_PROJET = '"+AF8->AF8_PROJET+"' AND "
		cQuery += " 	AFC_REVISA = '"+AF8->AF8_REVISA+"' AND "
		cQuery += " 	AFC_EDTPAI = '"+cEDTPai+"' AND "
		cQuery += " 	AFC.D_E_L_E_T_ <> '*' "
		cQuery += "GROUP BY AFC_NIVEL"
	else
		cQuery := " SELECT "
		cQuery += " 	AF9_NIVEL AS NIVATU "
		cQuery += " FROM "+RetSqlName("AF9")+" AF9 "
		cQuery += " WHERE "
		cQuery += " 	AF9_FILIAL = '"+xFilial("AF9")+"' AND "
		cQuery += " 	AF9_PROJET = '"+AF8->AF8_PROJET+"' AND "
		cQuery += " 	AF9_REVISA = '"+AF8->AF8_REVISA+"' AND "
		cQuery += " 	AF9_EDTPAI = '"+cEDTPai+"' AND "
		cQuery += " 	AF9.D_E_L_E_T_ <> '*' "
		cQuery += "GROUP BY AF9_NIVEL"
	Endif

	If Select("TSQL") > 0
		dbSelectArea("TSQL")
		TSQL->(dbCloseArea())
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TSQL", .F., .F.)

	dbSelectArea("TSQL")
	TSQL->(dbGotop())
	If TSQL->(!EOF())
		cNivTrf := TSQL->NIVATU
	else
		If cTabela == "AFC"
			cQuery := " SELECT "
			cQuery += " 	MAX(AFC_NIVEL) AS NIVATU "
			cQuery += " FROM "+RetSqlName("AFC")+" AFC "
			cQuery += " WHERE "
			cQuery += " 	AFC_FILIAL = '"+xFilial("AFC")+"' AND "
			cQuery += " 	AFC_PROJET = '"+AF8->AF8_PROJET+"' AND "
			cQuery += " 	AFC_REVISA = '"+AF8->AF8_REVISA+"' AND "
			cQuery += " 	AFC.D_E_L_E_T_ <> '*' "
		else
			cQuery := " SELECT "
			cQuery += " 	MAX(AF9_NIVEL) AS NIVATU "
			cQuery += " FROM "+RetSqlName("AF9")+" AF9 "
			cQuery += " WHERE "
			cQuery += " 	AF9_FILIAL = '"+xFilial("AF9")+"' AND "
			cQuery += " 	AF9_PROJET = '"+AF8->AF8_PROJET+"' AND "
			cQuery += " 	AF9_REVISA = '"+AF8->AF8_REVISA+"' AND "
			cQuery += " 	AF9.D_E_L_E_T_ <> '*' "
		Endif

		If Select("TSQL") > 0
			dbSelectArea("TSQL")
			TSQL->(dbCloseArea())
		EndIf

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TSQL", .F., .F.)

		dbSelectArea("TSQL")
		TSQL->(dbGotop())
		If TSQL->(!EOF())
			cNivTrf := TSQL->NIVATU
			cNivTrf := StrZero(Val(cNivTrf) + 1, TamSX3("AFC_NIVEL")[1])
		Endif
	Endif

	If Select("TSQL") > 0
		dbSelectArea("TSQL")
		TSQL->(dbCloseArea())
	EndIf

Return(cNivTrf)

// UTILIZAÇÃO DO DICIONÁRIO DE DADOS SX3
Static Function SNRetSx3(__cArq)

	Local aSX3    := {}           // DADOS DA SX3 COM BASE NO VETOR AFIELDS
	Local aFields := GetColumns() // CAMPOS DA SX3 PARA ESTRUTURA
	// EFETUA A ABERTURA E GERAÇÃO DO ARQUIVO DE TRABALHO
	If (OpenDic(__cArq))
		// PERCORRE A TABELA FILTRADA E MONTA ESTRUTURA
		DbEval({|| AAdd(aSX3, GenStruct(aFields))})
		// FECHA O ARQUIVO DE TRABALHO
		DbCloseArea()
	EndIf

Return (aSX3)

// CAMPOS QUE DESEJO UTILIZAR NA MINHA ESTRUTURA
Static Function GetColumns()
	Local aFields := {} // VETOR DE CAMPOS

	// ADIÇÃO DOS CAMPOS DESEJADOS
	AAdd(aFields, "X3_TITULO")
	AAdd(aFields, "X3_CAMPO")
	AAdd(aFields, "X3_PICTURE")
	AAdd(aFields, "X3_TAMANHO")
	AAdd(aFields, "X3_DECIMAL")
	AAdd(aFields, "X3_VALID")
	AAdd(aFields, "X3_USADO")
	AAdd(aFields, "X3_TIPO")
	AAdd(aFields, "X3_F3")
	AAdd(aFields, "X3_CONTEXT")
	AAdd(aFields, "X3_CBOX")
	AAdd(aFields, "X3_RELACAO")
	AAdd(aFields, "X3_WHEN")
	AAdd(aFields, "X3_VISUAL")
	AAdd(aFields, "X3_VLDUSER")
	AAdd(aFields, "X3_PICTVAR")
	AAdd(aFields, "X3_OBRIGAT")
	AAdd(aFields, "X3_NIVEL")
	AAdd(aFields, "X3_FOLDER")
	AAdd(aFields, "X3_ORDEM")
	AAdd(aFields, "X3_DESCRIC")

Return (aFields)

// EFETUA A ABERTURA E GERAÇÃO DO ARQUIVO TEMPORÁRIO
Static Function OpenDic(__cArq)
	Local lOpen   := .F.                                             // VALIDAÇÃO DE ABERTURA DE TABELA
	Local cAlias  := GetNextAlias()                                  // APELIDO DO ARQUIVO DE TRABALHO
	Local cFilter := cAlias + "->" + "X3_ARQUIVO" + " == " + "'"+ __cArq + "'" // FILTRO PARA A TABELA SX3

	// ABERTURA DO DICIONÁRIO SX3
	OpenSXs(NIL, NIL, NIL, NIL, FwCodEmp(), cAlias, "SX3", NIL, .F.)
	lOpen := Select(cAlias) > 0

	// CASO ABERTO FILTRA O ARQUIVO PELO X3_ARQUIVO "DIC",
	// DEFINE COMO TABELA CORRENTE E POSICIONA NO TOPO
	If (lOpen)
		DbSelectArea(cAlias)
		DbSetFilter({|| &(cFilter)}, cFilter)
		DbGoTop()
	EndIf
Return (lOpen)

// RETORNA A ESTRUTURA DE UM CAMPO COM BASE NA SX3
Static Function GenStruct(aFields)
	Local aAux := {} // VETOR AUXILIAR PARA MONTAGEM DA ASX3
	// LAÇO DE REPETIÇÃO NOS CAMPOS DA SX3 PARA MONTAR A ESTRUTURA DE DIC
	AEval(aFields, {|cField| AAdd(aAux, &(cField))})
Return (aAux)

Static Function GERLOG(_cOrigem, _cLog)

	dbSelectArea("fMark")
	RecLock("fMark",.T.)
	fMARK->PROJET 	:= AF8->AF8_PROJET
	fMARK->REVISA 	:= AF8->AF8_REVISA
	fMARK->ORIGEM 	:= _cOrigem
	fMARK->OBS 		:= _cLog
	MsUnlock()

Return


Static Function IMPEXC()

	Local oReport

	Private _cQuebra := " "

	If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
		oReport := ReportDef()
		oReport:SetTotalInLine(.F.)
		oReport:PrintDialog()
	EndIf
Return


Static Function ReportDef()

	Local oReport

	oReport := TReport():New("IMPEXC","Log",,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir Log")


	oSection1 := TRSection():New(oReport,OemToAnsi("Log"),{"fMark"})

	TRCell():New(oSection1,"PROJET","fMark","Projeto","@!",30)
	TRCell():New(oSection1,"REVISA","fMark","Revisao","@!",10)
	TRCell():New(oSection1,"ORIGEM","fMark","Planilha","@!",30)
	TRCell():New(oSection1,"OBS","fMark","LOG","@!",100)


Return oReport


// Impressao do Relatorio
Static Function PrintReport(oReport)

	Local oSection1 := oReport:Section(1)
	oSection1:SetTotalInLine(.F.)
	oSection1:SetTotalText("Total Geral  ")  // Imprime Titulo antes do Totalizador da Secao
	oReport:OnPageBreak(,.T.)

// Impressao da Primeira secao
	DbSelectArea("fMark")
	DbGoTop()

	oReport:SetMeter(RecCount())
	oSection1:Init()
	While  !Eof()
		If oReport:Cancel()
			Exit
		EndIf
		oSection1:PrintLine()

		DbSelectArea("fMark")
		DbSkip()
		oReport:IncMeter()
	EndDo
	oSection1:Finish()

Return

