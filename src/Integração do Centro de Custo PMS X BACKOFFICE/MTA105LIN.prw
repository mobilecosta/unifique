#include 'Protheus.ch'
/*/{Protheus.doc} MTA105LIN
P.E. na valida��o da linha da Solicita��o ao Almoxarifado
@type function
@version P12
@author Mateus R
@since 12/30/2023
@return variant, boolean
/*/
User Function MTA105LIN()

	Local nPosCC    := aScan(aHeader,{|x| AllTrim(x[2]) == 'CP_CC'})
	Local nPosICT   := aScan(aHeader,{|x| AllTrim(x[2]) == 'CP_ITEMCTA'})

	Local lRet 	:= .T.

	If "PMS" $ Funname()	//Integra��o centro de custo e item cont�bil com o PMS
		aCols[n][nPosCC]  := AF9->AF9_CCUSTO
		aCols[n][nPosICT] := AF8->AF8_XITCTB
	EndIf

Return lRet
