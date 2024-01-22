#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'

*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | WSRSA2TOPN  | Autor |                                      |*
*+------------+------------------------------------------------------------+*
*|Data        | 01.12.2023                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Consulta dos top n fornecedores                            |*
*+------------+------------------------------------------------------------+*
*|Solicitante |                                                            |*
*+------------+------------------------------------------------------------+*
*|Partida     | WebService                                                 |*
*+------------+------------------------------------------------------------+*
*|Arquivos    |                                                            |*
*+------------+------------------------------------------------------------+*
*|             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            |*
*+-------------------------------------------------------------------------+*
*| Programador       |   Data   | Motivo da alteracao                      |*
*+-------------------+----------+------------------------------------------+* 
*+-------------------+----------+------------------------------------------+*
*****************************************************************************

User Function WSRSA2TOPN()
Return

	WSRESTFUL WSRSA2TOPN DESCRIPTION "Servico REST para Consulta dos TOP N fornecedores"

		WSDATA FIL     As String
		WSDATA FILTRO  As String
		WSDATA COLUNAS As String  OPTIONAL
		WSDATA TOPREC  As Integer OPTIONAL

		WSMETHOD GET DESCRIPTION "Retorna a Consulta dos Produtos do Protheus informada na URL" WSSYNTAX "/WSRSA2TOPN || /WSRSA2TOPN/{}"

	END WSRESTFUL

WSMETHOD GET WSRECEIVE FILTRO  WSSERVICE WSRSA2TOPN
	Local cJson    := "{"
	Local aCabNom  := {}
	Local aDados   := {}
	Local xAlias
	Local TotCol   := 0
	Local aLinha   := {}
	Local cQuery   := ""
	Local cFilCmp  := ""
	Local aColunas := {}
	Local cSelect  := ''
	//Local I, n1, n
	Local I, n
	Local nTopRec  := 50 //Padrão 50 registros
	Private aFilt  := {}
	Private aFilInt  := {}

	//SRSF 04/02/2022 - Retirado RpcSetEnv("03","01")

	xAlias  := "SA2"

	//cFilAnt := UPPER(Self:FIL)

	//aFilt := StrTokArr( Self:FILTRO, "@" )
	cFilt := Self:FILTRO
	
	//ConOut("WSSB1TOPN Iniciado")

	If !Empty(AllTrim(Self:COLUNAS))
		//ConOut("Campo: "+Self:COLUNAS)
		aColunas := StrTokArr( Self:COLUNAS, "|" )
	EndIf

	If !Empty(Self:TOPREC)
		nTopRec := Self:TOPREC
	EndIf

	::SetContentType("application/json;  charset=iso-8859-1")

	SX2->( dbGoTop())
	dbSelectArea('SX2')
	If !SX2->( dbSeek( xAlias ) )
		//RpcClearEnv()
		::SetResponse('{"erro":"Tabela:' +xAlias+'  nao foi encontrada no Protheus."}')
		Return .T.
	EndIf
	SX2->( dbCloseArea())

	If Len(aColunas) > 0
		DbSelectArea("SX3")
		DbSetOrder(1)
		SX3->(DbSeek(xAlias))
		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == xAlias
			If "FILIAL" $ SX3->X3_CAMPO
				cFilCmp := SX3->X3_CAMPO
				Exit
			EndIF
			SX3->(DbSkip())
		End
		For I:=1 to Len(aColunas)
			DbSelectArea("SX3")
			DbSetOrder(2)
			If SX3->(DbSeek(Upper(aColunas[I])))
				If SX3->X3_CONTEXT <> "V"
					TotCol++
					Aadd(aCabNom,Alltrim(SX3->X3_CAMPO))
					//SRSF 26/01/2022 - Chamado: 202201000526 - Tratamento do campo B1_DESC
					//If Alltrim(SX3->X3_CAMPO) == "B1_DESC"
						//cSelect += "Case When ltrim(rtrim(B1_XDESCEX)) != '' Then B1_XDESCEX Else B1_DESC End B1_DESC"
					//	cSelect += "Case When ltrim(rtrim(B1_DESC)) != '' Then B1_DESC Else B1_DESC End B1_DESC"
					//Else
					cSelect += Alltrim(SX3->X3_CAMPO)
					//EndIf
					If I < Len(aColunas)
						cSelect += ','
					EndIf
				EndIf
			Else
				::SetResponse('{"erro":"Campo:' +aColunas[I]+'  nao foi encontrado no SX3 da Empresa no Protheus."}')
				Return .T.
			EndIf
		Next
	Else
		cSelect := '*'

		DbSelectArea("SX3")
		DbSetOrder(1)

		SX3->(DbSeek(xAlias))
		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == xAlias
			If ( SX3->X3_CONTEXT <> "V" )
				TotCol++
			Endif
			SX3->(DbSkip())
		End

		SX3->(DbGoTop())

		aCabNom := ARRAY(TotCol)

		TotCol := 0
		SX3->(DbSeek(xAlias))
		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == xAlias
			If "FILIAL" $ SX3->X3_CAMPO
				cFilCmp := SX3->X3_CAMPO
			EndIF
			If ( SX3->X3_CONTEXT <> "V" )
				TotCol++
				aCabNom[TotCol] := Alltrim(SX3->X3_CAMPO)
			Endif
			SX3->(DbSkip())
		End
	EndIf

	cQuery := "SELECT " + cSelect + "FROM "+RetSqlName(xAlias)
	cQuery += "  WHERE D_E_L_E_T_ = ' ' "
	cQuery += "  AND "+cFilCmp+" = '"+xFilial(xAlias)+"' "
	cQuery += "  AND (A2_COD LIKE '%"+cFilt+"%' OR A2_CGC LIKE '%"+cFilt+"%' OR A2_NOME LIKE '%"+cFilt+"%'  OR A2_NREDUZ LIKE '%"+cFilt+"%'   ) " //SRSF 13/12/2021 - Pesquisa pelo codigo ou descricao
	cQuery += "  AND A2_MSBLQL <> '1' "
	cQuery += "  AND ROWNUM  < " + Alltrim(Str(nTopRec)) + " 

/*	For n1 := 1 to Len(aFilt)

		If "$$" $ aFilt[n1]
			aFilInt := ACLONE(StrTokArr(aFilt[n1], "$$" ))
			cQuery += " AND B1_DESC LIKE '%"+aFilInt[2]+"%'"
		Else
			aFilInt := ACLONE(StrTokArr(aFilt[n1], "$" ))
			cQuery += " AND "+aFilInt[1]+"='"+aFilInt[2]+"'"
		EndIf
	Next n1*/

	cQuery := ChangeQuery(cQuery)

	//Antes de criar a tabela, verificar se a mesma já foi aberta
	If (Select("TMP") <> 0)
		dbSelectArea("TMP")
		TMP->(dbCloseArea ())
	Endif

	ConOut("WSSA2TOPN Query: "+cQuery)

	TCQUERY cQuery Alias TMP NEW

	//Item, Produto, Executado nao medido, executado, valor unitï¿½rio 

	If TMP->(EOF())
		//RpcClearEnv()
		::SetResponse('{"erro":"Registro nao encontrado na Tabela de produtos."}')
		Return .T.
	EndIF

	While TMP->(!EOF())

		aLinha := ARRAY(TotCol)

		For n := 1 to TotCol
			If Type("TMP->"+aCabNom[n]) = "N"
				aLinha[n] := Transform(&("TMP->"+aCabNom[n]),PesqPict(xAlias,aCabNom[n]))

			ElseIf Type("TMP->"+aCabNom[n]) = "D"
				aLinha[n] := Stod(&("TMP->"+aCabNom[n]))

			ElseIf Type("TMP->"+aCabNom[n]) # "U"
				aLinha[n] := Alltrim(&("TMP->"+aCabNom[n]))
                                //SRSF 04/11/2021 - 3 Linhas de defesa para retirar acentos
                                aLinha[n] := NoAcento(aLinha[n])
                                aLinha[n] := U_TIRACENTO(aLinha[n])
                                aLinha[n] := STRTRAN(aLinha[n] , '"', "") //Aspas duplas
								aLinha[n] := STRTRAN(aLinha[n] , '	',"") //Tirar TAB
                                FwCutOff(aLinha[n])

			Else
				aLinha[n] := ""
			EndIf
		Next n

		AADD(aDados, aLinha)
		TMP->(DBSkip())
	End
	TMP->(DBCloseArea())

	//ConOut("WSSB1TOPN Gerando JSON")
	cJson    += U_JSON( { xAlias , aCabNom, aDados} )

	cJson += "}"

	//RpcClearEnv()
	::SetResponse(cJson)   


Return(.T.)
