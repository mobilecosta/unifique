#include 'Protheus.ch'

/*/{Protheus.doc} INTPMSCC
Função de integração do financeiro com PMS via centro de custo
e item contábil
@type function
@version P12
@author Mateus R
@since 12/30/2023
@return variant, nil
/*/
User Function INTPMSCC(cCampo)

    Local cRet := ""

	If "PMS" $ Funname() .AND. !Empty(cCampo)
		Do Case
		Case FWIsInCallStack("FINA100") //Movimento Bancário
            If cCampo == "E5_CCUSTO"
                cRet := AF9->AF9_CCUSTO
            ElseIf cCampo == "E5_ITEMD"
			    cRet := AF8->AF8_XITCTB
            EndIf
		Case FWIsInCallStack("FINA050") //Contas a Pagar
            If cCampo == "E2_CCUSTO"
                cRet := AF9->AF9_CCUSTO
            ElseIf cCampo == "E2_ITEMCTA"
			    cRet := AF8->AF8_XITCTB
            EndIf
		Endcase
	EndIf

Return cRet
