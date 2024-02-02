/*
    - Função altera a fase do projeto baseado no valor orçado e realizado.
    - Quando o valor orçado for maior que o realizado, prosseguir com o processo até finalizar e devolver o saldo no final.
        - Ex: Valor OR->200.000.00 x Valor Realizado 150.000.00, devolver os 50.000.00, quando o projeto
for para a Fase de Termino.
    - Quando for orçado o valor menor que o realizado,não prosseguir com o processo, bloquear para não seguir de fase, até que seja aprovado o saldo complementar do mesmo, ou seja o orçamento deve ser enviado para a alçada de aprovação.
*/

USER FUNCTION PMA200GRV(cCusto, cDescri)
    Local cRetorno := ""

    If cCusto == ""
        cRetorno := "Centro de custo não informado."
        Return cRetorno
    Endif

    // Verifica se o centro de custo já existe
    lExiste := .F.
    
    DbSelectArea("CTT")
    DbSetOrder(1)
    
    If DbSeek(xFilial("CTT") + cCusto)
        cDescri := CTT->CTT_DESC01
        lExiste := .T.
    Endif  

    // Se a descrição não foi informada, retorna erro
    If cDescri == ""
        cRetorno := "Falha ao cadastrar centro de custo. Descrição não informada."
        Return cRetorno
    Endif

    // Se não existir, cria o centro de custo
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
