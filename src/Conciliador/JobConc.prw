#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "Directry.ch"

/*/{Protheus.doc} ADSConcA
Programa principal para a concilia��o autom�tica.
@type   : User Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
/*/
User Function JobConc()
	Local lAtivAmb     := .F.
	Private cDiretorio := Alltrim(GetMV("MV_XDIREXT",,"Z:\inbox\transferidos\"))
	
	If Select("SX2") <= 0
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv("01","010001",,,"FIN",,{})
		lAtivAmb := .T.
	EndIf

	ImpFile(cDiretorio)

	If lAtivAmb
		RpcClearEnv()
	Endif

Return

/*/{Protheus.doc}
Fun��o para importar os dados do arquivo e grav�-los na tabela.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
/*/
Static Function ImpFile(cDiretorio)

	Local aAreaZ0C	:= Z0C->(GetArea())
	Local aFiles	:= {}
	Local nFile		:= 0
	Private oJTable := U_ADSTab2J("Z0C")

	// Coleta todos arquivos da pasta.
	aFiles := Directory(cDiretorio + "EXT_*.RET")

	Z0C->(DBSetOrder(2))

	For nFile := 1 To Len(aFiles)
		If !Z0C->(DBSeek(xFilial("Z0C") + Upper(aFiles[nFile][F_NAME])))
			ReadFile(aFiles[nFile])
		Else
			ShowHelpDlg("IsImp",{"Arquivo j� importado: " + AllTrim(aFiles[nFile][F_NAME])},1,{},0)
		EndIf
	Next nFile

	RestArea(aAreaZ0C)

	WriteData()

Return

/*/{Protheus.doc} ReadFile
Fun��o respons�vel por ler o arquivo e estrutura os dados conforme a tabela de configura��es.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 10/09/2019
@version: 1.00
@param  : aFile, array, estrutura do arquivo.
/*/
Static Function ReadFile(aFile)

	Local aLines	:= {}
	Local cField	:= ""
	Local cLine		:= ""
	Local nField	:= 0
	Local nLine		:= 0
	Local oFile		:= Nil
	Local oJCNAB 	:= U_ADSCNAB()

	oFile := FWFileReader():New(cDiretorio + aFile[F_NAME])

	If oFile:Open()
		aLines := oFile:GetAllLines()
		oFile:Close()

		For nLine := 1 To Len(aLines)
			cLine := aLines[nLine]

			// Somente registros detalhe.
			If SubStr(cLine,8,1) == "3"
				// Nova linha.
				AAdd(oJTable["Data"],Array(Len(oJTable["Header"])))

				// Informa dados referente a importa��o.
				ATail(oJTable["Data"])[U_ADSAScan(oJTable["Header"],"Z0C_FILE")] := Upper(aFile[F_NAME])
				ATail(oJTable["Data"])[U_ADSAScan(oJTable["Header"],"Z0C_USER")] := cUserName
				ATail(oJTable["Data"])[U_ADSAScan(oJTable["Header"],"Z0C_DTIMP")] := Date()
				ATail(oJTable["Data"])[U_ADSAScan(oJTable["Header"],"Z0C_LINE")] := cLine

				For nField := 1 To Len(oJCNAB["CNAB"])
					// Coleta o campo e conte�do conforme o CNAB.
					cField := "Z0C_" + oJCNAB["CNAB"][nField]["Campo"]
					cValue := SubStr(cLine,oJCNAB["CNAB"][nField]["Inicio"],oJCNAB["CNAB"][nField]["Tamanho"])
					// Armazena o conte�do no JSON da tabela.
					ATail(oJTable["Data"])[U_ADSAScan(oJTable["Header"],cField)] := CToType(cValue,oJTable["Header"][U_ADSAScan(oJTable["Header"],cField)])
				Next nField
			EndIf
		Next nLine
	Else
		ShowHelpDlg("NoOpen",{"N�o foi poss�vel abrir o arquivo informado."},1,{"Tente novamente."},1)
	EndIf

	FreeObj(oFile)

Return

/*/{Protheus.doc} CToType
Fun��o para converter o dado de characters para o tipo informado.
@type 	: Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since	: 23/11/2019
@version: 1.0
@param	: cValue, characters, valor em caracter que ser� convertido.
@param	: oHeader, object, JSON do header do dado que ser� convertido.
@return	: xConvVal, undefined, dado convertido.
/*/
Static Function CToType(cValue,oHeader)

	Local xConvVal := Nil

	Do Case
		// N�mero.
		Case oHeader["Tipo"] == "N"
			xConvVal := Val(cValue)/(10^oHeader["Decimal"])
		// Data.
		Case oHeader["Tipo"] == "D"
			xConvVal := SToD(Right(cValue,4) + SubStr(cValue,3,2) + Left(cValue,2))
		// L�gico.
		Case oHeader["Tipo"] == "L"
			xConvVal := Upper(AllTrim(cValue)) == ".T."
		// Outro.
		OtherWise
			If AllTrim(oHeader["Campo"]) $ "Z0C_AGENC|Z0C_CONTA"
				// Tratativa para Caixa.
				If AllTrim(oHeader["Campo"]) == "Z0C_CONTA" .And. cValue == "003000000690"
					xConvVal := "690"
				ElseIf AllTrim(oHeader["Campo"]) == "Z0C_AGENC"
					xConvVal := StrZero(Val(cValue),4)
				Else
					xConvVal := cValToChar(Val(cValue))
				EndIf
			Else
				xConvVal := Upper(AllTrim(cValue))
			EndIf
	EndCase

Return xConvVal

/*/{Protheus.doc} WriteData
Fun��o para persistir os dados lidos do arquivo.
@type 	: Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since	: 23/11/2019
@version: 1.0
/*/
Static Function WriteData()

	Local nCol	:= 0
	Local nLine := 0
	Local nPos	:= 0

	Begin Transaction
		For nLine := 1 To Len(oJTable["Data"])

			RecLock("Z0C",.T.)
				For nCol := 1 To Len(oJTable["Header"])
					// Se o campo for encontrado, grava o seu conte�do.
					If (nPos := Z0C->(FieldPos(oJTable["Header"][nCol]["Campo"]))) > 0 .And. !Empty(oJTable["Data"][nLine][nCol])
						Z0C->(FieldPut(nPos,oJTable["Data"][nLine][nCol]))
					EndIf
				Next nCol
				// Informa filial posicionada.
				Z0C->Z0C_FILIAL := xFilial("Z0C")
			Z0C->(MsUnlock())
			//Verifica se � taxa e realiza a grava��o no SE5
			If Z0C->Z0C_CATLAN $ "105" .OR. SubStr(Z0C->Z0C_HIST,1,3) == 'TAR'
				GeraTaxa(Z0C->Z0C_DATA, "M1", Z0C->Z0C_VALOR, "20106001", Z0C->Z0C_BANCO, Z0C->Z0C_AGENC, Z0C->Z0C_CONTA, Z0C->Z0C_DOC, Z0C->Z0C_HIST)
			Endif
			//Fim
		Next nLine
	End Transaction

Return

/*/{Protheus.doc} GeraTaxa
Fun��o para realizar a grava�ao das taxas.
@type   : Static Function
@author : Walter Rodrigo
@since  : 08/12/2023
@version: 1.00
@param  : dDataInfo, cMoeda, nValor, cNatureza, cBanco, cAgencia, cConta, cHistorico
/*/
Static Function GeraTaxa(dDataInfo, cMoeda, nValor, cNatureza, cBanco, cAgencia, cConta, cDocumen, cHistorico)
	
	Local aFINA100 := {}
	Private lMsErroAuto := .F.
	
	aFINA100 := { {"E5_DATA"    , dDataInfo                 , Nil},;
				  {"E5_MOEDA"   , cMoeda                    , Nil},;
				  {"E5_VALOR"   , nValor                    , Nil},;
				  {"E5_NATUREZ" , cNatureza                 , Nil},;
				  {"E5_BANCO"   , cBanco                    , Nil},;
				  {"E5_AGENCIA" , cAgencia                  , Nil},;
				  {"E5_CONTA"   , cConta                    , Nil},;
				  {"E5_BENEF"   , "Tarifa automatica"       , Nil},;
				  {"E5_DOCUMEN" , cDocumen                  , Nil},;
				  {"E5_HISTOR"  , "Tarifa aut." + cHistorico, Nil}}

	MSExecAuto({|x,y,z| FinA100(x,y,z)}, 0, aFINA100, 3)

	If lMsErroAuto
		MostraErro()
	EndIf
Return
