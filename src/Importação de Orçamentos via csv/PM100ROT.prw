#include 'Protheus.ch'
/*/{Protheus.doc} PM100ROT
Ponto de entrada para adi��o de bot�o na tela de or�amentos
@type function
@version 12
@author Mateus Ramos
@since 12/20/2023
@return variant, nil
/*/
User Function PM100ROT()
	Local aRot := {}

	aAdd(aRot, { 'Importar Or�amento','U_PMSIMPORC', 0 , 2} )
    
Return aRot
