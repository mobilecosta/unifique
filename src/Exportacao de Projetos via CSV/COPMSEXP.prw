#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'
#INCLUDE "XMLXFUN.CH"
#Include "fileio.ch"
#INCLUDE "FWMVCDEF.CH"

User Function COPMSEXP()

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
	cMsg := cMsg + "Efetuar a exportação dos dados do projeto selecionado."

	TSay():New(1, 1, {|| cMsg}, oModal:getPanelMain(),,,,,, .T.,,, 200, 40,,,,,, .T.)

	oModal:addButton("Exportar Planilha", {|| oProcess := MsNewProcess():New( {|| fExport() }, 'Exportação' , 'Aguarde...' , .F. ), oProcess:Activate() },;
		"Exportar", , .T., .F., .T., )
	
	oModal:Activate()

Return

static function fExport()

	Local cPlan 	:= "EDT"
	Local cTable	:= "Layout PMS"
	Local cDir		:= "C:\temp\"
	Local cArq		:= "Layout_"+Alltrim(AF8->AF8_PROJET)+"_" + dtos(dDatabase) + ".xml"
	Local nX, nY
	Private oExcel
		
	cDir := cGetFile(,"Selecione o diretório",,, .F., GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE, .F.)

	oProcess:SetRegua1(3) //(3 etapas + 1 para inicializacao da barra)
	oProcess:IncRegua1()

	oExcel := fwMsExcel():new()

	oProcess:IncRegua1("Retornando registros. Aguarde...")
	oProcess:SetRegua2()

	oProcess:IncRegua2()

	For nX := 1 to 5
		aCpos := {}
		Do Case
		Case nX == 1
			cPlan := "EDT"
			aadd(aCpos,"AFC_EDT")
			aadd(aCpos,"AFC_DESCRI")
			aadd(aCpos,"AFC_UM")
			aadd(aCpos,"AFC_EDTPAI")
		Case nX == 2
			cPlan := "TAREFAS"
			aadd(aCpos,"AF9_EDTPAI")
			aadd(aCpos,"AF9_TAREFA")
			aadd(aCpos,"AF9_DESCRI")
			aadd(aCpos,"AF9_UM")
			aadd(aCpos,"AF9_QUANT")
			aadd(aCpos,"AF9_HDURAC")
			aadd(aCpos,"AF9_CCUSTO")
			aadd(aCpos,"AF9_BDI")
			aadd(aCpos,"AF9_NIVEL")
			aadd(aCpos,"AF9_START")
			aadd(aCpos,"AF9_FINISH")
		Case nX == 3
			cPlan := "PRODUTOS"
			aadd(aCpos,"AFA_TAREFA")
			aadd(aCpos,"AFA_ITEM")
			aadd(aCpos,"AFA_PRODUT")
			aadd(aCpos,"AFA_QUANT")
			aadd(aCpos,"AFA_MOEDA")
			aadd(aCpos,"AFA_CUSTD")
			aadd(aCpos,"AFA_DATPRF")
		Case nX == 4
			cPlan := "RECURSOS"
			aadd(aCpos,"AFA_TAREFA")
			aadd(aCpos,"AFA_ITEM")
			aadd(aCpos,"AFA_RECURS")
			aadd(aCpos,"AFA_PRODUT")
			aadd(aCpos,"AFA_QUANT")
			aadd(aCpos,"AFA_CUSTD")
			aadd(aCpos,"AFA_DATPRF")
			aadd(aCpos,"AFA_MOEDA")
			aadd(aCpos,"AFA_ALOC")
		Case nX == 5
			cPlan := "DESPESAS"
			aadd(aCpos,"AFB_TAREFA")
			aadd(aCpos,"AFB_ITEM")
			aadd(aCpos,"AFB_TIPOD")
			aadd(aCpos,"AFB_DESCRI")
			aadd(aCpos,"AFB_VALOR")
			aadd(aCpos,"AFB_MOEDA")
			aadd(aCpos,"AFB_DATPRF")
		EndCase

		aRetCpos := RETDADOS(cPlan)

		oExcel:addWorkSheet(cPlan)
		oExcel:addTable(cPlan, cTable)

		For nY := 1 to Len(aCpos)
			oExcel:addColumn(cPlan, cTable, alltrim(aCpos[nY]), 1, 1, .F.)
		Next nY

		For nY := 1 to Len(aRetCpos)
			oExcel:AddRow(cPlan, cTable, aRetCpos[nY])
		Next nY

	Next nX

	oExcel:Activate()

	oProcess:IncRegua1("Gerando arquivo. Aguarde...")
	oProcess:SetRegua2(0)
	oExcel:GetXMLFile(cArq)
	if !Empty(cDir)
		MakeDir(cDir)
	endif
	if __CopyFile(cArq, cDir + cArq)
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cDir + cArq)
		oExcelApp:SetVisible(.T.)
		MsgInfo( "Arquivo " + cArq + " gerado com sucesso no diretório " + cDir )
		oExcelApp:Destroy()
	else
		MsgInfo( "Arquivo não copiado para temporário do usuário." )
	endif

	oExcel:DeActivate()
	oModal:OOWNER:END()

return

Static Function RETDADOS(cPlan)

	Local aRetCpos := {}
		
	Do Case
	Case cPlan == "EDT"
		cQuery := " SELECT "
		cQuery += " 	AFC_EDT, AFC_DESCRI, AFC_UM, AFC_EDTPAI "
		cQuery += " FROM "+RetSqlName("AFC")+" AFC "
		cQuery += " WHERE "
		cQuery += " 	AFC_FILIAL ='"+xFilial("AFC")+"' AND "
		cQuery += " 	AFC_PROJET = '"+AF8->AF8_PROJET+"' AND "
		cQuery += " 	AFC_REVISA = '"+AF8->AF8_REVISA+"' AND "
		cQuery += " 	AFC_EDTPAI != '' AND "
		cQuery += " 	AFC.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY AFC_EDTPAI, AFC_EDT "
	Case cPlan == "TAREFAS"
		cQuery := " SELECT "
		cQuery += " 	AF9_EDTPAI, AF9_TAREFA,	AF9_DESCRI,	AF9_UM,	"
		cQuery += " 	AF9_QUANT, AF9_HDURAC, AF9_CCUSTO, AF9_BDI, AF9_NIVEL, AF9_START, AF9_FINISH "
		cQuery += " FROM "+RetSqlName("AF9")+" AF9 "
		cQuery += " WHERE "
		cQuery += " 	AF9_FILIAL ='"+xFilial("AF9")+"' AND "
		cQuery += " 	AF9_PROJET = '"+AF8->AF8_PROJET+"' AND "
		cQuery += " 	AF9_REVISA = '"+AF8->AF8_REVISA+"' AND "
		cQuery += " 	AF9.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY AF9_EDTPAI, AF9_TAREFA "
	Case cPlan == "PRODUTOS"
		cQuery := " SELECT "
		cQuery += " 	AFA_TAREFA,	AFA_ITEM, AFA_PRODUT, AFA_QUANT, AFA_MOEDA, AFA_CUSTD, AFA_DATPRF "
		cQuery += " FROM "+RetSqlName("AFA")+" AFA "
		cQuery += " WHERE "
		cQuery += " 	AFA_FILIAL ='"+xFilial("AFA")+"' AND "
		cQuery += " 	AFA_PROJET = '"+AF8->AF8_PROJET+"' AND "
		cQuery += " 	AFA_REVISA = '"+AF8->AF8_REVISA+"' AND "
		cQuery += " 	AFA_RECURS = '' AND "
		cQuery += " 	AFA.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY AFA_TAREFA, AFA_ITEM "
	Case cPlan == "RECURSOS"
		cQuery := " SELECT "
		cQuery += " 	AFA_TAREFA,	AFA_ITEM, AFA_RECURS, AFA_PRODUT, AFA_QUANT, "
		cQuery += " 	AFA_CUSTD, AFA_DATPRF,	AFA_MOEDA,	AFA_ALOC "
		cQuery += " FROM "+RetSqlName("AFA")+" AFA "
		cQuery += " WHERE "
		cQuery += " 	AFA_FILIAL ='"+xFilial("AFA")+"' AND "
		cQuery += " 	AFA_PROJET = '"+AF8->AF8_PROJET+"' AND "
		cQuery += " 	AFA_REVISA = '"+AF8->AF8_REVISA+"' AND "
		cQuery += " 	AFA_RECURS != '' AND "
		cQuery += " 	AFA.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY AFA_TAREFA, AFA_ITEM "
	Case cPlan == "DESPESAS"
		cQuery := " SELECT "
		cQuery += " 	AFB_TAREFA,	AFB_ITEM, AFB_TIPOD, AFB_DESCRI, AFB_VALOR, AFB_MOEDA, AFB_DATPRF "
		cQuery += " FROM "+RetSqlName("AFB")+" AFB "
		cQuery += " WHERE "
		cQuery += " 	AFB_FILIAL ='"+xFilial("AFB")+"' AND "
		cQuery += " 	AFB_PROJET = '"+AF8->AF8_PROJET+"' AND "
		cQuery += " 	AFB_REVISA = '"+AF8->AF8_REVISA+"' AND "
		cQuery += " 	AFB.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY AFB_TAREFA, AFB_ITEM "
	EndCase

	If Select("TSQL") > 0
		dbSelectArea("TSQL")
		TSQL->(dbCloseArea())
	EndIf

	//dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TSQL", .F., .F.)
	MpSysOpenQuery(cQuery, "TSQL")

	Do Case
	Case cPlan == "EDT"
		TcSetField("TSQL","AFC_EDT",TAMSX3("AFC_EDT")[3],TamSx3("AFC_EDT")[1],TamSx3("AFC_EDT")[2])
		TcSetField("TSQL","AFC_DESCRI",TAMSX3("AFC_DESCRI")[3],TamSx3("AFC_DESCRI")[1],TamSx3("AFC_DESCRI")[2])
		TcSetField("TSQL","AFC_UM",TAMSX3("AFC_UM")[3],TamSx3("AFC_UM")[1],TamSx3("AFC_UM")[2])
		TcSetField("TSQL","AFC_EDTPAI",TAMSX3("AFC_EDTPAI")[3],TAMSX3("AFC_EDTPAI")[1],TAMSX3("AFC_EDTPAI")[2])
	Case cPlan == "TAREFAS"		
		TcSetField("TSQL","AF9_EDTPAI",TAMSX3("AF9_EDTPAI")[3],TamSx3("AF9_EDTPAI")[1],TamSx3("AF9_EDTPAI")[2])
		TcSetField("TSQL","AF9_TAREFA",TAMSX3("AF9_TAREFA")[3],TamSx3("AF9_TAREFA")[1],TamSx3("AF9_TAREFA")[2])
		TcSetField("TSQL","AF9_DESCRI",TAMSX3("AF9_DESCRI")[3],TamSx3("AF9_DESCRI")[1],TamSx3("AF9_DESCRI")[2])
		TcSetField("TSQL","AF9_UM",TAMSX3("AF9_UM")[3],TAMSX3("AF9_UM")[1],TAMSX3("AF9_UM")[2])
		TcSetField("TSQL","AF9_QUANT",TAMSX3("AF9_QUANT")[3],TamSx3("AF9_QUANT")[1],TamSx3("AF9_QUANT")[2])
		TcSetField("TSQL","AF9_HDURAC",TAMSX3("AF9_HDURAC")[3],TamSx3("AF9_HDURAC")[1],TamSx3("AF9_HDURAC")[2])
		TcSetField("TSQL","AF9_CCUSTO",TAMSX3("AF9_CCUSTO")[3],TamSx3("AF9_CCUSTO")[1],TamSx3("AF9_CCUSTO")[2])
		TcSetField("TSQL","AF9_BDI",TAMSX3("AF9_BDI")[3],TamSx3("AF9_BDI")[1],TamSx3("AF9_BDI")[2])
		TcSetField("TSQL","AF9_NIVEL",TAMSX3("AF9_NIVEL")[3],TAMSX3("AF9_NIVEL")[1],TAMSX3("AF9_NIVEL")[2])
		TcSetField("TSQL","AF9_START",TAMSX3("AF9_START")[3],TAMSX3("AF9_START")[1],TAMSX3("AF9_START")[2])
		TcSetField("TSQL","AF9_FINISH",TAMSX3("AF9_FINISH")[3],TAMSX3("AF9_FINISH")[1],TAMSX3("AF9_FINISH")[2])		
	Case cPlan == "PRODUTOS"
		TcSetField("TSQL","AFA_TAREFA",TAMSX3("AFA_TAREFA")[3],TamSx3("AFA_TAREFA")[1],TamSx3("AFA_TAREFA")[2])
		TcSetField("TSQL","AFA_ITEM",TAMSX3("AFA_ITEM")[3],TamSx3("AFA_ITEM")[1],TamSx3("AFA_ITEM")[2])
		TcSetField("TSQL","AFA_PRODUT",TAMSX3("AFA_PRODUT")[3],TamSx3("AFA_PRODUT")[1],TamSx3("AFA_PRODUT")[2])
		TcSetField("TSQL","AFA_QUANT",TAMSX3("AFA_QUANT")[3],TAMSX3("AFA_QUANT")[1],TAMSX3("AFA_QUANT")[2])
		TcSetField("TSQL","AFA_MOEDA",TAMSX3("AFA_MOEDA")[3],TAMSX3("AFA_MOEDA")[1],TAMSX3("AFA_MOEDA")[2])
		TcSetField("TSQL","AFA_CUSTD",TAMSX3("AFA_CUSTD")[3],TamSx3("AFA_CUSTD")[1],TamSx3("AFA_CUSTD")[2])
		TcSetField("TSQL","AFA_DATPRF",TAMSX3("AFA_DATPRF")[3],TamSx3("AFA_DATPRF")[1],TamSx3("AFA_DATPRF")[2])
	Case cPlan == "RECURSOS"
		TcSetField("TSQL","AFA_TAREFA",TAMSX3("AFA_TAREFA")[3],TamSx3("AFA_TAREFA")[1],TamSx3("AFA_TAREFA")[2])
		TcSetField("TSQL","AFA_ITEM",TAMSX3("AFA_ITEM")[3],TamSx3("AFA_ITEM")[1],TamSx3("AFA_ITEM")[2])
		TcSetField("TSQL","AFA_RECURS",TAMSX3("AFA_RECURS")[3],TamSx3("AFA_RECURS")[1],TamSx3("AFA_RECURS")[2])
		TcSetField("TSQL","AFA_PRODUT",TAMSX3("AFA_PRODUT")[3],TamSx3("AFA_PRODUT")[1],TamSx3("AFA_PRODUT")[2])
		TcSetField("TSQL","AFA_QUANT",TAMSX3("AFA_QUANT")[3],TAMSX3("AFA_QUANT")[1],TAMSX3("AFA_QUANT")[2])
		TcSetField("TSQL","AFA_CUSTD",TAMSX3("AFA_CUSTD")[3],TamSx3("AFA_CUSTD")[1],TamSx3("AFA_CUSTD")[2])
		TcSetField("TSQL","AFA_DATPRF",TAMSX3("AFA_DATPRF")[3],TamSx3("AFA_DATPRF")[1],TamSx3("AFA_DATPRF")[2])
		TcSetField("TSQL","AFA_MOEDA",TAMSX3("AFA_MOEDA")[3],TamSx3("AFA_MOEDA")[1],TamSx3("AFA_MOEDA")[2])
		TcSetField("TSQL","AFA_ALOC",TAMSX3("AFA_ALOC")[3],TamSx3("AFA_ALOC")[1],TamSx3("AFA_ALOC")[2])		
	Case cPlan == "DESPESAS"
		TcSetField("TSQL","AFB_TAREFA",TAMSX3("AFB_TAREFA")[3],TamSx3("AFB_TAREFA")[1],TamSx3("AFB_TAREFA")[2])
		TcSetField("TSQL","AFB_ITEM",TAMSX3("AFB_ITEM")[3],TamSx3("AFB_ITEM")[1],TamSx3("AFB_ITEM")[2])
		TcSetField("TSQL","AFB_TIPOD",TAMSX3("AFB_TIPOD")[3],TamSx3("AFB_TIPOD")[1],TamSx3("AFB_TIPOD")[2])
		TcSetField("TSQL","AFB_DESCRI",TAMSX3("AFB_DESCRI")[3],TamSx3("AFB_DESCRI")[1],TamSx3("AFB_DESCRI")[2])
		TcSetField("TSQL","AFB_VALOR",TAMSX3("AFB_VALOR")[3],TAMSX3("AFB_VALOR")[1],TAMSX3("AFB_VALOR")[2])
		TcSetField("TSQL","AFB_MOEDA",TAMSX3("AFB_MOEDA")[3],TamSx3("AFB_MOEDA")[1],TamSx3("AFB_MOEDA")[2])
		TcSetField("TSQL","AFB_DATPRF",TAMSX3("AFB_DATPRF")[3],TamSx3("AFB_DATPRF")[1],TamSx3("AFB_DATPRF")[2])
	EndCase

	dbSelectArea("TSQL")
	TSQL->(dbGotop())
	Do While TSQL->(!EOF())
		Do Case
		Case cPlan == "EDT"
			aadd(aRetCpos, {TSQL->AFC_EDT, TSQL->AFC_DESCRI, TSQL->AFC_UM, TSQL->AFC_EDTPAI})
		Case cPlan == "TAREFAS"
			aadd(aRetCpos, {TSQL->AF9_EDTPAI, TSQL->AF9_TAREFA,	TSQL->AF9_DESCRI, TSQL->AF9_UM,;
				TSQL->AF9_QUANT, TSQL->AF9_HDURAC, TSQL->AF9_CCUSTO, TSQL->AF9_BDI, TSQL->AF9_NIVEL, DTOC(TSQL->AF9_START), DTOC(TSQL->AF9_FINISH) })
		Case cPlan == "PRODUTOS"
			aadd(aRetCpos, {TSQL->AFA_TAREFA, TSQL->AFA_ITEM, TSQL->AFA_PRODUT, TSQL->AFA_QUANT, TSQL->AFA_MOEDA,;
				TSQL->AFA_CUSTD, DTOC(TSQL->AFA_DATPRF)})
		Case cPlan == "RECURSOS"
			aadd(aRetCpos, {TSQL->AFA_TAREFA, TSQL->AFA_ITEM, TSQL->AFA_RECURS, TSQL->AFA_PRODUT,;
				TSQL->AFA_QUANT, TSQL->AFA_CUSTD, DTOC(TSQL->AFA_DATPRF),	TSQL->AFA_MOEDA, TSQL->AFA_ALOC  })
		Case cPlan == "DESPESAS"
			aadd(aRetCpos, {TSQL->AFB_TAREFA, TSQL->AFB_ITEM, TSQL->AFB_TIPOD, TSQL->AFB_DESCRI,;
				TSQL->AFB_VALOR, TSQL->AFB_MOEDA, DTOC(TSQL->AFB_DATPRF)})
		EndCase

		TSQL->(DbSkip())
	Enddo

	If Select("TSQL") > 0
		dbSelectArea("TSQL")
		TSQL->(dbCloseArea())
	EndIf

Return(aRetCpos)

