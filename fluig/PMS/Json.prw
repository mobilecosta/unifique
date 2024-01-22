#include 'protheus.ch'
#include 'parmtype.ch'


*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | JSON  | Autor | Jader Berto        			               |*
*+------------+------------------------------------------------------------+*
*|Data        | 30.01.2018                                                 |*
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
Local cJSON  	:= ""                   
Local cTable 	:= aGeraXML[1]                    
Local aCab   	:= aGeraXML[2]  
Local aLin   	:= aGeraXML[3]  
Local lArray 	:= Empty(cTable)
Local C
Local L
Local cLinhas

If !lArray 
	cJSON += '"'+cTable+'": ['
Else
	cJSON += ' ['
EndIf 

FOR L:= 1 TO LEN( aLin )
 

    jLinha  := JsonObject():New()
    
    for C:= 1 to Len( aCab ) 

        jLinha[aCab[C]] := aLin[L][C]
 
    Next C

    cLinhas := Replace(Replace(FWJsonSerialize(jLinha), '[', ''), ']', '')  
    
    cJSON += cLinhas

    IF L < LEN(aLin)
       cJSON += ','
    ENDIF
         
Next L
 
 
cJSON  += ']'

Return cJSON
