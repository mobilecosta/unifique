#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
 
/*{Protheus.doc} CNTA121()
   Possibilitar ao desenvolvedor realizar a mesma opera��o anteriormente feita no ponto de entrada CN130BUT
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
            xRet := { {'Bot�o customizado', 'BUDGET', { |x| U_Exemplo(x) }, 'Bot�o customizado' } } //Uma op��o nova ser� adicionada ao menu Outras A��es
         EndIf
     EndIf
 Return xRet
 
User Function Exemplo(oView)
    Local oModel    := oView:GetModel()
    Local nOpc      := oModel:GetOperation()   
 
    Alert( 'A��o customizada.' )
 
Return


