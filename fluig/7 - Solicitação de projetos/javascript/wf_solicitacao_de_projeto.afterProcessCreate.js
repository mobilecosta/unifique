function afterProcessCreate(processId){
	//Setando número da solicitação
	var matriculaCorrente = getValue("WKUser");
	hAPI.setCardValue("numeroSolicitacao", processId);
	hAPI.setCardValue("solicitanteMatricula", matriculaCorrente);
	hAPI.setCardValue("solicitanteEmail", obterNomeUsuarioPelaMatricula(matriculaCorrente));
	hAPI.setCardValue("dataSolicitacao", obterDataCorrente() + " " + obterHoraCorrente());
}