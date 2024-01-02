#INCLUDE "RWMAKE.CH"
#include 'TBICONN.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "FWMVCDEF.CH"

#DEFINE nN4_FILIAL    1
#DEFINE nN4_CBASE     2
#DEFINE nN4_ITEM      3
#DEFINE nN4_TIPO      4
#DEFINE nN4_OCORR     5
#DEFINE nN4_MOTIVO    6
#DEFINE nN4_TIPOCNT   7
#DEFINE nN4_CONTA     8
#DEFINE nN4_DATA      9
#DEFINE nN4_QUANTD    10
#DEFINE nN4_VLROC1    11
#DEFINE nN4_VLROC2    12
#DEFINE nN4_VLROC3    13
#DEFINE nN4_VLROC4    14
#DEFINE nN4_VLROC5    15
#DEFINE nN4_SERIE     16
#DEFINE nN4_NOTA      17
#DEFINE nN4_VENDA     18
#DEFINE nN4_TXMEDIA   19
#DEFINE nN4_TXDEPR    20
#DEFINE nN4_CCUSTO    21
#DEFINE nN4_LOCAL     22
#DEFINE nN4_SEQ       23
#DEFINE nN4_SUBCTA    24
#DEFINE nN4_SEQREAV   25
#DEFINE nN4_CODBAIX   26
#DEFINE nN4_FILORIG   27
#DEFINE nN4_CLVL      28
#DEFINE nN4_DCONTAB   29
#DEFINE nN4_IDMOV     30
#DEFINE nN4_QUANTPR   31
#DEFINE nN4_CALCPIS   32
#DEFINE nN4_LA        33
#DEFINE nN4_ORIGEM    34
#DEFINE nN4_LP        35
#DEFINE nN4_CCUSTOT   36
#DEFINE nN4_GRUPOTR   37
#DEFINE nN4_TAXAPAD   38
#DEFINE nN4_ORIUID    39
#DEFINE nN4_TPSALDO   40
#DEFINE nN4_DIACTB    41
#DEFINE nN4_NODIA     42
#DEFINE nN4_HORA      43
#DEFINE nN4_SDOC      44

User Function LerTabN4(cEmpInfo, cFilInfo, cGrupo)
	Local cBcoProd := "MSSQL/PRODUCAO"
	Local cServer  := "10.252.15.101"     //Servidor que está configurado
	Local nPorta   := 7891
	Local cQuery   := ''
	Local nHandle  := 0
	Local aDados   := {}

	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv( cEmpInfo, cFilInfo)

	nHandle := TcLink(cBcoProd, cServer, nPorta) //realizar conexão

	If nHandle <> 0 //caso conecte, executa a query

		cQuery+= "	SELECT
		cQuery+= "		COUNT(*) OVER() AS Total,*
		cQuery+= "	FROM "+RetSqlName('SN4')+ " SN4
		cQuery+= "	INNER JOIN
		cQuery+= "	"+RetSqlName('SN1')+ " SN1 ON SN1.N1_FILIAL = SN4.N4_FILIAL
		cQuery+= "	AND SN1.N1_CBASE = SN4.N4_CBASE
		cQuery+= "	AND SN1.N1_ITEM = SN4.N4_ITEM
		cQuery+= "	INNER JOIN
		cQuery+= "	"+RetSqlName('SN3')+ " SN3 ON SN3.N3_FILIAL = SN1.N1_FILIAL
		cQuery+= "	AND SN3.N3_CBASE = SN1.N1_CBASE
		cQuery+= "	AND SN3.N3_ITEM = SN1.N1_ITEM
		cQuery+= "	WHERE
		cQuery+= "	SN1.N1_GRUPO = '"+cGrupo+"' "
		cQuery+= "	AND SN1.N1_BAIXA = ''
		cQuery+= "	AND SN4.N4_CONTA NOT IN ('1220101011','1220101012','1220101013','1220101014','1220101015','1220101018','1220101019','1220101020','1220101021','1220101022','1220101023','1220101024','1220101025','1220101026','1220101027','1220101028','1220101029','1220101030','1220101031','1220101032','1220101033','1220101034','1220101035','1220101036','1220101037','1220101038','1230101020','1230201003','1230202006','1230202007','1230202008','1230202009','1230202014','1230202016','1230204001','1230204002','1230204004','1230204005','1230204006','1230204008','1230204009','1230204010','1230204011','1230301001','1260101050','1260101053','1260101066','1260101082','1230202014','1230101017')
		cQuery+= "	AND SN1.D_E_L_E_T_ = ''
		cQuery+= "	AND SN4.D_E_L_E_T_ = ''
		cQuery+= "	AND SN3.D_E_L_E_T_ = ''
		cQuery+= "	AND SUBSTRING(SN1.N1_FILIAL, 1, 2) = '01'
		cQuery+= "	ORDER BY
		cQuery+= "	SN1.N1_FILIAL, SN4.N4_FILIAL, SN4.N4_CBASE

/* SELECT  						//query utilizada, posta aqui para fácil acesso de consulta no banco.
    COUNT(*) OVER() AS Total,*
FROM 
    SN4010 SN4
INNER JOIN 
    SN1010 SN1 ON SN1.N1_FILIAL = SN4.N4_FILIAL
    AND SN1.N1_CBASE = SN4.N4_CBASE
    AND SN1.N1_ITEM = SN4.N4_ITEM
INNER JOIN 
    SN3010 SN3 ON SN3.N3_FILIAL = SN1.N1_FILIAL
    AND SN3.N3_CBASE = SN1.N1_CBASE
    AND SN3.N3_ITEM = SN1.N1_ITEM
WHERE 
    SN1.N1_GRUPO = '0008'
    AND SN1.N1_BAIXA = ''
AND SN4.N4_CONTA NOT IN ('1220101011','1220101012','1220101013','1220101014','1220101015','1220101018','1220101019','1220101020','1220101021','1220101022','1220101023','1220101024','1220101025','1220101026','1220101027','1220101028','1220101029','1220101030','1220101031','1220101032','1220101033','1220101034','1220101035','1220101036','1220101037','1220101038','1230101020','1230201003','1230202006','1230202007','1230202008','1230202009','1230202014','1230202016','1230204001','1230204002','1230204004','1230204005','1230204006','1230204008','1230204009','1230204010','1230204011','1230301001','1260101050','1260101053','1260101066','1260101082','1230202014','1230101017')
    AND SN1.D_E_L_E_T_ = ''
    AND SN4.D_E_L_E_T_ = ''
    AND SN3.D_E_L_E_T_ = ''
    AND SUBSTRING(SN1.N1_FILIAL, 1, 2) = '01'
ORDER BY 
    SN1.N1_FILIAL, SN4.N4_FILIAL, SN4.N4_CBASE  */

		MPSysOpenQuery(cQuery,"TMPMSQ")

		While TMPMSQ->(!Eof()) //Percorrendo a query

			AADD(aDados,{; //Adicionando as informações no Array
			TMPMSQ->N4_FILIAL	,;
				TMPMSQ->N4_CBASE	,;
				TMPMSQ->N4_ITEM		,;
				TMPMSQ->N4_TIPO		,;
				TMPMSQ->N4_OCORR	,;
				TMPMSQ->N4_MOTIVO	,;
				TMPMSQ->N4_TIPOCNT	,;
				TMPMSQ->N4_CONTA	,;
				TMPMSQ->N4_DATA		,;
				TMPMSQ->N4_QUANTD	,;
				TMPMSQ->N4_VLROC1	,;
				TMPMSQ->N4_VLROC2	,;
				TMPMSQ->N4_VLROC3	,;
				TMPMSQ->N4_VLROC4	,;
				TMPMSQ->N4_VLROC5	,;
				TMPMSQ->N4_SERIE	,;
				TMPMSQ->N4_NOTA		,;
				TMPMSQ->N4_VENDA	,;
				TMPMSQ->N4_TXMEDIA	,;
				TMPMSQ->N4_TXDEPR	,;
				TMPMSQ->N4_CCUSTO	,;
				TMPMSQ->N4_LOCAL	,;
				TMPMSQ->N4_SEQ		,;
				TMPMSQ->N4_SUBCTA	,;
				TMPMSQ->N4_SEQREAV	,;
				TMPMSQ->N4_CODBAIX	,;
				TMPMSQ->N4_FILORIG	,;
				TMPMSQ->N4_CLVL		,;
				TMPMSQ->N4_DCONTAB	,;
				TMPMSQ->N4_IDMOV	,;
				TMPMSQ->N4_QUANTPR	,;
				TMPMSQ->N4_CALCPIS	,;
				TMPMSQ->N4_LA		,;
				TMPMSQ->N4_ORIGEM	,;
				TMPMSQ->N4_LP		,;
				TMPMSQ->N4_CCUSTOT	,;
				TMPMSQ->N4_GRUPOTR	,;
				TMPMSQ->N4_TAXAPAD	,;
				TMPMSQ->N4_ORIUID	,;
				TMPMSQ->N4_TPSALDO	,;
				TMPMSQ->N4_DIACTB	,;
				TMPMSQ->N4_NODIA	,;
				TMPMSQ->N4_HORA		,;
				TMPMSQ->N4_SDOC      ;
				})
			TMPMSQ->(Dbskip())
		End
	Endif

	TcUnLink(nHandle)

	RpcClearEnv()

return aDados

User Function RECPROC4() //**************FUNÇÃO QUE DEVE SER CHAMADA PARA REALIZAR A IMPORTAÇÃO**********, necessário para chamar a régua de medição de registros
	Processa({|| u_RECATF4()}, "Importando...") 
return

User Function RECATF4()
	Local nItens := 1
	Local aDados     := {}
	Local aPergs := {}
	Local cGrupo := ''
	Local cContaN4 := ''
    Local nTotal := 0


	aAdd( aPergs ,{9,"Insira o Codigo do Grupo desejado para Importação - SN4",200, 40,.T.})
	aAdd( aPergs ,{1,"Grupo:"    , Upper(Space(100))    ,"","","","",110,.T.})
	IF parambox(aPergs, "Importação de ATF",)
		cGrupo:= AllTrim(MV_PAR02)
	else
		MsgAlert("Processo cancelado","Atenção")
	endif

	aDados := StartJob( "U_LerTabN4", GetEnvServer(), .T.,cEmpAnt, cFilAnt, cGrupo) //chamada de função para ler tabela
	ProcRegua(len(aDados))
	nTotal := cValToChar(Len(aDados))
	//SetFunName('Atfa012')
	DbSelectArea('SN4')

	While nItens <= Len(aDados) //laço para percorrer Array preenchida

    IncProc("Importando Registro " + cValToChar(nItens) + " de " + nTotal)
		
		//como o campo N4_CONTA não retorna apenas conta contábil, é necessario rodar pelos 3 deParas
		cContaN4 :=  u_deParDPR(aDados[nItens, nN4_CONTA])
		If EMPTY(cContaN4)
			cContaN4 := u_deParCTB(aDados[nItens, nN4_CONTA])
			If EMPTY(cContaN4)
				cContaN4 := u_deParDPA(aDados[nItens, nN4_CONTA])
			Endif
		Endif

		IF !EMPTY(cContaN4) //se não estiver vazio, grava o registro, se não, pula.
			SN4->(RecLock( "SN4", .T. ))
			SN4->N4_FILIAL       := "0100" +SubStr(Alltrim(aDados[nItens, nN4_FILIAL]),3,2)
			SN4->N4_CBASE        := AllTrim(aDados[nItens, nN4_CBASE  ])
			SN4->N4_ITEM         := aDados[nItens, nN4_ITEM   ]
			SN4->N4_TIPO         := aDados[nItens, nN4_TIPO   ]
			SN4->N4_OCORR        := aDados[nItens, nN4_OCORR  ]
			SN4->N4_MOTIVO       := aDados[nItens, nN4_MOTIVO ]
			SN4->N4_TIPOCNT      := aDados[nItens, nN4_TIPOCNT]
			SN4->N4_CONTA        := cContaN4
			SN4->N4_DATA         := Stod(aDados[nItens, nN4_DATA])
			SN4->N4_QUANTD       := aDados[nItens, nN4_QUANTD ]
			SN4->N4_VLROC1       := aDados[nItens, nN4_VLROC1 ]
			SN4->N4_VLROC2       := aDados[nItens, nN4_VLROC2 ]
			SN4->N4_VLROC3       := aDados[nItens, nN4_VLROC3 ]
			SN4->N4_VLROC4       := aDados[nItens, nN4_VLROC4 ]
			SN4->N4_VLROC5       := aDados[nItens, nN4_VLROC5 ]
			SN4->N4_SERIE        := aDados[nItens, nN4_SERIE  ]
			SN4->N4_NOTA         := aDados[nItens, nN4_NOTA   ]
			SN4->N4_VENDA        := aDados[nItens, nN4_VENDA  ]
			SN4->N4_TXMEDIA      := aDados[nItens, nN4_TXMEDIA]
			SN4->N4_TXDEPR       := aDados[nItens, nN4_TXDEPR ]
			SN4->N4_CCUSTO       := u_deParCst(aDados[nItens, nN4_CCUSTO])
			SN4->N4_LOCAL        := aDados[nItens, nN4_LOCAL  ]
			SN4->N4_SEQ          := aDados[nItens, nN4_SEQ    ]
			SN4->N4_SUBCTA       := aDados[nItens, nN4_SUBCTA ]
			SN4->N4_SEQREAV      := aDados[nItens, nN4_SEQREAV]
			SN4->N4_CODBAIX      := aDados[nItens, nN4_CODBAIX]
			SN4->N4_FILORIG      := aDados[nItens, nN4_FILORIG]
			SN4->N4_CLVL         := aDados[nItens, nN4_CLVL   ]
			SN4->N4_DCONTAB      := StoD(aDados[nItens, nN4_DCONTAB])
			SN4->N4_IDMOV        := aDados[nItens, nN4_IDMOV  ]
			SN4->N4_QUANTPR      := aDados[nItens, nN4_QUANTPR]
			SN4->N4_CALCPIS      := aDados[nItens, nN4_CALCPIS]
			SN4->N4_LA           := aDados[nItens, nN4_LA     ]
			SN4->N4_ORIGEM       := aDados[nItens, nN4_ORIGEM ]
			SN4->N4_LP           := aDados[nItens, nN4_LP     ]
			SN4->N4_CCUSTOT      := aDados[nItens, nN4_CCUSTOT]
			SN4->N4_GRUPOTR      := aDados[nItens, nN4_GRUPOTR]
			SN4->N4_TAXAPAD      := aDados[nItens, nN4_TAXAPAD]
			SN4->N4_ORIUID       := aDados[nItens, nN4_ORIUID ]
			SN4->N4_TPSALDO      := aDados[nItens, nN4_TPSALDO]
			SN4->N4_DIACTB       := aDados[nItens, nN4_DIACTB ]
			SN4->N4_NODIA        := aDados[nItens, nN4_NODIA  ]
			SN4->N4_HORA         := aDados[nItens, nN4_HORA   ]
			SN4->N4_SDOC		 := aDados[nItens, nN4_SDOC   ]
			SN4->(MSUNLOCK())
			nItens++
		else
			nItens++
		Endif
	End

return
