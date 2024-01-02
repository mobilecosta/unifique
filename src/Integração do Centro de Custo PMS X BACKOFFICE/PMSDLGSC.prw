#include 'Protheus.ch'
/*/{Protheus.doc} PMSAJEMB
Ponto de entrada para integra��o de centro de custo com a solicita��o de compras
@type function
@version  P12
@author Mateus Ramos
@since 12/19/2023
@return variant, boolean
/*/
User Function PMSDLGSC(aCols, aHeader, aSavCols, aSavHeader, nLinha)

    Local nPosCC :=  aScan(aSavHeader, {|x| AllTrim(Upper(x[2])) == "C1_CC" }) //Posi��o do C.Custo do aHeader

    aSavCols[nLinha][nPosCC] := PadR(Alltrim(AF9->AF9_CCUSTO), TamSX3("C1_CC")[1])       

    aSavCols[nLinha][nPosCC] := PadR(Alltrim(AF9->AF9_CCUSTO), TamSX3("C1_CC")[1])  //Express�o de tratamento para caso algum dia 
                                                                                    //o tamanho dos campos venham a divergir
Return
