function beforeStateEntry(sequenceId) {
    if (sequenceId == 108) {
        if (hAPI.getCardValue("rDecisaoAprovadores") == "aprovado") {
            aprovaFormularioAlcadaFluig()
        }
    }
    if (sequenceId == 116) {
        Reprovar()
    }

    if (sequenceId == 218) {
        log.info("##[ENTROU NA 19]##");
        log.info("##[RETORNO DO CAMPO]## - " + hAPI.getCardValue("rTipoSolicitacao"));

        //preencheAlcadaProtheus()
        var enviaAprovadores = hAPI.getCardValue('mandaAprovadores')

        if (enviaAprovadores == "enviar") {

            if (hAPI.getCardValue("rTipoSolicitacao") == "expansao") {
                log.info("##[ENTROU NA 19 preencheAlcadaFluig]##");
                preencheAlcadaFluig()
            } else {
                log.info("##[ENTROU NA 19 preencheAlcadaProtheus]##");
                preencheAlcadaProtheus()
            }
        }
    }
}