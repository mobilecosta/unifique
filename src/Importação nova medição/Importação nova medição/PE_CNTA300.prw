#Include 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
 
/*/{Protheus.doc} CNTA121
Ponto de entrada MVC da rotina Medi��o de contrato
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
            xRet := { {'Importa��o de Itens', 'BUDGET', { |x| U_ImpItens() }, 'Bot�o customizado' } } //Uma op��o nova ser� adicionada ao menu Outras A��es
         EndIf
     EndIf

Return xRet
