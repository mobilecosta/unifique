#include 'Protheus.ch'
/*/{Protheus.doc} PMSAJEMB
Ponto de entrada para integração de centro de custo com a solicitação ao armazém
@type function
@version  P12
@author Mateus Ramos
@since 12/19/2023
@return variant, boolean
/*/
User Function PMSDLGSA(aCols, aHeader, aSavCols, aSavHeader, nLinha)

    Local nPosCC :=  aScan(aSavHeader, {|x| AllTrim(Upper(x[2])) == "CP_CC" }) //Posição do C.Custo do aHeader

    aSavCols[nLinha][nPosCC] := PadR(Alltrim(AF9->AF9_CCUSTO), TamSX3("CP_CC")[1]) //Expressão de tratamento para caso algum dia 
                                                                              //o tamanho dos campos venham a divergir
Return
