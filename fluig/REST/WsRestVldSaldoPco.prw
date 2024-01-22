#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'

User Function WSRESTVLDSALDOPCO

Return

WSRESTFUL WSRESTVLDSALDOPCO DESCRIPTION "Serviço REST para retorno de saldos orçamentários"
WSDATA NATUREZA   As STRING  
WSDATA ITEM       As STRING 
WSDATA CCUSTO     As STRING 
WSDATA CLASSE     As STRING 
WSDATA DATAREF    As STRING 
WSDATA VALOR      As STRING 

WSMETHOD GET DESCRIPTION "Retorna Saldo orçamentário" WSSYNTAX "/WSRESTVLDSALDOPCO || /WSRESTVLDSALDOPCO/{}//"
END WSRESTFUL

WSMETHOD GET WSRECEIVE RECEIVE  WSSERVICE WSRESTVLDSALDOPCO

Local _cOperacao    := ""
Local _cConfig      := "BL"
Local _cNivel       := "01" 
Local x             := 0
Local nValorCred    := 0
Local nValorDeb     := 0
Local nSaldo        := 0
Local _cContaCt1    := " "

//|----------------------|
//|Parâmetros de entrada |
//|----------------------|

Local _cNatureza    := Alltrim(self:NATUREZA)    //"51102110012"
Local _cItemCtb     := Alltrim(self:ITEM)        //"0"
Local _cCusto       := Alltrim(self:CCUSTO)       //"606001"
Local _cClasse      := Alltrim(self:CLASSE)      //"010048"
Local dDataRef      := CTOD(self:DATAREF)       //cTod("01/01/2024")
Local nValTit       := VAL(self:VALOR)           //Val("100,00")

::SetContentType("application/json; charset=UTF-8")

aObjRet :=  JsonObject():New() 
aObjRet["Saldos"]  := {}

DbSelectArea("CTD")
DbSetOrder(1)

// Valida o Item Contábil
If !DbSeek(xFilial("CTD") + _cItemCtb )
    
    cMensagem := "Item contábil não localizado. Favor verifique e tente novamente." 
	
	cRetorno  := "{"
    cRetorno  += '"status":"erro",'
    cRetorno  += '"mensagem":"' + cMensagem + '"'
    cRetorno  += "}"
	
    ::setResponse(cRetorno)
    
    RETURN

Endif  

// Valida o Item Classe de valor

DbSelectArea("CTH")
DbSetOrder(1)

If !DbSeek(xFilial("CTH") + _cClasse )
    
    cMensagem := "Classe contábil não localizado. Favor verifique e tente novamente." 
	
	cRetorno  := "{"
    cRetorno  += '"status":"erro",'
    cRetorno  += '"mensagem":"' + cMensagem + '"'
    cRetorno  += "}"
	
    ::setResponse(cRetorno)
    
    RETURN

Endif  

// Valida centro de custos
DbSelectArea("CTT")
DbSetOrder(1)

If !DbSeek(xFilial("CTT") + _cCusto )
    
    cMensagem := "Classe contábil não localizado. Favor verifique e tente novamente." 
	
	cRetorno  := "{"
    cRetorno  += '"status":"erro",'
    cRetorno  += '"mensagem":"' + cMensagem + '"'
    cRetorno  += "}"
	
    ::setResponse(cRetorno)
    
    RETURN

Endif  

// Valida centro de custos
DbSelectArea("SED")
DbSetOrder(1)

If !DbSeek(xFilial("SED") + _cNatureza )
    
    cMensagem := "Natureza não localizada. Favor verifique e tente novamente." 
	
	cRetorno  := "{"
    cRetorno  += '"status":"erro",'
    cRetorno  += '"mensagem":"' + cMensagem + '"'
    cRetorno  += "}"
	
    ::setResponse(cRetorno)
    
    RETURN
else
   _cContaCt1 := SED->ED_CONTA 
Endif  

// Busca conta orçamentária através da conta contábil
cTab := GetNextAlias()
	
BeginSQL Alias cTab

SELECT CT1_CONTA,
          CT1_XCO  ,
          AK5_XOPER
FROM %table:CT1% CT1
INNER JOIN %table:AK5% AK5
   ON    CT1_FILIAL  =  %xFilial:CT1%
   AND   AK5_FILIAL  =  %xFilial:AK5% 
   AND   CT1.CT1_XCO = AK5.AK5_CODIGO
WHERE CT1.CT1_CONTA = %Exp:_cContaCt1%
    AND  CT1.%notdel%
    AND  AK5.%notdel% 
EndSQL

If (cTab)->(!EOF()) 			

    _cOperacao := (cTab)->AK5_XOPER
    _cTpSaldo  := "OR"
    
    cChave := " "

    DbSelectArea("AKW")
    DbSetOrder(1)

    If DbSeek(xFilial("AKW") + _cConfig + _cNivel  )

        While !eof() .And. AKW->AKW_FILIAL = xFilial("AKW") .AND. AKW->AKW_COD == _cConfig 

                If AKW->AKW_ALIAS == "CTH"
                    cChave := Padr(_cClasse   ,AKW->AKW_TAMANH)
                ElseIf AKW->AKW_ALIAS == "CTT"
                    cChave += Padr(_cCusto    ,AKW->AKW_TAMANH)
                ElseIf AKW->AKW_ALIAS == "CTD"
                    cChave += Padr(_cItemCtb  ,AKW->AKW_TAMANH)
                ElseIf AKW->AKW_ALIAS == "AKF"
                    cChave += Padr(_cOperacao ,AKW->AKW_TAMANH)
                ElseIf AKW->AKW_ALIAS == "AL2"
                    cChave += Padr(_cTpSaldo  ,AKW->AKW_TAMANH)
                Endif
                
            AKW->(DbSkip())
       
       Enddo

    Endif

    aRet := fSaldosDt(_cConfig,cChave,dDataRef)
    
    //Soma valores a Credito
    For x := 1 to len(aRet)
        nValorCred += aRet[x,1,1]
        nValorDeb  += aRet[x,2,1]
    Next  
    
    nSaldo := ( nValorCred - nValorDeb) 
        
   // aObjRet :=  JsonObject():New() 
   // aObjRet["Saldos"]  := {}

    aAdd(aObjRet["Saldos"], JsonObject():new())
    
    aObjRet["Saldos"][1]["ValorCredito"] := nValorCred 
    aObjRet["Saldos"][1]["ValorDebito" ] := nValorDeb
    aObjRet["Saldos"][1]["Saldo" ]       := nSaldo

    If nValTit <= nSaldo
        aObjRet["Saldos"][1]["Bloqueio" ]      := "Nao"
    else
        aObjRet["Saldos"][1]["Bloqueio" ]      := "Sim"
    ENDIF    

    cJson := aObjRet:toJson()    
    ::setResponse(cJson)

Else
    cMensagem := "Dados não localizados. Favor verifique e tente novamente." 
	
	cRetorno  := "{"
    cRetorno  += '"status":"erro",'
    cRetorno  += '"mensagem":"' + cMensagem + '"'
    cRetorno  += "}"

    ::setResponse(cRetorno)

Endif

FreeObj(aObjRet)

Return

*************************************************
static function fSaldosDt(cCubo,cChave,dDataRef)
*************************************************

Local aRetSld := {}

DbSelectArea("AKT")
DbSetOrder(1)
    
If DbSeek(xFilial("AKT") + cCubo + cChave )
    aAdd(aRetSld ,PcoRetSld(AKT->AKT_CONFIG,AKT->AKT_CHAVE,dDataRef))
Endif   
// tem que tratar o tipos TE  e CT  e somar ao saldo  OR
RETURN aRetSld
