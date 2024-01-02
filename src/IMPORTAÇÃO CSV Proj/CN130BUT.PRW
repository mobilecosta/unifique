#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
 
/*{Protheus.doc} CNTA121()
   Possibilitar ao desenvolvedor realizar a mesma operação anteriormente feita no ponto de entrada CN130BUT
*/
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
            xRet := { {'Botão customizado', 'BUDGET', { |x| U_Exemplo(x) }, 'Botão customizado' } } //Uma opção nova será adicionada ao menu Outras Ações
         EndIf
     EndIf
 Return xRet
 
User Function Exemplo(oView)
    Local oModel    := oView:GetModel()
    Local nOpc      := oModel:GetOperation()   
 
    Alert( 'Ação customizada.' )
 
Return


