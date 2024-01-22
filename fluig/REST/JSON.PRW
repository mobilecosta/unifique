#include 'protheus.ch'
#include 'parmtype.ch'


*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | JSON  | Autor |                 			               |*
*+------------+------------------------------------------------------------+*
*|Data        | 27.12.2018                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Função para Conversão de Matriz em String JSON		       |*
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
*|                   |          |                                          |*
*+-------------------+----------+------------------------------------------+*
*****************************************************************************


//Função para Gerar Formato Json
User function JSON(aGeraXML)
Local cJSON  := ""                   
Local cTable := aGeraXML[1]                    
Local aCab   := aGeraXML[2]  
Local aLin   := aGeraXML[3]

Local	C, L  
 
cJSON += '"'+cTable+'": [' 
 
FOR L:= 1 TO LEN( aLin )
 
    cJSON += '{'
 
    for C:= 1 to Len( aCab ) 
     
        IF VALTYPE(aLin[L][C]) = "C"  
           cConteudo := '"'+aLin[L][C]+'" '
        ELSEIF VALTYPE(aLin[L][C]) = "N"
            cConteudo := ALLTRIM(STR(aLin[L][C]))
        ELSEIF VALTYPE(aLin[L][C]) = "D"
            cConteudo := '"'+DTOC(aLin[L][C])+'"'
        ELSEIF VALTYPE(aLin[L][C]) = "L"
            cConteudo := IF(aLin[L][C], '"true"' , '"false"') 
       // ELSE
        //    cConteudo := '"'+U_TIRACENTO(aLin[L][C])+'"'
        ENDIF               
 
        cJSON += '"'+aCab[C]+'":' + cConteudo
 
        IF C < LEN(aCab)
           cJSON += ','
        ENDIF
 
    Next C
    cJSON += '}'
    IF L < LEN(aLin)
       cJSON += ','
    ENDIF
         
Next
 
cJSON += ']'
 
Return cJSON
