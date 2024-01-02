
#INCLUDE 'protheus.ch'

#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
#Define PAD_JUSTIFY 3 //Op�?„o disponÌvel somente a partir da vers„o 1.6.2 da TOTVS Printer

//Static _cRepDb	:= GetSrvProfString("RepositInDataBase","")
//Static _cRep	:= SuperGetMv("MV_REPOSIT",.F.,"1")
//Static _lRepDb	:= ( _cRepDb == "1" .And. _cRep == "2" )


/*/

CARGA

Termo de conduta do fornecedor

SA2 Precisa estar posicionada para o correto funcionamento.

@author
@since 07/12/21

/*/ 
User Function UNIR245()
	Local nCount := 0
	Local nInc := 0

	/*cQuery := " SELECT SA2.R_E_C_N_O_ SA2RECNO "
	cQuery += " FROM "+RetSqlName("SA2")+" SA2"
	cQuery += " WHERE SA2.D_E_L_E_T_ = '' "
	cQuery += "   AND SA2.A2_CGC = '28916695000175' "
	cQuery += " AND A2_FILIAL = '"+xFilial("SA2")+"'"*/

	cQuery := " SELECT A2.R_E_C_N_O_  SA2RECNO "
	cQuery += " FROM "+RetSqlName("SA2")+" A2 "
	cQuery += " INNER JOIN "+RetSqlName("SE2")+" E2 "
	cQuery += " ON E2.D_E_L_E_T_ = ' ' "
	cQuery += " AND E2_EMISSAO >= '20210101' "
	cQuery += " AND E2_FORNECE = A2_COD "
	cQuery += " AND E2_LOJA = A2_LOJA "
	cQuery += " WHERE A2.D_E_L_E_T_ = ' ' "
	cQuery += " AND A2_EMAIL <> ' ' "
	cQuery += " AND A2_TIPO <>'F' "
	cQuery += " GROUP BY A2_EMAIL, A2_NOME, A2_CGC, A2.R_E_C_N_O_ "
	cQuery += "  ORDER BY A2_NOME "

	cQuery:=ChangeQuery(cQuery)

	MPSysOpenQuery( cQuery , "TRBDATA")
	Count to nCount

	TRBDATA->(dbGoTOp())
	While TRBDATA->(!Eof())
		nInc++
		SA2->(dbGoTO(TRBDATA->SA2RECNO))

		FWMsgRun(, {||  U_UNIR245R()  },"Termo de Conduta - "+CValToChar(nInc)+"/"+CValToChar(nCount),"Gerando termo de conduta")

		TRBDATA->(dbSkip())
	EndDo


Return

/*/

	Termo de conduta do fornecedor

	SA2 Precisa estar posicionada para o correto funcionamento.

	@author
	@since 07/12/21

/*/ 
User Function UNIR245R()
	Local lSucess := .F.
	//Local cNomePData := SubStr(GetSrvProfString("RootPath",""),RAt("\",GetSrvProfString("RootPath",""))+1)
	//Local cPathPrg := '"'+GetSrvProfString("PDFtk","E:\TOTVS12\Microsiga\"+cNomePData+"\PDFtk\")
	Local cPathPrg := '"'+GetSrvProfString("PDFtk",GetSrvProfString("RootPath","")+"\PDFtk\")
	//Local cPathTC1 := '"'+GetSrvProfString("termodeconduta1","E:\TOTVS12\Microsiga\"+cNomePData+"\termodeconduta\")+"termodeconduta1.pdf"+'"'
	//Local cPathAss := '"'+GetSrvProfString("termodeconduta1","E:\TOTVS12\Microsiga\"+cNomePData+"\spool\")
	Local cPathAss := '"'+GetSrvProfString("termodeconduta1",GetSrvProfString("RootPath","")+"\spool\")
	//Local cPathTC3 := '"'+GetSrvProfString("termodeconduta3","E:\TOTVS12\Microsiga\"+cNomePData+"\termodeconduta\")+"termodeconduta3.pdf"+'"'
	Local cNewArq  := ""

	// ConOut(RAt("\",GetSrvProfString("RootPath",""))+1)
	// ConOut(cNomePData)

	cNomeArq := FAssinTF()

	// CpyT2S('E:\temp\'+cNomeArq, '\temp', .F. )
	// sleep(100)
	cFileNaPDF := SA2->(A2_COD+A2_LOJA)+".pdf"
	cPathAssB := cPathAss+cNomeArq+'.pdf"'
	cNewArq  := cPathAss+cFileNaPDF
	cRelSpooP := "\spool\"+cFileNaPDF
	cRelSpooT:= "\spool\"+cNomeArq+".pdf"

	//cTxt2Pdf := cPathPrg+'pdftk.exe" '+cPathTC1+' '+cPathAssB+' '+cPathTC3+' cat output '+cNewArq
	cTxt2Pdf := cPathPrg+'pdftk.exe" '+cPathAssB+' cat output '+cNewArq

	// ConOut(cTxt2Pdf)

	lSucess  := WaitRunSrv(cTxt2Pdf,.T.,GetSrvProfString("RootPath","")+"\Temp\")

	If lSucess
		fCopyFTP(cRelSpooP, cFileNaPDF)

		If File(cRelSpooP)
			FErase(cRelSpooP)
		EndIf


		If File(cRelSpooT)
			FErase(cRelSpooT)
		EndIf
	EndIf

Return

/*/    
	Envia para o FTP

	@author -
	@since 07/12/2021
/*/
Static Function FAssinTF()

	Local cTexto := "", nO
	Local lDisabeSetup := .T.
	Local lDisableLega := .F.

	Local cNomeArq     := "termocond"+dtos(date())+StrTran(Time(),":","")+".pdf"

	Private oPrint

//Linhas e colunas
	Private nLinAtu    := 10
	Private nLinFin    := 800
	Private nColIni    := 020
	Private nColFin    := 570
	Private cCaminho	:="\spool\"
	Private cFileName   := FWUUIDV4(.F.)
	Private cFilPrtPDF	:=	cFileName+".pdf"

	If File(cCaminho+cFilPrtPDF)
		FERASE(cCaminho+cFilPrtPDF)
	EndIf


	oFontTit  := TFont():New("Arial Black",16,16		,,.F.		,,,,.T.,			.F.)
	oFontSub  := TFont():New("Arial Black",12,12		,,.F.		,,,,.T.,			.F.)
	oFontDad  := TFont():New("Arial Black",10,10		,,.F.		,,,,.T.,			.F.)
	oFontDet  := TFont():New("Arial"	  ,12,12		,,.F.		,,,,.F.,			.F.)

	oPrint := FWMSPrinter():New(cFileName, IMP_PDF, lDisableLega,, lDisabeSetup,,,,,,,.F.)
	oPrint:SetPortrait()
	oPrint:SetPaperSize(9) // Seta para papel A4
	oPrint:SetViewPDF(.F.)
	oPrint:lServer  :=  .T.
	// oPrint:cPathPDF:= "E:\temp\"

	If File("\spool\"+oPrint:cFileName+".pdf")
		FErase("\spool\"+oPrint:cFileName+".pdf")
	EndIf

	// Via SmartClient
	// If GetRemoteType() <> -1
	// 	oPrinter:LVIEWPDF :=   .F.
	// 	cCaminho    :=  GetTempPath(.T.)
	// 	cPathTPrin	:=	cCaminho+'totvsprinter\'+oPrint:cFileName+".pdf"
	// 	oPrinter:lServer  :=  .F.

	// 	oPrinter:cPathPDF := cCaminho//cCaminho // Caso seja utilizada impress�o em IMP_PDF
	// 	If File(cPathTPrin)
	// 		FErase(cPathTPrin)
	// 	EndIf

	// 	// Via JOB
	// else
	oPrint:lServer  :=  .T.

	oPrint:cPathPDF := "\spool\"

	// EndIF

	oPrint:StartPage()

	nLinAtu += 50

	cTexto := 'Termo de Aceite e Compromisso' + CRLF
	cTexto += "" + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,cTexto,oFontTit,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 50

	cTexto := 'Todos os fornecedores devem:' + CRLF
	cTexto += "" + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,cTexto,oFontSub,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 30

	cTexto := '- Cumprir todas as leis aplicáveis.' + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 15
	cTexto := '- Proibir atos de corrupção.' + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 15
	cTexto := '- Engajar-se na implementação de mecanismos de combate à corrupção, fraude, lavagem de dinheiro, cartel e outras ilicitudes à administração pública.' + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 35
	cTexto := '- Respeitar os direitos humanos básicos dos colaboradores.' + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 15
	cTexto := '- Proibir o trabalho escravo e o trabalho infantil.' + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 15
	cTexto := '- Assumir responsabilidade pela saúde e a segurança dos seus colaboradores.' + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 15
	cTexto := '- Agir de acordo com as normas locais e internacionais aplicáveis relativas à proteção ambiental.' + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 15
	cTexto := '- Promover, dentro de sua cadeia de fornecedores, o cumprimento desses requisitos.' + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 50

	cTexto := 'Razão Social:'
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDad,(nColFin - nColIni),300,,PAD_LEFT,)
	cTexto := SA2->A2_NOME + CRLF
	oPrint:SayAlign(nLinAtu, nColIni+80,cTexto,oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 25
	If AllTrim(SA2->A2_TIPO) == 'J'
		cTexto := 'CNPJ:'
		oPrint:SayAlign(nLinAtu, nColIni,cTexto,oFontDad,(nColFin - nColIni),300,,PAD_LEFT,)
		cTexto :=Transform(SA2->A2_CGC,"@R 99.999.999/9999-99") + CRLF
		oPrint:SayAlign(nLinAtu, nColIni+30,cTexto,oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	elseif AllTrim(SA2->A2_TIPO) == 'F'
		cTexto := 'CPF:'
		oPrint:SayAlign(nLinAtu, nColIni,cTexto,oFontDad,(nColFin - nColIni),300,,PAD_LEFT,)
		cTexto :=Transform(SA2->A2_CGC,"@R 999.999.999-99") + CRLF
		oPrint:SayAlign(nLinAtu, nColIni+30,cTexto,oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	EndIf
	nLinAtu += 25
	cTexto := 'Inscrição Estadual:'
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDad,(nColFin - nColIni),300,,PAD_LEFT,)
	cTexto := SA2->A2_INSCR + CRLF
	oPrint:SayAlign(nLinAtu, nColIni+105,cTexto,oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 25
	cTexto := 'Representante Legal:__________________________________'
	oPrint:SayAlign(nLinAtu, nColIni,cTexto,oFontDad,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 25
	cTexto := 'CPF:__________________________________________________'
	oPrint:SayAlign(nLinAtu, nColIni,cTexto,oFontDad,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 50

	cTexto := 'Declaro que:' + CRLF
	cTexto += "" + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontSub,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 30
	cTexto := '1. Li e concordo integralmente com os princípios contidos no Código de Ética dos Fornecedores da Unifique, cuja íntegra me foi entregue nesta data.' + CRLF
	cTexto += "" + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 45
	cTexto := '2. Comprometo me a cumprir os termos e condições transcritos neste Código e que buscarei me manter adequado a ele, desenvolvê-lo e integrá-lo a meus processos de gestão.' + CRLF
	cTexto += "" + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 45
	cTexto := '3. Estou ciente que a assinatura deste Termo de Compromisso não limita a liberdade da Unifique em termos de iniciar, manter, ampliar ou descontinuar relações comerciais com a empresa signa- tária.' + CRLF
	cTexto += "" + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 45
	cTexto := '4. Estou ciente que o descumprimento dos princípios e compromissos expressos neste Código poderá implicar na adoção de medidas disciplinares, desde o bloqueio do fornecedor para novas aquisições até o encerramento dos contratos vigentes.' + CRLF
	cTexto += "" + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,DecodeUTF8(cTexto, "cp1252"),oFontDet,(nColFin - nColIni),300,,PAD_LEFT,)
	nLinAtu += 90


	cTexto := 'Assinatura: _______________________________________________' + CRLF
	oPrint:SayAlign(nLinAtu, nColIni,cTexto,oFontSub,(nColFin - nColIni),300,,PAD_LEFT,)

	oPrint:EndPage()
	// oPrint:Preview()
	oPrint:Print()

	//Apaga arquivos de danfe menores que 1 dia
	aArqErase := directory(cCaminho+"\*.pdf")
	For nO := 1 To Len(aArqErase)
		If aArqErase[nO][3] < date()
			FERASE(cCaminho+aArqErase[nO][1])
		EndIf
	Next

Return cFileName


/*/    
	Envia para o FTP

	@author -
	@since 07/12/2021
/*/
Static Function fCopyFTP(cFilePathS, cFileName)

	Local cHost 	:= GetMv("MV_XHSTFTP", .F., "192.168.65.203")
	Local cPort 	:= GetMv("MV_XPRTFTP", .F., 3099)
	Local cUser 	:= GetMv("MV_XUSRFTP", .F., "unifique")
	Local cPassword := GetMv("MV_XPSWFTP", .F., "unifique_ftp")

//Copia para o FTP
	oFTPHandle := tFtpClient():New()

	oFTPHandle:bFireWallMode := .T.


	//nRet := oFTPHandle:FTPConnect("192.168.65.56", 1357 ,"usuario", "senha")
	nRet := oFTPHandle:FTPConnect(cHost, cPort , cUser, cPassword)

/*  a partir de: 06-04-2022
	HOST = 192.168.65.56
    PORTA = 1357
    USUARIO = superadmin000
    SENHA = mpSzTqCj6Dkl  */


	If nRet == 0
		nRet := oFTPHandle:ChDir("/ENVIO_FORNECEDOR/")
		If nRet == 0
			cPathFin := "/ENVIO_FORNECEDOR/"

			oFTPHandle:MkDir(cPathFin)

			nRet := oFTPHandle:ChDir(cPathFin)
			If nRet == 0
				nRet := oFTPHandle:SendFile(cFilePathS , cFileName)
			EndIf
		Endif

		oFTPHandle:Close()
	EndIf

Return
