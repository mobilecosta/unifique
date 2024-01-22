#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'
#Include 'Totvs.CH'
#INCLUDE "MATA010.CH"
#INCLUDE "MATA019.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "GCTXDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE 'FWLIBVERSION.CH'


*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | WSRINCPROD  | Autor |                                 	   |*
*+------------+------------------------------------------------------------+*
*|Data        | 01/11/2023                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | incluir cadastro de produto via REST   				       |*
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

WSRESTFUL WSRINCPROD DESCRIPTION "Serviço REST para incluir cadastro de produto"

	WSMETHOD POST DESCRIPTION "Efetua Cadastro no Protheus informada na URL" WSSYNTAX "/WSRINCPROD || /WSRINCPROD/{}"

END WSRESTFUL


WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE WSRINCPROD

Local	cJSON    	:=  Self:GetContent() // Pega a string do JSON
Local	oOBJ1 		:=  Nil
Local   oSBZ	    := Nil
Local	cMessage    :=	""
Local	nIdxSBZ     := 0
Local   cCEST := ''

//Variaveis de controle do ExecAuto
/*Private lMSHelpAuto     := .T.
Private lAutoErrNoFile  := .T.
Private lMsErroAuto     := .F.

Public _aSB1Alt := {} //Array será utilizado no PE_ITEM para registrar os produtos alterados na tela MVC*/

ConOut("WSRINCPROD JSON: "+cJSON)
::SetContentType("application/json; charset=UTF-8")

oOBJ1 := JsonObject():new()
oOBJ1:fromJson(cJSON)

//CONOUT(cJSON)

If ValType(oOBJ1) == "U"
	::SetResponse('{"erro":{"mensagem": "JSON recebido com problemas - '+cJSON+'"}}')
	Return .T.
ENDIF

cDESC       :=  UPPER(oOBJ1:GetJsonObject("DESC"))
cTIPO       :=  oOBJ1:GetJsonObject("TIPO")
cUM         :=  oOBJ1:GetJsonObject("UNID")
cGRUPO      :=  oOBJ1:GetJsonObject("GRUPO")  
cSEGUM      :=  oOBJ1:GetJsonObject("SEGUM")
cLOCPAD     :=  oOBJ1:GetJsonObject("LOCPAD")
cRASTRO     :=  oOBJ1:GetJsonObject("RASTRO")
cLOCALIZ    :=  oOBJ1:GetJsonObject("LOCALIZ")
cPOSIPI     :=  oOBJ1:GetJsonObject("POSIPI")
cGRTRIB     :=  oOBJ1:GetJsonObject("GRTRIB")
cINSS       :=  oOBJ1:GetJsonObject("INSS")
nPCSLL      :=  oOBJ1:GetJsonObject("PCSLL")
nPCOFINS 	:=  oOBJ1:GetJsonObject("PCOFINS")
nPPIS       :=  oOBJ1:GetJsonObject("PPIS")
cCONTA      :=  oOBJ1:GetJsonObject("CONTA")
cCC         :=  oOBJ1:GetJsonObject("CC")
cCEST       :=  oOBJ1:GetJsonObject("CEST")
cORIGEM     :=  oOBJ1:GetJsonObject("ORIGEM")
nAli_IPI    :=  oOBJ1:GetJsonObject("ALIQ_IPI")
nPICM       :=  oOBJ1:GetJsonObject("PICM") 	  		//B1_PICM   	Alíquota de ICMS         
nALIQISS    :=  oOBJ1:GetJsonObject("ALIQISS") 			//B1_ALIQISS	Aliquota de ISS  
cCODISS     :=  oOBJ1:GetJsonObject("CODISS")			//B1_CODISS 	Cod.Serv.ISS 
cTRIBMUN	:=	oOBJ1:GetJsonObject("TRIBMUN")			//B1_TRIBMUN	Codigo de Trib. Municipal 
cIRRF		:=	oOBJ1:GetJsonObject("IRRF")				//B1_IRRF   	Incide imposto renda      
cCOFINS		:=	oOBJ1:GetJsonObject("COFINS")			//B1_COFINS 	Efetua a retenção-COFINS 
cPIS		:=	oOBJ1:GetJsonObject("PIS")				//B1_PIS    	Efetua a retenção-PIS      
cRETOPER	:=	oOBJ1:GetJsonObject("RETOPER")			//B1_RETOPER	Retém PIS/COFINS operação   
cCSLL		:=	oOBJ1:GetJsonObject("CSLL")				//B1_CSLL   	Efetua a Retenção-CSLL   
cTNATREC	:=	oOBJ1:GetJsonObject("TNATREC")			//B1_TNATREC	Tab. Nat. Receita        
cCNATREC	:=	oOBJ1:GetJsonObject("CNATREC")			//B1_CNATREC	Cod Nat Receita    
cMSBLQL		:=	oOBJ1:GetJsonObject("MSBLQL")			//B1_MSBLQL 	Bloqueio de Tela         
cXOPER		:=	oOBJ1:GetJsonObject("XPER")			//B1_XOPER   	Tipo de Operação
cATIVO		:=	oOBJ1:GetJsonObject("ATIVO")			//B1_ATIVO  	Produto Ativo (Sim/Nao)  
cXCONTAR	:=	oOBJ1:GetJsonObject("XCONTAR")			//B1_XCONTAR	Conta Receita
cXCONTAC	:=	oOBJ1:GetJsonObject("XCONTAC")			//B1_XCONTAC	Conta Custo
cXCONTAO	:=	oOBJ1:GetJsonObject("XCONTAO")			//B1_XCONTAO	Conta Comercial
cXCONTAA	:=	oOBJ1:GetJsonObject("XCONTAA")			//B1_XCONTAA    Conta Administrativa
cXBTVCOD	:=	oOBJ1:GetJsonObject("XBTVCOD")			//B1_XBTVCOD 	Codigo BTV Sistema
cCONV		:=	oOBJ1:GetJsonObject("CONV")				//B1_CONV 		Fator de Conversão
cTIPCONV	:=	oOBJ1:GetJsonObject("TIPCONV")			//B1_TIPCONV 	Tipo de Conversão
cCODBAR		:=	oOBJ1:GetJsonObject("CODBAR")			//B1_CODBAR		Código de Barra
cGRPTI		:=	oOBJ1:GetJsonObject("GRPTI")			//B1_GRPTI  	Grupo da TES Inteligente 
cCODISS		:=	oOBJ1:GetJsonObject("CODISS")  			//B1_CODISS		Cod.Serv.ISS  
//cAGLUMRP	:=	oOBJ1:GetJsonObject("AGLUMRP")			//B1_AGLUMRP	Aglu. MRP //Campo não existe.
cMRP		:=	oOBJ1:GetJsonObject("MRP")				//B1_MRP		Form. MPR
cCLASSE		:=	oOBJ1:GetJsonObject("CLASSE") 			//B1_CLASSE		Classe

//**********SB5********** 
cB5_CEME		:=	oOBJ1:GetJsonObject("B5_CEME")	//B5_CEME   	Descricao cientifica    
cB5_AGLUMRP		:=	oOBJ1:GetJsonObject("B5_AGLUMRP")		//B5_AGLUMRP	Aglu. MRP "
cB5_CLIT        :=  oOBJ1:GetJsonObject("B5_CLIT")

  
cCod    :=  fBuscaCod(cGRUPO) //Função para retornar o código do produto de acordo com o sequencial do grupo. 


dbSelectArea("SB1") 
DbSetOrder(1)
dbSeek(xFilial("SB1") + cCod)

dbSelectArea("SB5") 
DbSetOrder(1)
dbSeek(xFilial("SB5") + cCod)

dbSelectArea("SBZ") 
DbSetOrder(1)
dbSeek(xFilial("SBZ") + cCod)

If cCEST = NIL
    cCEST := ""
EndIf

If cB5_CLIT = NIL
    cB5_CLIT := ""
EndIf

//Pegando o modelo de dados, setando a operação de inclusão
oModelB1 := FWLoadModel("MATA010")
oModelB1:SetOperation(MODEL_OPERATION_INSERT) 

//cCod    :=  fBuscaCod(cGRUPO) //Função para retornar o código do produto de acordo com o sequencial do grupo. 
 
Begin Transaction

If(oModelB1:CanActivate())  
	
    //Pegando o model e setando os campos 
    oModelB1:Activate()      
    oModelB1:SetValue("SB1MASTER","B1_COD"          , cCod      )
    oModelB1:SetValue("SB1MASTER","B1_DESC"         , cDesc     )
    oModelB1:SetValue("SB1MASTER","B1_TIPO"         , cTipo     )
    oModelB1:SetValue("SB1MASTER","B1_UM"           , cUM       )
    oModelB1:SetValue("SB1MASTER","B1_LOCPAD" 	    , cLocPad   )
    oModelB1:SetValue("SB1MASTER","B1_LOCALIZ"      , cLOCALIZ  )
    oModelB1:SetValue("SB1MASTER","B1_GRUPO"        , cGRUPO    )
    oModelB1:SetValue("SB1MASTER","B1_CONTA"        , cCONTA    )
    oModelB1:SetValue("SB1MASTER","B1_POSIPI"       , cPOSIPI   )
    oModelB1:SetValue("SB1MASTER","B1_ORIGEM"       , cORIGEM   )
    oModelB1:SetValue("SB1MASTER","B1_SEGUM"  		, cSEGUM    )
	oModelB1:SetValue("SB1MASTER","B1_RASTRO" 		, cRASTRO   ) 
	oModelB1:SetValue("SB1MASTER","B1_GRTRIB"    	, cGRTRIB   ) 
	oModelB1:SetValue("SB1MASTER","B1_INSS"      	, cINSS	    )
	oModelB1:SetValue("SB1MASTER","B1_PCSLL"     	, nPCSLL    )
	oModelB1:SetValue("SB1MASTER","B1_PCOFINS"   	, nPCOFINS  )
	oModelB1:SetValue("SB1MASTER","B1_PPIS"      	, nPPIS     )
	oModelB1:SetValue("SB1MASTER","B1_CC"        	, cCC 	    ) 
	oModelB1:SetValue("SB1MASTER","B1_IPI"       	, nAli_IPI  )
	oModelB1:SetValue("SB1MASTER","B1_PICM"   		, nPICM     )				 
	oModelB1:SetValue("SB1MASTER","B1_ALIQISS"   	, nALIQISS  )      		 
	oModelB1:SetValue("SB1MASTER","B1_TRIBMUN"   	, cTRIBMUN  )      		 
	oModelB1:SetValue("SB1MASTER","B1_IRRF"   		, cIRRF     ) 			      
	oModelB1:SetValue("SB1MASTER","B1_COFINS"  		, cCOFINS   ) 			 
	oModelB1:SetValue("SB1MASTER","B1_PIS"   		, cPIS 	    ) 			      
	oModelB1:SetValue("SB1MASTER","B1_RETOPER"   	, cRETOPER  ) 			   
	oModelB1:SetValue("SB1MASTER","B1_CSLL"   		, cCSLL		) 			 
	oModelB1:SetValue("SB1MASTER","B1_TNATREC"   	, cTNATREC  ) 			    
	oModelB1:SetValue("SB1MASTER","B1_CNATREC"  	, cCNATREC  ) 			    
	oModelB1:SetValue("SB1MASTER","B1_MSBLQL"   	, cMSBLQL   ) 			        
	oModelB1:SetValue("SB1MASTER","B1_ATIVO"  		, cATIVO    ) 			  
	oModelB1:SetValue("SB1MASTER","B1_CONV"   		, cCONV     ) 			 
	oModelB1:SetValue("SB1MASTER","B1_TIPCONV"   	, cTIPCONV  ) 			 
	oModelB1:SetValue("SB1MASTER","B1_CODBAR"   	, cCODBAR   ) 			 
	oModelB1:SetValue("SB1MASTER","B1_GRPTI"   		, cGRPTI    )			 
	oModelB1:SetValue("SB1MASTER","B1_CODISS"   	, cCODISS   )			 
	oModelB1:SetValue("SB1MASTER","B1_MRP"   		, cMRP   	)				 
	oModelB1:SetValue("SB1MASTER","B1_CLASSE"   	, cCLASSE	)
    oModelB1:SetValue("SB1MASTER","B1_XOPER"   	    , cXOPER	)
    oModelB1:SetValue("SB1MASTER","B1_XBTVCOD"   	, cXBTVCOD	)
    oModelB1:SetValue("SB1MASTER","B1_XCONTAR"   	, cXCONTAR	)
    oModelB1:SetValue("SB1MASTER","B1_XCONTAC"   	, cXCONTAC	)
    oModelB1:SetValue("SB1MASTER","B1_XCONTAO"   	, cXCONTAO	)
    oModelB1:SetValue("SB1MASTER","B1_XCONTAA"   	, cXCONTAA	)



    //Setando o complemento do produto  
    If "SB5" $ SuperGetMv("MV_CADPROD",.F.,"")
        If !Empty(cB5_CEME)
            oSB5Mod := oModelB1:GetModel("SB5DETAIL")
            If oSB5Mod != Nil
				oSB5Mod:SetValue("B5_FILIAL" , xFilial("SB5")  ) 
                oSB5Mod:SetValue("B5_CEME"   , cB5_CEME ) 
                If !Empty(cB5_AGLUMRP)
                    oSB5Mod:SetValue("B5_AGLUMRP", cB5_AGLUMRP )
                EndIf
                If !Empty(cB5_CLIT)
                    oSB5Mod:SetValue("B5_CLIT", cB5_CLIT ) 
                EndIf
            EndIf
        EndIf
    EndIf
 

	//Testa se a SBZ faz parte do cadastro do produto.
    If "SBZ" $ SuperGetMv("MV_CADPROD",.F.,"")
    
		//SBZ Crio o objeto do array
		oSBZ  := JsonObject():new()
		oSBZ  := oOBJ1:GetJsonObject("SBZ")

		If Len(oSBZ) > 0

			oSBZMod := oModelB1:GetModel("SBZDETAIL")
			If oSBZMod != Nil
				
				For nIdxSBZ := 1 To Len(oSBZ)

					oSBZ[nIdxSBZ]:toJSON()
					
					If oSBZMod:Length() < nIdxSBZ
						oSBZMod:AddLine()
					EndIf

					oSBZMod:SetValue("BZ_FILIAL"   , oSBZ[nIdxSBZ]:GetJsonText("BZ_FILIAL")	) 
					oSBZMod:SetValue("BZ_ALIQISS"  , Val(oSBZ[nIdxSBZ]:GetJsonText("BZ_ALIQISS"))) 
					oSBZMod:SetValue("BZ_LOCPAD"   , oSBZ[nIdxSBZ]:GetJsonText("BZ_LOCPAD")	) 
					oSBZMod:SetValue("BZ_ORIGEM"   , oSBZ[nIdxSBZ]:GetJsonText("BZ_ORIGEM")	) 
					oSBZMod:SetValue("BZ_TRIBMUN"  , oSBZ[nIdxSBZ]:GetJsonText("BZ_TRIBMUN")) 

				Next
			
			EndIf
		EndIf

	EndIf

EndIf
   
//Se conseguir validar as informações
If oModelB1:VldData()
       
    //Tenta realizar o Commit
    If oModelB1:CommitData()
        lOk := .T.    
    Else
        lOk := .F. //Se não deu certo, altera a variável para false
    EndIf
       
//Se não conseguir validar as informações, altera a variável para false
Else
    lOk := .F.
EndIf
   
//Se não deu certo a inclusão, mostra a mensagem de erro
If ! lOk
    //Busca o Erro do Modelo de Dados
	aErro := oModelB1:GetErrorMessage()
       
    //Monta o Texto que será mostrado na tela
    cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
    cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
    cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
    cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
    cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
    cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
    cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
    cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
    cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
     
    //Mostra mensagem de erro
    lRet := .F.
    ConOut("Erro: " + cMessage)
	::SetResponse('{"RETORNO": "ERRO", "MENSAGEM":"' + cMessage + '"}')
Else
    lRet := .T.
    ConOut("Produto incluido!")
	::SetResponse('{"RETORNO": "OK", "MENSAGEM":"' + cCod + '"}')

EndIf
   
//Desativa o modelo de dados
oModelB1:DeActivate()

End Transaction

Return Nil

//Return (.T.)


//-- Retorna o próximo código do produto a ser criado de acordo com o grupo de produto.	 
Static Function fBuscaCod(cGRUPO)

Local cArqTrb	:=	GetNextAlias()
//Local nTgrp   	:= 3 //Len(cGRUPO)  
Local nCodB1    := 6 //(nTamanho - nTgrp)

	//-- Busca o maior código do produto de determinado grupo.
	cQuery := " SELECT "
	cQuery += " MAX(B1_COD) B1_COD " 
	cQuery += " FROM "+RetSQLName("SB1")+" B1 "
	cQuery += " WHERE "
	cQuery += " B1_FILIAL = '"+xFilial("SB1")+"' And "
	cQuery += " B1_GRUPO = '"+ %Exp:cGRUPO% +"' And " 
	cQuery += " B1.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )

	If !EMPTY((cArqTrb)->B1_COD)  
		cCod := somastr((cArqTrb)->B1_COD, '1')  
	Else
		cCod := '1'
        cCod := PadL(cCod, nCodB1, '0')
	    cCod := cGRUPO + cCod
	EndIf

	(cArqTrb)->(dbCloseArea())

    CONOUT("CODIGO DO PRODUTO: ")
    CONOUT(cCod)
	
Return cCod





/*
//http://10.252.15.102:8401/WSRINCPROD
//http://10.252.15.102:8500/WSRINCPROD
{
   "DESC":"TESTE SOAPUI",
   "TIPO":"MC",
   "UNID":"UN",
   "GRUPO":"001",
   "SEGUM":"CT",
   "CONV":0,
   "TIPCONV":"M",
   "LOCPAD":"01",
   "RASTRO":"N",
   "LOCALIZ":"N",
   "POSIPI":"30064012",
   "GRTRIB":"",
   "INSS":"N",
   "PCSLL":0.0,
   "PCOFINS":7.60,
   "PPIS":1.65,
   "CONTA":"11205010002",
   "CC":"",
   "ALIQ_IPI":0.0,
   "ORIGEM":"0",
   "PICM":0.0,
   "ALIQISS":0.0,
   "TRIBMUN":"",
   "IRRF":"S",
   "COFINS":"1",
   "PIS":"1",
   "CSLL":"1",
   "RETOPER":"2",
   "TNATREC":"",
   "CNATREC":"",
   "MSBLQL":"2",
   "ATIVO":"S",
   "CODBAR":"",
   "GRPTI":"",
   "CODISS":"",
   "MRP":"",
   "CLASSE":"",
   "XPER":"",
   "XCONTAR":"",
   "XCONTAC":"",
   "XCONTAO":"",
   "XCONTAA":"",
   "XBTVCOD":"",
   "B5_CEME":"NOME CIENTIFICO",
   "B5_AGLUMRP":"",
   "B5_CLIT":"",
   "SBZ":[
      {
         "BZ_FILIAL":"010001",
         "BZ_ALIQISS":0.0,
         "BZ_LOCPAD":"10",
         "BZ_ORIGEM":"1",
         "BZ_TRIBMUN":"123"
      },
      {
         "BZ_FILIAL":"010002",
         "BZ_ALIQISS":0.0,
         "BZ_LOCPAD":"10",
         "BZ_ORIGEM":"1",
         "BZ_TRIBMUN":"123"
      }
   ]
}
*/
