#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'

*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | WSCONSULTA  | Autor | Jader Berto                          |*
*+------------+------------------------------------------------------------+*
*|Data        | 25.10.2021                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Consulta Dinámica para Tabelas do Protheus                 |*
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
*|                   |          |                                          |*
*+-------------------+----------+------------------------------------------+*
*****************************************************************************
 
WSRESTFUL WSCONSULTA DESCRIPTION "Serviço REST para manipulação de WSCONSULTA"

WSDATA FILTRO  As String
WSDATA TABELA  As String
WSDATA COLUNAS As String OPTIONAL

WSMETHOD GET DESCRIPTION "Retorna a Consulta no Protheus informada na URL" WSSYNTAX "/WSCONSULTA || /WSCONSULTA/{}"

END WSRESTFUL





WSMETHOD GET WSRECEIVE FILTRO  WSSERVICE WSCONSULTA
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
Local I, n1, n
Local cError   := ""
Local bError   := ErrorBlock({ |oError| cError := oError:Description})
Local ret
Private aFilt  := {}
Private aFilInt  := {}
        


//Inicio a utilização da tentativa
Begin Sequence

	::SetContentType("application/json; charset=iso-8859-1")

        If !Empty(cError)
                ::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
                
                Return .T.
        endif
        
        xAlias  := Self:TABELA


        aFilt := StrTokArr( Self:FILTRO, "@" )

        If !Empty(AllTrim(Self:COLUNAS))
                aColunas := StrTokArr( Self:COLUNAS, "|" )
        EndIf

        //Set(_SET_DATEFORMAT, 'dd/mm/yyyy')
                                        
        ::SetContentType("application/json;  charset=iso-8859-1")
        
        SX2->( dbGoTop())
        dbSelectArea('SX2')
        If !SX2->( dbSeek( xAlias ) )
                If !Empty(cError)
                        ::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
                        
                        Return .T.
                Else
                        
                        ::SetResponse('{"erro":"Tabela:' +xAlias+'  não foi encontrada na Empresa '+cEmpAnt+' do Protheus."}')
                        Return .T.
                EndIf
        EndIf   

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
                                If !Empty(cError)
                                   ::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
                                   
                                   Return .T.
                                Else
                                   ::SetResponse('{"erro":"Campo:' +aColunas[I]+'  não foi encontrado no SX3 da Empresa '+cEmpAnt+' do Protheus."}')
                                   Return .T.                              
                                EndIf
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
        //Tátulo dos campos
        aCab   :=  {"Codigo", "Descricao" , "UM" }
        */
        
        cQuery := "SELECT " + cSelect + " FROM "+RetSqlName(xAlias)
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
                
        //cQuery := ChangeQuery(cQuery)
        
        //Antes de criar a tabela, verificar se a mesma já foi aberta
        If (Select("TMP") <> 0)
                dbSelectArea("TMP")
                TMP->(dbCloseArea ())
        Endif
        
        TCQUERY cQuery Alias TMP NEW
        
        //Item, Produto, Executado nao medido, executado, valor unitário

        If TMP->(EOF())
                If !Empty(cError)
                        ::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
                        
                        Return .T.
                Else
                        
                        ::SetResponse('{"erro":"Registro nao encontrado na Tabela:' +xAlias+' da Empresa/Filial '+cEmpAnt+cFilAnt+'."}') 
                        Return .T.
                EndIf
        EndIF
        
        While TMP->(!EOF())     
                
                aLinha := ARRAY(TotCol)
                        
                For n := 1 to TotCol
                    If TamSx3(aCabNom[n])[3] == "D"
                        aLinha[n] := STOD(Alltrim(&("TMP->"+aCabNom[n])))
                    ElseIf TamSx3(aCabNom[n])[3] == "L"
                        If Alltrim(&("TMP->"+aCabNom[n])) == "T"
                            aLinha[n] := .T.
                        else
                            aLinha[n] := .F.
                        EndIf
                    ElseIf TamSx3(aCabNom[n])[3] == "N"
                        aLinha[n] := &("TMP->"+aCabNom[n])
                    Else
                        aLinha[n] := Alltrim(&("TMP->"+aCabNom[n]))
                    EndIf

                Next n
        
                AADD(aDados, aLinha)
        TMP->(DBSkip())
        End
        TMP->(DBCloseArea())
        
                
        
        
        
        cJson    += U_JSON( { xAlias , aCabNom, aDados} )
        
        cJson += "}"
        
        	
End Sequence



//Restaurando bloco de erro do sistema
ErrorBlock(bError)


If !Empty(cError)
        ::SetResponse('{"retorno":"Ocorreu um erro no Sistema Protheus. ['+cError+']"}')
        
        Return .T.
Else
        ::SetResponse(cJson)
EndIf
        
        

Return(.T.)
