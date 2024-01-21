#Include 'totvs.ch'
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PMA241ROT
DESC: Ponto de entrada na finalização da revisão

If ExistBlock( "PM410ROT" )
	If ValType( aUsRotina := ExecBlock( "PM410ROT", .F., .F. ) ) == "A"
		AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
	EndIf
EndIf

@sample		PM410ROT()
@return 	NIL
@author		Mobile/Washington
@since		21/01/2024
@version 	P12
/*/
//--------------------------------------------------------------------

User Function PM410ROT()

Local aRotina := {}

/*
  Public 34: __CUSERID(C) :000000
*/

IF __cUSerId $ SuperGetMv("UN_PM410PV", .F., "000000")
	ADD OPTION aRotina TITLE "Aprovar"	ACTION "U_PM410Apv"  OPERATION 2 ACCESS 0
EndIF

Return aRotina

User Function PM410Apv

	IF AF8->AF8_FASE <> "05"
		Alert("Esse projeto não precisa ser aprovado !")
		Return
	EndIF

	If ! MsgYesNo("Confirma a aprovação do projeto [" + AF8->AF8_PROJET + "]")
		Return .F.
	EndIF

	RecLock("AF8",.F.)
	AF8->AF8_FASE := "01"
	AF8->(MsUnLock())

Return
