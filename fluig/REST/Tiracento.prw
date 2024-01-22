#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"


*---------------------------*
User Function TIRACENTO(_cVar)
*---------------------------*

Local	_cnt

If Empty(_cVar)
	_cVar:=" "
	Return(_cVar)	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Matriz de codigos ASCII para procura de posicao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aAce := { ASC("á"),ASC("Á"),ASC("ã"),ASC("Ã"),ASC("ä"),ASC("Ä"),ASC("à"),ASC("À"),;
		ASC("é"),ASC("É"),ASC("ë"),ASC("Ë"),ASC("è"),ASC("È"),;
		ASC("í"),ASC("Í"),ASC("ï"),ASC("Ï"),ASC("ì"),ASC("Ì"),;
		ASC("ó"),ASC("Ó"),ASC("õ"),ASC("Õ"),ASC("ö"),ASC("Ö"),ASC("ò"),ASC("Ò"),;
		ASC("ú"),ASC("Ú"),ASC("ü"),ASC("Ü"),ASC("ù"),ASC("Ù"),;
		ASC("ç"),ASC("Ç"),;
		ASC("â"),ASC("ê"),ASC("î"),ASC("ô"),ASC("û"),;
		ASC("Â"),ASC("Ê"),ASC("Î"),ASC("Ô"),ASC("Û"),;
		ASC("ÿ"),ASC("ª"),ASC("º"),ASC("½"),ASC("¼"),")","(","-",",",ASC(""),'"'}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Matriz de caracteres que serao trocados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aSac := { "a","A","a","A","a","A","a","A",;
             "e","E","e","E","e","E",;
             "i","I","i","I","i","I",;
             "o","O","o","O","o","O","o","O",;
             "u","U","u","U","u","U",;
             "c","C",;
             "a","e","i","o","u",;
             "A","E","I","O","U",;
             "Y","a","o","*","*",","," "," "," "," "," "," "}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Matriz ASCII referentes aos acentuos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aMat := { "á","Á","ã","Ã","ä","Ä","à","À",;
              "é","É","ë","Ë","è","È",;
              "í","Í","ï","Ï","ì","Ì",;
              "ó","Ó","õ","Õ","ö","Ö","ò","Ò",;
              "ú","Ú","ü","Ü","ù","Ù",;
              "ç","Ç",;
              "â","ê","î","ô","û",;
              "Â","Ê","Î","Ô","Û",;
              "ÿ","ª","º","½","¼",")","(","-",",","",'"' }

_cnt := 0
_nPos:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Laco para verificar todas as posicoes da string ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For _cnt := 1 to len(RTRIM(_cVar))
	
    _nPos := ascan(_aAce, ASC(substr(_cVar,_cnt,1)))	    // Identifica posicao

    If !_nPos==0 
         _cVar:=strtran(_cVar,_aMAT[_nPos],_aSac[_nPos])	// Faz a troca    	 
    Endif
Next _cnt 

_cVar := StrTran(_cVar,CHR(13)+CHR(10)," ")
_cVar := StrTran(_cVar,CHR(13)," ")
_cVar := StrTran(_cVar,CHR(10)," ")

_cVar:=Upper(_cVar)

Return(_cVar)   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ PROTXMCC ³ Autor ³ Vitor Felipe        ³ Data ³ 20/12/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Integração PROTHEUS x MCC Medições de Servico.   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PROTXMCC(cOPC,cFilBX)

Local lRet		:= .F.
Local cAlias	:= GetNextAlias()
Local aRet		:= {}
Local lOk		:= .F.

Default cOPC := ""
Default cFilBX := cFilAnt

Do Case
	//INCLUSAO DO TITULO -->>
	Case AllTrim(cOPC) == "1"
		If TcSpExist("P_MCC_SIGA_INTEGRA_TITULO")
			aRet := TcSpExec("P_MCC_SIGA_INTEGRA_TITULO",cFilAnt,SE1->E1_FILIAL,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"NF ")
			lOk := .T.	
		EndIf

	 //EXCLUSAO DO TITULO -->>	
	Case AllTrim(cOPC) == "2"
		If TcSpExist("P_MCC_SIGA_ESTORNA_TITULO")
			aRet := TcSpExec("P_MCC_SIGA_ESTORNA_TITULO",cFilAnt,SF2->F2_FILIAL,SF2->F2_PREFIXO,SF2->F2_DOC," ","NF ",SF2->(RECNO()))
			lOk := .T.
		EndIf	
		
	 //BAIXA DO TITULO -->>	
	Case AllTrim(cOPC) == "3"		
		If TcSpExist("P_MCC_SIGA_INTEGRA_BAIXA")
			aRet := TcSpExec("P_MCC_SIGA_INTEGRA_BAIXA",cFilBX,SE5->E5_FILIAL,SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_SEQ)
			lOk := .T.
		EndIf	
		
 	 //ESTORNA BAIXA DO TITULO -->>	
	Case AllTrim(cOPC) == "4"
		If TcSpExist("P_MCC_SIGA_ESTORNA_BAIXA")
			aRet := TcSpExec("P_MCC_SIGA_ESTORNA_BAIXA",cFilBX,SE5->E5_FILIAL,SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_SEQ)
			lOk := .T.
		EndIf	
EndCase

//PROCESSA RESULTADO DA PROCEDURE MCC
If lOk
	If aRet == Nil
		Alert(TcSQLError())
	Else
		If AllTrim(aRet[1]) <> 'OK' // Solicitado por Hiemer, exibir mensagem enviada pelo SGE quando diferente de OK
			Aviso("Atencao!",aRet[1],{"OK"},2)
		Else
			TcSQLExec("Commit")
			lRet := .T.
		EndIf
	EndIf
Else
	Alert("Erro na Procedure de integração Protheus X MCC, entrar em contato com o Administrador")
EndIf

	
Return(lRet)          

*******************************************************
User Function fProxCod(_xAlias,_xCampo,nTam,_cFiltro)
*******************************************************
Local aArea := GetArea()
Local cRet  := StrZero(1,nTam)

DbSelectArea(_xAlias)

cQuery := " SELECT MAX(" + _XCAMPO + ") PROXCOD " 
cQuery += " FROM " + RetSqlName(_xAlias)
cQuery += " WHERE D_E_L_E_T_ = ' ' "

If !Empty(_cFiltro)
  cQuery += " AND " + _cFiltro
Endif

TcQuery cQuery Alias "TRB" New

TRB->(DbGoTop())

If !Empty(TRB->PROXCOD)
   cRet := Left(Soma1(Alltrim(TRB->PROXCOD)),nTam)
Endif   

DbCloseArea("TRB")

RestArea(aArea)

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ PROTXMCC ³ Autor ³ Vitor Felipe        ³ Data ³ 20/12/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Integração PROTHEUS x MCC Medições de Servico.   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User Function PROTXMCC(cOPC,cFilBX)

Local lRet		:= .F.
Local cAlias	:= GetNextAlias()
Local aRet		:= {}
Local lOk		:= .F.

Default cOPC := ""
Default cFilBX := cFilAnt

Do Case		
	 //BAIXA DO TITULO -->>	
	Case AllTrim(cOPC) == "3"		
		If TcSpExist("P_MCC_SIGA_INTEGRA_BAIXA")
			aRet := TcSpExec("P_MCC_SIGA_INTEGRA_BAIXA",cFilBX,SE5->E5_FILIAL,SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_SEQ)
			lOk := .T.
		EndIf	
		
 	 //ESTORNA BAIXA DO TITULO -->>	
	Case AllTrim(cOPC) == "4"
		If TcSpExist("P_MCC_SIGA_ESTORNA_BAIXA")
			aRet := TcSpExec("P_MCC_SIGA_ESTORNA_BAIXA",cFilBX,SE5->E5_FILIAL,SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_SEQ)
			lOk := .T.
		EndIf	
EndCase

//PROCESSA RESULTADO DA PROCEDURE MCC
If lOk
	If aRet == Nil
		Alert(TcSQLError())
	Else
		If AllTrim(aRet[1]) <> 'OK' // Solicitado por Hiemer, exibir mensagem enviada pelo SGE quando diferente de OK
			Aviso("Atencao!",aRet[1],{"OK"},2)
		Else
			TcSQLExec("Commit")
			lRet := .T.
		EndIf
	EndIf
Else
	Alert("Erro na Procedure de integração Protheus X MCC, entrar em contato com o Adminstrador")
EndIf

	
Return(lRet)
*/

******************************
User Function QGQINTEGRA(cRet)
******************************
Local _aAux   		:= {}
Local i       		:= 0
Local aArea			:= GetArea()
Local _aAreaSM0 	:= {}
Local _oAppBk 		:= oApp //Guardo a variavel resposavel por componentes visuais

dbSelectArea("SM0")
_aAreaSM0 	:= SM0->(GetArea())
_cEmpBkp 	:= SM0->M0_CODIGO //Guardo a empresa atual
_cFilBkp 	:= SM0->M0_CODFIL //Guardo a filial atual
	
//Lista Empresas que usuario tem Acesso
//Retorno - array
//1 - Codigo da empresa
//2 - Nome da empresa
//3 - Codigo da filial
//4 - Nome da filials
_aAux := FWEmpLoad(.F.)

For i := 1 to Len(_aAux)
						//troco de empresa
	dbCloseAll() 		//Fecho todos os arquivos abertos
	OpenSM0() 			//Abrir Tabela SM0 (Empresa/Filial)
	dbSelectArea("SM0") //Abro a SM0
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(_aAux[i][1] + _aAux[i][3],.T.)) 	//Posiciona Empresa
	cEmpAnt := SM0->M0_CODIGO 						//Seto as variaveis de ambiente
	cFilAnt := SM0->M0_CODFIL
	
	IF SELECT("TRB_TOP") > 0 ; dbSelectArea("TRB_TOP") ; TRB_TOP->(DBCLOSEAREA()) ; ENDIF
	
	cQuery := "SELECT * FROM XXD XX WHERE XX.D_E_L_E_T_ = '' AND XXD_EMPPRO = '"+cEmpAnt+"' AND XXD_FILPRO = '"+cFilAnt+"' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TRB_TOP",.F.,.T.)
	dbSelectArea("TRB_TOP")
	
	If TRB_TOP->(Eof()) ; TRB_TOP->(DbCloseArea()) ; Loop ; EndIf
	
	OpenFile(cEmpAnt + cFilAnt) 					//Abro a empresa que eu desejo trabalhar

	Begin Transaction
		If cRet == "1"
			DbSelectArea("SA2")
			DbSetOrder(1)    
			If DbSeek(xFilial("SA2") + SA2->A2_COD) 
				FwIntegDef("MATA020")
			EndIf
		ElseIf cRet == "2"
			DbSelectArea("SB1")
			DbSetOrder(1)    
			If DbSeek(xFilial("SB1") + SB1->B1_COD) 
				FwIntegDef("MATA010")
			EndIf
		EndIf	
	End Transaction	
	
Next i

dbCloseAll() 		//Fecho todos os arquivos abertos
OpenSM0() 			//Abrir Tabela SM0 (Empresa/Filial)
dbSelectArea("SM0")
SM0->(dbSetOrder(1))
SM0->(RestArea(_aAreaSM0)) 	//Restaura Tabela
cFilAnt := SM0->M0_CODFIL 	//Restaura variaveis de ambiente
cEmpAnt := SM0->M0_CODIGO
	
OpenFile(cEmpAnt + cFilAnt) //Abertura das tabelas
oApp := _oAppBk 			//Backup do componente visual

RestArea(aArea)
Return         

*------------------------*
User Function QGValidNF()
*------------------------*
Local cTab := GetNextAlias()

BeginSQL Alias cTab

SELECT *
  FROM %table:SF1% SF1
 WHERE SF1.%notdel%
   AND F1_FILIAL = %xFilial:SF1%
   AND F1_DOC = %Exp:cNFiscal%
   AND F1_FORNECE = %Exp:ca100for%
   AND F1_LOJA = %Exp:cLoja%

EndSQL

DbSelectArea(cTab)
If !(cTab)->(Eof())
    Aviso("Atenção","Já foi incluído documento de entrada com mesmo número e fornecedor. Verifique!",{"Fechar"})
EndIf                                                                                                           

(cTab)->(DbCloseArea())

Return(.T.)


