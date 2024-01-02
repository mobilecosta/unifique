#include "PROTHEUS.CH"

/*/{Protheus.doc} HistorLP
Função para retornar o historico para o LP.
@type   : User Function
@author : Walter Rodrigo
@version: 1.00
@param  : oJSON, object, json com header e detail.
/*/
User Function HistorLP(cLP, cCampo)
    Local cUserCtb  := " User Ctb " + SUBSTR(USUÁRIO,7,15)
    Local cDataInfo := " " + Dtoc(Date())
    Local cUserInc  := " User Inclusão " + Alltrim(FWLeUserlg(cCampo, 1))
    Local cHistor   := cLP + cUserCtb + cDataInfo + cUserInc

Return cHistor
