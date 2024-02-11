#Include 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
 
/*/{Protheus.doc} CNTA121
Ponto de entrada MVC da rotina Medição de contrato
@type   : User Function
@author : Rivaldo Junior
@since  : 09/01/2024
@return : return, return_type, return_description
/*/

User Function CNTA121()
     Local aParam := PARAMIXB
     Local xRet := .T.
     Local oModel := ''
     Local cIdPonto := ''
     Local cIdModel := ''
  
     If aParam <> NIL
         oModel  := aParam[1]
         cIdPonto:= aParam[2]
         cIdModel:= aParam[3]
          
         If(cIdPonto == 'BUTTONBAR')
            xRet := { {'Imp. Quantidade Itens', 'BUDGET', { |x| U_ImpCNTA121() }, 'Botão customizado' } } //Uma opção nova será adicionada ao menu Outras Ações
         EndIf
     EndIf

Return xRet
