function displayFields(form, customHTML) {
	// [Inicio] DisplayFields Padronizado
	form.setShowDisabledFields(true);
	form.setHidePrintLink(true);

	var atividade = getValue("WKNumState");
	var processId = getValue("WKNumProces");
	var usuario = fluigAPI.getUserService().getCurrent();

	var documentid = form.getDocumentId();

	var modo = form.getFormMode();
	customHTML.append("<script>function getWKNumState(){ return " + atividade + "; }</script>");
	customHTML.append("<script>function getFormMode(){ return '" + modo + "'; }</script>");
	customHTML.append("<script>function getUser(){ return '" + getValue("WKUser") + "'; }</script>");
	customHTML.append("<script>function getEmail(){ return '" + getValue("WKUser") + "'; }</script>");
	customHTML.append("<script>function getCompany(){ return " + getValue("WKCompany") + "; }</script>");
	customHTML.append("<script>function getMobile(){ return " + form.getMobile() + "; }</script>");
	customHTML.append("<script>function getWKNumProces(){ return " + processId + "; }</script>");

	if (modo == "ADD") {

		if (atividade == INICIO || atividade == ABERTURA) {
			form.setValue("solicitanteMatricula", usuario.getCode());
			form.setValue("nomeSolicitante", usuario.getFullName());
			form.setValue("solicitanteEmail", usuario.getEmail());

			var dataCorrente = obterDataCorrente();
			form.setValue("dataSolicitacao", dataCorrente);
		}

	}





	setaDadosAprovacao(atividade, form, usuario.getFullName(), getValue("WKUser"), modo, documentid);
	return true;

	// [Fim] DisplayFields Padronizado
}

function obterDataCorrente() {
	var dateCorrente = new Date();
	var formatoData = new java.text.SimpleDateFormat("dd/MM/yyyy");
	return formatoData.format(dateCorrente);

}

function setaDadosAprovacao(activity, form, name, userID, mode, documentid) {
	if (mode != "VIEW") {
		var dataCorrente = obterDataCorrente();

		if (activity == CONFERENCIA_SOLICITACAO_PROJETO) {

			form.setValue("codRespAnalistaProj", userID);
			form.setValue("respAnalistaProj", name);
			form.setValue("dataRespAnalistaProj", dataCorrente);

		}

		if (activity == CONFIRMACAO_ORCAMENTO_GERADO) {
			form.setValue("codRespConfirmacao", userID);
			form.setValue("respConfirmacao", name);
			form.setValue("dataRespConfirmacao", dataCorrente);

		}

		if (activity == ANALISE_ENGENHARIA) {
			form.setValue("codRespEngenharia", userID);
			form.setValue("respEngenharia", name);
			form.setValue("dataRespEngenharia", dataCorrente);

		}

		if (activity == REALIZAR_AJUSTE_ORCAMENTO) {
			form.setValue("codRespAjusteOrcamento", userID);
			form.setValue("respAjusteOrcamento", name);
			form.setValue("dataRespAjusteOrcamento", dataCorrente);

		}

		if (activity == ALCADA_APROVADORES) {
			form.setValue("codRespAprovador", userID);
			form.setValue("respAprovador", name);
			form.setValue("dataRespAprovador", dataCorrente);

		}




	}
}