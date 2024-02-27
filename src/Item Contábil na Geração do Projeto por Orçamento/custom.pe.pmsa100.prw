//-------------------------------------------------------------------
/*/{Protheus.doc} PM100ITCTB
DESC: Valida��o do item contabil

@sample		PM100ITCTB()
@return 	NIL
@author		Mobile/Washington
@since		27/02/2024
@version 	P12
/*/
//--------------------------------------------------------------------
USER FUNCTION P100ITCT
	Local lRet := .T.

	If LEN(AllTrim(M->AF1_XITCTB)) <> 6
		ALERT("Aten��o. O Item cont�bil deve ter 6 caracteres")
		lRet := .F.
	Endif  

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PMA100Alt
DESC: Ponto de entrada na grava��o do item contabil

@sample		PMA100Alt()
@return 	NIL
@author		Mobile/Washington
@since		27/02/2024
@version 	P12
/*/
//--------------------------------------------------------------------

User Function PMA100Alt

Local lRet := U_P100ITCT()

Return lRet