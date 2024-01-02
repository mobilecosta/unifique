#INCLUDE "PROTHEUS.CH"


#Define aCamposSX3 { 'X3_TITULO', 'X3_CAMPO', 'X3_PICTURE', 'X3_TAMANHO', 'X3_DECIMAL', 'X3_VALID', 'X3_USADO', 'X3_TIPO', 'X3_F3', 'X3_CONTEXT', 'X3_CBOX' }
#Define aCamposAFF {"AFF_PROJET","AFF_REVISA","AFF_TAREFA","AFF_DATA","AFF_QUANT","AFF_PERC","AFF_OBS","AFF_OCORRE"}

/*/{Protheus.doc} PMA310MNU
Ponto de entrada na chamada do pop-up das Confirmações
@type function
@version P12
@author Mateus Ramos
@since 12/21/2023
@return variant, nil
/*/
User Function PMA310MNU
************************
Local _oMenu    := PARAMIXB[1]
Local _oTree    := PARAMIXB[2]
Local _cArquivo := PARAMIXB[3]
Local _lVisual  := PARAMIXB[4]

MENUITEM 'Import. confirmacoes' Action U_U310Imp() ,Eval(bRefresh) //"Confirmacao multi-tarefa"
 
Return


User Function U310Imp()
***************************
Local aDados   		:= {}
Local aHeader  		:= {}
Local aArray		:= {}
Local a 	   		:= 0
Local b 			:= 0

Private oDados

/*SX3->(dbSetOrder(2))
SX3->( dbSeek("AFF_PROJET"))
AAdd(aHeader, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX ,""})
SX3->( dbSeek("AFF_REVISA"))
AAdd(aHeader, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX ,""})
SX3->( dbSeek("AFF_TAREFA"))
AAdd(aHeader, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX ,""})				
SX3->( dbSeek("AFF_DATA"))
AAdd(aHeader, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX ,""})
SX3->( dbSeek("AFF_QUANT"))
AAdd(aHeader, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX ,""})		
SX3->( dbSeek("AFF_PERC"))
AAdd(aHeader, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX ,""})		
SX3->( dbSeek("AFF_OBS"))
AAdd(aHeader, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX ,""})
SX3->( dbSeek("AFF_OCORRE"))
AAdd(aHeader, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX ,""})		
*/

For a := 1 to Len(aCamposAFF)
	aArray := Array(Len(aCamposSX3))
	For b := 1 to Len(aCamposSX3)
		aArray[b] := GetSx3Cache(aCamposAFF[a],aCamposSX3[b])
	Next
	aAdd(aHeader,aArray)
Next

aDados := UP311Dlg(aHeader)

If Len(aDados) > 0
	MsgRun("Gravando a confirmacao das tarefas","",{|| UP311Grv(aDados,aHeader)}) 
EndIf

Return

Static Function UP311Grv(aDados,aHeader)
*************************** 
Local i := 0
Local nx := 0
//Local bCampo 	:= {|n| FieldName(n) }
Local aArea		:= GetArea()
Local aAreaAF9  := {}
Local aArea2AF9 := {}
Local aAreaAN8  := {}
Local nQTMKPMS	:= GetNewPar("MV_QTMKPMS",0)
Local cAcao 	:= ""
Local cRevaca 	:= ""
//Local cAF9found := ""
Local cUsuario	:= ""

If Aviso("Atualizar confirmacoes","Deseja atualizar as confirmacoes posteriores para considerar a inclus„o efetuada?",{"Sim", "Nao"}, 3) == 1
	lCntPrg := .T.
Else
	lCntPrg := .F.
Endif
		
For i := 1 To Len(aDados)

	If !aDados[i,Len(aHeader)+1]

		AF9->(DbSetOrder(1))
		If AF9->(DbSeek(xFilial("AF9")+Padr(aDados[i,1],TamSX3("AF9_PROJET")[1])+Padr(aDados[i,2],TamSX3("AF9_REVISA")[1])))

			If ValType(nQTMKPMS) != "N"
				nQTMKPMS := 0
			EndIf
		
			If !Empty(RetCodUsr())
				cUsuario := RetCodUsr() //Usu·rio do protheus
			Else
				cUsuario := UsrPrtErp() //Usuario do portal
			EndIf
		
			RecLock("AFF",.T.)
			
			For nx := 1 TO FCount()
				If GdFieldPos(FieldName(nx),oDados:aHeader) > 0
					FieldPut(nx,aDados[i,GdFieldPos(FieldName(nx),oDados:aHeader)])
				EndIf
			Next nx

			AFF->AFF_FILIAL	:= xFilial("AFF")
			AFF->AFF_USER	:= cUsuario		
			MsUnlock()
			MSMM(,TamSx3("AFF_OBS")[1],,aDados[i,GdFieldPos("AFF_OBS",aHeader)],1,,,"AFF","AFF_CODMEM")
			PmsAvalAFF("AFF",1)
		
			If aDados[i,GdFieldPos("AFF_PERC",aHeader)] == 100
				dbSelectArea("AF9")
				aAreaAF9  := AF9->(GetArea())
				AF9->(dbSetOrder(1))
				If AF9->(MsSeek(xFilial("AF9")+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA,.F.))
					If !Empty(AF9->AF9_ACAO)
						If __lRejec
							// Busca outas taerfas que foram abertas em paralelo
							AF9->(dbSetOrder(6))
							cAcao 		:= AF9->AF9_ACAO
							cRevaca 	:= AF9->AF9_REVACA
							aArea2AF9	:= AF9->(GetArea())
							AF9->(dbSeek(xFilial("AF9")+cAcao+cRevaca,.F.))
							While AF9->(!EOF()) .AND. AF9->AF9_ACAO+AF9->AF9_REVACA == cAcao+cRevaca
									RegToMemory("AFF",.F.)
									RecLock("AFF",.T.)
									If GdFieldPos(FieldName(nx),oDados:aHeader) > 0
										FieldPut(nx,aDados[i,GdFieldPos(FieldName(nx),oDados:aHeader)])
									EndIf
									AFF->AFF_FILIAL	:= xFilial("AFF")
									AFF->AFF_USER	:= cUsuario									
									AFF->(MsUnlock())
									MSMM(,TamSx3("AFF_OBS")[1],,"Tarefa rejeitada",1,,,"AFF","AFF_CODMEM")
								AF9->(DbSkip())
							EndDo
							RestArea(aArea2AF9)
		
							dbSelectArea("QI5")
							QNC50BXPEND(AF9->AF9_ACAO,AF9->AF9_REVACA,AF9->AF9_TPACAO,__cQNCRej,__cQNCDEP,__cNEWQUO,aDados[i,GdFieldPos("AFF_OBS",aHeader)])//Rejeitou
							// atualiza a hora total executada
							QN5AltPrz(AF9->AF9_FNC,AF9->AF9_REVFNC,AF9->AF9_TPACAO,,,QNCPrzHR2(PMS320THr(AFF->AFF_PROJET,AFF->AFF_REVISA,AFF->AFF_TAREFA),"D","H","H","H"))
		
						Else	//Caso contr·rio.
							Q50BXTMKPMS(xFilial("QI5"),AF9->AF9_ACAO,AF9->AF9_REVACA,AF9->AF9_TPACAO,.F.,aDados[i,GdFieldPos("AFF_TAREFA",aHeader)],aDados[i,GdFieldPos("AFF_OBS",aHeader)])
							// atualiza a hora total executada
							QN5AltPrz(AF9->AF9_FNC,AF9->AF9_REVFNC,AF9->AF9_TPACAO,,,QNCPrzHR2(PMS320THr(AFF->AFF_PROJET,AFF->AFF_REVISA,AFF->AFF_TAREFA),"D","H","H","H"))
						EndIf
					EndIf
				EndIf
				RestArea(aAreaAF9)
		
				dbSelectArea("AF9")
				aAreaAF9  := AF9->(GetArea())
				dbSetOrder(1)
				If MsSeek(xFilial("AF9")+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA,.F.)
					dbSelectArea("AN8")
					aAreaAN8  := AN8->(GetArea())
					AN8->(dbSetOrder(1)) //AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA+DTOS(AN8_DATA)+AN8_HORA+AN8_TRFORI
					If AN8->( MsSeek( xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA) ) )
						Do While !AN8->(Eof()) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
							If AN8->AN8_STATUS=='1'
								RecLock("AN8",.F.)
								AN8->AN8_STATUS := '3'
								MsUnlock()
							EndIf
							AN8->(dbSkip())
						EndDo
					EndIf
					RestArea(aAreaAN8)
				EndIf
			EndIf
			If ExistBlock("PMA311GRV")
				ExecBlock("PMA311GRV",.F.,.F.)
			EndIf
		EndIf
 	EndIf

 	If lCntPrg
		nQtdAnt   := AFF->AFF_QUANT
		cAFFProj  := AFF->AFF_PROJET
		cAFFRev   := AFF->AFF_REVISA
		cAFFTask  := AFF->AFF_TAREFA
		cAFFDate  := DToS(AFF->AFF_DATA)
		cAFFQuant := AFF->AFF_QUANT

		If PMSExistAFF(AFF->AFF_PROJET, AFF->AFF_REVISA, AFF->AFF_TAREFA, DToS(AFF->AFF_DATA + 1))		
			lCanDel := lCntPrg
	
			// recalcula os apontamentos, sugerindo a quantidade
			// do apontamento incluÌdo como valor a ser aplicado
			PMS311Rec(cAFFProj, cAFFRev, cAFFTask, cAFFDate, GetNewDiff(cAFFQuant,.F.), lCanDel)
		EndIf
	EndIf
			
 	RestArea(aArea)
Next i

Return

Static Function UP311Dlg(aHeader)
	***********************
	Local aDados   := {}
    Local aButtons := {}
	Local nCntFor  := 0
    
	Private oDlg
	Private aCols  := {}

	aAdd(aCols,Array(Len(aHeader)+1))
	nAcols := Len(aCols)
	aCols[nAcols,Len(aHeader)+1] := .F.
	For nCntFor := 1 To Len(aHeader)	
			aCols[nAcols,nCntFor] := Iif(aHeader[nCntFor,8] == "M","",CriaVar(aHeader[nCntFor,2],.F.))
	Next nCntFor

    aadd(aButtons ,{"DESTINOS", {|| U_fImpCSV(oDados)} , "Importar confirmacoes","Import. confirm." })

	oMainWnd:ReadClientCoords()
	oDlg := MsDialog():New(oMainWnd:nTop+125,oMainWnd:nLeft+5,oMainWnd:nBottom-60,oMainWnd:nRight-10,OemToAnsi("Confrmacoes"),,,.F.,,,,,oMainWnd,.T.,,,.F.)

	oDados := MsNewGetDados():New(1,1,1,1,GD_INSERT+GD_DELETE+GD_UPDATE,"U_U311Vld()",,,,,,,,,oDlg,aHeader,aCols)
	oDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	Activate MSDialog oDlg On Init EnchoiceBar(oDlg,{|| aDados := oDados:aCols, oDlg:End()},{|| aDados := {}, oDlg:End()},,aButtons) Centered
	
Return aDados

User Function fImpCSV(oDados)
***********************


	Local nLin := 0
	Local aDados := {}

	//###############################################################

	Local aRet := {}
	Local aParamBox := {}
	Local i := 0
	Local cArqXXX := ''

	Private cCadastro := "xParambox"

	aAdd(aParamBox,{6,"Buscar arquivo",Space(50),"","","",50,.T.,"Arquivos .CSV |*.CSV","C:\"})

	If ParamBox(aParamBox,"Importar Arquivo CSV...",@aRet)
		For i:=1 To Len(aRet)

			cArqXXX := aRet[i]

		Next 
	Endif

	//###############################################################
	cPathXXX := SubStr( cArqXXX, 1, RAt( '\', cArqXXX ) ) //"Caminho"
	cFileXXX := SubStr( cArqXXX, RAt('\', cArqXXX )+1 , LEN(cArqXXX)   ) //"Arquivo"

	xLerCVS(cPathXXX,cFileXXX,oDados)

Return


//##################################################################################
Static Function xLerCVS(cPatchX,cFileX,oDados)
	//Local aArea    := Getarea()
	//Local aAreaSB1 := SB1->(Getarea())
	Local cArq    := cFileX //"clientes.txt"
	Local cDir    := cPatchX
	Local cLinha  := ""
	Local lPrim   := .T.
	Local aCampos := {}
	Local aDados  := {}
	Local i := 0

	If !File(cDir+cArq)
		MsgStop("O arquivo " +cDir+cArq + " não foi encontrado. A importação será abortada!","ATENCAO")
		Return {}
	EndIf

	FT_FUSE(cDir+cArq)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()

		IncProc("Lendo arquivo CSV...")

		cLinha := FT_FREADLN()

		If lPrim
			aCampos := {"","","","","","","","",.F.}
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo

	oDados:aCols := {}

	ProcRegua(Len(aDados))
	For i := 1 to Len(aDados)

		IncProc("Importando confirmacoes...")

		aAdd(oDados:aCols, { aDados[i,1],; //Projeto 
		aDados[i,2],; //Revisao                                              
		aDados[i,3],; //Tarefa
		CToD(aDados[i,4]),; //Data
		Val(aDados[i,5]),; //Quantidade
		Val(aDados[i,6]),; //%
		aDados[i,7],; //Obs
		aDados[i,8],; //Ocorrencaias
		.F.})

	Next i

	FT_FUSE()

	oDados:oBrowse:Refresh()	

Return

User Function U311Vld()// -- User Function Comentada pois já existe no fonte PMA311IN
***********************
Local cProj  := AF9->AF9_PROJET
Local cRev   := AF9->AF9_REVISA
Local cTarf  := oDados:aCols[oDados:oBrowse:nAt,GdFieldPos("AFF_TAREFA",oDados:aHeader)]
Local dDt    := oDados:aCols[oDados:oBrowse:nAt,GdFieldPos("AFF_DATA",oDados:aHeader)]

If !ExistChav("AFF",cProj+cRev+cTarf+DTOS(dDt))
	Aviso("Atencao","Ja existe confirmacao para esta data no projeto "+cProj+", impossivel incluir."+CRLF+"Caso seja necessario, edite confirmacao existente.",{"OK"})
	Return .F.
Endif
	
Return .T.

//Função retorna se o projeto está encerrado(1) ou Não(2)
Static Function fAF8Sts(pProj)
	Local cQuery := ''
	Local cRet := ''
	
	cQuery	  := " SELECT AF8_ENCPRJ AS STATUS "
	cQuery	  += " FROM " + RetSqlName('AF8')
	cQuery	  += " WHERE AF8_FILIAL = '" + xFilial('AF8')+ "'"
	cQuery	  += "  AND AF8_PROJET	= '" + pProj  + "'"
	cQuery	  += "  AND D_E_L_E_T_  = ' '"
	
	cQuery    := ChangeQuery(cQuery)
	If Select("AF8TMP") != 0
		AF8TMP->(dbCloseArea())
	EndIf
	dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), "AF8TMP", .F., .T.)
	
	If !AF8TMP->(Eof())
		cRet := AF8TMP->STATUS
	EndIf
	
Return cRet
