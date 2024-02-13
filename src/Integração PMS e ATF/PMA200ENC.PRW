#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "FWMVCDEF.CH"

User Function PMA200ENC()


	Local lRet := PARAMIXB[1]

	//verifica se houve encerramento de projeto
	If lRet .And. M->AF8_FASE == "04"	// Somente gera o Ativo na fase 04
		U_GeraATF() //chamada da função para inclusão de bem no Ativo Fixo
	
	Endif


return lRet
