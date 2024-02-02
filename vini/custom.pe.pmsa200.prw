/*
    - Fun��o altera a fase do projeto baseado no valor or�ado e realizado.
    - Quando o valor or�ado for maior que o realizado, prosseguir com o processo at� finalizar e devolver o saldo no final.
        - Ex: Valor OR->200.000.00 x Valor Realizado 150.000.00, devolver os 50.000.00, quando o projeto
for para a Fase de Termino.
    - Quando for or�ado o valor menor que o realizado,n�o prosseguir com o processo, bloquear para n�o seguir de fase, at� que seja aprovado o saldo complementar do mesmo, ou seja o or�amento deve ser enviado para a al�ada de aprova��o.
*/

USER FUNCTION PMA200GRV(cCusto, cDescri)
    Local cRetorno := ""

    If cCusto == ""
        cRetorno := "Centro de custo n�o informado."
        Return cRetorno
    Endif

    // Verifica se o centro de custo j� existe
    lExiste := .F.
    
    DbSelectArea("CTT")
    DbSetOrder(1)
    
    If DbSeek(xFilial("CTT") + cCusto)
        cDescri := CTT->CTT_DESC01
        lExiste := .T.
    Endif  

    // Se a descri��o n�o foi informada, retorna erro
    If cDescri == ""
        cRetorno := "Falha ao cadastrar centro de custo. Descri��o n�o informada."
        Return cRetorno
    Endif

    // Se n�o existir, cria o centro de custo
    If !lExiste
        cInsertCTTQuery := "INSERT INTO CTT (CTT_FILIAL, CTT_CUSTO, CTT_DESC01) VALUES (" + xFilial("CTT") + ", '" + cCusto + "', '" + cDescri + "')"

        If SqlQuery(cInsertCTTQuery)
            lExiste := .T.
        Else
            cRetorno := "Falha ao cadastrar centro de custo."
            Return cRetorno
        Endif
    Endif

Return cRetorno
