#Include 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
 
/*/{Protheus.doc} CNTA121
Ponto de entrada MVC da rotina Medição de contrato
@type   : User Function
@author : Rivaldo Junior
@since  : 09/01/2024
@return : return, return_type, return_description
/*/
User Function CNTA300()
     Local aParam   := PARAMIXB
     Local xRet     := .T.
     Local oModel   := ''
     Local cIdPonto := ''
     Local cIdModel := ''
  
     If aParam <> NIL
         oModel  := aParam[1]
         cIdPonto:= aParam[2]
         cIdModel:= aParam[3]
          
         If(cIdPonto == 'BUTTONBAR')
            xRet := { {'Importação de Itens', 'BUDGET', { |x| U_ImpItens() }, 'Botão customizado' } } //Uma opção nova será adicionada ao menu Outras Ações
         EndIf
     EndIf

Return xRet

User Function CTA100MNU

    aAdd(aRotina,{"Imp. Itens via CSV","U_ImpItens()",0,1,0,NIL,NIL,NIL})

Return
