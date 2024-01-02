#include 'Protheus.ch'
/*/{Protheus.doc} PMSAJEMB
Ponto de entrada para integra��o de centro de custo com SC na tela de planejamento
@type function
@version  P12
@author Mateus Ramos
@since 12/19/2023
@return variant, boolean
/*/
User Function PMSGRVSC

    If !Empty(AFK->AFK_TRFDE) .AND. Alltrim(AFK->AFK_TRFDE) == Alltrim(AFK->AFK_TRFATE)
        Reclock("SC1", .F.)
        SC1->C1_CC := Posicione("AF9",5,FWxFilial("AF9")+AFK->AFK_PROJET+AFK->AFK_TRFDE, "AF9_CCUSTO")
        SC1->(MsUnlock())
    Else
        FWAlertWarning("Nenhuma tarefa espec�fica informada / m�ltiplas tarefas informadas." + Chr(10) + Chr(13);
        +"C. Custo n�o ser� informado na solicita��o de compras.",;
        "Aten��o")
    EndIf

Return
