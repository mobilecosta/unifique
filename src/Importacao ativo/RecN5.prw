#INCLUDE "RWMAKE.CH"
#include 'TBICONN.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "FWMVCDEF.CH"

#DEFINE nN5_FILIAL	1
#DEFINE nN5_CONTA	2
#DEFINE nN5_DATA	3
#DEFINE nN5_TIPO	4
#DEFINE nN5_VALOR1	5
#DEFINE nN5_VALOR2	6
#DEFINE nN5_VALOR3	7
#DEFINE nN5_VALOR4	8
#DEFINE nN5_VALOR5	9
#DEFINE nN5_DC		10
#DEFINE nN5_TAXA	11
#DEFINE nN5_TPSALDO	12
#DEFINE nN5_TPBEM	13

User Function LerTabN5(cEmpInfo, cFilInfo)
	Local cBcoProd := "MSSQL/PRODUCAO"
	Local cServer  := "10.252.15.101"     //Servidor que está configurado
	Local nPorta   := 7891
	Local cQuery   := ''
	Local nHandle  := 0
	Local aDados   := {}

	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv(cEmpInfo,cFilInfo)

	nHandle := TcLink(cBcoProd, cServer, nPorta) //realizar conexão

	If nHandle <> 0 //caso conecte, executa a query
		cQuery+= "SELECT *"
		cQuery+= "	FROM "+RetSqlName('SN5')+ " SN5"
		cQuery+= "	WHERE SUBSTRING(SN5.N5_FILIAL,1,2) = '01'"
		cQuery+= "	AND SN5.N5_CONTA NOT IN ('1220101011','1220101012','1220101013','1220101014','1220101015','1220101018','1220101019','1220101020','1220101021','1220101022','1220101023','1220101024','1220101025','1220101026','1220101027','1220101028','1220101029','1220101030','1220101031','1220101032','1220101033','1220101034','1220101035','1220101036','1220101037','1220101038','1230101020','1230201003','1230202006','1230202007','1230202008','1230202009','1230202014','1230202016','1230204001','1230204002','1230204004','1230204005','1230204006','1230204008','1230204009','1230204010','1230204011','1230301001','1260101050','1260101053','1260101066','1260101082','1230202014','1230101017','1220101071','1230102001','1230102002','1230102003','1230102004')
		cQuery+= "	AND SN5.D_E_L_E_T_ =''"
		cQuery+= "	ORDER BY SN5.N5_FILIAL,SN5.N5_CONTA
		MPSysOpenQuery(cQuery,"TMPMSQ")

/* SELECT Count(*) over(), * //query utilizada, posta aqui para fácil acesso de consulta no banco.
	FROM SN5010 SN5
	WHERE SUBSTRING(SN5.N5_FILIAL,1,2) = '01'
        AND SN5.N5_CONTA NOT IN ('1220101011','1220101012','1220101013','1220101014','1220101015','1220101018','1220101019','1220101020','1220101021','1220101022','1220101023','1220101024','1220101025','1220101026','1220101027','1220101028','1220101029','1220101030','1220101031','1220101032','1220101033','1220101034','1220101035','1220101036','1220101037','1220101038','1230101020','1230201003','1230202006','1230202007','1230202008','1230202009','1230202014','1230202016','1230204001','1230204002','1230204004','1230204005','1230204006','1230204008','1230204009','1230204010','1230204011','1230301001','1260101050','1260101053','1260101066','1260101082','1230202014','1230101017','1220101071','1230102001','1230102002')
	AND SN5.D_E_L_E_T_ =''
	ORDER BY SN5.N5_FILIAL,SN5.N5_CONTA, SN5.R_E_C_N_O_
 */
		While TMPMSQ->(!Eof()) //Percorrendo a query
			//Adicionando as informações no Array
			AADD(aDados,{;
				TMPMSQ->N5_FILIAL,;
				TMPMSQ->N5_CONTA,;
				TMPMSQ->N5_DATA	,;
				TMPMSQ->N5_TIPO	,;
				TMPMSQ->N5_VALOR1,;
				TMPMSQ->N5_VALOR2,;
				TMPMSQ->N5_VALOR3,;
				TMPMSQ->N5_VALOR4,;
				TMPMSQ->N5_VALOR5,;
				TMPMSQ->N5_DC	,;
				TMPMSQ->N5_TAXA	,;
				TMPMSQ->N5_TPSALDO,;
				TMPMSQ->N5_TPBEM;
				})
			TMPMSQ->(Dbskip())
		End
	Endif

	TcUnLink(nHandle)

	RpcClearEnv()

return aDados
User Function RECPROC5() //**************FUNÇÃO QUE DEVE SER CHAMADA PARA REALIZAR A IMPORTAÇÃO**********, necessário para chamar a régua de medição de registros
	Processa({|| u_RECATF5()}, "Importando...") 
return

User Function RECATF5()
	Local nItens:= 1
	Local aDados:= {}
	Local cContaN5 := ''
	Local cFili := ''
	Local nTotal

	aDados := StartJob( "U_LerTabN5", GetEnvServer(), .T.,cEmpAnt, cFilAnt)

	DbSelectArea('SN5')
	dbSetOrder(1)
	ProcRegua(len(aDados))
	nTotal := cValToChar(Len(aDados))

	While nItens <= Len(aDados) //percorre Array preenchido

		IncProc("Importando Registro " + cValToChar(nItens) + " de " + nTotal)
		cFili:= "0100" + xFilial("SN5")

		cContaN5 := u_deParCTB(aDados[nItens, nN5_CONTA]) //chamada dos dePara, verificando se o campo N5_CONTA está preenchido em algum deles.
		If EMPTY(cContaN5)
			cContaN5 := u_deParDPR(aDados[nItens, nN5_CONTA])
		Endif
		If EMPTY(cContaN5)
			cContaN5 := u_deParDPA(aDados[nItens, nN5_CONTA])
		Endif

		IF !EMPTY(cContan5) //apenas realiza a gravação de registro se houver alguma conta
			SN5->(RecLock( "SN5", .T. ))
			SN5->N5_FILIAL	:= "0100" +SubStr(Alltrim(aDados[nItens, nN5_FILIAL]),3,2)
			SN5->N5_CONTA	:= Alltrim(cContaN5)
			SN5->N5_DATA	:=StoD(aDados[nItens, nN5_DATA])
			SN5->N5_TIPO	:=aDados[nItens, nN5_TIPO	 ]
			SN5->N5_VALOR1	:=aDados[nItens, nN5_VALOR1]
			SN5->N5_VALOR2	:=aDados[nItens, nN5_VALOR2]
			SN5->N5_VALOR3	:=aDados[nItens, nN5_VALOR3]
			SN5->N5_VALOR4	:=aDados[nItens, nN5_VALOR4]
			SN5->N5_VALOR5	:=aDados[nItens, nN5_VALOR5]
			SN5->N5_DC		:=aDados[nItens, nN5_DC		 ]
			SN5->N5_TAXA	:=aDados[nItens, nN5_TAXA	 ]
			SN5->N5_TPSALDO	:=aDados[nItens, nN5_TPSALDO ]
			SN5->N5_TPBEM	:=aDados[nItens, nN5_TPBEM	 ]
			SN5->(MSUNLOCK())
			nItens++

		Else//se não tiver conta, pula o registro
			nItens++
		endif
	end
return
