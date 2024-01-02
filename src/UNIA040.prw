#include "TOPCONN.CH"
#include "rwmake.ch"
#Include "PROTHEUS.CH"

//--------------------------------------------------------------------
/*/{Protheus.doc} UNIA040
DESC: Este programa tem a importar para o Ativo, uma lista de novos 
bens a partir de uma planilha importada.
Planilha: CODIGO;VR_TOTAL
@sample		UNIA040()
@return 	Nill
@author		João E. Lopes
@since		25/11/2019
@version 	P12
/*/
//--------------------------------------------------------------------

User Function UNIA040()

	Local oButton1
	Local oButton2
	Local oButton3
//	Local oButton4
	Local oGet1
	Local cGet1 := space(80)
//	Local oGet2
//	Local cGet2 := space(2)
//	Local oGet3
//	Local cGet3 := space(10)
//	Local oGet4
//	Local cGet4 := space(10)
	Local oGroup1
	Local oSay1
//	Local oSay2
//	Local oSay3
//	Local oSay4
	Static oDlg

	Private cPerg	 := "UNIA040" // Nome do alias no arquivo de Perguntas (SX1)
	Private nLastKey := 0
	Private dData    := ""
	Private lUsrOk   := RetCodUsr() $ GETMV("UN_USRINCP", , "000000" ) // parametro de autorização de utilização da rotina.
	Private cExistCB := ""

	Private cFilSN1 := xFilial("SN1")


	VerPerg()
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	dData:= Mv_par01


	DEFINE MSDIALOG oDlg TITLE "Importação de Ativos" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL

	@ 006, 008 GROUP oGroup1 TO 145, 293 PROMPT "   Importação de Ativos     " OF oDlg COLOR 0, 16777215 PIXEL
	@ 046, 056 MSGET oGet1 VAR cGet1 SIZE 176, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 046, 011 SAY oSay1 PROMPT "Local do Arquivo" SIZE 041, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 124, 130 BUTTON oButton1 PROMPT "Importar" 	SIZE 037, 012 OF oDlg ACTION (SBM01imp(cGet1)) PIXEL
	@ 124, 180 BUTTON oButton2 PROMPT "Sair" 		SIZE 037, 012 OF oDlg ACTION (oDlg:end()) PIXEL
	@ 044, 239 BUTTON oButton3 PROMPT "Procurar" 	SIZE 037, 012 OF oDlg ACTION (cGet1:=u_SN101proc()) PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return

User Function SN101proc

	cDestino := cGetFile("CSV | *.CSV","Selecione o Arquivo...",1,"",.t.,GETF_LOCALHARD)

return (cDestino)


Static Function SBM01Imp(cArq)

	Local i := 0.00
	_cDest:= GetSrvProfString("Startpath","")+'implista\'

	If apmsgyesno("Deseja Iniciar a Importação da planilha?")

		If .t.//lUsrOk

			If !File(cArq)
				MsgInfo("Arquivo não encontrado!!")
				Return()
			EndIf

			//Verifica o nome do arquivo.
			for i:=len(cArq) to 1 step -1
				if substr(cArq,i,i)='\'
					cFile:= substr(cArq,(i+1),len(cArq))
					exit
				Endif
			Next

			//copia arquivo da estação para o servidor
			CpyT2S( cArq , _cDest , .T. )

			processa({||OkProc(_cDest+cFile,cFile),"Importação da Lista" ,"Importação... ",.F.,"Aguarde. "})

			//apaga arquivo do servidor
			fErase(_cDest+cFile)

		Else
			MsgAlert("Usuário não autorizado a usar a rotina de Incorporação de Ativos! ","UNIA040_A")
			Return
		EndIf

	Endif

Static Function OkProc(mv_par01,cFile)

//	Local __lSrv  := .f.
	Local aParam  := {}
	Local aCab    := {}
	Local aItens  := {}
	Local aRetcBS := TamSX3("N3_CBASE")
	Local aRetIt  := TamSX3("N3_ITEM")
	Local lTem    := .F.

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	// Chama a rotina para gerar a área.
	cArq := U_N1LerCSV(mv_par01,"(cArq)",",",";")

/*
	if Empty(cArq)
		If Select("(cArq)") > 0
			(cArq)->(dbCloseArea())
		Endif
		MsgBox("Verifique o arquivo "+Alltrim(mv_par01),"info","stop")
		oDlg:end()
		Return .f.
	endif
*/
	if type('(cArq)->DTAQUISIC')=='U' .OR. type('(cArq)->CBASE')=='U'
		MsgBox("Problema com o arquivo "+Alltrim(mv_par01)+'. A primeira linha da tabela deve ter a DTAQUISIC (Data Aquisição)e CABSE (codigo do Bem).',"info","stop")
		If Select("(cArq)") > 0
			(cArq)->(dbCloseArea())
		Endif
		fErase(mv_par01)
		Return .f.
	Endif

	ProcRegua((cArq)->(LASTREC()))

	nReg    := 0
	ntot    := 0
	nTotReg := (cArq)->(RecCount())

	(cArq)->(dbGotop())

	lAtu  := .f.
	lAtu2 := .f.

	While !(cArq)->(Eof())

		If Select("TSN1") <> 0
			dbSelectArea("TSN1")
			TSN1->(dbCloseArea())
		Endif

		_cIniBase := "AI"

		If TCGetDB() = "ORACLE"

			cQuery := " SELECT                         "
			cQuery += " (N1_CBASE) AS UCBASE,    "
			cQuery += " N1_ITEM          AS ITEMB,     "
			cQuery += " N1_FILIAL        AS BFILIAL,   "
			cQuery += " N1_AQUISIC       AS AQUISIC    "
			cQuery += "	FROM "+RetSqlName("SN1")+" SN1 "
			cQuery += " WHERE SN1.D_E_L_E_T_= ' '    "
			cQuery += " AND SUBSTR(N1_CBASE,1,2) = '" + Alltrim(_cIniBase) +"'  "
			cQuery += " and rownum <= 1 ORDER BY N1_CBASE DESC

		Else

			cQuery := " SELECT                         "
			cQuery += " TOP 1 (N1_CBASE) AS UCBASE,    "
			cQuery += " N1_ITEM          AS ITEMB,     "
			cQuery += " N1_FILIAL        AS BFILIAL,   "
			cQuery += " N1_AQUISIC       AS AQUISIC    "
			cQuery += "	FROM "+RetSqlName("SN1")+" SN1 "
			cQuery += " WHERE SN1.D_E_L_E_T_= ' '        "
			cQuery += " AND SUBSTRING(N1_CBASE,1,2) = '" + _cIniBase +"'  "
			cQuery += " ORDER BY N1_CBASE DESC                            "
		Endif

		If Select("TSN1") <> 0
			TSN1->(dbCloseArea())
		Endif

		cQuery:=ChangeQuery(cQuery)

		TCQuery cQuery New Alias "TSN1"

		dbSelectArea("TSN1")
		TSN1->(DBGotop())

		If Empty(TSN1->UCBASE)
			nSeqCb := 0
		Else
			nSeqCb := VAL(SUBSTR(TSN1->UCBASE,3,8))
			lTem   := .T.
		EndIf

		nCntCB := 1

		If lTem
			nNewSeq   := nCntCB+VAL(SUBSTR(TSN1->UCBASE,3,8))
		Else
			nNewSeq   := nCntCB
		EndIf

		// Variaveis que serão alimentadas de acordo com a planilha Excel.
		// cBase     := ALLTRIM(_cIniBase + StrZero(nNewSeq,8))
		cBase     := ALLTRIM((cArq)->CBASE)
		cItem     := AllTrim((cArq)->ITEMCB)
		dDataAqs  := STOD((cArq)->DTAQUISIC)
		cDescric  := ALLTRIM((cArq)->DESCRICAO)
		nQtd      := VAL((cArq)->QTDE)
		cChapa    := ALLTRIM(_cIniBase + StrZero(nNewSeq,8))
		cPatrim   := "N"
		cGrupo    := ALLTRIM((cArq)->GRUPO)
		cSerie    := ALLTRIM((cArq)->SERIE)
		cNFiscal  := ALLTRIM((cArq)->NOTA)

		cTipo     := AllTrim((cArq)->TIPODEP)
		//cHistor   := "AQUISICAO POR INCORPORACAO"
		aFilial   := ALLTRIM((cArq)->FILIAL)
		cHistor   := AllTrim((cArq)->HISTORICO)
		cContab   := ALLTRIM((cArq)->CONTAB)
		cCusto    := ""
		cCdeprec  := ALLTRIM((cArq)->CDEPREC)
		cCCDepr   := ALLTRIM((cArq)->CCDEPR)
		cCdesp    := ""
		cCorrec   := ""
		dDTIniDp  := STOD((cArq)->DTINIDEPR)
		nVlrOrig1 := VAL((cArq)->VLRORIG)
		nTaxa     := VAL((cArq)->TAXA)
		nVerdaCM1 := VAL((cArq)->VERDACM)
		cLp       := AllTrim((cArq)->LP)

		cQuery := " SELECT                         "
		cQuery += " N1_FILIAL AS EXISTFL,          "
		cQuery += " N1_CBASE  AS EXISTCB           "
		cQuery += "	FROM "+RetSqlName("SN1")+" SN1 "
		cQuery += " WHERE SN1.D_E_L_E_T_= ' '        "
		cQuery += " AND N1_CBASE = '" + Alltrim(cBase) +"'  "
		cQuery += " AND N1_ITEM = '" + Alltrim(cItem) +"'   "

		If Select("TSN1A") <> 0
			TSN1A->(dbCloseArea())
		Endif

		TCQuery cQuery New Alias "TSN1A"

		dbSelectArea("TSN1A")
		TSN1A->(DBGotop())

		cExistCB := TSN1A->EXISTFL+TSN1A->EXISTCB

		//If Empty(cExistCB)
		If cExistCB <> aFilial+cBase
			aCab := {}
			AAdd(aCab,{"N1_FILIAL" , aFilial ,NIL})
			AAdd(aCab,{"N1_CBASE" , cBase ,NIL})
			AAdd(aCab,{"N1_ITEM" , cItem ,NIL})
			AAdd(aCab,{"N1_AQUISIC", dDataAqs ,NIL})
			AAdd(aCab,{"N1_DESCRIC", cDescric ,NIL})
			AAdd(aCab,{"N1_QUANTD" , nQtd ,NIL})
			AAdd(aCab,{"N1_CHAPA" , cChapa ,NIL})
			AAdd(aCab,{"N1_PATRIM" , cPatrim ,NIL})
			AAdd(aCab,{"N1_GRUPO" , cGrupo ,NIL})
			AAdd(aCab,{"N1_NSERIE" , cSerie ,NIL})
			AAdd(aCab,{"N1_NFISCAL" , cNFiscal ,NIL})

			aItens := {}
			//-- Preenche itens
			AAdd(aItens,{;
				{"N3_FILIAL" , aFilial ,NIL},;
				{"N3_CBASE" , cBase ,NIL},;
				{"N3_ITEM" , cItem ,NIL},;
				{"N3_SEQ" , "01" ,NIL},;
				{"N3_TIPO" , cTipo ,NIL},;
				{"N3_BAIXA" , "0" ,NIL},;
				{"N3_HISTOR" , cHistor ,NIL},;
				{"N3_DINDEPR" , dDTIniDp ,NIL},;
				{"N3_AQUISIC" , dDataAqs ,NIL},;
				{"N3_CCONTAB" , cContab ,NIL},;
				{"N3_CUSTBEM" , cCusto ,NIL},;
				{"N3_CDEPREC" , cCdeprec ,NIL},;
				{"N3_CCDEPR" , cCCDepr ,NIL},;
				{"N3_CDESP" , cCdesp ,NIL},;
				{"N3_CCORREC" , cCorrec ,NIL},;
				{"N3_CCUSTO" , cCusto ,NIL},;
				{"N3_VORIG1" , nVlrOrig1 ,NIL},;
				{"N3_TXDEPR1" , nTaxa ,NIL},;
				{"N3_VRDACM1", nVerdaCM1  ,NIL};
				})

			nRecTRB := (cArq)->(Recno())
			(cArq)->(DbSkip())
			While (cArq)->(!Eof())

				If AllTrim((cArq)->FILIAL)+AllTrim((cArq)->CBASE)+AllTrim((cArq)->ITEMCB) == aFilial+cBase+cItem

					aFilial   := AllTrim((cArq)->FILIAL)
					cTipo     := AllTrim((cArq)->TIPODEP)
					//cHistor   := "AQUISICAO POR INCORPORACAO"
					cHistor   := AllTrim((cArq)->HISTORICO)
					cContab   := ALLTRIM((cArq)->CONTAB)
					cCusto    := ""
					cCdeprec  := ALLTRIM((cArq)->CDEPREC)
					cCCDepr   := ALLTRIM((cArq)->CCDEPR)
					cCdesp    := ""
					cCorrec   := ""
					dDTIniDp  := STOD((cArq)->DTINIDEPR)
					nVlrOrig1 := VAL((cArq)->VLRORIG)
					nTaxa     := VAL((cArq)->TAXA)
					nVerdaCM1 := VAL((cArq)->VERDACM)

					AAdd(aItens,{;
						{"N3_FILIAL" , aFilial ,NIL},;
						{"N3_CBASE" , cBase ,NIL},;
						{"N3_ITEM" , cItem ,NIL},;
						{"N3_SEQ" , "02" ,NIL},;
						{"N3_TIPO" , cTipo ,NIL},;
						{"N3_BAIXA" , "0" ,NIL},;
						{"N3_HISTOR" , cHistor ,NIL},;
						{"N3_DINDEPR" , dDTIniDp ,NIL},;
						{"N3_AQUISIC" , dDataAqs ,NIL},;
						{"N3_CCONTAB" , cContab ,NIL},;
						{"N3_CUSTBEM" , cCusto ,NIL},;
						{"N3_CDEPREC" , cCdeprec ,NIL},;
						{"N3_CCDEPR" , cCCDepr ,NIL},;
						{"N3_CDESP" , cCdesp ,NIL},;
						{"N3_CCORREC" , cCorrec ,NIL},;
						{"N3_CCUSTO" , cCusto ,NIL},;
						{"N3_VORIG1" , nVlrOrig1 ,NIL},;
						{"N3_TXDEPR1" , nTaxa ,NIL},;
						{"N3_VRDACM1", nVerdaCM1  ,NIL};
						})

					Exit
				EndIf

				(cArq)->(DbSkip())
			EndDo
			(cArq)->(DbGoTo(nRecTRB))

			//Controle de contabilizacao
			If cLp == "N"

				Pergunte("AFA012",.F.)

				//mv_par05 := 2
				SetMVValue("AFA012","MV_PAR05",2)

			Else

				SetMVValue("AFA012","MV_PAR05",1)

			EndIf


			dDataBase := dDataAqs

			MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)

			//If Empty(cExistCB)

			If lMsErroAuto
				MsgAlert("Ativo Codigo Base: "+ALLTRIM(cBase)+" - "+ALLTRIM(cDescric)+" NÃO IMPORTADO! Corrija planilha e Importe Novamente!","UNIA040_10")

				//RollBackSX8()
				DisarmTransaction()
				mostraerro()      //Se Precisa... comentar essa linha...
				Return
				//cRetorno := .F.
			Else
				MsgAlert("Ativo Codigo Base: "+ALLTRIM(cBase)+" - "+ALLTRIM(cDescric)+" Importado com Sucesso!","UNIA040_11")
			EndIf

			//Else
			//MsgAlert("Ativo Codigo Base: "+ALLTRIM(cBase)+" - Item: "+ALLTRIM(cItem)+" Já Existente, Não será importado!","UNIA040_12")
			//EndIf

			dbSelectArea("SN3")
			dbSetOrder( 1 ) 	//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
			If dbSeek(cFilSN1 + PADR( alltrim(cBase ), aRetcBS[1] ) + PADR( alltrim(cItem), aRetIt[1] ) )

				/// Atualiza tabela SN3
				/*
				While SN3->(!Eof()) .And. SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM == cFilSN1 + PADR( alltrim(cBase ), aRetcBS[1] ) + PADR( alltrim(cItem), aRetIt[1])
					RecLock("SN3",.F.)
					SN3->N3_VRDACM1 := nVerdaCM1
					MsUnlock()

					SN3->(DbSkip())
				EndDo
				*/
				//Se estiver marcado na planilha para nao contabilizar, atualiza o status para nao contabilizar nem off line
				If (cArq)->LP == "N"
					//Marca os registros na SE1
					cQuery := "	UPDATE SN4010 SET N4_LA = 'S'  "
					cQuery += " WHERE SN4010.D_E_L_E_T_     = ' ' "
					cQuery += "       AND SN4010.N4_FILIAL  = '"+cFilSN1+"' "
					cQuery += "       AND SN4010.N4_CBASE   = '"+PADR( alltrim(cBase ), aRetcBS[1] )+"' "
					cQuery += "       AND SN4010.N4_ITEM    = '"+PADR( alltrim(cItem), aRetIt[1] )+"' "
					cQuery += "       AND SN4010.N4_TIPOCNT = '1' "

					TCSQLExec(cQuery)
				EndIf

			EndIf
		EndIf

		(cArq)->(DbSkip())

	Enddo
	MsgAlert("Ativo Importado com Sucesso!","UNIA040_11")
Return

//Cria as perguntas----------------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function VerPerg()

	// local i := 0
	// local j := 0

	// _sAlias := Alias()
	// dbSelectArea("SX1")
	// dbSetOrder(1)
	// cPerg := PADR(cPerg,10)
	// aRegs:={}

	// AADD(aRegs,{cPerg,"01","Importa ativos na data?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	// For i:=1 to Len(aRegs)
	// 	If !dbSeek(cPerg+aRegs[i,2])
	// 		RecLock("SX1",.T.)
	// 		For j:=1 to FCount()
	// 			If j <= Len(aRegs[i])
	// 				FieldPut(j,aRegs[i,j])
	// 			Endif
	// 		Next
	// 		MsUnlock()
	// 	Endif
	// Next

	// dbSelectArea(_sAlias)
Return

User Function TiraGraf (_sOrig)
	local _sRet := _sOrig
	_sRet = strtran (_sRet, "á", "a")
	_sRet = strtran (_sRet, "é", "e")
	_sRet = strtran (_sRet, "í", "i")
	_sRet = strtran (_sRet, "ó", "o")
	_sRet = strtran (_sRet, "ú", "u")
	_SRET = STRTRAN (_SRET, "Á", "A")
	_SRET = STRTRAN (_SRET, "É", "E")
	_SRET = STRTRAN (_SRET, "Í", "I")
	_SRET = STRTRAN (_SRET, "Ó", "O")
	_SRET = STRTRAN (_SRET, "Ú", "U")
	_sRet = strtran (_sRet, "ã", "a")
	_sRet = strtran (_sRet, "õ", "o")
	_SRET = STRTRAN (_SRET, "Ã", "A")
	_SRET = STRTRAN (_SRET, "Õ", "O")
	_sRet = strtran (_sRet, "â", "a")
	_sRet = strtran (_sRet, "ê", "e")
	_sRet = strtran (_sRet, "î", "i")
	_sRet = strtran (_sRet, "ô", "o")
	_sRet = strtran (_sRet, "û", "u")
	_SRET = STRTRAN (_SRET, "Â", "A")
	_SRET = STRTRAN (_SRET, "Ê", "E")
	_SRET = STRTRAN (_SRET, "Î", "I")
	_SRET = STRTRAN (_SRET, "Ô", "O")
	_SRET = STRTRAN (_SRET, "Û", "U")
	_sRet = strtran (_sRet, "ç", "c")
	_sRet = strtran (_sRet, "Ç", "C")
	_sRet = strtran (_sRet, "à", "a")
	_sRet = strtran (_sRet, "À", "A")
	_sRet = strtran (_sRet, "º", ".")
	_sRet = strtran (_sRet, "ª", ".")
	_sRet = strtran (_sRet, chr (9), " ") // TAB
return _sRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+----------+-------+-----------------------+------+----------+¦¦
¦¦¦ Programa ¦ N1LerCSV ¦ Autor ¦ Silvano Silva Araújo  ¦ Data ¦ 27/04/08 ¦¦¦
¦¦+----------+----------+-------+-----------------------+------+----------+¦¦
¦¦¦Descrição ¦ Importacao Dados de arquivos .CSV                          ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦ Generico                                                   ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦ Parametro¦ __cArqCSV   - Nome do arquivo .CSV                         ¦¦¦
¦¦¦          ¦ __cAliasRet - Nome do Alias a ser criado, para gravacao dos¦¦¦
¦¦¦          ¦               dados lidos no formato .DBF                  ¦¦¦
¦¦¦          ¦ __TpDec     - Caracter considerado no arquivo .CSV como    ¦¦¦
¦¦¦          ¦               decimal pode ser "," ou ".". Default ","     ¦¦¦
¦¦¦          ¦               Formato Brasileiro                           ¦¦¦
¦¦¦          ¦ __TpSepara  - Tipo do caracter separador, ";" ou ","       ¦¦¦
¦¦¦          ¦               Default ";" - Formato Brasileiro             ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦ Retorno  ¦ __ArqDBF    - Nome do Arquivo DBF criado, onde estam grava-¦¦¦
¦¦¦          ¦               os dados importados do .CSV                  ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦ ATENCAO  ¦ O arquivo gerado permanece aberto apos o processamento do  ¦¦¦
¦¦¦          ¦ programa.                                                  ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function N1LerCSV(__cArqCSV,__cAliasRet,__TpDec,__TpSepara)

	Local __a := 0.00
	Local _nIB := 0.00
	Local __b := 0.00
	Local __x := 0.00
	__aAlias := GetArea()
	__ArqDbf := ""

	if ValType(__TpDec) = "U"
		__TpDec := ","
	endif

	if ValType(__TpSepara) = "U"
		__TpDec := ";"
	endif

	__cArqCSV := Alltrim(__cArqCSV)
	__cArqCSV := iif(At(".CSV",Upper(__cArqCSV))=0,__cArqCSV+".CSV",__cArqCSV)
	__cEOL := CHR(13)+CHR(10)
	__nHdl := fOpen(__cArqCSV,68)

	If __nHdl == -1
		MsgAlert("O arquivo de nome "+__cArqCSV+" nao pode ser aberto! Verifique os parametros.","Atencao!")
		Return(__ArqDbf)
	Endif

	__nTamFile := __nRestaLer := fSeek(__nHdl,0,2)
	fSeek(__nHdl,0,0)
	__nCampos := 0
	_lFimLin := .f.

	__cVar234:= ' '

	While __nRestaLer > 0
		__cLeitura  := fReadStr(__nHdl,1200000)
		__nRestaLer -= Len(__cLeitura)
		__nFimLinha := At(__cEol,__cLeitura)+1
		__cString   := Substr(__cLeitura,1,__nFimLinha)+';' //--( ADICIONADO ; AO FINAL DE TODAS AS LINHAS) - correção necessária para importar a ultima coluna - L.A.G
		_lCont01:= .t.
		//Determinando o numero de campos importados
		if __nCampos = 0
			For __a := 1 to Len(__cString)
				if Substr(__cString,__a,1) = __TpSepara
					__nCampos ++
				endif
			Next
		endif
		//Criando Arquivo Temporario para receber as informacoes do .CSV
		if Select(__cAliasRet) = 0
			__nCampos := iif(__nCampos=0,1,__nCampos+1)
			__aEstrut := {}
			_nPosAtu  := 1
			_cVarName := "CHR_0001"
			cVarCmp:= '<html>#'
			_lFimLin := .f.
			For __a := 1 to len(__cString)
				if __a==len(__cString)
					_lFimLin := .t.
				Endif
				if Substr(__cString,__a,1)=__TpSepara .or. _lFimLin

					_cNewVar:= Upper(SubStr(__cString,_nPosAtu,iif(__a-_nPosAtu<10,__a-_nPosAtu,10)))
					_cNewVar := U_TiraGraf(_cNewVar)

					_cVar01:= ' '
					for _nIb:= 1 to len(_cNewVar)
						if (substr(_cNewVar,_nIb,1)>=CHR(65) .and. substr(_cNewVar,_nIb,1)<=CHR(90)) .or. ;
								(substr(_cNewVar,_nIb,1)>=CHR(97) .and. substr(_cNewVar,_nIb,1)<=CHR(122)) .or.;
								(substr(_cNewVar,_nIb,1)=CHR(95))
							_cVar01+= substr(_cNewVar,_nIb,1)
						Endif
					Next

					if !len(_cNewVar)==len(_cVar01)
						_cNewVar:= _cVar01
						_cNewVar:= StrTran(_cNewVar," ","")
					Endif

					if(empty(_cNewVar))
						_cNewVar:= _cVarName
						_cVarName:= soma1(_cVarName)
					Endif

					if !('#'+_cNewVar+'#'$cVarCmp)
						//				MSGINFO("#"+_cNewVar+"#"+alltrim(STR(LEN(_cNewVar))))
						Aadd(__aEstrut,{_cNewVar,"C",80,0})
						cVarCmp:= cVarCmp+_cNewVar+'#<br>#'
					Else
						msginfo("<html>Existem campos duplicados na planilha!<br>"+_cNewVar)
						Return .f.
					Endif
					_nPosAtu:= __a
					_nPosAtu++
				endif
			Next

			//	Memowrit("C:\ZZ2HX\QPRD.SQL",cVarCmp)
			//	MSGINFO(cVarCmp)

			//			__ArqDbf := CriaTrab(__aEstrut,.t.)

			cChave		:= SN1->(IndexKey())
			//			Aadd(aStru, {"RECNO","N",10,0})

			__cAliasRet := GetNextAlias()

			_oTemp040 := FWTemporaryTable():New(__cAliasRet)
			_oTemp040:SetFields(__aEstrut)
			//			_oATFA0122:AddIndex("1", {"N1_FILIAL","N1_CBASE","N1_ITEM"})

			//------------------
			//Criação da tabela temporaria
			//------------------
			_oTemp040:Create()


			//		Memowrit("C:\ZZ2HX\temporaria.SQL",__ArqDbf)
//			Use ( __ArqDbf ) Alias (__cAliasRet) Shared New via "dbfcdx"
			dbselectarea(__cAliasRet)
		endif
		// Lendo linhas
		For __x := 1 to Len(__cLeitura)
			if __x=1
				__cString   := Substr(__cLeitura,__x,__nFimLinha)
			else
				__cString   := Substr(__cLeitura,__x-1,__nFimLinha)
			endif
			//Quebrando a Linha em campos
			__nPi       := 1
			__aLerLinha := {}
			__nCont     := 0
			For __a := 1 to Len(__cString)
				if Substr(__cString,__a,1) = __TpSepara .or. __a==Len(__cString)
					__cVar := Substr(__cString,__nPi,__nCont)

					//Determinando o tipo da informacao Numero ou Caracter/Data
					__lNum      := .f.
					__lData     := .f.
					__lCaracter := .f.
					For __b := 1 to Len(__cVar)

						If __nPi==1
							__lCaracter := .t.
						Elseif Substr(__cVar,__b,1) $ " rR$0123456789.,-" .and. !__lCaracter
							__lNum      := .t.
						else
							__lCaracter := .t.
						endif
					Next
					__cMudaVar := ""
					__cVar234+= '##'+__cVar
					//Retirando , ou . se numero
					if __lNum
						For __b := 1 to Len(__cVar)
							//Se tipo de separador decimal for ,
							if Substr(__cVar,__b,1) = "." .and. __TpDec  = ","
								Loop
							endif
							//Se tipo de separdor decimal for .
							if Substr(__cVar,__b,1) = "," .and. __TpDec  = "."
								Loop
							endif
							if Substr(__cVar,__b,1) = "," .and. __TpDec  = ","

								__cMudaVar += "."
							else
								__cMudaVar += Substr(__cVar,__b,1)
							endif
						Next
						__cVar := __cMudaVar
					endif

					__cVar234+= '##'+__cVar

					Aadd(__aLerLinha,__cVar)
					__nPi   := __a+1
					__nCont := 0
				else
					__nCont ++
				endif
			Next
			//Gravando no arquivo temporario
			dbSelectArea(__cAliasRet)
			if __x <> 1
				RecLock(__cAliasRet,.t.)
				For __a := 1 to (iif(__nCampos > len(__aLerLinha),len(__aLerLinha),__nCampos))
					FieldPut(__a,__aLerLinha[__a])
				Next
				MsUnLock()
			Endif
			__x         += __nFimLinha
			__nFimLinha := At(__cEol,Substr(__cLeitura,__x))
		Next
	End

	fClose(__nHdl)
	RestArea(__aAlias)
	//Memowrit("C:\ZZ2HX\temporaria222.SQL",__cVar234)

//Return(__ArqDbf)
Return(__cAliasRet)
