#include 'Protheus.ch'
/*/{Protheus.doc} PMSAJEMB
Ponto de entrada para integração de centro de custo com o contas a pagar
@type function
@version  P12
@author Mateus Ramos
@since 12/19/2023
@return variant, boolean
/*/
User Function PMSDLGFI(aCols, aHeader)

    If Select("AF8") > 0
        M->E2_CCUSTO    := AF9->AF9_CCUSTO
        M->E2_ITEMCTA   := AF8->AF8_XITCTB
    EndIf

Return
