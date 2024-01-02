#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

User Function MT103FIM()
	//ponto de entrada pós gravação de documento de entrada
	Local lRet := .T.
	local cParam := ""

	cParam := SUPERGETMV("MV_XTSCIAP", .F., "",)

	cQuery := "SELECT * "
	cQuery += " FROM "+RetSQLName('SD1')+" D1"
	cQuery += " WHERE D1.D_E_L_E_T_ <> '*'  "
	cQuery += " AND D1_FILIAL ='"+SF1->F1_FILIAL+"'"
	cQuery += " AND D1_DOC = '"+SF1->F1_DOC+"'"
	cQuery += " AND D1_SERIE ='"+SF1->F1_SERIE+"'"
	cQuery += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"'"
	cQuery += " AND D1_LOJA ='"+SF1->F1_LOJA+"'"
	cQuery += " ORDER BY D1_DOC"
	MPSysOpenQuery(cQuery,"TMP")

	While TMP->(!EOF())
		If TMP->D1_TES $ cParam
			cProduto := TMP->D1_COD
			cCodFor  := TMP->D1_FORNECE
			cLoja    := TMP->D1_LOJA
			cDocNF   := TMP->D1_DOC
			cSerNF   := TMP->D1_SERIE
			dDtdg    := TMP->D1_DTDIGIT
			dDtEmi   := TMP->D1_EMISSAO
			nQuant	 := TMP->D1_QUANT
			nValicms := TMP->D1_VALICM/TMP->D1_QUANT*nQuant
			cItem    := TMP->D1_ITEM
			cTipDoc  := SF1->F1_ESPECIE

			GeraCiap(cProduto, cCodFor, cLoja, cDocNF, cSerNF,cTipDoc, dDtDg, dDtEmi, nQuant,nValIcms, cItem)
		endif
		TMP->(DBSKIP())
	End

Return lRet

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | GeraCiap | Autor |    Helton Silva                               |*
*+------------+------------------------------------------------------------------+*
*|Data        | 01.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Função para geração automatica do CIAP                           |*
**********************************************************************************/
Static Function GeraCiap(cProduto, cCodFor, cLoja, cDocNF, cSerNF,cTipDoc, dDtDg, dDtEmi,nQtde, nValIcms, cItem)
			
	Local nFor := 0
    
    For nFor := 1 To nQtde
		SF9->(RecLock( "SF9", .T. )) //Reclock 
            SF9->F9_FILIAL := xFilial('SF9')
			SF9->F9_CODIGO := GetCodF9(xFilial('SF9'),cDocNF,cSerNF)
			SF9->F9_CODPROD  := cProduto
			SF9->F9_DESCRI  := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
			SF9->F9_FORNECE := cCodFor
			SF9->F9_LOJAFOR := cLoja
			SF9->F9_DOCNFE  := cDocNF
			SF9->F9_SERNFE  := cSerNF
			SF9->F9_ITEMNFE := cItem
			SF9->F9_TPESP 	:= cTipDoc
			SF9->F9_PROPRIO := 'N'
			SF9->F9_DTENTNE := STOD(dDtDg)
			SF9->F9_DTEMINE := STOD(dDtEmi)
			SF9->F9_VALICMS := nValIcms/nQtde
			//SF9->F9_CFOENT 	:= cCfop
			SF9->F9_TIPO 	:= '02'
			SF9->F9_VALICMP := nValIcms/nQtde
		SF9->(MSUNLOCK())
	Next	
Return

Static Function GetCodF9(cFilSF9,cDocNF,cSerNF)
    Local cQuery := ""
    local cCodigo:= ""

    cQuery := "SELECT MAX(F9_CODIGO) as F9_CODIGO"
    cQuery += " FROM "+RetSQLName('SF9')+"" 
    cQuery += " WHERE F9_FILIAL = '"+cFilSF9+"' AND F9_DOCNFE = '"+cDocNF+"' AND F9_SERNFE = '"+cSerNF+"' AND D_E_L_E_T_ <> '*' "
    MPSysOpenQuery(cQuery,"Temp")

    If Temp->(!EOF())
        cCodigo := Temp->F9_CODIGO
        cCodigo := SOMA1(cCodigo)
    Else
        cCodigo := "000001"
    Endif
Return cCodigo
