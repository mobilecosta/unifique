#INCLUDE "RWMAKE.CH"
#include 'TBICONN.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "FWMVCDEF.CH"

//Setando posição das informações
#DEFINE nN1_FILIAL		1
#DEFINE nN1_CBASE		2
#DEFINE nN1_ITEM  	 	3
#DEFINE nN1_AQUISIC  	4
#DEFINE nN1_DESCRIC  	5
#DEFINE nN1_QUANTD   	6
#DEFINE nN1_CHAPA		7
#DEFINE nN1_PATRIM   	8
#DEFINE nN1_GRUPO		9
#DEFINE nN1_MARGEM   	10

#DEFINE nN1_STATUS	   	11
#DEFINE nN1_CALCPIS	   	12
#DEFINE nN1_PENHORA	   	13
#DEFINE nN1_INIAVP	   	14
#DEFINE nN1_TPAVP	   	15
#DEFINE nN1_VLAQUIS	   	16

#DEFINE nN3_FILIAL     	17
#DEFINE nN3_CBASE      	18
#DEFINE nN3_ITEM	   	19
#DEFINE nN3_TIPO	   	20
#DEFINE nN3_BAIXA	   	21
#DEFINE nN3_HISTOR     	22
#DEFINE nN3_CCONTAB	   	23
#DEFINE nN3_CUSTBEM    	24
#DEFINE nN3_CDEPREC    	25
#DEFINE nN3_CCDEPR     	26
#DEFINE nN3_CDESP	   	27
#DEFINE nN3_CCORREC    	28
#DEFINE nN3_CCUSTO     	29

#DEFINE nN3_TPSALDO		30
#DEFINE nN3_TPDEPR		31
#DEFINE nN3_AQUISIC		32
#DEFINE nN3_CALCDEP		33
#DEFINE nN3_SEQREAV		34
#DEFINE nN3_FILORIG		35
#DEFINE nN3_RATEIO		36
#DEFINE nN3_ATFCPR		37
#DEFINE nN3_INTP		38

#DEFINE nN3_DINDEPR 	39
#DEFINE nN3_VORIG1  	40
#DEFINE nN3_TXDEPR1 	41
#DEFINE nN3_VORIG2  	42
#DEFINE nN3_TXDEPR2 	43
#DEFINE nN3_VORIG3  	44
#DEFINE nN3_TXDEPR3 	45
#DEFINE nN3_VORIG4  	46
#DEFINE nN3_TXDEPR4 	47
#DEFINE nN3_VORIG5  	48
#DEFINE nN3_TXDEPR5 	49
#DEFINE nN3_VRDACM1 	50
#DEFINE nN3_SUBCCON 	51
#DEFINE nN3_SEQ			52
#DEFINE nN3_CLVLCON 	53

User Function LerTab(cEmpInfo, cFilInfo, cGrupo)
	Local cBcoProd := "MSSQL/PRODUCAO"	  //Banco selecionado
	Local cServer  := "10.252.15.101"     //Ip do banco configurado
	Local nPorta   := 7891
	Local cQuery   := ''
	Local nHandle  := 0
	Local aDados   := {}

	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv( cEmpInfo, cFilInfo)

	nHandle := TcLink(cBcoProd, cServer, nPorta) //realiza conexão com o banco

	If nHandle <> 0 //caso conecte, executa a query
		cQuery+= " SELECT *
		cQuery+= "  FROM "+RetSqlName('SN1')+ " SN1"
		cQuery+= "  INNER JOIN "+RetSqlName('SN3')+ " SN3 ON SN3.N3_FILIAL = SN1.N1_FILIAL"
		cQuery+= "  AND SN3.N3_CBASE = SN1.N1_CBASE"
		cQuery+= "  AND SN3.N3_ITEM = SN1.N1_ITEM"
		cQuery+= "  AND SN3.D_E_L_E_T_ =''"
		cQuery+= "  AND SN3.N3_DTBAIXA = '' " //Para trazer apenas os ativos
		cQuery+= "  WHERE SN1.D_E_L_E_T_ = ''"
		cQuery+= "  AND SN1.N1_GRUPO = '"+cGrupo+"' "
		cQuery+= "  AND SN1.N1_BAIXA = '' "
		cQuery+= "  AND SUBSTRING(N1_FILIAL,1,2) = '01' "
		//cQuery+= "  AND SN3.N3_CCUSTO <>'' "
		//cQuery+= "  AND SN3.N3_CDEPREC <> '' "  //retirado filtros a pedido da equipe
		//cQuery+= "  AND SN3.N3_CCDEPR <>'' "
		//cQuery+= "  AND SN3.N3_CCONTAB <> '' "
		cQuery+= "  ORDER BY SN1.N1_FILIAL,SN1.N1_CBASE,SN1.N1_ITEM,SN3.R_E_C_N_O_"

/* SELECT  count (*) over(),*
FROM SN1010 SN1
INNER JOIN SN3010 SN3 ON SN3.N3_FILIAL = SN1.N1_FILIAL AND SN3.N3_CBASE = SN1.N1_CBASE AND SN3.N3_ITEM = SN1.N1_ITEM AND SN3.D_E_L_E_T_ ='' AND SN3.N3_DTBAIXA = ''
WHERE SN1.D_E_L_E_T_ = ''
  AND SN1.N1_GRUPO = '0210'
  AND SN1.N1_BAIXA = ''
  AND SN3.N3_CCONTAB NOT IN ('1220101011','1220101012','1220101013','1220101014','1220101015','1220101018','1220101019','1220101020','1220101021','1220101022','1220101023','1220101024','1220101025','1220101026','1220101027','1220101028','1220101029','1220101030','1220101031','1220101032','1220101033','1220101034','1220101035','1220101036','1220101037','1220101038','1230101020','1230201003','1230202006','1230202007','1230202008','1230202009','1230202014','1230202016','1230204001','1230204002','1230204004','1230204005','1230204006','1230204008','1230204009','1230204010','1230204011','1230301001','1260101050','1260101053','1260101066','1260101082','1230202014','1230101017')
 AND SN3.N3_CDEPREC <> '5170101013' //O NOT in é para contas que não estão no de Para, pode ser incluso na query.
 AND SN3.N3_CCDEPR <> '1230102016'
AND SUBSTRING(N1_FILIAL,1,2) = '01'
ORDER BY SN1.N1_FILIAL,
        SN1.N1_CBASE,
         SN3.R_E_C_N_O_
 */

		MPSysOpenQuery(cQuery,"TMPMSQ")

		While TMPMSQ->(!Eof()) //Percorrendo a query

			AADD(aDados,{; //Adicionando as informações no Array
			TMPMSQ->N1_FILIAL,;
			TMPMSQ->N1_CBASE,;
			TMPMSQ->N1_ITEM,;
			TMPMSQ->N1_AQUISIC,;
			TMPMSQ->N1_DESCRIC,;
			TMPMSQ->N1_QUANTD,;
			TMPMSQ->N1_CHAPA,;
			TMPMSQ->N1_PATRIM,;
			TMPMSQ->N1_GRUPO,;
			TMPMSQ->N1_MARGEM,;
			TMPMSQ->N1_STATUS,;
			TMPMSQ->N1_CALCPIS,;
			TMPMSQ->N1_PENHORA,;
			TMPMSQ->N1_INIAVP,;
			TMPMSQ->N1_TPAVP,;
			TMPMSQ->N1_VLAQUIS,;
			TMPMSQ->N3_FILIAL,;
			TMPMSQ->N3_CBASE,;
			TMPMSQ->N3_ITEM,;
			TMPMSQ->N3_TIPO,;
			TMPMSQ->N3_BAIXA,;
			TMPMSQ->N3_HISTOR,;
			TMPMSQ->N3_CCONTAB,;
			TMPMSQ->N3_CUSTBEM,;
			TMPMSQ->N3_CDEPREC,;
			TMPMSQ->N3_CCDEPR,;
			TMPMSQ->N3_CDESP,;
			TMPMSQ->N3_CCORREC,;
			TMPMSQ->N3_CCUSTO,;
			TMPMSQ->N3_TPSALDO,;
			TMPMSQ->N3_TPDEPR,;	
			TMPMSQ->N3_AQUISIC,;
			TMPMSQ->N3_CALCDEP,;
			TMPMSQ->N3_SEQREAV,;
			TMPMSQ->N3_FILORIG,;
			TMPMSQ->N3_RATEIO,;	
			TMPMSQ->N3_ATFCPR,;	
			TMPMSQ->N3_INTP,;
			TMPMSQ->N3_DINDEPR,;
			TMPMSQ->N3_VORIG1,;
			TMPMSQ->N3_TXDEPR1,;
			TMPMSQ->N3_VORIG2,;
			TMPMSQ->N3_TXDEPR2,;
			TMPMSQ->N3_VORIG3,;
			TMPMSQ->N3_TXDEPR3,;
			TMPMSQ->N3_VORIG4,;
			TMPMSQ->N3_TXDEPR4,;
			TMPMSQ->N3_VORIG5,;
			TMPMSQ->N3_TXDEPR5,;
			TMPMSQ->N3_VRDACM1,;
			TMPMSQ->N3_SUBCCON,;
			TMPMSQ->N3_SEQ,;
			TMPMSQ->N3_CLVLCON;
				})
			TMPMSQ->(Dbskip())
		End
	Endif

	TcUnLink(nHandle)

	RpcClearEnv()

return aDados

User Function RECPROC() //**************FUNÇÃO QUE DEVE SER CHAMADA PARA REALIZAR A IMPORTAÇÃO**********, necessário para chamar a régua de medição de registros
	Processa({|| u_RecATF()}, "Importando...") 
return

User Function RecATF()

	Local nItens     := 1
	Local aDados     := {}
	Local cFiliN1	 := ''
	Local cBaseN1    :=	''
	Local cItemN1    :=	''
	Local dAquisicN1
	Local cDescricN1 := ''
	Local nQuantN1   := 0
	Local cChapaN1   := ''
	Local cPatrim    := ''
	Local cGrupo 	 := ''
	Local cCodMarg	 := ''
	Local cCBaseN3	 := ''
	Local cItemN3	 := ''
	Local cTipoN3	 := ''
	Local cTpBaixaN3 := ''
	Local cHistorN3	 := ''
	Local cContabN3	 := ''
	Local cCustoN3 	 := ''
	Local cContDprN3 := ''
	Local cCCDEPR 	 := ''
	Local cDesp 	 := ''
	Local cCorrec 	 := ''
	Local cFiliN3 := ''
	Local aPergs := {}
	Local nTotal

	aAdd( aPergs ,{9,"Insira o Codigo do Grupo desejado para Importação",200, 40,.T.})
	aAdd( aPergs ,{1,"Grupo:"    , Upper(Space(100))    ,"","","","",110,.T.})
	IF parambox(aPergs, "Importação de ATF",)
		cGrupo:= AllTrim(MV_PAR02)
	else
		MsgAlert("Processo cancelado","Atenção")
	endif //recebo a informação do grupo pedido
	aDados := StartJob( "U_LerTab", GetEnvServer(), .T.,cEmpAnt, cFilAnt, cGrupo)

	SetFunName('Atfa012')//setando a rotina que realiza o cadastro de ativos

	DbSelectArea('SN1')
	DbSelectArea('SN3')

	ProcRegua(len(aDados))
	nTotal := cValToChar(Len(aDados))

	While nItens <= Len(aDados) //primeiro laço para preenchimento na SN1
		IncProc("Importando Registro " + cValToChar(nItens) + " de " + nTotal)
		cFiliN1	   := "0100" +SubStr(Alltrim(aDados[nItens, nN1_FILIAL]),3,2)
		cBaseN1    := AllTrim(aDados[nItens, nN1_CBASE])
		cItemN1    := AllTrim(aDados[nItens, nN1_ITEM])
		dAquisicN1 := 	 StoD(aDados[nItens, nN1_AQUISIC])
		cDescricN1 :=  subStr(aDados[nItens, nN1_DESCRIC],1,TAMSX3('N1_DESCRIC')[1])
		nQuantN1   := 		  aDados[nItens, nN1_QUANTD]
		cChapaN1   := AllTrim(aDados[nItens, nN1_CHAPA])
		cPatrim    := AllTrim(aDados[nItens, nN1_PATRIM])
		cGrupo	   := u_deParGrp(aDados[nItens,nN1_GRUPO])//chamando função do dePara relacionada aos grupos
		cCodMarg   := aDados[nItens, nN1_MARGEM]

		SN1->(RecLock( "SN1", .T. ))
		SN1->N1_FILIAL :=	cFiliN1
		SN1->N1_CBASE  :=	cBaseN1
		SN1->N1_ITEM   :=	cItemN1
		SN1->N1_AQUISIC:=	dAquisicN1
		SN1->N1_DESCRIC:=	cDescricN1
		SN1->N1_QUANTD :=	nQuantN1
		SN1->N1_CHAPA  :=	cChapaN1
		SN1->N1_PATRIM :=	cPatrim
		SN1->N1_GRUPO  :=	cGrupo
		SN1->N1_MARGEM := 	cCodMarg

		SN1->N1_STATUS	:=	aDados[nItens, nN1_STATUS ]
		SN1->N1_CALCPIS	:=	aDados[nItens, nN1_CALCPIS]
		SN1->N1_PENHORA	:=	aDados[nItens, nN1_PENHORA]
		SN1->N1_INIAVP	:=	Stod(aDados[nItens, nN1_INIAVP ])
		SN1->N1_TPAVP	:=	aDados[nItens, nN1_TPAVP  ]
		SN1->N1_VLAQUIS	:=  aDados[nItens, nN1_VLAQUIS]
		SN1->(MSUNLOCK())
		cFiliN3 := "0100" +SubStr(Alltrim(aDados[nItens, nN1_FILIAL]),3,2)

		While nItens <= Len(aDados) .AND. cFiliN1 == cFiliN3 .AND. cBaseN1 == AllTrim(aDados[nItens, nN3_CBASE]) .AND. cItemN1 ==  AllTrim(aDados[nItens, nN3_ITEM])
			cCBaseN3	:= aDados[	nItens,  nN3_CBASE]//Laço para gravação na SN3
			cItemN3		:= aDados[	 nItens, nN3_ITEM]//atribuição de dados em variaveis para facilitar checagem
			cTipoN3		:= aDados[	 nItens, nN3_TIPO]
			cTpBaixaN3	:= aDados[	nItens, nN3_BAIXA]
			cHistorN3	:= AllTrim(aDados[nItens, nN3_HISTOR])
			cContabN3	:= U_deParCTB(aDados[nItens, nN3_CCONTAB])//Função para chamada do DePara referente a Conta Contabil
			IF 	EMPTY((aDados[nItens, nN3_CCUSTO]))
				cCustoN3:= '601004'
			Else
				cCustoN3 	:= u_deParCst(aDados[nItens, nN3_CCUSTO])
			Endif
			cContDprN3  := u_deParDPR(aDados[nItens, nN3_CDEPREC])//Chamada do DePara
			cCCDEPR  	:= U_deParDPA(aDados[nItens,nN3_CCDEPR])//Chamada do DePara
			cDesp 		:= aDados[nItens, nN3_CDESP	]
			cCorrec 	:= aDados[nItens, nN3_CCORREC]
			//Informação importante: Se houver algum registro que não possua o campo preenchido, o DePara não irá preencher(com exceção do N3_CCCUSTO)


			SN3->(RecLock( "SN3", .T. ))
			SN3->N3_FILIAL  :=	cFiliN3
			SN3->N3_CBASE   :=	cCBaseN3
			SN3->N3_ITEM    :=	cItemN3
			SN3->N3_TIPO    :=	cTipoN3
			SN3->N3_BAIXA   :=	cTpBaixaN3
			SN3->N3_HISTOR  :=	cHistorN3
			SN3->N3_CCONTAB :=	cContabN3

			SN3->N3_CUSTBEM :=	cCustoN3
			SN3->N3_CDEPREC :=	cContDprN3
			SN3->N3_CCDEPR  :=	cCCDEPR
			SN3->N3_CDESP   :=	cDesp
			SN3->N3_CCORREC :=	cCorrec
			SN3->N3_CCUSTO  :=	cCustoN3

			SN3->N3_TPSALDO :=	aDados[nItens, nN3_TPSALDO]
			SN3->N3_TPDEPR	:=	aDados[nItens, nN3_TPDEPR  ]
			SN3->N3_AQUISIC :=	StoD(aDados[nItens, nN3_AQUISIC ])
			SN3->N3_CALCDEP :=	aDados[nItens, nN3_CALCDEP ]
			SN3->N3_SEQREAV :=	aDados[nItens, nN3_SEQREAV ]
			SN3->N3_FILORIG :=	aDados[nItens, nN3_FILORIG ]
			SN3->N3_RATEIO	:=	aDados[nItens, nN3_RATEIO  ]
			SN3->N3_ATFCPR	:=	aDados[nItens, nN3_ATFCPR  ]
			SN3->N3_INTP	:=	aDados[nItens, nN3_INTP	   ]

			SN3->N3_DINDEPR:=	StoD(aDados[nItens, nN3_DINDEPR ])
			SN3->N3_VORIG1 :=	aDados[nItens, nN3_VORIG1 ]
			SN3->N3_TXDEPR1:=	aDados[nItens, nN3_TXDEPR1]
			SN3->N3_VORIG2 :=	aDados[nItens, nN3_VORIG2 ]
			SN3->N3_TXDEPR2:=	aDados[nItens, nN3_TXDEPR2]
			SN3->N3_VORIG3 :=	aDados[nItens, nN3_VORIG3 ]
			SN3->N3_TXDEPR3:=	aDados[nItens, nN3_TXDEPR3]
			SN3->N3_VORIG4 :=	aDados[nItens, nN3_VORIG4 ]
			SN3->N3_TXDEPR4:=	aDados[nItens, nN3_TXDEPR4]
			SN3->N3_VORIG5 :=	aDados[nItens, nN3_VORIG5 ]
			SN3->N3_TXDEPR5:=	aDados[nItens, nN3_TXDEPR5]
			SN3->N3_VRDACM1:=	aDados[nItens, nN3_VRDACM1]
			SN3->N3_SUBCCON:=	aDados[nItens, nN3_SUBCCON]
			SN3->N3_SEQ    :=	aDados[nItens, nN3_SEQ    ]
			SN3->N3_CLVLCON:=	aDados[nItens, nN3_CLVLCON]
			SN3->(MSUNLOCK())
			nItens := nItens + 1
		End
	End
	MSGINFO("Importação Concluida, Realize a Analise de dados.","Atenção")//importação concluida
return

//('AI00000163','AI00000164','AI00000165','AI00000166','AI00000168','AI00000169','AI00000616','AI00001393','AI00002499','AI00002550','AI00002551','AI00002552','AI00002554','AI00003896','AI00003897','AI00003898','AI00003899','NAJA001477','NAJA001479','NAJA001480','NAJA001481','NAJA001482','NAJA001483','NAJA001484','NAJA001485','NAJA001486','NAJA001487','NAJA001488','NAJA001489','NAJA001490','NAJA001491','NAJA001492','NAJA001493','NAJA001494','NAJA001495','NAJA001496','NAJA001497','NAJA001498','NAJA001499','NAJA001500','NAJA001502','NAJA001503','NAJA001504','NAJA001507','NAJA001508','TKNETS0077','TKNETS0078','TKNETS0080','TKNETS0081','TKNETS0082','TKNETS0083','TKNETS0084','TKNETTI064','TKNETTI065','TKNETTI066','TKNETTI067','TKNETTI068','TKNETTI069')
//Codigo dos ativos que estão com grupo em branco, analisar ^
