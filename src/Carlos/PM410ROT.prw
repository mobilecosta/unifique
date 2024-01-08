#include 'protheus.ch'

User Function PM410ROT()

	Local aArea 	:= GetArea()
	Local aUsrBot := {}

	aAdd(aUsrBot,{ "Importar Projeto" , "U_COPMSIMP()"    , 0 , 4} )
	aAdd(aUsrBot,{ "Exportar Projeto" , "U_COPMSEXP()"    , 0 , 4} )

	RestArea(aArea)

Return(aUsrBot)


