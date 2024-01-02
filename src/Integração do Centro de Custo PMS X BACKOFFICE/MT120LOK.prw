#include 'Protheus.ch'
/*/{Protheus.doc} MT120LOK
P.E. na validação da linha do Pedido de Compras
@type function
@version P12
@author Mateus R
@since 12/30/2023
@return variant, boolean
/*/
User Function MT120LOK()

	Local nPosCC    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_CC'})
	Local nPosICT   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEMCTA'})

	Local lRet 	:= .T.

	If "PMS" $ Funname()	//Integração centro de custo e item contábil com o PMS
		aCols[n][nPosCC]  := AF9->AF9_CCUSTO
		aCols[n][nPosICT] := AF8->AF8_XITCTB
	EndIf

Return lRet
