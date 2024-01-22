#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.CH'
#Include 'TopConn.CH'

User Function WSXEMPRESASFILIAIS

Return

WSRESTFUL WSXEMPRESASFILIAIS DESCRIPTION "Serviço REST para retorno de empresas"
WSDATA EMAIL      As STRING OPTIONAL 
WSDATA VALIDAUSER As STRING 
WSDATA LISTAGRUPO As STRING 

WSMETHOD GET DESCRIPTION "Retorna as empresas de um usuário específico no Protheus a partir da URL" WSSYNTAX "/WSXEMPRESASFILIAIS || /WSXEMPRESASFILIAIS/{}//"
END WSRESTFUL

WSMETHOD GET WSRECEIVE RECEIVE  WSSERVICE WSXEMPRESASFILIAIS

Local aUsers       := {}
Local I            := 0
Local J            := 0
Local nPos         := 0
Local aEmps        := {}
Local aGrupos      := {}
Local cRegraGrp    := ''
Local aEmpAcess    := {}
Local cEmail       := self:EMAIL
Local cValidaUser  := self:VALIDAUSER
Local cListaGrupo  := self:LISTAGRUPO

::SetContentType("application/json; charset=UTF-8")



aObjEmp :=  JsonObject():New() 

If Upper(cValidaUser) == "S"  // Valida usuário no Protheus por intermédio do e-mail    

    aUsers := FWSFALLUSERS() // Retorna vetor com informações dos usuários
        
    nPos := aScan(aUsers, { |u| AllTrim(Upper(u[5])) == Upper(AllTrim(cEmail))})

    If nPos = 0
        
        cMensagem := "Nao existe usuario cadastrado no Protheus com o email ..:" + cEmail
        
        cRetorno  := "{"
        cRetorno  += '"status":"erro",'
        cRetorno  += '"mensagem":"' + cMensagem + '"'
        cRetorno  += "}"
        
        ::SetResponse(cRetorno)
        
        Return .t.
    Else
        //CONOUT("XPLANNING - PARADA 1")
        cRegraGrp := FWUsrGrpRule(aUsers[nPos,2])	
        
        If cRegraGrp $ "1|3"
            aGrupos := UsrRetGrp(,aUsers[nPos,2])
        EndIf

        Do Case
            Case cRegraGrp = '1' //Prioriza regra por grupo
                //CONOUT("XPLANNING - PARADA 2")
                For J:= 1 to Len(aGrupos)					
                    
                    aEmps := fBuscaEmpresas(FWGrpEmp(aGrupos[J]),'',.F.,.T.)
                    
                    For I := 1 to Len(aEmps)
                        
                           If aScan(aEmpAcess, { |u| AllTrim(Upper(u[2][2])) == Upper(AllTrim(aEmps[I,1,2])) .And. AllTrim(Upper(u[4][2])) == Upper(AllTrim(aEmps[I,4,2]))}) = 0

                               // aAdd(aEmpAcess,{Upper(AllTrim(aEmps[I,1])),Upper(AllTrim(aEmps[I,2])),Upper(AllTrim(aEmps[I,3])),Upper(AllTrim(aEmps[I,4])),Upper(AllTrim(aEmps[I,5]))})
                                
						 	    AADD(aEmpAcess, {   { "codEmpresa"         ,Upper(AllTrim(aEmps[I,1,2])) } ,;
													{ "grupoEmpresa"       ,Upper(AllTrim(aEmps[I,2,2]))}  ,;
													{ "empresa"            ,Upper(AllTrim(aEmps[I,3,2]))}  ,;
													{ "codFilial"          ,Upper(AllTrim(aEmps[I,4,2]))}  ,;
													{ "filial"             ,Upper(AllTrim(aEmps[I,5,2]))}  ,;
                                                    { "cnpj"               ,Upper(AllTrim(aEmps[I,6,2]))}  ,;
													{ "E-Mail"             ,cEmail} })
                            EndIf
                    Next
                Next
                
            Case cRegraGrp = '2' //Desconsidera regra por grupo
                    //CONOUT("XPLANNING - PARADA 3")
                    aEmpAcess := fBuscaEmpresas(FWUsrEmp( aUsers[nPos,2]),'',.F.,.T.)	
                            
            Case cRegraGrp = '3' //Soma regra por grupo
                //CONOUT("XPLANNING - PARADA 4")
                For J:= 1 to Len(aGrupos)					
                    aEmps := fBuscaEmpresas(FWGrpEmp(aGrupos[J]),'',.F.,.T.)
                    For I := 1 to Len(aEmps)
                        
                        If aScan(aEmpAcess, { |u| AllTrim(Upper(u[2][2])) == Upper(AllTrim(aEmps[I,1,2])) .And. AllTrim(Upper(u[4][2])) == Upper(AllTrim(aEmps[I,4,2]))}) = 0

                           // aAdd(aEmpAcess,{Upper(AllTrim(aEmps[I,1])),Upper(AllTrim(aEmps[I,2])),Upper(AllTrim(aEmps[I,3])),Upper(AllTrim(aEmps[I,4])),Upper(AllTrim(aEmps[I,5]))})
                           
						 	   	AADD(aEmpAcess, {   { "codEmpresa"         ,Upper(AllTrim(aEmps[I,1,2])) } ,;
													{ "grupoEmpresa"       ,Upper(AllTrim(aEmps[I,2,2]))}  ,;
													{ "empresa"            ,Upper(AllTrim(aEmps[I,3,2]))}  ,;
													{ "codFilial"          ,Upper(AllTrim(aEmps[I,4,2]))}  ,;
													{ "filial"             ,Upper(AllTrim(aEmps[I,5,2]))}  ,;
													{ "cnpj"               ,Upper(AllTrim(aEmps[I,6,2]))}  ,;
                                                    { "E-Mail"             ,cEmail} })
                        EndIf
                    
                    Next
                Next
                
                aEmps := fBuscaEmpresas(FWUsrEmp( aUsers[nPos,2]),'',.F.,.T.)		
                For I := 1 to Len(aEmps)
                
                    //aAdd(aEmpAcess,{Upper(AllTrim(aEmps[I,1])),Upper(AllTrim(aEmps[I,2])),Upper(AllTrim(aEmps[I,3])),Upper(AllTrim(aEmps[I,4])),Upper(AllTrim(aEmps[I,5]))})
                    If aScan(aEmpAcess, { |u| AllTrim(Upper(u[2][2])) == Upper(AllTrim(aEmps[I,1,2])) .And. AllTrim(Upper(u[4][2])) == Upper(AllTrim(aEmps[I,4,2]))}) = 0
	                            
                                AADD(aEmpAcess, {   { "codEmpresa"         ,Upper(AllTrim(aEmps[I,1,2])) } ,;
													{ "grupoEmpresa"       ,Upper(AllTrim(aEmps[I,2,2]))}  ,;
													{ "empresa"            ,Upper(AllTrim(aEmps[I,3,2]))}  ,;
													{ "codFilial"          ,Upper(AllTrim(aEmps[I,4,2]))}  ,;
													{ "filial"             ,Upper(AllTrim(aEmps[I,5,2]))}  ,;
                                                    { "cnpj"               ,Upper(AllTrim(aEmps[I,6,2]))}  ,;
                                                    { "E-Mail"             ,cEmail} })
                    EndIf
                Next
                            
        EndCase 

    EndIf

else
        aEmpAcess := {} 
        
        DbSelectArea("SM0")
        SM0->(dbGoTop())
                
        While SM0->(!EOF())
				AADD(aEmpAcess, {{ "codEmpresa"    ,SM0->M0_CODIGO } ,;
							     { "grupoEmpresa"  ,FWGrpName(SM0->M0_CODIGO)},;
                     		     { "empresa"       ,SM0->M0_NOMECOM} ,;
							     { "codFilial"     ,SM0->M0_CODFIL}  ,;
							     { "filial"        ,SM0->M0_FILIAL}  ,;
                                 { "cnpj"          ,SM0->M0_CGC   }  ,;
					             { "E-Mail"        ,cEmail} })
			
	   		SM0->(dbSkip())
	   	EndDo

Endif 

If Len(aEmpAcess) > 0
    
    //CONOUT("XPLANNING - PARADA 5")

	aObjRet :=  JsonObject():New() 
    aObjRet["empresas"]  := {}

    If cListaGrupo == "S"
        
        aGrupos := {}
        nLin    := 0

        For I := 1 to Len(aEmpAcess)

            If aScan(aGrupos, { |u| AllTrim(u[1]) == AllTrim(aEmpAcess[I,1,2])}) == 0
	        
                nLin ++    
                aAdd(aObjRet["empresas"], JsonObject():new())

                aAdd(aGrupos,{AllTrim(aEmpAcess[I][1][2]),AllTrim(aEmpAcess[I][2][2])})      

                aObjRet["empresas"][nLin]["codEmpresa"]   := AllTrim(aEmpAcess[I][1][2])
                aObjRet["empresas"][nLin]["grupoEmpresa"] := AllTrim(aEmpAcess[I][2][2])
            
            Endif            
            
        Next
        
    Else    
        For I := 1 to Len(aEmpAcess)

            aAdd(aObjRet["empresas"], JsonObject():new())
        
            aObjRet["empresas"][I][aEmpAcess[I][1][1]] := AllTrim(aEmpAcess[I][1][2])
            aObjRet["empresas"][I][aEmpAcess[I][2][1]] := AllTrim(aEmpAcess[I][2][2])
            aObjRet["empresas"][I][aEmpAcess[I][3][1]] := AllTrim(aEmpAcess[I][3][2])
            aObjRet["empresas"][I][aEmpAcess[I][4][1]] := AllTrim(aEmpAcess[I][4][2])
            aObjRet["empresas"][I][aEmpAcess[I][5][1]] := AllTrim(aEmpAcess[I][5][2])
            aObjRet["empresas"][I][aEmpAcess[I][6][1]] := AllTrim(aEmpAcess[I][6][2])
            
            
        Next
    
    Endif   

    cJson := aObjRet:toJson()
    ::setResponse(cJson)
        
else
    
	cMensagem := "Não foram localizadas empresas para o usuário informado." 
	
	cRetorno  := "{"
    cRetorno  += '"status":"erro",'
    cRetorno  += '"mensagem":"' + cMensagem + '"'
    cRetorno  += "}"
	
	::setResponse(cRetorno)
	
	FreeObj(aObjEmp)
    
 //   rpcClearenv()

Endif

Return(.T.)

*-----------------------------------------------------*
Static Function fBuscaEmpresas(aArray,cEmail,lEmp,lFil)
*-----------------------------------------------------*
Local cEmpUsr
Local cFilUsr
Local I      := 0
Local aDados := {}

For I:= 1 to Len(aArray)
	cEmpUsr:= Substr(aArray[I],1,2)
	cFilUsr:= Substr(aArray[I],3,2)

	If cEmpUsr = '@@' .And. cFilUsr = '@@' //Acesso a todas as empresas
		
        aSM0:= FwLoadSm0() 
		
        DbSelectArea("SM0")
		
        SM0->(dbGoTop())
		
        While SM0->(!EOF())
			
				AADD(aDados,    {{ "codEmpresa"    ,SM0->M0_CODIGO } ,;
							     { "grupoEmpresa"  ,FWGrpName(SM0->M0_CODIGO)},;
                     		     { "empresa"       ,SM0->M0_NOMECOM} ,;
							     { "codFilial"     ,SM0->M0_CODFIL}  ,;
							     { "filial"        ,SM0->M0_FILIAL}  ,;
                                 { "cnpj"          ,SM0->M0_CGC   }  ,;
                                 { "E-Mail"        ,cEmail} })
            
	   		SM0->(dbSkip())
	   	EndDo
	Else
        cFilUsr:= Substr(aArray[I],3,FWSizeFilial(cEmpUsr))
		Aadd(aDados,{{"codEmpresa"       ,cEmpUsr },;
                     {"grupoEmpresa"     ,FWGrpName(cEmpUsr)},;
					 {"empresa"          ,FWEmpName(cEmpUsr)},;
                     {"codFilial"        ,cFilUsr},;
                     {"filial"           ,FWFilName(cEmpUsr,cFilUsr)},;
                     { "cnpj"            ,SM0->M0_CGC   }  ,;
                     {"E-Mail"           ,cEmail }})
	 
    EndIf
Next

Return(aDados)

