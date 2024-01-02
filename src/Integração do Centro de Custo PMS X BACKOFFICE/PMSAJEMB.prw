#include 'Protheus.ch'
/*/{Protheus.doc} PMSAJEMB
Ponto de entrada para integração de centro de custo com o movimento bancário
@type function
@version  P12
@author Mateus Ramos
@since 12/19/2023
@return variant, boolean
/*/
User Function PMSAJEMB

	If Select("AF8") > 0
		M->E5_CCUSTO := AF9->AF9_CCUSTO
		M->E5_ITEMD  := AF8->AF8_XITCTB
	EndIf
	
Return .T.
































