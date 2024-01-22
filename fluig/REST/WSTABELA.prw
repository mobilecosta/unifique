#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'

*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | WSTABELA  | Autor |                                        |*
*+------------+------------------------------------------------------------+*
*|Data        | 21.12.2017                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Consulta Dinï¿½mica para Tabelas do Protheus               |*
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
*| SANDRO FARIZEL    | 04/11/21 | Função para tirar acentos e aspas        |*
*|                   |          | para colunas tipo caracter               |*
*| SANDRO FARIZEL    | 18/11/21 | Reforcando a funcao para caracteres      |*
*|                   |          | especiais.                               |*
*+-------------------+----------+------------------------------------------+*
*****************************************************************************

User Function WSTABELA()
Return

	WSRESTFUL WSTABELA DESCRIPTION "Servico REST para manipulacao de WSTABELA"

		WSDATA FIL As String
		WSDATA FILTRO  As String
		WSDATA TABELA  As String
		WSDATA OPCAO   As String
		WSDATA COLUNAS As String OPTIONAL

		WSMETHOD GET DESCRIPTION "Retorna a Consulta no Protheus informada na URL" WSSYNTAX "/WSTABELA || /WSTABELA/{}"

	END WSRESTFUL

WSMETHOD GET WSRECEIVE FILTRO  WSSERVICE WSTABELA
	Local cJson    := "{"
	Local aCabNom  := {}
	Local aDados   := {}
	Local xAlias
	Local TotCol   := 0
	Local aLinha   := {}
	Local cQuery   := ""
	Local cFilCmp  := ""
	Local cOpcao   := Upper(Alltrim(Self:OPCAO))
	Local cTab, cFilAnt
	Local aColunas := {}
	Local cSelect  := ''
	Local I, n1, n
	Private aFilt  := {}
	Private aFilInt  := {}


	//SRSF 04/02/2022 - Retirado RpcSetEnv("03","01")

	If cOpcao = 'CCUSTO'
		//cFilAnt := UPPER(Self:FIL)

		cTab       := GetNextAlias()

		aDados  := {}
		aCabNom := {"CODIGO","DESCRICAO"}

		BeginSQL Alias cTab
                                SELECT DISTINCT SUBSTR(CTT_CUSTO, 1, 10) AS CCUSTO
                                  FROM %table:CTT% CTT
                                 WHERE CTT.%notdel%
                                   AND CTT.CTT_FILIAL = %xFilial:CTT%
                                   AND CTT.CTT_CLASSE = '2'
                                   AND CTT.CTT_BLOQ = '2'
		EndSQL

		DbSelectArea(cTab)
		If !(cTab)->(Eof())
			While !(cTab)->(Eof())

				DbSelectArea("CTT")
				DbSetOrder(1)
				If DbSeek(xFilial("CTT")+(cTab)->CCUSTO)
					aADD(aDados,{(cTab)->CCUSTO, U_TIRACENTO(CTT->CTT_DESC01) })
				EndIf
				(cTab)->(DbSkip())
			End
		Else
			aADD(aDados,{"Nï¿½o hï¿½ dados a serem exibidos."})

		EndIf


		(cTab)->(DbCloseArea())

		cJson    += U_JSON( { "CCUSTOS" , aCabNom, aDados} )

		cJson += "}"


		//RpcClearEnv()
		::SetResponse(cJson)

		Return(.T.)

	EndIf

	xAlias  := Self:TABELA

	//cFilAnt := UPPER(Self:FIL)

	aFilt := StrTokArr( Self:FILTRO, "@" )

	If !Empty(AllTrim(Self:COLUNAS))
		aColunas := StrTokArr( Self:COLUNAS, "|" )
	EndIf

	::SetContentType("application/json;  charset=iso-8859-1")

	SX2->( dbGoTop())
	dbSelectArea('SX2')
	If !SX2->( dbSeek( xAlias ) )
		//RpcClearEnv()
		::SetResponse('{"erro":"Tabela:' +xAlias+'  nao foi encontrada na Empresa do Protheus."}')
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
					cSelect += Alltrim(SX3->X3_CAMPO)
					If I < Len(aColunas)
						cSelect += ','
					EndIf
				EndIf
			Else
				::SetResponse('{"erro":"Campo:' +aColunas[I]+'  nï¿½o foi encontrado no SX3 da Empresa '+cEmpAnt+' do Protheus."}')
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


                /*
                //Tï¿½tulo dos campos
                aCab   :=  {"Codigo", "Descricao" , "UM" }
                */

	cQuery := "SELECT" + cSelect + "FROM "+RetSqlName(xAlias)
	cQuery += "  WHERE D_E_L_E_T_ = ' ' "
	cQuery += "  AND "+cFilCmp+" = '"+xFilial(xAlias)+"' "

	For n1 := 1 to Len(aFilt)

		If "$$" $ aFilt[n1]
			aFilInt := ACLONE(StrTokArr(aFilt[n1], "$$" ))
			cQuery += " AND "+aFilInt[1]+" LIKE '%"+aFilInt[2]+"%'"
		Else
			aFilInt := ACLONE(StrTokArr(aFilt[n1], "$" ))
			cQuery += " AND "+aFilInt[1]+"='"+aFilInt[2]+"'"
		EndIf
	Next n1

	cQuery := ChangeQuery(cQuery)

	//Antes de criar a tabela, verificar se a mesma jï¿½ foi aberta
	If (Select("TMP") <> 0)
		dbSelectArea("TMP")
		TMP->(dbCloseArea ())
	Endif

	TCQUERY cQuery Alias TMP NEW

	//Item, Produto, Executado nao medido, executado, valor unitï¿½rio

	If TMP->(EOF())
		//RpcClearEnv()
		::SetResponse('{"erro":"Registro nao encontrado na Tabela:' +xAlias+' da Empresa/Filial '+cEmpAnt+cFilAnt+'."}')
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





	cJson    += U_JSON( { xAlias , aCabNom, aDados} )

	cJson += "}"


	//RpcClearEnv()
	::SetResponse(cJson)



Return(.T.)
