#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'


*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | WSRALCADA  | Autor |                      	    	       |*
*+------------+------------------------------------------------------------+*
*|Data        | 30.11.2023                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Consulta da alçada de aprovação via REST		 	       |*
*+------------+------------------------------------------------------------+*
*|Solicitante |                                                            |*
*+------------+------------------------------------------------------------+*
*|Partida     | WebService	                                               |*
*+------------+------------------------------------------------------------+*
*|Arquivos    |                                                            |*
*+------------+------------------------------------------------------------+*
*|             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            |*
*+-------------------------------------------------------------------------+*
*| Programador       |   Data   | Motivo da alteracao                      |*
*+-------------------+----------+------------------------------------------+* 
*+-------------------+----------+------------------------------------------+*
*****************************************************************************

User Function WSRALCADA()
Return
	
WSRESTFUL WSRALCADA DESCRIPTION "Serviço REST para consulta da alçada de aprovação por CC e TIPO"

//WSDATA	FIL 		As String    
WSDATA	TIPO 		As String    
WSDATA	CCUSTO 		As String 

WSMETHOD GET DESCRIPTION "Retorna a alçada de aprovação por CC e TIPO." WSSYNTAX "/WSRALCADA || /WSRALCADA/{}"

END WSRESTFUL


WSMETHOD GET WSRECEIVE WSRALCADA  WSSERVICE WSRALCADA 
Local aCabNom  := {}
Local cJson    := "{"    
Local cTabela  := "ALCADA"
Local aDados   := {} 
Local cTab 
Local cTP, cCC  := ''

	::SetContentType("application/json; charset=UTF-8")
	
	cTP := UPPER(Self:TIPO)
	cCC :=  Self:CCUSTO

	//IF cTP = 'TIT'
	//	cQry :=	AL_XDOCTIT
	//ELSEIF cTP = 'PRJ'
	//	cQry := AL_XDOCPRJ
	//ENDIF

	 	
	cTab    := GetNextAlias()
		
	//------------CABEÇALHO------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	aCabNom := {"GRUPO","GRUPO_DESCRICAO","LOGIN","NOME","EMAIL","NIVEL","TIPO_APROVACAO","CC","CC_DESCRICAO","PERFIL","LIMITE_MINIMO","LIMITE_MAXIMO","LIMITE"} 


	IF cTP = 'TIT'

		BeginSQL Alias cTab 
	
		SELECT 
			AL_COD 		 GRUPO, 
			AL_DESC 	 GRUPO_DESCRICAO, 
			USR_CODIGO 	 LOGIN, 
			USR_NOME 	 NOME, 
			USR_EMAIL 	 EMAIL, 
			AL_NIVEL 	 NIVEL, 
			CASE
				WHEN AL_TPLIBER = 'U' THEN 'USUARIO'
				WHEN AL_TPLIBER = 'N' THEN 'NIVEL'
				WHEN AL_TPLIBER = 'P' THEN 'DOCUMENTO'
			END 		 TIPO_APROVACAO,                                                                                              
			DBL_CC 		 CC, 
			CTT_DESC01 	 CC_DESCRICAO, 
			DHL_DESCRI   PERFIL,
			DHL_LIMMIN   LIMITE_MINIMO,
			DHL_LIMMAX   LIMITE_MAXIMO,
			DHL_LIMITE   LIMITE

		FROM %table:CTT% CTT

			INNER JOIN %table:DBL% DBL
				ON DBL_FILIAL = %xFilial:DBL% 
			AND DBL_CC = CTT_CUSTO
			AND DBL.D_E_L_E_T_ = ' '

			INNER JOIN %table:SAL% AL
				ON AL_FILIAL = %xFilial:SAL% 
			AND AL_COD = DBL_GRUPO 		
			AND AL_XDOCTIT = '1'
			AND AL.D_E_L_E_T_ = ' '

			INNER JOIN SYS_USR 
				ON USR_ID = AL_USER
			
			LEFT JOIN %table:DHL% DHL 
				ON DHL_FILIAL = %xFilial:DHL% 
				AND DHL_COD = AL_PERFIL
				AND DHL.D_E_L_E_T_ = ''

		WHERE
			CTT_FILIAL = %xFilial:CTT% 
			AND CTT_CUSTO = DBL_CC
			AND CTT_BLOQ = '2'
			AND CTT_CUSTO =  %Exp:cCC%  //'600001   ' --Receber por parâmetro
			AND CTT.D_E_L_E_T_ = ' '

		ORDER BY AL_COD, AL_NIVEL, AL_TPLIBER
				
		EndSql		

	ELSEIF cTP = 'PRJ'

		BeginSQL Alias cTab 
	
		SELECT 
			AL_COD 		 GRUPO, 
			AL_DESC 	 GRUPO_DESCRICAO, 
			USR_CODIGO 	 LOGIN, 
			USR_NOME 	 NOME, 
			USR_EMAIL 	 EMAIL, 
			AL_NIVEL 	 NIVEL, 
			CASE
				WHEN AL_TPLIBER = 'U' THEN 'USUARIO'
				WHEN AL_TPLIBER = 'N' THEN 'NIVEL'
				WHEN AL_TPLIBER = 'P' THEN 'DOCUMENTO'
			END 		 TIPO_APROVACAO,                                                                                              
			DBL_CC 		 CC, 
			CTT_DESC01 	 CC_DESCRICAO, 
			DHL_DESCRI   PERFIL,
			DHL_LIMMIN   LIMITE_MINIMO,
			DHL_LIMMAX   LIMITE_MAXIMO,
			DHL_LIMITE   LIMITE

		FROM %table:CTT% CTT

			INNER JOIN %table:DBL% DBL
				ON DBL_FILIAL = %xFilial:DBL% 
			AND DBL_CC = CTT_CUSTO
			AND DBL.D_E_L_E_T_ = ' '

			INNER JOIN %table:SAL% AL
				ON AL_FILIAL = %xFilial:SAL% 
			AND AL_COD = DBL_GRUPO 		
			AND AL_XDOCPRJ = '1'
			AND AL.D_E_L_E_T_ = ' '

			INNER JOIN SYS_USR 
				ON USR_ID = AL_USER
			
			LEFT JOIN %table:DHL% DHL 
				ON DHL_FILIAL = %xFilial:DHL% 
				AND DHL_COD = AL_PERFIL
				AND DHL.D_E_L_E_T_ = ''

		WHERE
			CTT_FILIAL = %xFilial:CTT% 
			AND CTT_CUSTO = DBL_CC
			AND CTT_BLOQ = '2'
			AND CTT_CUSTO =  %Exp:cCC%  //'600001   ' --Receber por parâmetro
			AND CTT.D_E_L_E_T_ = ' '

		ORDER BY AL_COD, AL_NIVEL, AL_TPLIBER
				
		EndSql	
	
	ENDIF	

		
	If (cTab)->(EOF()) 			  
		::SetResponse('{"Aviso":{"Mensagem": "Usuários não encontrados."}}')
		Return .T.
	EndIF
				
	While !(cTab)->(Eof()) 
	//{"GRUPO","GRUPO_DESCRICAO","LOGIN","NOME","EMAIL","NIVEL","TIPO_APROVACAO","CC","CC_DESCRICAO","PERFIL","LIMITE_MINIMO","LIMITE_MAXIMO","LIMITE"} 
       aAdd(aDados, {	AllTrim((cTab)->GRUPO),; 
						AllTrim((cTab)->GRUPO_DESCRICAO),;  
						AllTrim((cTab)->LOGIN),;
						AllTrim((cTab)->NOME),;  
						AllTrim((cTab)->EMAIL),;  
						AllTrim((cTab)->NIVEL),; 
						AllTrim((cTab)->TIPO_APROVACAO),; 
						AllTrim((cTab)->CC),; 
						AllTrim((cTab)->CC_DESCRICAO),;
						AllTrim((cTab)->PERFIL),;
						(cTab)->LIMITE_MINIMO,;
						(cTab)->LIMITE_MAXIMO,;
						(cTab)->LIMITE})

                   	                   
      	   (cTab)->(DbSkip())
		End
		
		(cTab)->(DbCloseArea())
			
		cJson    += U_JSON( { cTabela , aCabNom, aDados} ) 
	
	cJson    += "}"
	::SetResponse(cJson)
	
	

Return(.T.)
