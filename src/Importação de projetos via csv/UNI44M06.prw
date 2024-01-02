#include "protheus.ch"
//#include "pmsa001.ch"
//#include "pmsicons.ch"

Static lFWCodFil := FindFunction("FWCodFil")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA001  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de importacao de projetos no AF8 atraves de arquivo ³±±
±±³          ³ texto.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UNI44M06()

If PMSBLKINT()
	Return Nil
EndIf

//Aviso("Importacao de projetos","Atencao! Certifique-se de que o arquivo foi gerado com este formato de data no Microsoft Project (Ferramentas - Opcoes): 31/12/00 12:33",{"Ok"},2) //"Importacao de projetos"######
      
Processa({||A001Import()},"Importando CSV. Aguarde...") //"Importando CSV. Aguarde..."

Return

/*/{Protheus.doc} A001Import

Função para leitura de arquivo .CSV para gravação nas tabelas do modulo SIGAPMS. 
Permitindo importar um projeto contido em um arquivo em formato .CSV para o modulo SIGAPMS

@author desconhecido

@since desconhecido

@version P11

@param nenhum

@return nenhum

/*/
Static Function A001Import()

Local aCalend
Local nx := 0
Local nY := 0
Local nCntCpo := 0

Local cCodEDT
Local cCodTrf

Local nPosCalend

Local nPosRevisa
Local nPosEdtPai
Local nPosConf
Local cEdtPAI	:=	""

Local nPosSep
Local nDelEDT
Local nDelTrf

Local lNewTrf := .T.

Local lNewEDT := .T.
Local aTipos  := {}
Local aCpoImp := {}
Local cLinha  := ""
Local cCpoFun := ""
Local nPosPredec := 0
Local cStartPath := GetSrvProfString("Startpath","")
Local cFile
Local aSelectEDT:={} 
Local aCopyTxt  := {}
Local lOk
Local nSepMilhar, nSepDec
Local nPosRecurs := 0
Local aVldEDTPrinc := {}

Private lUsaAJT		:= .F.
Private p_nX		:= 0
Private p_nCntCpo	:= 0
Private aRecAmarr	:= {}
Private nPosTarefa
Private nPosID
Private nPosComp
Private nPosTpVRel
Private cCadastro	:= "Importar arquivo .CSV"
Private aTxt        := {}
Private aParam       := {}
Private aRotina := {{"", "AxPesqui", 0, 1, , .F.}, ;
                    {"", "PMS200Dlg", 0, 2}, ;
                    {"", "PMS200Dlg", 0, 3}, ;
                    {"", "PMS200Alt", 0, 4}, ;
                    {"", "PMS200Dlg", 0, 4} }

If Right(cStartPath,1)  <> "\" .And. Right(cStartPath,1)  <> "/"
	cStartPath	:=	cStartPath+If(IsSrvUnix(),"/","\")
Endif	                                              

Inclui   := .T.
Altera   := .F.
lRefresh := .T.

aCamposExc := {"FILIAL","PROJET","EDT","TAREFA","DESCRI","NIVEL","HUTEIS","TPMEDI","START","FINISH","HORAI","HORAF"}

dbSelectArea("AF8")
AF8->(dbSetOrder(1))	
AF8->(dbGoTop())

If ParamBox({	{6,"Arquivo",SPACE(50),"","FILE(mv_par01)","", 55 ,.T.,"Arquivo .CSV |*.CSV"},;  //"Arquivo"###
			    {3,"Versao do Project",1,{"Portugues","Ingles","Espanhol"},70,,.F.},; //###### //
			    {1,"Projeto",SPACE(TamSX3("AF8_PROJET")[1]),"","dbSeek(xFilial('AF8')+AllTrim(mv_par03))","AF8","", 85 ,.F.},;
			    {3,"Separador Milhar",3,{"Ponto","Virgula","Nao Tem"},70,,.F.},;  //######
			    {3,"Separador Decimal",1,{"Virgula","Ponto"},70,,.F.} ;  //####
			    },"Importar .CSV" ,@aParam,,{{5,{|| A001CfgCol(aCamposExc)}}}) ////"Atualizar Projeto"
	
	If At(":", AllTrim(aParam[1])) > 0 .OR. Substr(AllTrim(aParam[1]),1,2) == "\\"
		cFile := cStartPath+CriaTrab(, .F.) + ".csv"
		__CopyFile(AllTrim(aParam[1]), cFile)
	Else
		cFile	:=	AllTrim(aParam[1])
	Endif
	
	
	If (nHandle := FT_FUse(cFile))== -1
		Help(" ",1,"NOFILEIMPOR")
		Return
	EndIf

	nSepMilhar := aParam[4]
	nSepDec := aParam[5]

	cMv1    := GetMv("MV_PMSIMP1")
	cMv2    := GetMv("MV_PMSIMP2")

	cMv1Aux := cMv1

	If !Empty(cMv1Aux) .And. SubStr(cMv1Aux,Len(cMv1Aux)-1,1) != "#"
		cMv1Aux += "#"
	EndIf

	cMv2Aux := cMv2

	If !Empty(cMv2Aux) .And. SubStr(cMv2Aux,Len(cMv2Aux)-1,1) != "#"
		cMv2Aux += "#"
	EndIf

	While Len(cMv1Aux) > 1
		nPosSep  := At("#",cMv1Aux)
		aAdd(aCpoImp,Substr(cMv1Aux,2,nPosSep-2))
		cMv1Aux := Substr(cMv1Aux,nPosSep+1,Len(cMv1Aux)-nPosSep)
	End
	While Len(cMv2Aux) > 1
		nPosSep  := At("#",cMv2Aux)
		aAdd(aCpoImp,Substr(cMv2Aux,2,nPosSep-2))
		cMv2Aux := Substr(cMv2Aux,nPosSep+1,Len(cMv2Aux)-nPosSep)
	End

 	nPosTarefa := aScan(aCpoImp,"$A001CODIGO")
	nPosNivel  := aScan(aCpoImp,"$A001NIVEL")
	nPosID     := aScan(aCpoImp,"$A001ID")
	nPosDescri := aScan(aCpoImp,"$A001DESCRI")
	nPosDataI  := aScan(aCpoImp,"$A001DATAI")
	nPosDataf  := aScan(aCpoImp,"$A001DATAF")
	nPosPredec := aScan(aCpoImp,"$A001PREDEC")
	nPosCalend := aScan(aCpoImp,"CALEND")
	nPosRevisa := aScan(aCpoImp,"REVISA")
	nPosEdtPai := aScan(aCpoImp,"EDTPAI")
	nPosQuant  := aScan(aCpoImp,"QUANT")
	nPosUM     := aScan(aCpoImp,"UM")
	nPosConf   := aScan(aCpoImp,"$A001CONF")
	nPosComp   := aScan(aCpoImp,"COMPUN")
	nPosTpVRel := aScan(aCpoImp,"TPVREL")
	nPosRecurs := aScan(aCpoImp,"$A001RECURS")

 	Do Case
	 	Case (nPosTarefa == 0) 
			Aviso("Estrutura .CSV Invalida","O campo 'código da Tarefa/EDT' é obrigatório existir na estrutura para a importação CSV possa funcionar corretamente.",{"Fechar"},2) //"Estrutura .CSV Invalida"### ###"Fechar"	 	
			Return
	 	Case (nPosNivel == 0)
			Aviso("Estrutura .CSV Invalida","O campo 'Nível de estrutura' é obrigatório existir na estrutura para a importação CSV possa funcionar corretamente.",{"Fechar"},2) //"Estrutura .CSV Invalida"### ###"Fechar"		
			Return
		Case (nPosID == 0)
			Aviso("Estrutura .CSV Invalida","O campo 'ID' é obrigatório existir na estrutura para a importação CSV possa funcionar corretamente.",{"Fechar"},2) //"Estrutura .CSV Invalida"### ###"Fechar"		
			Return
		Case (nPosDescri == 0)
			Aviso("Estrutura .CSV Invalida","O campo 'descrição' é obrigatório existir na estrutura para a importação CSV possa funcionar corretamente.",{"Fechar"},2) //"Estrutura .CSV Invalida"### ###"Fechar"		
			Return
		Case (nPosDataI == 0)
			Aviso("Estrutura .CSV Invalida","O campo 'Data Início' é obrigatório existir na estrutura para a importação CSV possa funcionar corretamente.",{"Fechar"},2) //"Estrutura .CSV Invalida"### ###"Fechar"
			Return
		Case (nPosDataf == 0)
			Aviso("Estrutura .CSV Invalida","O campo 'Data Final' é obrigatório existir na estrutura para a importação CSV possa funcionar corretamente.",{"Fechar"},2) //"Estrutura .CSV Invalida"### "O campo 'Data Final' é obrigatório existir na estrutura para a importação CSV possa funcionar corretamente."###"Fechar"
 			Return
	EndCase
	
	ProcRegua(FT_FLastRec())
	FT_FGOTOP()
	While !FT_FEOF()
		IncProc("Lendo Arquivo") //Lendo Arquivo
		cLinha := FT_FREADLN()
		AADD(aTxt,{})
		nCampo := 1
		While At("#",cLinha)>0
			aAdd(aTxt[Len(aTxt)],Substr(cLinha,1,At("#",cLinha)-1))
			nCampo ++
			cLinha := StrTran(Substr(cLinha,At("#",cLinha)+1,Len(cLinha)-At("#",cLinha)),'"','')
		End
		If Len(AllTrim(cLinha)) > 0
			aAdd(aTxt[Len(aTxt)],StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
		Else
			aAdd(aTxt[Len(aTxt)],"")
		Endif	
		FT_FSKIP()
	End
	FT_FUSE()
	If aParam[2] == 1
		aTipos := {"TI","II","TT","IT"}
	ElseIf aParam[2] ==3
		aTipos := {"FC","CC","FF","CF"}
	Else
		aTipos := {"FS","SS","FF","SF"}
	Endif	

	// [1][1] numerico, Quantidade de linhas com nivel de estrutura igual a zero
	// [1][2] array, As linhas em que o nivel de estrutura é igual a zero
	// [2][1] numerico, Quantidade de linhas com nivel de estrutura igual a 1
	// [2][2] array, As linhas em que o nivel de estrutura é igual a 1
	aVldEDTPrinc := {{0,{}},{0,{}}}
	
	ProcRegua(Len(aTxt))
	// loop para validar as informações do arquivo texto 
	For nX := 1 To Len(aTxt)
		
		IncProc("Analisando os dados...") //"Analisando os dados..."
		If ValType(aTxt) !='A' .OR. Len(aTxt[nx]) != Len(aCpoImp)
			Aviso("Estrutura .CSV Invalida","A quantidade de campos do arquivo .CSV difere do configurado. Utilize a Sincronizacao com o MS-Project para importar este projeto.",{"Fechar"},2) //"Estrutura .CSV Invalida"### "A quantidade de campos do arquivo .CSV difere do configurado. Utilize a Sincronizacao com o MS-Project para importar este projeto."###"Fechar"
			Return
		EndIf
		
       If Len(aTxt[nx][nPosTarefa]) > LEN(AF9->AF9_TAREFA)
			Aviso("Estrutura .CSV Invalida"+"O sistema nao suporta o tamanho do codigo da estrutura do .CSV . Utilize a Sincronizacao com o MS-Project para importar este projeto."+Str(nx),"STR0040",{"Fechar"},2) //"Estrutura .CSV Invalida"###"O sistema nao suporta o tamanho do codigo da estrutura do .CSV . Utilize a Sincronizacao com o MS-Project para importar este projeto."###"Fechar" //"Linha "
			Return
		EndIf
		
		//If (!aTxt[nX][nPosNivel] $ "000")
			//Este if foi feito para nao gerar erro de memoria, quando ocorrer reimportacao do projeto, se o mesmo foi utilizado com o project
			//If nX != 1 //!( (nX == 1 .OR. (nX==2 .AND. (Val(aTxt[nX,nPosNivel]) == 1))) .and. aTxt[nX][nPosNivel] $ "1/001" .and. !Empty(aParam[03]) .and. AllTrim(aTxt[nX][nPosTarefa]) == AllTrim(aParam[03]) ) .AND. Val(aTxt[nX,nPosNivel])<>0
				aAdd(aCopyTxt,aTxt[nX])
			//EndIf
		//EndIf
		
	Next nX

	//+---------------------------------------------------------------+
	//| Tratamento para importação de arquivo que inicie do nível 1   |
	//+---------------------------------------------------------------+
	/*
	If ( Val(aTxt[1][nPosNivel]) == 1 .Or.  Val(aTxt[1][nPosNivel]) == 0  ) .And. !Empty(aParam[03]) .And. ;
	(AllTrim(aTxt[1][nPosTarefa]) == AllTrim(aParam[03]) .OR. AllTrim(aTxt[2][nPosTarefa]) == AllTrim(aParam[03])) 
		
		ProcRegua(Len(aCopyTxt))
		For nX := 1 To Len(aCopyTxt)
			IncProc("Reorganizando os niveis...")//"Reorganizando os niveis..."
			//+---------------------------------------------------------+
			//| Decrementa todos os níves para manter a consistência da |
			//| rotina, pois as tarefas estavam ficando embaralhadas    |
			//| com arquivos iniciados no nível 1.                      |
			//+---------------------------------------------------------+
			If !Empty(aCopyTxt[nX][nPosNivel])
				aCopyTxt[nX][nPosNivel] := CValToChar( Val(aCopyTxt[nX][nPosNivel])-1 )
			EndIf
		Next nX
	EndIf
	*/		
	aTxt := aClone(aCopyTxt)
	
	If ExistBlock("PMA001VL")
		If !ExecBlock("PMA001VL",.F.,.F.,{aParam[3]})
			Return
		EndIf
	EndIf

	If Empty(aParam[3])
		nConfirma := AxInclui("AF8",1,3,,,,"Pms200Ok()",,"Pms200Atu()")
	Else
		nConfirma := AxVisual("AF8",Recno(),1)
	Endif

	If nConfirma == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define se o projeto usa composicoes aux   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If HasTemplate( "CCT" )
			lUsaAJT := AF8->AF8_USAAJT == "1"
		EndIf

		dbSelectArea("AFC")
		dbSetOrder(1)
		lNewEdt := If(dbSeek(xFilial("AFC")+AF8->AF8_PROJET+AF8->AF8_REVISA+AF8->AF8_PROJET),.F.,.T.)
		If lNewEdt
			PmsNewRec("AFC")
		Else
			RecLock("AFC",lNewEdt)
		EndIf
		AFC->AFC_FILIAL := xFilial("AFC")
		AFC->AFC_PROJET := AF8->AF8_PROJET
		AFC->AFC_REVISA := AF8->AF8_REVISA
		AFC->AFC_EDT    := AF8->AF8_PROJET
		AFC->AFC_NIVEL  := "001"
		AFC->AFC_DESCRI := AF8->AF8_DESCRI
		AFC->AFC_UM     := "UN"
		AFC->AFC_QUANT  := 1
		AFC->AFC_CALEND := AF8->AF8_CALEND
		AFC->AFC_EDTPAI := ""
		AFC->(MsUnlock())
		ProcRegua(Len(aTxt))
		aEdt	:=	{}		
		For nx := 1 to Len(aTxt)
			IncProc("importando linha"+Alltrim(Str(nX))+"de"+Alltrim(Str(Len(aTxt)) )) //importando linha # de
			cTrfAtu		:= ""
			If Val(aTxt[nx][nPosNivel]) == 1
				cEdtPAI	:= AF8->AF8_PROJET
			Else
				//nPosNivAnt	:=	Ascan(aEDT,{|x| x[2]==Val(aTxt[nx][nPosNivel])-1})
				//If nPosNivAnt > 0
				cEdtPai		:= aTxt[nx][nPosEdtPai]//aEDT[nPosEdtPai][1]
				//EndIf
			EndIf
			nPosNivAtu	:=	Ascan(aEDT,{|x| x[2]==Val(aTxt[nx][nPosNivel])})
			If nPosNivAtu > 0
				cTrfAtu		:= aEDT[nPosNivAtu][1]
			Endif
			lEmptyTar	:=	.F.
			If Empty(aTxt[nx][nPosTarefa])
				If (nx == Len(aTxt)) .or. (Val(aTxt[nx][nPosNivel]) >= Val(aTxt[nx+1][nPosNivel]))
					aTxt[nx][nPosTarefa]	 := PmsNumAF9(AF8->AF8_PROJET,AF8->AF8_REVISA,StrZero(Val(aTxt[nx][nPosNivel]),3),cEdtPai,cTrfAtu,.T.) 
				Else
					aTxt[nx][nPosTarefa]	 := PmsNumAFC(AF8->AF8_PROJET,AF8->AF8_REVISA,StrZero(Val(aTxt[nx][nPosNivel]),3),cEdtPai,cTrfAtu,.T.) 
				Endif			
				lEmptyTar	:=	.T.
			Endif

			If !Empty(aTxt[nx][nPosTarefa])
				If (nx == Len(aTxt)) .or. (Val(aTxt[nx][nPosNivel]) >= Val(aTxt[nx+1][nPosNivel]))
					dbSelectArea("AF9")
					dbSetOrder(1)
					lNewTrf := If(dbSeek(xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA+aTxt[nx][nPosTarefa]),.F.,.T.)
					If lNewTrf
						PmsNewRec("AF9")
					Else
						RecLock("AF9",lNewTrf)
					EndIf
					AF9->AF9_FILIAL	:= xFilial("AF9")
					AF9->AF9_PROJET	:= AF8->AF8_PROJET
					If lEmptyTar
						AF9->AF9_TAREFA	:= aTxt[nx][nPosTarefa]						
					Endif
					If nPosCalend == 0
						AF9->AF9_CALEND	:= AF8->AF8_CALEND
					EndIf

					// Se usa template CCT, grava o campo de composicoes aux
					If lUsaAJT
						AF9->AF9_COMPUN := aEDT[nPosComp][1]
					EndIf

					If nPosEdtPai == 0
						// Se for o 1o nivel a EDT PAI da tarefa é o código do projeto
						If Val(aTxt[nx][nPosNivel]) == 1
							AF9->AF9_EDTPAI	:= AF8->AF8_PROJET
						Else
							nPosNivAnt	:=	Ascan(aEDT,{|x| x[2]==Val(aTxt[nx][nPosNivel])-1})
							If nPosNivAnt > 0
								AF9->AF9_EDTPAI	:= aEDT[nPosNivAnt][1]
							EndIf
							nPosNivAtu	:=	Ascan(aEDT,{|x| x[2]==Val(aTxt[nx][nPosNivel])})
							If nPosNivAtu > 0
								aEDT[nPosNivAtu][1] := AF9->AF9_TAREFA
							EndIf
						EndIf
					Endif
					If nPosRevisa == 0
						AF9->AF9_REVISA	:= AF8->AF8_REVISA
					EndIf
					If nPosQuant == 0
						AF9->AF9_QUANT := 1
					EndIf
					If nPosUM == 0
						AF9->AF9_UM := "UN"
					EndIf                    
					For nCntCpo := 1 to Len(aCpoImp)
						If Substr(aCpoImp[nCntCpo],1,1) == "$"
							If aCpoImp[nCntCpo] <> "$A001ID" .And.aCpoImp[nCntCpo] <> "$A001RECURS" .And.aCpoImp[nCntCpo] <> "$A001PREDEC"       
								p_nX 	  := nX
								p_nCntCpo := nCntCpo
								If aCpoImp[nCntCpo] == "$A001TPREST"
									cCpoFun := Substr(aCpoImp[nCntCpo],2,Len(aCpoImp[nCntCpo])-1) + '("AF9",aTxt[p_nX][p_nCntCpo],aParam[2],aTxt,p_nX)'
									&(cCpoFun)
								Else
									cCpoFun := Substr(aCpoImp[nCntCpo],2,Len(aCpoImp[nCntCpo])-1) + '("AF9",aTxt[p_nX][p_nCntCpo])'
									&(cCpoFun)
								EndIf
								
							EndIf
						Else
							dbSelectArea("AF9")
							cCampo1 := "AF9_" + aCpoImp[nCntCpo]
							If FieldPos(cCampo1) > 0
								If ValType(&cCampo1) == "N"
									If nSepMilhar == 1 .And. nSepDec = 1 //separador milhar = ponto e separador decimal = virgula
										&cCampo1 := Val( StrTran(StrTran(aTxt[nx][nCntCpo], "." , ""), "," , ".") )
									ElseIf  nSepMilhar == 2 .And. nSepDec = 2 //separador milhar = virgula e separador decimal = ponto
										&cCampo1 := Val( StrTran(aTxt[nx][nCntCpo], "," , "") )
									Else
										&cCampo1 := Val( StrTran(aTxt[nx][nCntCpo], "," , ".") )
									EndIf
								ElseIf ValType(&cCampo1) == "D"
									aDtHrImp := ConvDtHrImp(aTxt[nx][nCntCpo],aParam[2])
									&cCampo1 := aDtHrImp[1]
								Else
									&cCampo1 := aTxt[nx][nCntCpo]
								EndIf
							EndIf
						EndIf
					Next
					MsUnlock()
					If AF9->AF9_START==AF9->AF9_FINISH
						nDuracao := PmsHrUtil(AF9->AF9_START,"00"+AF9->AF9_HORAI,"00"+AF9->AF9_HORAF,AF9->AF9_CALEND)
					Else
						nDuracao := 0
						dStart	:= AF9->AF9_START
						dFinish	:= AF9->AF9_FINISH
						nDuracao := PmsHrUtil(AF9->AF9_START,"00"+AF9->AF9_HORAI,"0024:00",AF9->AF9_CALEND,aCalend,AF8->AF8_PROJET)
						dStart++
						While dStart <= dFinish
							If dStart==dFinish
								nDuracao += PmsHrUtil(dStart,"0000:00","00"+AF9->AF9_HORAF,AF9->AF9_CALEND,aCalend,AF8->AF8_PROJET)
							Else
								nDuracao += PmsHrUtil(dStart,"0000:00","0024:00",AF9->AF9_CALEND,aCalend,AF8->AF8_PROJET)
							EndIf
							dStart++
						End
					EndIf
					RecLock("AF9")
					AF9->AF9_HDURAC := nDuracao
					AF9->AF9_HUTEIS := nDuracao
					
					If nPosRecurs > 0 // existe a coluna "$A001RECURS"
						p_nX 	  := nX
						p_nCntCpo := nPosRecurs
						cCpoFun := Substr(aCpoImp[nPosRecurs],2,Len(aCpoImp[nPosRecurs])-1) + '("AF9",aTxt[p_nX][p_nCntCpo],aParam[2],aTxt,p_nX)'
						&(cCpoFun)
					EndIf


					MsUnlock()
					// Se existir check list
				
					If !Empty(AF9->AF9_TIPPAR) .And. GetNewPar("MV_PMSCHKA","2")=="1" .And. Empty(AF9->AF9_CHKLST)
						dbSelectArea("AJQ")
						dbSetOrder(2)
						If AJQ->(MsSeek(xFilial("AJQ")+AF9->AF9_TIPPAR))
							RecLock("AF9")
							AF9->AF9_CHKLST := AJQ->AJQ_CODIGO
							MsUnlock()
							lOk := .T.
							If !Empty(AF9->AF9_DTATUI) .And. !lNewTrf
								lOk := .F.
							EndIf

							If lOk
								dbSelectArea("AJO")
								dbSetOrder(1)
								AJO->(MsSeek(xFilial("AJO")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
								Do While lOk .And. !AJO->(Eof()) .And. AJO->(AJO_FILIAL+AJO_PROJET+AJO_REVISA+AJO_TAREFA)==xFilial("AJO")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
									If !Empty(AJO->AJO_INI)
										lOk := .f.
									EndIf
									AJO->(dbSkip())
								EndDo
							EndIf	

							If lOk
								// Apaga itens antigos
								dbSelectArea("AJO")
								dbSetOrder(1)
								AJO->(MsSeek(xFilial("AJO")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
								Do While !AJO->(Eof()) .And. AJO->(AJO_FILIAL+AJO_PROJET+AJO_REVISA+AJO_TAREFA)==xFilial("AJO")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
									RecLock("AJO",.F.,.T.)
									dbDelete()
									MsUnlock()
									AJO->(dbSkip())
								EndDo
								// grava arquivo AJO (Tarefa X Itens Check List)
								dbSelectArea("AJN")
								dbSetOrder(1)
								AJN->(MsSeek(xFilial("AJN")+AF9->AF9_CHKLST))
								nY := 1
								Do While !AJN->(Eof()) .And. AJN->(AJN_FILIAL+AJN_CODIGO)==xFilial("AJN")+AF9->AF9_CHKLST
									RecLock("AJO",.T.)
									AJO->AJO_FILIAL	:= xFilial("AJO")
									AJO->AJO_PROJET	:= AF9->AF9_PROJET
									AJO->AJO_REVISA := AF9->AF9_REVISA
									AJO->AJO_TAREFA	:= AF9->AF9_TAREFA
									AJO->AJO_ORDEM	:= StrZero(ny,TamSX3("AJO_ORDEM")[1])
									AJO->AJO_ITEM	:= AJN->AJN_ITEM
									AJO->AJO_OBRIGA := AJN->AJN_OBRIGA
									AJO->AJO_REPEXE := AJN->AJN_REPEXE
									MsUnlock()
									AJN->(dbSkip())
									nY++
								EndDo
							EndIf
						EndIf
						dbSelectArea("AF9")
					EndIf
				Else                
					dbSelectArea("AFC")
					dbSetOrder(1)
					lNewEDT := If(dbSeek(xFilial("AFC")+AF8->AF8_PROJET+AF8->AF8_REVISA+PadR(aTxt[nx][nPosTarefa],Len( AFC->AFC_EDT ))),.F.,.T.)
					If lNewEdt
						PmsNewRec("AFC")
					Else
						RecLock("AFC",lNewEdt)
					EndIf
					AFC->AFC_FILIAL	:= xFilial("AFC")
					AFC->AFC_PROJET	:= AF8->AF8_PROJET
					If nPosCalend == 0
						AFC->AFC_CALEND	:= AF8->AF8_CALEND
					EndIf
					If nPosRevisa == 0
						AFC->AFC_REVISA	:= AF8->AF8_REVISA
					EndIf
					If nPosQuant == 0
						AFC->AFC_QUANT := 1
					EndIf
					If nPosUM == 0
						AFC->AFC_UM := "UN"
					EndIf
					If lEmptyTar
						AFC->AFC_EDT	:= aTxt[nx][nPosTarefa]
					Endif
					
					For nCntCpo := 1 to Len(aCpoImp)
						If Substr(aCpoImp[nCntCpo],1,1) == "$"
							If aCpoImp[nCntCpo] <> "$A001ID" .and. aCpoImp[nCntCpo] <> "$A001PREDEC"        
								p_nX 	  := nX
								p_nCntCpo := nCntCpo
								cCpoFun := Substr(aCpoImp[nCntCpo],2,Len(aCpoImp[nCntCpo])-1) + '("AFC",aTxt[p_nX][p_nCntCpo])'
								&(cCpoFun)
							
							EndIf
						Else
							dbSelectArea("AFC")
							cCampo1 := "AFC_" + aCpoImp[nCntCpo]
							If FieldPos(cCampo1) > 0
								If ValType(&cCampo1) == "N"
									If nSepMilhar == 1 .And. nSepDec = 1 //separador milhar = ponto e separador decimal = virgula
										&cCampo1 := Val( StrTran(StrTran(aTxt[nx][nCntCpo], "." , ""), "," , ".") )
									ElseIf  nSepMilhar == 2 .And. nSepDec = 2 //separador milhar = virgula e separador decimal = ponto
										&cCampo1 := Val( StrTran(aTxt[nx][nCntCpo], "," , "") )
									Else
										&cCampo1 := Val( StrTran(aTxt[nx][nCntCpo], "," , ".") )
									EndIf
								ElseIf ValType(&cCampo1) == "D"
									aDtHrImp := ConvDtHrImp(aTxt[nx][nCntCpo],aParam[2])
									&cCampo1 := aDtHrImp[1]
								Else
									&cCampo1 := aTxt[nx][nCntCpo]
								EndIf
							EndIf
							If Val(aTxt[nx][nPosNivel]) == 1
								AFC->AFC_EDTPAI	:= AF8->AF8_PROJET
							EndIf
						EndIf
					Next nCntCpo
					
					If nPosEdtPai == 0
						If Val(aTxt[nx][nPosNivel]) == 1
							AFC->AFC_EDTPAI	:= AF8->AF8_PROJET
							aEDT	:= {}
							aAdd(aEDT,{AFC->AFC_EDT,1})
						Else
							nPosNivAnt	:=	Ascan(aEDT,{|x| x[2]==Val(aTxt[nx][nPosNivel])-1})
							If nPosNivAnt > 0
								AFC->AFC_EDTPAI	:= aEDT[nPosNivAnt][1]
							EndIf
							nPosNivAtu	:= Ascan(aEDT,{|x| x[2]==Val(aTxt[nx][nPosNivel])})
							If nPosNivAtu == 0           
								// Tratamento para a EDT principal(PROJETO) do arquivo CSV
								If(Val(aTxt[nx][nPosNivel])==0)
									AFC->AFC_NIVEL := "002"
									AFC->AFC_EDTPAI := AF8->AF8_PROJET
								else
									aAdd(aEDT,{AFC->AFC_EDT,Val(aTxt[nx][nPosNivel])  } )								
								Endif                                                     
								////////
							ElseIf nPosNivAtu >0 
								If Val(aTxt[nx][nPosNivel]) > Len(aEDT)
									aAdd(aEDT,{AFC->AFC_EDT,Val(aTxt[nx][nPosNivel])})
								Else
									aEDT[nPosNivAtu][1] := AFC->AFC_EDT
								EndIf
							EndIf
						EndIf
					Endif
				
					MsUnLock()
				EndIf
				aSort(aEDT,,,{|x,y| x[2] < y[2]})
				If Val(aTxt[nx][nPosNivel])<Len(aEDT)
					aSize(aEdt,Val(aTxt[nx][nPosNivel]))
				Endif	
			EndIf
		Next nx         
		ProcRegua(Len(aTxt))	
		If nPosPredec > 0
			For nx := 1 to Len(aTxt)
				IncProc("Analisando predecessoras - Tarefa"+Alltrim(Str(nX))+"de"+Alltrim(Str(Len(aTxt)))) //Analisando predecessoras - Tarefa # de 
				If !Empty(aTxt[nx][nPosTarefa])
					dbSelectArea("AF9")
					dbSetOrder(1)
					If dbSeek(xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA+aTxt[nx][nPosTarefa])
						p_nX 	  := nx
						p_nCntCpo := nPosPredec
						cCpoFun := Substr(aCpoImp[nPosPredec],2,(Len(aCpoImp[nPosPredec]))-1) + '("AF9",aTxt[p_nX][p_nCntCpo],aParam[2],aTxt,p_nX)'
						&(cCpoFun)
					Endif
				Else
					dbSelectArea("AFC")
					dbSetOrder(1)
					If dbSeek(xFilial("AFC")+AF8->AF8_PROJET+AF8->AF8_REVISA+aTxt[nx][nPosTarefa])  
						p_nX 	  := nx
						p_nCntCpo := nPosPredec
						cCpoFun := Substr(aCpoImp[nPosPredec],2,(Len(aCpoImp[nPosPredec]))-1) + '("AFC",aTxt[p_nX][p_nCntCpo],aParam[2],aTxt,p_nX)'			
						&(cCpoFun)
					EndIf
				EndIf
			Next nx       
		EndIf
		/*
		ProcRegua(7)
		dbSelectArea("AF9")
		dbSetOrder(1)
		dbSeek(xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA)
		IncProc(STR0062)    //Excluindo tarefas não importadas...
		While !Eof() .And. xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA==AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA
			cCodTrf := AF9->AF9_TAREFA
			If (nDelTrf := aScan(aTxt,{|x| AllTrim(x[nPosTarefa]) == AllTrim(cCodTrf)})) == 0
				MaDelAF9(,,,AF9->(RecNo()),.F.)
			EndIf
			dbSkip()
		EndDo

		dbSelectArea("AFC")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA)
		IncProc(STR0063) //"Excluindo EDTs não importadas..."
		While !Eof() .And. xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA==AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA
			If AFC->AFC_NIVEL <> "001"
				cCodEDT := AFC->AFC_EDT
				If (nDelEDT := aScan(aTxt,{|x| AllTrim(x[nPosTarefa]) == AllTrim(cCodEDT)})) == 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica a existencia de registros no AFQ e efetua a exclusao   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("AFQ")
					dbSetOrder(1)
					MsSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
					While !Eof() .And. xFilial("AFQ")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT==;
						AFQ->AFQ_FILIAL+AFQ->AFQ_PROJET+AFQ->AFQ_REVISA+AFQ->AFQ_EDT
						RecLock("AFQ",.F.,.T.)
						dbDelete()
						MsUnlock()
						dbSkip()
					EndDo
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica a existencia de registros no AFX e efetua a exclusao   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("AFX")
					dbSetOrder(1)
					MsSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
					While !Eof() .And. xFilial("AFX")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT==;
						AFX->AFX_FILIAL+AFX->AFX_PROJET+AFX->AFX_REVISA+AFX->AFX_EDT
						RecLock("AFX",.F.,.T.)
						dbDelete()
						MsUnlock()
						dbSkip()
					EndDo

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica a existencia de registros no AFX e efetua a exclusao   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("AFX")
					dbSetOrder(1)
					MsSeek(xFilial()+AFC->AFC_PROJET+SPACE(LEN(AFX->AFX_REVISA))+AFC->AFC_EDT)
					While !Eof() .And. xFilial("AFX")+AFC->AFC_PROJET+SPACE(LEN(AFX->AFX_REVISA))+AFC->AFC_EDT==;
						AFX->AFX_FILIAL+AFX->AFX_PROJET+AFX->AFX_REVISA+AFX->AFX_EDT
						RecLock("AFX",.F.,.T.)
						dbDelete()
						MsUnlock()
						dbSkip()
					EndDo
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica a existencia de registros no AFP e efetua a exclusao   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("AFP")
					dbSetOrder(2)
					MsSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
					While !Eof() .And. xFilial("AFP")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT==;
						AFP->AFP_FILIAL+AFP->AFP_PROJET+AFP->AFP_REVISA+AFP->AFP_EDT
						RecLock("AFP",.F.,.T.)
						PMSAvalAFP("AFP",3,2)
						dbDelete()
						MsUnlock()
						dbSkip()
					EndDo
					
					dbSelectArea("AFT")
					dbSetOrder(4)
					MsSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
					While !Eof() .And. xFilial("AFT")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT==;
						AFT->AFT_FILIAL+AFT->AFT_PROJET+AFT->AFT_REVISA+AFT->AFT_EDT
						RecLock("AFT",.F.,.T.)
						dbDelete()
						MsUnlock()
						dbSkip()
					EndDo
					
					dbSelectArea("SC6")
					dbSetOrder(8)
					MsSeek(xFilial()+AFC->AFC_PROJET+SPACE(LEN(SC6->C6_TASKPMS))+AFC->AFC_EDT)
					While !Eof() .And. xFilial("SC6")+AFC->AFC_PROJET+SPACE(LEN(SC6->C6_TASKPMS))+AFC->AFC_EDT==;
						SC6->C6_FILIAL+SC6->C6_PROJPMS+SC6->C6_TASKPMS+SC6->C6_EDTPMS
						RecLock("SC6",.F.)
						SC6->C6_PROJPMS	:= ""
						SC6->C6_EDTPMS	:= ""
						MsUnlock()
						dbSelectArea("SC9")
						dbSetOrder(1)
						MsSeek(xFilial()+SC6->C6_NUM+SC6->C6_ITEM)
						While !Eof() .And. xFilial()+SC6->C6_NUM+SC6->C6_ITEM==SC9->C9_PEDIDO+SC9->C9_ITEM
							RecLock("SC9",.F.)
							SC9->C9_PROJPMS	:= ""
							SC9->C9_EDTPMS	:= ""
							MsUnlock()
							dbSelectArea("SC9")
							dbSkip()
						End
						dbSelectArea("SC6")
						dbSkip()
					EndDo
										
					dbSelectArea("SE5")
					dbSetOrder(9)
					MsSeek(xFilial("SE5")+AFC->AFC_PROJET+AFC->AFC_EDT)
					While !Eof() .And. SE5->E5_FILIAL+SE5->E5_PROJPMS+SE5->E5_EDTPMS == xFilial("SE5")+AFC->AFC_PROJET+AFC->AFC_EDT
						RecLock("SE5",.F.)
						SE5->E5_PROJPMS	:= ""
						SE5->E5_EDTPMS	:= ""
						MsUnlock()
						dbSelectArea("SE5")
						dbSkip()
					End
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica a existencia de registros no AFS e efetua a exclusao   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("AFS")
					dbSetOrder(3)
					MsSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
					While !Eof() .And. xFilial("AFS")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT==;
						AFS->AFS_FILIAL+AFS->AFS_PROJET+AFS->AFS_REVISA+AFS->AFS_EDT
						RecLock("AFS",.F.,.T.)
						dbDelete()
						MsUnlock()
						dbSkip()
					EndDo
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica a existencia de registros no AJ5 e efetua a exclusao   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("AJ5")
					dbSetOrder(1)
					MsSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
					While !Eof() .And. xFilial("AJ5")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT==;
						AJ5->AJ5_FILIAL+AJ5->AJ5_PROJET+AJ5->AJ5_REVISA+AJ5->AJ5_EDT
						RecLock("AJ5",.F.,.T.)
						dbDelete()
						MsUnlock()
						dbSkip()
					EndDo
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica a existencia de registros no AJ6 e efetua a exclusao   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("AJ6")
					dbSetOrder(1)
					MsSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
					While !Eof() .And. xFilial("AJ6")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT==;
						AJ6->AJ6_FILIAL+AJ6->AJ6_PROJET+AJ6->AJ6_REVISA+AJ6->AJ6_EDT
						RecLock("AJ6",.F.,.T.)
						dbDelete()
						MsUnlock()
						dbSkip()
					EndDo
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exclui o refistro do AFC                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("AFC")
					RecLock("AFC",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
			PmsIncProc(.T.)	
			dbSelectArea("AFC")
			dbSkip()
		End	
		dbSelectArea("AFD")
		dbSetOrder(1)
		dbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA)
		IncProc(STR0064) //"Excluindo relacionamentos de tarefas não importados..."
		While !Eof() .And. xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA==AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA	
			dbSelectArea("AF9")
			dbSetOrder(1)
			If !dbSeek(xFilial()+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC)
				RecLock("AFD",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
			dbSelectArea("AFD")
			dbSkip()
		End

		dbSelectArea("AJ4")
		dbSetOrder(1)
		dbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA)
		IncProc(STR0065) //"Excluindo relacionamentos de EDTs não importados..."
		While !Eof() .And. xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA==AJ4->AJ4_FILIAL+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA	
			dbSelectArea("AFC")
			dbSetOrder(1)
			If !dbSeek(xFilial()+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_PREDEC)
				RecLock("AJ4",.F.,.T.)                 
				dbDelete()
				MsUnlock()
			EndIf
			dbSelectArea("AJ4")
			dbSkip()
		EndDo
		*/	
		//Atualizacao de acumulados e progresso
		IncProc("Carregando EDTs para atualizar acumulados...") //"Carregando EDTs para atualizar acumulados..."
		PmsLoadEDT(AF8->AF8_PROJET, AF8->AF8_REVISA, Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)), .T., .T., @aSelectEDT) // Carrega as EDT's filhas mais a edt informada
	
		If !Empty(aSelectEDT)
			aSort(aSelectEDT,,, {|x, y| y[2] < x[2] })
			IncProc("Atualizando acumulados previstos...") //"Atualizando acumulados previstos..."
			PmsEdtPrv(AF8->AF8_PROJET, AF8->AF8_REVISA, Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)), aSelectEDT)
			IncProc("Atualizando acumulados realizados...") //"Atualizando acumulados realizados..."
			PMSEdtReal(AF8->AF8_PROJET, AF8->AF8_REVISA, Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)), aSelectEDT)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada para validacao na finalizacao da importacao³
		//³do arquivo texto.                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("PMA001FIM")
			ExecBlock("PMA001FIM",.F.,.F.)
		EndIf
	Endif
	fClose(nHandle)
	
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A001CfgCol ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 10-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Configuracao das colunas do projeto a serem importadas do     ³±±
±±³          ³MS-Project para o Siga.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array com os campos padroes                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A001CfgCol(aCamposExc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nx := 0
Local nCnt1 := 0
Local nCnt2 := 0
Local nCampos1
Local nCampos2
Local nPos1      := 0
Local nPos2      := 0
Local cCampoAux
Local aCampos1   := {}
Local aCampos2   := {}
Local aCamposA   := {}
Local aCamposB   := {}
Local aBtn       := Array(6)
Local oCampos1
Local oCampos2
Local oBtn1
Local oBtn2
Local lCampos1   := .T.
Local lCampos2   := .F.
Local aFunc		 := { 	{"*Codigo da EDT/Tarefa","$A001CODIGO"},; //"*Codigo da EDT/Tarefa"
						{"*Nivel da Estrutura de Topicos","$A001NIVEL"},; //"*Nivel da Estrutura de Topicos"
						{"*Descricao da EDT/Tarefa","$A001DESCRI"},; //"*Descricao da EDT/Tarefa"
						{"*Data e Hora Inicial da EDT/Tarefa","$A001DATAI"},; //"*Data e Hora Inicial da EDT/Tarefa"
						{"*Data e Hora Final da EDT/Tarefa","$A001DATAF"},; //"*Data e Hora Final da EDT/Tarefa"
						{"*Predecessoras","$A001PREDEC"},; //"*Predecessoras"
						{"*ID","$A001ID"} ; //"*ID"
					}
Local aFuncNO    := {	{"%Concluido","$A001CONF"} ,; //"%Concluido"
                        {"Tipo Restricao","$A001TPREST" },; // "Tipo Restricao"
						{"Nome dos Recursos","$A001RECURS" } ; //"Nome dos Recursos"
                    } 

Local lA001UsrBlk := ExistBlock("PM001Blk")
Local lRetUsrBlk  := .F.

DEFAULT aCamposExc := {"FILIAL"}

nOrdSX3  := SX3->(IndexOrd())
nRegSX3  := SX3->(Recno())

cPln1SX6 := GetMv("MV_PMSIMP1")
cPln2SX6 := GetMv("MV_PMSIMP2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do array de campos selecionados                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While At("#",cPln1SX6) <> 0
	nPosSep := At("#",cPln1SX6)
	aAdd(aCampos2,{,})
	aCampos2[Len(aCampos2)][2] := AllTrim(Substr(cPln1Sx6,2,nPosSep-2))
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("AF9"+"_"+aCampos2[Len(aCampos2)][2])
		aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
	ElseIf dbSeek("AFC"+"_"+aCampos2[Len(aCampos2)][2])
		aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
	ElseIf dbSeek("AFD"+"_"+aCampos2[Len(aCampos2)][2])
		aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
	Else
		nPosFunc := aScan(aFunc,{|x| AllTrim(x[2])==AllTrim(aCampos2[Len(aCampos2)][2])}) 
		If nPosFunc > 0
			aCampos2[Len(aCampos2)][1] := aFunc[nPosFunc][1]
		Else
			nPosFunc := aScan(aFuncNO,{|x| AllTrim(x[2])==AllTrim(aCampos2[Len(aCampos2)][2])}) 
			If nPosFunc > 0
				aCampos2[Len(aCampos2)][1] := aFuncNO[nPosFunc][1]
			EndIf
		EndIf
	Endif
	cPln1Sx6 := Substr(cPln1SX6,nPosSep+1,Len(cPln1SX6)-nPosSep)
End
While At("#",cPln2SX6) <> 0
	nPosSep := At("#",cPln2SX6)
	aAdd(aCampos2,{,})
	aCampos2[Len(aCampos2)][2] := AllTrim(Substr(cPln2Sx6,2,nPosSep-2))
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("AF9"+"_"+aCampos2[Len(aCampos2)][2])
		aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
	ElseIf dbSeek("AFC"+"_"+aCampos2[Len(aCampos2)][2])
		aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
	ElseIf dbSeek("AFD"+"_"+aCampos2[Len(aCampos2)][2])
		aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
	Else
		nPosFunc := aScan(aFunc,{|x| AllTrim(x[2])==AllTrim(aCampos2[Len(aCampos2)][2])}) 
		If nPosFunc > 0
			aCampos2[Len(aCampos2)][1] := aFunc[nPosFunc][1]
		Else
			nPosFunc := aScan(aFuncNO,{|x| AllTrim(x[2])==AllTrim(aCampos2[Len(aCampos2)][2])}) 
			If nPosFunc > 0
				aCampos2[Len(aCampos2)][1] := aFuncNO[nPosFunc][1]
			EndIf
		EndIf
	Endif
	cPln2Sx6 := Substr(cPln2SX6,nPosSep+1,Len(cPln2SX6)-nPosSep)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do array de campos disponiveis                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
If (dbSeek("AF9"))
	While SX3->X3_ARQUIVO == "AF9"
		If (X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL ).Or. SX3->X3_CAMPO == "AF9_DTREST"
			cCampoAux := AllTrim(Substr(SX3->X3_CAMPO,5,6))
			If Len(aCampos1) <> 0
				If  (nPosCampo := aScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
				Endif
			Else
				If  (nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
				Endif
			Endif
		Endif
		dbSkip()
	End
Endif

If (dbSeek("AFC"))
	While SX3->X3_ARQUIVO == "AFC"
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			cCampoAux := AllTrim(Substr(SX3->X3_CAMPO,5,6))
			If Len(aCampos1) <> 0
				If  (nPosCampo := aScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
				Endif
			Else
				If  (nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
				Endif
			Endif
		Endif
		dbSkip()
	End
Endif

If (dbSeek("AFD"))
	While SX3->X3_ARQUIVO == "AFD"
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			cCampoAux := AllTrim(Substr(SX3->X3_CAMPO,5,6))
			If Len(aCampos1) <> 0
				If  (nPosCampo := aScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
				Endif
			Else
				If  (nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
				Endif
			Endif
		Endif
		dbSkip()
	End
Endif

For nx := 1 to Len(aFunc)
	If Len(aCampos1) <> 0
		If  (nPosCampo := aScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := aScan(aCamposExc,aFunc[nx][2])) == 0
			aAdd(aCampos1,{aFunc[nx][1],aFunc[nx][2]})
		Endif
	Else
		If  (nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := aScan(aCamposExc,aFunc[nx][2])) == 0
			aAdd(aCampos1,{aFunc[nx][1],aFunc[nx][2]})
		Endif
	Endif
Next

For nx := 1 to Len(aFuncNO)
	If Len(aCampos1) <> 0
		If  (nPosCampo := aScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(aFuncNO[nx][2])})) == 0 .And.;
			(nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFuncNO[nx][2])})) == 0 .And.;
			(nPosCampo := aScan(aCamposExc,aFuncNO[nx][2])) == 0
			aAdd(aCampos1,{aFuncNO[nx][1],aFuncNO[nx][2]})
		Endif
	Else
		If  (nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFuncNO[nx][2])})) == 0 .And.;
			(nPosCampo := aScan(aCamposExc,aFuncNO[nx][2])) == 0
			aAdd(aCampos1,{aFuncNO[nx][1],aFuncNO[nx][2]})
		Endif
	Endif
Next                                              

aSort(aCampos1,,, {|x,y| x[1] < y[1]})
aCampos3 := aClone(aCampos1)
aCampos4 := aClone(aCampos2)
aCamposA  := {}
aCamposB  := {}
For nCnt1 := 1 to Len(aCampos1)
	aAdd(aCamposA,aCampos1[nCnt1][1])
Next
For nCnt2 := 1 to Len(aCampos2)
	aAdd(aCamposB,aCampos2[nCnt2][1])
Next

If lA001UsrBlk
	lRetUsrBlk := ExecBlock("PM001Blk",.F.,.F.)
	If ValType(lRetUsrBlk) <> "L"
		lRetUsrBlk := .T.
	EndIf 
EndIf

DEFINE MSDIALOG oDlg1 FROM 00,00 TO 300,520 TITLE "Selecione os campos" PIXEL  //"Selecione os campos"

@08,05  SAY "Campos Disponiveis" PIXEL OF oDlg1  //"Campos Disponiveis"
@08,143 SAY "Campos Selecionados" PIXEL OF oDlg1 //"Campos Selecionados"
@45,240 SAY "Mover" PIXEL OF oDlg1 //"Mover"
@50,237 SAY "Campos" PIXEL OF oDlg1 //"Campos"

@16,05  LISTBOX oCampos1 VAR nCampos1 ITEMS aCamposA SIZE 90,110 ON DBLCLICK;
AddFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nPos1,nPos2) PIXEL OF oDlg1 WHEN IIf(lA001UsrBlk,lRetUsrBlk,.T.)
oCampos1:SetArray(aCamposA)
oCampos1:bChange    := {|| nCampos2 := 0,nPos1:=oCampos1:nAT,oCampos2:Refresh(),lCampos1 := .T.,lCampos2 := .F.}
oCampos1:bGotFocus  := {|| lCampos1 := .T.,lCampos2 := .F.}

@16,143 LISTBOX oCampos2 VAR nCampos2 ITEMS aCamposB SIZE 90,110 ON DBLCLICK;
DelFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nPos1,nPos2,aFunc) PIXEL OF oDlg1 WHEN IIf(lA001UsrBlk,lRetUsrBlk,.T.)
oCampos2:SetArray(aCamposB)
oCampos2:bChange    := {|| nCampos1 := 0,nPos2:=oCampos2:nAT,oCampos1:Refresh(),lCampos1 := .F.,lCampos2 := .T.}
oCampos2:bGotFocus  := {|| lCampos1 := .F.,lCampos2 := .T.}

@16,98  BUTTON aBtn[1] PROMPT " Add.Todos >>" SIZE 42,11 PIXEL; //" Add.Todos >>"
ACTION AddAllFld(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) WHEN IIf(lA001UsrBlk,lRetUsrBlk,.T.)

@28,98  BUTTON aBtn[2] PROMPT "&Adicionar >>" SIZE 42,11 PIXEL; //"&Adicionar >>"
ACTION AddFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nPos1,nPos2) WHEN ( lCampos1 .and. IIf(lA001UsrBlk,lRetUsrBlk,.T.) )

@40,98  BUTTON aBtn[3] PROMPT "<< &Remover " SIZE 42,11 PIXEL; //"<< &Remover "
ACTION DelFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nPos1,nPos2,aFunc) WHEN ( lCampos2 .and. IIf(lA001UsrBlk,lRetUsrBlk,.T.) )

@52,98  BUTTON aBtn[4] PROMPT "<< Rem.Todos" SIZE 42,11 PIXEL; //"<< Rem.Todos"
ACTION DelAllFld(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,aFunc) WHEN IIf(lA001UsrBlk,lRetUsrBlk,.T.)

@115,98 BUTTON aBtn[5] PROMPT "  Restaurar " SIZE 42,11 PIXEL; //"  Restaurar "
ACTION RestFields(@aCampos1,oCampos1,@aCampos2,oCampos2,aCampos3,aCampos4,@aCamposA,@aCamposB) WHEN IIf(lA001UsrBlk,lRetUsrBlk,.T.)

@115,480 BTNBMP oBtn1 RESOURCE BMP_SETA_UP   SIZE 25,25 ACTION UpField(@aCampos2,oCampos2,@aCamposB,nPos2);
MESSAGE "Mover campo para cima" WHEN lCampos2 //"Mover campo para cima"

@140,480 BTNBMP oBtn2 RESOURCE BMP_SETA_DOWN SIZE 25,25 ACTION DwField(@aCampos2,oCampos2,@aCamposB,nPos2);
MESSAGE "Mover campo para baixo" WHEN lCampos2 //"Mover campo para baixo"

DEFINE SBUTTON FROM 130,175 TYPE 1 ENABLE OF oDlg1 ACTION {|| GravaMvSX6(aCampos2,{"MV_PMSIMP1","MV_PMSIMP2"}),oDlg1:End()}
DEFINE SBUTTON FROM 130,205 TYPE 2 ENABLE OF oDlg1 ACTION oDlg1:End()

ACTIVATE DIALOG oDlg1 CENTERED

dbSelectArea("SX3")
dbSetOrder(nOrdSX3)
dbGoTo(nRegSX3)

Return Nil



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddFields  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move campo disponivel para array de campos selecionados       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddFields(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB,nPos1,nPos2,aFunc)
Local nCnt1 := 0
Local nCnt2 := 0

If nPos1 <> 0 .And. Len(aCampos1) <> 0
	aAdd(aCampos2,{aCampos1[nPos1][1],aCampos1[nPos1][2]})
	aDel(aCampos1,nPos1)
	aSize(aCampos1,Len(aCampos1)-1)
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2][1])
	Next
	oCampos1:SetArray(aCamposA)
	oCampos1:nAt := 1
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Refresh()
	oCampos1:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelFields  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move campo selecionados para array de campos disponiveis      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DelFields(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB,nPos1,nPos2,aFunc)
Local nCnt1 := 0
Local nCnt2 := 0

If nPos2 <> 0 .And. Len(aCampos2) <> 0
	If (nPosCampo := aScan(aFunc,{|x| AllTrim(x[2]) == aCampos2[nPos2][2]})) == 0
		aAdd(aCampos1,{aCampos2[nPos2][1],aCampos2[nPos2][2]})
		aDel(aCampos2,nPos2)
		aSize(aCampos2,Len(aCampos2)-1)
		aSort(aCampos1,,, {|x,y| x[1] < y[1]})
		aCamposA  := {}
		aCamposB  := {}
		For nCnt1 := 1 to Len(aCampos1)
			aAdd(aCamposA,aCampos1[nCnt1][1])
		Next
		For nCnt2 := 1 to Len(aCampos2)
			aAdd(aCamposB,aCampos2[nCnt2][1])
		Next
	Else
		MsgAlert("Os campos fixos nao podem ser retirados da lista de selecionados") //"Os campos fixos nao podem ser retirados da lista de selecionados"
	Endif
	oCampos1:SetArray(aCamposA)
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt := 1
	oCampos2:Refresh()
	oCampos2:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddAllFld  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move todos os campos do array de campos disponiveis para      ³±±
±±³          ³array de campos selecionados.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddAllFld(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0
Local nCnt2 := 0

If Len(aCampos1) <> 0
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCampos2,{aCampos1[nCnt1][1],aCampos1[nCnt1][2]})
	Next
	aCampos1 := {}
	aCamposA := {}
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposB  := {}
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2][1])
	Next
	oCampos1:SetArray(aCamposA)
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt := 1
	oCampos2:Refresh()
	oCampos2:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelAllFld  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move todos os campos do array de campos selecionados para     ³±±
±±³          ³array de campos disponiveis.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DelAllFld(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB,aFunc)
Local nCnt1 := 0
Local aCamposAux := {}

aCamposAux := aClone(aCampos2)
aCampos2   := {}
aCamposB   := {}

If Len(aCamposAux) <> 0
	For nCnt1 := 1 to Len(aCamposAux)
		If (nPosCampo := aScan(aFunc,{|x| AllTrim(x[2]) == aCamposAux[nCnt1][2]})) == 0
			aAdd(aCampos1,{aCamposAux[nCnt1][1],aCamposAux[nCnt1][2]})
		Else
			aAdd(aCampos2,{aCamposAux[nCnt1][1],aCamposAux[nCnt1][2]})
			aAdd(aCamposB,aCamposAux[nCnt1][1])
		Endif
	Next
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposA  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	oCampos1:SetArray(aCamposA)
	oCampos1:nAt   := 1
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Refresh()
	oCampos1:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UpField    ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move o campo para uma posicao acima dentro do array           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function UpField(aCampos2,oCampos2,aCamposB,nPos2)
Local nCnt2 := 0
Local cCampoAux

If nPos2 <> 1 .And. nPos2 <> 0
	cCampoAux := aCampos2[nPos2-1][1]
	aCampos2[nPos2-1][1] := aCampos2[nPos2][1]
	aCampos2[nPos2][1] := cCampoAux
	cCampoAux := aCampos2[nPos2-1][2]
	aCampos2[nPos2-1][2] := aCampos2[nPos2][2]
	aCampos2[nPos2][2] := cCampoAux
	aCamposB  := {}
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2][1])
	Next
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt:=nPos2-1
	oCampos2:Refresh()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DwField    ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move o campo para uma posicao abaixo dentro do array          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DwField(aCampos2,oCampos2,aCamposB,nPos2)
Local nCnt2 := 0
Local cCampoAux

If nPos2 < Len(aCampos2) .And. nPos2 <> 0
	cCampoAux := aCampos2[nPos2+1][1]
	aCampos2[nPos2+1][1] := aCampos2[nPos2][1]
	aCampos2[nPos2][1] := cCampoAux
	cCampoAux := aCampos2[nPos2+1][2]
	aCampos2[nPos2+1][2] := aCampos2[nPos2][2]
	aCampos2[nPos2][2] := cCampoAux
	aCamposB  := {}
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2][1])
	Next
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt:=nPos2+1
	oCampos2:Refresh()
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RestFields ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Restaura arrays originais                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RestFields(aCampos1,oCampos1,aCampos2,oCampos2,aCampos3,aCampos4,aCamposA,aCamposB)
Local nCnt1 := 0
Local nCnt2 := 0

aCampos1  := aClone(aCampos3)
aCampos2  := aClone(aCampos4)
aSort(aCampos1,,, {|x,y| x[1] < y[1]})
aCamposA  := {}
aCamposB  := {}
For nCnt1 := 1 to Len(aCampos1)
	aAdd(aCamposA,aCampos1[nCnt1][1])
Next
For nCnt2 := 1 to Len(aCampos2)
	aAdd(aCamposB,aCampos2[nCnt2][1])
Next
oCampos1:SetArray(aCamposA)
oCampos2:SetArray(aCamposB)
If Len(aCampos1) > 0
	oCampos1:nAt := 1
	oCampos1:Refresh()
	oCampos1:SetFocus()
Else
	If Len(aCampos2) > 0
		oCampos2:nAt := 1
		oCampos2:Refresh()
		oCampos2:SetFocus()
	Else
		oCampos1:Refresh()
		oCampos2:Refresh()
	Endif
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravaMvSX6 ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os campos selecionados nos parametros MV_PMSPLN? (SX6)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GravaMvSX6(aCampos2,aMvPmsImp)
Local nCntFields := 0
Local nCntMv    := 1
Local cMvFldPln := ""

For nCntFields := 1 to Len(aCampos2)

	If Len(cMvFldPln + ("_"+aCampos2[nCntFields][2]+"#")) <= 240
		cMvFldPln := cMvFldPln + ("_"+aCampos2[nCntFields][2]+"#")
	Else
		PutMv(aMvPmsImp[nCntMv],cMvFldPln)
		If len(aMvPmsImp) > nCntMv
			cMvFldPln := "_"+aCampos2[nCntFields][2]+"#"
			nCntMv++
		EndIf
	Endif
Next nCntFields
PutMv(aMvPmsImp[nCntMv],cMvFldPln)
If nCntMv==1
	PutMv(aMvPmsImp[2],"")
EndIf

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvDtHrImp³ Autor ³ Cristiano G. Cunha   ³ Data ³ 15-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Converte strings importadas do arquivo .TXT para data e hora  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA001                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ConvDtHrImp(cDtHrImp)

Local aDtHrImp := {,}

aDtHrImp[1] := CTOD(Substr(cDtHrImp,1,8))
aDtHrImp[2] := Substr(cDtHrImp,Len(cDtHrImp)-4,5)

Return(aDtHrImp)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A001Codigo ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 21-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Codigo da EDT/Tarefa.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A001Codigo(cAliasFun,cConteudo)

If cAliasFun == "AFC"
	AFC->AFC_EDT    := cConteudo
ElseIf cAliasFun == "AF9"
	AF9->AF9_TAREFA := cConteudo
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A001Nivel  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 21-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Nivel da EDT/Tarefa.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A001Nivel(cAliasFun,cConteudo)

If cAliasFun == "AFC"
	AFC->AFC_NIVEL	:= StrZero(Val(cConteudo) + 1, TamSX3("AFC_NIVEL")[1])
ElseIf cAliasFun == "AF9"
	AF9->AF9_NIVEL	:= StrZero(Val(cConteudo) + 1, TamSX3("AF9_NIVEL")[1])
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A001Descri ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 21-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a Descricao da EDT/Tarefa.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A001Descri(cAliasFun,cConteudo)

If cAliasFun == "AFC"
	AFC->AFC_DESCRI := cConteudo
ElseIf cAliasFun == "AF9"
	AF9->AF9_DESCRI := cConteudo
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A001DataI  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 21-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a Data e a Hora Inicial da EDT/Tarefa.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A001DataI(cAliasFun,cConteudo)

Local aDtHrIni := {}

aDtHrIni := ConvDtHrImp(cConteudo)

If cAliasFun == "AFC"
	AFC->AFC_START	:= aDtHrIni[1]
	AFC->AFC_HORAI	:= aDtHrIni[2]
Else
	AF9->AF9_START	:= aDtHrIni[1]
	AF9->AF9_HORAI	:= aDtHrIni[2]
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A001DataF  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 21-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a Data e a Hora Final da EDT/Tarefa.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A001DataF(cAliasFun,cConteudo)

Local aDtHrFim := {}

aDtHrFim := ConvDtHrImp(cConteudo)

If !Empty(caliasFun) .and. !(cAliasFun)->(EOF())
	If cAliasFun == "AFC"
		AFC->AFC_FINISH := aDtHrFim[1]
		AFC->AFC_HORAF  := aDtHrFim[2]
	ElseIf cAliasFun == "AF9"
		AF9->AF9_FINISH := aDtHrFim[1]
		AF9->AF9_HORAF  := aDtHrFim[2]
	EndIf
EndIf	
Return


/*/{Protheus.doc} A001Predec

Função que atualiza os recursos da tarefa na tabela AFA de acordo com o arquivo texto importado.
IMPORTANTE: antes da chamada, o registro na tabela AF9/AFC deve estar posicionado corretamente

@author Cristiano G. Cunha

@since 21/05/2002

@version P10

@param cAliasFun, 	caracter,	Alias da Tabela AF9 ou AFC
@param cConteudo, 	caracter,	Contem as predecessoras na tarefa/edt em formato de arquivo texto 
@param nVerPrj, 		numerico,	Idioma em que se encontra o arquivo texto
@param aTxt, 			array,		Contem o arquivo texto importado, separado cada informacao por um vetor
@param nLinha, 		numerico,	Linha atual do arquivo texto importado

@return nulo

/*/
Static Function A001Predec(cAliasFun,cConteudo,nVerPrj,aTxt,nLinha)
Local cLineRelacs := ""
Local nPosSep 	:= 0
Local cRelac1 	:= 0
Local nPosPred 	:= 0
Local cPredec 	:= ""
Local cTipoRel	:= ""   
Local nHRetar 	:= 0
Local lPerTip 	:= .F.
Local nPosTipo 	:= 0
Local nCntTip 	:= 0
Local aTipos   	:= {}        
Local nAtDias 	:= 0
Local nAtHoras 	:= 0
Local aPredecs 	:= {{},{}} // 01- predecessora que são tarefas, 02 - predecessoras que são edts
Local nCntPred 	:= 0
Local cSeek 		:= ""

Local aArea    	:= GetArea()
Local aAreaAFC 	:= AFC->(GetArea())
Local aAreaAF9 	:= AF9->(GetArea())
Local aAreaPredec := {}
Local aAreaAFD 	:= {}
Local aAreaAJ4 	:= {}

// Não existe informacao importada de predecessão
If Empty(cConteudo)
	// deve procurar se existe relacionamento e excluir
	If cAliasFun=="AF9"
		// Excluir todas as tarefas relacionadas como predecessora
		dbSelectArea("AFD")
		AFD->(dbSetOrder(1))
		AFD->(dbSeek(xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
		While !Eof() .AND. xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==AFD->(AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA)
			Reclock("AFD")
			AFD->(dbDelete())
			AFD->(dbSkip())
		EndDo
		// Excluir todas as edts relacionadas como predecessora
		dbSelectArea("AJ4")
		AJ4->(dbSetOrder(1))
		AJ4->(dbSeek(xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
		While !Eof() .AND. xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==AJ4->(AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA)
			Reclock("AJ4")
			AJ4->(dbDelete())
			AJ4->(dbSkip())
		EndDo

	EndIf
	
// Existe informacao importada de predecessão(relacionamento)
Else
	If nVerPrj == 1
		aTipos := {"TI","II","TT","IT"}                         
	Else
		If nVerPrj == 3
			aTipos := {"FC","CC","FF","CF"}
		Else	
			aTipos := {"FS","SS","FF","SF"}
		EndIf
	Endif
	
	If cAliasFun=="AF9"                                   
		cLineRelacs := cConteudo
		While Len(cLineRelacs) > 0
			nPosSep := At(";",cLineRelacs)
			cRelac1 := Substr(cLineRelacs,1,If(nPosSep==0,Len(cLineRelacs),nPosSep-1))
			
			nPosPred := 0
			cPredec := ""
			cTipoRel:= ""   
			nHRetar := 0
			lPerTip := .F.
			nPosTipo:= 0
			For nCntTip := 1 to Len(aTipos)
				If aTipos[nCntTip] $ cRelac1
					lPerTip := .T.
					nPosTipo := At(aTipos[nCntTip],cRelac1)
					cTipoRel := Alltrim(Str(nCntTip))
				Endif
			Next		
			If Len(Alltrim(cRelac1)) == 1 .or. (Len(Alltrim(cRelac1)) > 1 .and. !lPerTip)
				nPosPred	:=	aScan(aTxt,{|x| Alltrim(x[nPosID])==AllTrim(cRelac1)})
				cTipoRel := "1"
				If nPosPred > 0
					cPredec := aTxt[nPosPred,nPosTarefa]
				Endif
			Else
				nAtDias := At("d",cRelac1) //se o retardo foi informado em dias
				If nAtDias >0
					If "-" $ cRelac1 // se retardo é negativo
						nHRetar := 24 * Val(Substr(cRelac1,At("-",cRelac1),(nAtDias-2)))
					Else
						nHRetar := 24 * Val(Substr(cRelac1,At("+",cRelac1),(nAtDias-2)))
					EndIf
				Else
					nAtHoras := At("h",cRelac1) //se o retardo foi informado em horas
					If nAtHoras > 0
						If "-" $ cRelac1 // se retardo é negativo
							nHRetar := Val(Substr(cRelac1,At("-",cRelac1),(nAtHoras-2)))
						Else
							nHRetar := Val(Substr(cRelac1,At("+",cRelac1),(nAtHoras-2)))
						EndIf
					EndIf
				EndIf
				
				nPosPred	:=	aScan(aTxt,{|x| Alltrim(x[nPosID])==AllTrim(Substr(cRelac1,1,(nPosTipo-1)))})
				If nPosPred > 0
					cPredec := aTxt[nPosPred,nPosTarefa] // codigo da tarefa predecessora
				Endif
			Endif
		
			If nPosPred > 0 // Predecessora existe como tarefa/edt no arquivo importado
				If (nPosPred == Len(aTxt)) .or. (Val(aTxt[nPosPred,nPosNivel]) >= Val(aTxt[nPosPred+1,nPosNivel])) // Condicao verdadeira, se trata de uma tarefa. A variavel nPosNivel é private
					If nPosTpVRel > 0  
						aAdd(aPredecs[01], {cPredec,cTipoRel,nHRetar,aTxt[nLinha,nPosTpVRel]})
					Else
						aAdd(aPredecs[01], {cPredec,cTipoRel,nHRetar,""})
					EndIf
				Else
					aAdd(aPredecs[02], {cPredec,cTipoRel,nHRetar,""})
				EndIf
			EndIf
		
			cLineRelacs := Substr(cLineRelacs,(Len(cRelac1)+2),(Len(cLineRelacs)-Len(cRelac1)))
		
		End
	
		If Len(aPredecs[01]) > 0 // existe tarefas predecessoras na tarefa importada do arquivo texto
		
			cSeek := xFilial("AF9")+AF9->(AF9_PROJET+AF9_REVISA)
			
			dbSelectArea("AFD")
			aAreaAFD := AFD->(GetArea())
			AFD->(dbSetOrder(1))
			
			For nCntPred := 1 To len(aPredecs[01])
				
				dbSelectArea("AF9")
				aAreaPredec := AF9->(GetArea())
				AF9->(dbSetOrder(1))
				lFound := AF9->(dbSeek(cSeek+Padr(aPredecs[01,nCntPred,01],len(AF9->AF9_TAREFA))))	// Se a predecessora está incluida na tabela AF9
				RestArea(aAreaPredec)
				
				dbSelectArea("AFD")
				If lFound
					cItem := StrZero(nCntPred,Len(AFD->AFD_ITEM))
						
					If dbSeek(xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+cItem)
						RecLock("AFD",.F.)
					Else
						RecLock("AFD",.T.)
					EndIf
						
					AFD->AFD_FILIAL := xFilial("AFD")
					AFD->AFD_PROJET := AF9->AF9_PROJET
					AFD->AFD_REVISA := AF9->AF9_REVISA
					AFD->AFD_TAREFA := AF9->AF9_TAREFA
					AFD->AFD_ITEM   := cItem
					AFD->AFD_PREDEC := aPredecs[01,nCntPred,01]
					AFD->AFD_TIPO   := aPredecs[01,nCntPred,02]
					AFD->AFD_HRETAR := aPredecs[01,nCntPred,03]
					AFD->AFD_TPVREL := aPredecs[01,nCntPred,04]
					AFD->(MsUnlock())
				EndIf
			Next nCntPred
			
			AFD->(dbSkip())
					
			// Se houver mais predecessoras na tabela AFD do que no arquivo importado, deve excluir as predecessoras na tabela AFD
			While AFD->(!Eof()) .AND. AFD->(AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA)==xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA .AND. AFD->AFD_ITEM>=StrZero(nCntPred,Len(AFD->AFD_ITEM))
				Reclock("AFD")
				AFD->(dbDelete())
				AFD->(dbSkip())
			End

			RestArea(aAreaAFD)
			
		Else
			dbSelectArea("AFD")
			aAreaAFD := AFD->(GetArea())
			AFD->(dbSetOrder(1))
			AFD->(dbSeek(xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
			While AFD->(!Eof()) .AND. AFD->(AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA)==xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA 
				RecLock("AFD")
				AFD->(dbDelete())
				AFD->(dbSkip())
			End
			RestArea(aAreaAFD)
		EndIf
			
		If Len(aPredecs[02]) > 0 // existe EDTs predecessoras na tarefa importada do arquivo texto			
			
			cSeek := xFilial("AFC")+AFC->(AFC_PROJET+AFC_REVISA)
			
			dbSelectArea("AJ4")
			aAreaAJ4 := AJ4->(GetArea())
			AJ4->(dbSetOrder(1))
			
			For nCntPred := 1 To len(aPredecs[02])
				
				dbSelectArea("AFC")
				aAreaPredec := AFC->(GetArea())
				AFC->(dbSetOrder(1))
				lFound := AFC->(dbSeek(cSeek+Padr(aPredecs[02,nCntPred,01],len(AFC->AFC_EDT))))	// Se a predecessora está incluida na tabela AFC
				RestArea(aAreaPredec)

				dbSelectArea("AJ4")
				If lFound				
					cItem := StrZero(nCntPred,Len(AJ4->AJ4_ITEM))
						
					If dbSeek(xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+cItem)
						RecLock("AJ4",.F.)
					Else
						RecLock("AJ4",.T.)
					EndIf
					
					AJ4->AJ4_FILIAL := xFilial("AJ4")
					AJ4->AJ4_PROJET := AF9->AF9_PROJET
					AJ4->AJ4_REVISA := AF9->AF9_REVISA
					AJ4->AJ4_TAREFA := AF9->AF9_TAREFA
					AJ4->AJ4_ITEM   := cItem
		   			AJ4->AJ4_PREDEC := aPredecs[02,nCntPred,01]
					AJ4->AJ4_TIPO   := aPredecs[02,nCntPred,02]
					AJ4->AJ4_HRETAR := aPredecs[02,nCntPred,03]
					AJ4->(MsUnlock())
				EndIf
			Next nCntPred
			
			AJ4->(dbSkip())
			
			// Se houver mais predecessoras na tabela AJ4 do que no arquivo importado, deve excluir as predecessoras na tabela AJ4
			While AJ4->(!Eof()) .AND. AJ4->(AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA)==xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA .AND. AJ4->AJ4_ITEM>=StrZero(nCntPred,Len(AJ4_>AJ4_ITEM))
				Reclock("AJ4")
				AJ4->(dbDelete())
				AJ4->(dbSkip())
			End
			
			RestArea(aAreaAJ4)

		Else // predecessoras não foram informados na tarefa importada do arquivo texto, deve excluir as predecessoras tabela AFD
			dbSelectArea("AJ4")
			aAreaAJ4 := AJ4->(GetArea())
			AJ4->(dbSetOrder(1))
			AJ4->(dbSeek(xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
			While AJ4->(!Eof()) .AND. AJ4->(AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA)==xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA 
				RecLock("AJ4")
				AJ4->(dbDelete())
				AJ4->(dbSkip())
			End
			RestArea(aAreaAJ4)
		EndIf
	EndIf
					
EndIf

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A001Conf   ³ Autor ³ Fabio Rogerio Pereira³ Data ³ 14-11-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava as confirmacoes da tarefa								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A001Conf(cAliasFun,cConteudo)
Local cPerc		:= ""
Local bCampo	:= {|n| FieldName(n) }
Local nj 		:= 0
Local aAreaAF9 	:= {}

cPerc:= SubStr(cConteudo,1,AT("%",cConteudo)-1)
cPerc:= IIf(Empty(cPerc) .Or. (Valtype(Val(cPerc)) <> "N"),"0",cPerc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa o Percentual Realizado da Tarefa                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAliasFun == "AF9")
	If (PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataBase) <> Val(cPerc))
		aAreaAF9 := AF9->(GetArea())
		dbSelectArea("AFF")
		dbSetOrder(1)
		If dbSeek(xFilial("AFF")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+DTOS(dDataBase))
			RecLock("AFF",.F.)
			PMSAvalAFF("AFF",2)
		Else
			RegToMemory("AFF",.T.)
			RecLock("AFF",.T.)
			For nj := 1 TO FCount()
				FieldPut(nj,M->&(EVAL(bCampo,nj)))
			Next nj
		EndIf
		AFF->AFF_FILIAL := xFilial("AFF")
		AFF->AFF_PROJET	:= AF9->AF9_PROJET
		AFF->AFF_REVISA	:= AF9->AF9_REVISA
		AFF->AFF_TAREFA	:= AF9->AF9_TAREFA
		AFF->AFF_QUANT	:= AF9->AF9_QUANT*Val(cPerc)/100
		AFF->AFF_USER	:= RetCodUsr()
		AFF->AFF_DATA	:= dDataBase
		PMSAvalAFF("AFF",1)
		MsUnlock()

		RestArea(aAreaAF9)		
		RecLock("AF9",.F.) //-- Retorna a tabela AF9 para gravação.
	EndIf
EndIf
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A001TpRest ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 21-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava o tipo de resricao da tarefa.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A001TpRest(cAliasFun,cConteudo,nVerPrj)
Local cRestProject 	:= Alltrim(cConteudo)
Local cTipoRest		:=	" "
If cAliasFun == "AF9"
	If nVerPrj == 3
		Do Case
		// iniciar
		Case cRestProject == "Debe comenzar el"
			cTipoRest := "1"
		
		// terminar
		Case cRestProject == "Debe finalizar el"
			cTipoRest := "2"
		
		// nao iniciar antes
		Case cRestProject == "No comenzar antes del"
			cTipoRest := "3"
		
		// nao iniciar depois
		Case cRestProject == "No comenzar después del"
			cTipoRest := "4"
		
		// nao terminar antes
		Case cRestProject == "No finalizar antes del"
			cTipoRest := "5"
		
		// nao terminar depois
		Case cRestProject == "No finalizar después del"
			cTipoRest := "6"
		
		// o mais breve
		Case cRestProject == "Lo antes posible"
			cTipoRest := "7"
		
		// o mais tarde
		Case cRestProject == "Lo más tarde posible"
			cTipoRest := "8"
		
		Otherwise
			cTipoRest := " "
		EndCase
	ElseIf nVerPrj == 1
	
		Do Case
		// iniciar
		Case cRestProject == "Deve iniciar em"
			cTipoRest := "1"
		
		// terminar
		Case cRestProject == "Deve terminar em"
			cTipoRest := "2"
		
		// nao iniciar antes
		Case cRestProject == "Não iniciar antes de"
			cTipoRest := "3"
		
		// nao iniciar depois
		Case cRestProject == "Não iniciar depois de"
			cTipoRest := "4"
		
		// nao terminar antes
		Case cRestProject == "Não terminar antes de"
			cTipoRest := "5"
		
		// nao terminar depois
		Case cRestProject == "Não terminar depois de"
			cTipoRest := "6"
		
		// o mais breve
		Case cRestProject == "O Mais Breve Possível"
			cTipoRest := "7"
		
		// o mais tarde
		Case cRestProject == "O mais tarde possível"
			cTipoRest := "8"
		
		Otherwise
			cTipoRest := " "
		EndCase
	ElseIf nVerPrj == 2
		Do Case
		// iniciar
		Case cRestProject == "MUST START ON"
			cTipoRest := "1"
		
		// terminar
		Case cRestProject == "MUST FINISH ON"
			cTipoRest := "2"
		
		// nao iniciar antes
		Case cRestProject == "START NO EARLIER THAN"
			cTipoRest := "3"
		
		// nao iniciar depois
		Case cRestProject == "START NO LATER THAN"
			cTipoRest := "4"
		
		// nao terminar antes
		Case cRestProject == "FINISH NO EARLIER THAN"
			cTipoRest := "5"
		
		// nao terminar depois
		Case cRestProject == "FINISH NO LATER THAN"
			cTipoRest := "6"
		
		// o mais breve
		Case cRestProject == "AS SOON AS POSSIBLE"
			cTipoRest := "7"
		
		// o mais tarde
		Case cRestProject == "AS LATE AS POSSIBLE"
			cTipoRest := "8"
		
		Otherwise
			cTipoRest := " "
		EndCase
	
	Endif
	If AF9->(!Eof())
		AF9->AF9_RESTRI := cTipoRest
	EndIf
EndIf

Return


/*/{Protheus.doc} A001RECURS

Função que atualiza os recursos da tarefa na tabela AFA de acordo com o arquivo texto importado.
IMPORTANTE: antes da chamada, o registro na tabela AF9 deve estar posicionado corretamente

@author Cristiano G. Cunha

@since 21/05/2002

@version P10

@param cAliasFun, 	caracter,	Alias da Tabela AF9
@param cConteudo, 	caracter,	Contem os recursos alocados na tarefa em formato de arquivo texto 
@param nVerPrj, 		numerico,	Idioma em que se encontra o arquivo texto
@param aTxt, 			array,		Contem o arquivo texto importado, separado cada informacao por um vetor

@return nulo

/*/
Static Function A001RECURS(cAliasFun,cConteudo,nVerPrj,aTxt)
Local nPosSep
Local nCntRel
Local cRelac1
Local nPosElem
Local nCntRec 	:= 0
Local cLineRec 	:= ""
Local cRecurso	:=	""
Local aRet			:=	{}
Local cCodRec		:=	""
Local aRecurs		:=	{}
Local cItem		:= ""
Local aArea 		:= GetArea()
Local aAreaAE8 	:= AE8->(GetArea())
Local aAreaAFA 	:= {}
Local nTamCodRec := TamSX3("AE8_RECURS")[1]

If Empty(cConteudo)
	dbSelectArea("AFA")
	aAreaAFA := AFA->(GetArea())
	dbSetOrder(1)
	If dbSeek(xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) .AND. ( Empty(AFA->AFA_RECURS) .AND. Empty (AFA->AFA_TAREFA))
		While AFA->(!Eof()) .AND. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)==xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
			RecLock("AFA")
			dbDelete()
			dbSkip()
		End
	EndIf	
	RestArea(aAreaAFA)
Else
	cLineRec := cConteudo
	While Len(cLineRec) > 0
		nPosSep := At(";",cLineRec)
		cRelac1 := Substr(cLineRec,1,If(nPosSep==0,Len(cLineRec),nPosSep-1))
		
		If "[" $ cRelac1 .And. "]" $ cRelac1
			nPosPerc := At("[",cRelac1)
			nPerc := Val(StrTran(Substr(cRelac1,nPosPerc+1,3),"%",""))    
			cCodRec	:=	Substr(cRelac1,1,nPosPerc-1)
		Else
			nPerc := 100
			cCodRec :=	cRelac1
		EndIf
		
		nPosElem := aScan(aRecAmarr, { |x| x[2]==cCodRec })
		
		If nPosElem > 0
			cRecurso	:=	 aRecAmarr[nPosElem,1]
		Else
			AE8->(dbSetOrder(1))
			If AE8->(dbSeek(xFilial("AE8")+AllTrim( Substr(cCodRec,1,nTamCodRec) )))
				cRecurso	:=	AE8->AE8_RECURS
			Else
				If ParamBox({	{1,"Recurso invalido",cCodRec,"@",'.F.',,'.F.',40,.F.},; //"Recurso invalido"
								{1,"Selecione ",CriaVar('AE8_RECURS'),"@!",'ExistCpo("AE8",mv_par02)','AE8','.T.',40,.T.},;  //"Selecione "
								{5,"Associar sempre a este recurso.",.F.,100,,.F.};  //"Associar sempre a este recurso."
								},"Recurso invalido. Selecione o recurso correto.",aRet)  //"Recurso invalido. Selecione o recurso correto."
					AE8->(dbSetOrder(1))
					If AE8->(dbSeek(xFilial("AE8")+aRet[2]))
						If aRet[3] 
							aAdd(aRecAmarr,{AE8->AE8_RECURS, cCodRec} )
						EndIf                                                          
						cRecurso :=	AE8->AE8_RECURS
					EndIf
				Endif
			EndIf
		EndIf
	
		aAdd( aRecurs,{cRecurso,nPerc})
	
		cLineRec := Substr(cLineRec,(Len(cRelac1)+2),(Len(cLineRec)-Len(cRelac1)))
	End
	
	dbSelectArea("AFA")
	aAreaAFA := AFA->(GetArea())
	dbSetOrder(1)
	If Len(aRecurs) > 0 // existe recursos na tarefa importada do arquivo texto
		For nCntRec := 1 To len(aRecurs)
		
			cItem := StrZero(nCntRec,Len(AFA->AFA_ITEM))
			
			If dbSeek(xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+cItem)
				RecLock("AFA",.F.)
			Else
				PmsNewRec("AFA")
			EndIf
			AFA->AFA_FILIAL 	:= xFilial("AFA")
			AFA->AFA_PROJET 	:= AF9->AF9_PROJET
			AFA->AFA_TAREFA 	:= AF9->AF9_TAREFA
			AFA->AFA_REVISA 	:= AF9->AF9_REVISA
			AFA->AFA_ITEM 	:= cItem
			AFA->AFA_RECURS 	:= aRecurs[nCntRec,01]
			AFA->AFA_ALOC		:= aRecurs[nCntRec,02] 
			AFA->AFA_QUANT 	:= AF9->AF9_HDURAC * AFA->AFA_ALOC /100
			AFA->AFA_DATPRF	:= AF9->AF9_START
			AFA->AFA_START	:= AF9->AF9_START
			AFA->AFA_HORAI	:= AF9->AF9_HORAI
			AFA->AFA_FINISH	:= AF9->AF9_FINISH
			AFA->AFA_HORAF	:= AF9->AF9_HORAF
			MsUnlock()
		Next nCntRec
		AFA->(dbSkip())
		// Se houver mais recursos na AFA do que no arquivo importado, deve excluir os recursos na tabela AFA
		While AFA->(!Eof()) .AND. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)==xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA .AND. AFA->AFA_ITEM>=StrZero(nCntRec,Len(AFA->AFA_ITEM))
			Reclock("AFA")
			dbDelete()
			dbSkip()
		End
		
	Else // recursos não informados na tarefa importada do arquivo texto, deve excluir os recursos da tabela AFA
		dbSeek(xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
		While AFA->(!Eof()) .AND. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)==xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
			RecLock("AFA")
			dbDelete()
			dbSkip()
		End
	EndIf
	RestArea(aAreaAFA)
EndIf
RestArea(aAreaAE8)
RestArea(aArea)

Return

Static Function PmsOrdCsv(aCposCSV) // Ordena as colunas inclusas pelo usuario
Local nPosTarefa := 0
Local nPosNivel  := 0
Local nPosID     := 0
Local nPosCalend := 0
Local nPosRevisa := 0
Local nPosEdtPai := 0
Local nPosQuant  := 0
Local nPosUM     := 0
Local nPosConf   := 0
Local nPosComp   := 0
Local nPosPredec := 0
Local aNewCSV	 := {}
DEFAULT aCposCSV := {}
                      
aNewCSV := aClone(aCposCSV)
               
nPosTarefa := aScan(aCposCSV,"$A001CODIGO")
nPosNivel  := aScan(aCposCSV,"$A001NIVEL")
nPosID     := aScan(aCposCSV,"$A001ID")
nPosCalend := aScan(aCposCSV,"CALEND")
nPosRevisa := aScan(aCposCSV,"REVISA")
nPosEdtPai := aScan(aCposCSV,"EDTPAI")
nPosQuant  := aScan(aCposCSV,"QUANT")
nPosUM     := aScan(aCposCSV,"UM")
nPosConf   := aScan(aCposCSV,"$A001CONF")
nPosComp   := aScan(aCposCSV,"COMPUN")
nPosPredec := aScan(aCposCSV,"$A001PREDEC")
   
If nPosPredec < nPosTarefa
	aNewCSV := aChangePos(aNewCSV,nPosTarefa,nPosPredec) // funcao aChangePos -> PMSXFUNB
EndIf

aCposCSV := aClone(aNewCSV)

Return aCposCSV
