#include 'Protheus.ch'
/*/{Protheus.doc} MT100LOK
P.E. na validação da linha do Documento de Entrada
@type function
@version P12
@author Mateus R
@since 12/30/2023
@return variant, boolean
/*/
User Function MT100LOK()

	Local nPosCC    := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_CC'})
	Local lRet 	:= .T.

	If "PMS" $ Funname()	//Integração centro de custo com o PMS
		aCols[n][nPosCC] := AF9->AF9_CCUSTO
	EndIf

Return lRet

