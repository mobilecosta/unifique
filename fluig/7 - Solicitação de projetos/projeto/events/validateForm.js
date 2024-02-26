function validateForm(form) {

	var atividadeAtual = getValue("WKNumState");
	var proximaAtividade = getValue("WKNextState");
	var msgErro = "";

	if (atividadeAtual == ABERTURA || atividadeAtual == INICIO || atividadeAtual == REVISAO_SOLICITACAO_PROJETO) {

		if (campoVazio(form, "empresaZoom")) {
			msgErro += "<li>Empresa</li>";
		}

		if (campoVazio(form, "filialZoom")) {
			msgErro += "<li>Filial</li>";
		}

		if (campoVazio(form, "rTipoSolicitacao")) {
			msgErro += "<li>Tipo Solicitacao</li>";
		}

		if (form.getValue("rTipoSolicitacao") == "expansao") {

			if (campoVazio(form, "zUfExpansao")) {
				msgErro += "<li>UF</li>";
			}

			if (campoVazio(form, "zCidadeExpansao")) {
				msgErro += "<li>Cidade</li>";
			}

			if (campoVazio(form, "fnArea")) {
				msgErro += "<li>Área</li>";
			}

			if (form.getValue("fnProspect") != "") {

				if (campoVazio(form, "numeroProspect")) {
					msgErro += "<li>Qtd. Prospect</li>";
				}

			}

			if (campoVazio(form, "descricaoExpansao")) {
				msgErro += "<li>Descrição</li>";
			}

		} else if (form.getValue("rTipoSolicitacao") == "manutencao") {

			if (campoVazio(form, "zUfManutencao")) {
				msgErro += "<li>UF</li>";
			}

			if (campoVazio(form, "zCidadeManutencao")) {
				msgErro += "<li>Cidade</li>";
			}

			if (campoVazio(form, "descricaoManutencao")) {
				msgErro += "<li>Descrição</li>";
			}

			if (campoVazio(form, "fnKMZ")) {
				msgErro += "<li>KMZ</li>";
			}

		}


	}

	if (atividadeAtual == CONFERENCIA_SOLICITACAO_PROJETO) {

		

		if (campoVazio(form, "rDecisaoConferencia")) {
			msgErro += "<li>Decisão</li>";
		}

		if (form.getValue("rDecisaoConferencia") == "ajuste") {

			var tblConferencia = form.getChildrenIndexes("tblConferencia");

			if (tblConferencia.length <= 0) {

				if (campoVazio(form, "obsConferencia___1")) {
					msgErro += "<li> Observações " + "</li>";
				}

			} else {
				log.dir("entrou else");
				log.info('<------teste----> >tblConferencia.length ' + tblConferencia.length)

				for (var i = 0; i < tblConferencia.length; i++) {
					log.info('<------teste----> > tblConferencia[i] ' + tblConferencia[i])
					var obsConferencia = form.getValue("obsConferencia___" + tblConferencia[i]);
					if (obsConferencia == null || obsConferencia == "") {
						msgErro += "<li>Observação " + (i + 1) + "</li>";
					}

				}

			}

		}else{

			if (campoVazio(form, "zCentroCusto")) {
				msgErro += "<li>Centro de Custo</li>";
			}
	

		}

	}

	if (atividadeAtual == CONFIRMACAO_ORCAMENTO_GERADO) {

		// OPÇÃO ENCONTRADA PARA VALIDAR CHECKBOX, verificar a metodologia do validate pra este campo com o cliente

		if (campoVazio(form, "checkorcamentoGerado")) {
			msgErro += "<li>Checkbox 'Ciente do Orçamento gerado'" + "</li>";
		}

		// OPÇÃO ENCONTRADA PARA VALIDAR CHECKBOX, verificar a metodologia do validate pra este campo com o cliente

	}

	if (atividadeAtual == ANALISE_ENGENHARIA) {

		if (campoVazio(form, "valorOrcamento")) {
			msgErro += "<li>Valor</li>";
		}

		if (form.getValue("acimaCinco") == "") {

			if (campoVazio(form, "rDecisaoEng")) {
				msgErro += "<li>Decisão</li>";
			}

		}

	}

	if (atividadeAtual == ALCADA_APROVADORES) {

		if (campoVazio(form, "rDecisaoAprovadores")) {
			msgErro += "<li>Decisão</li>";
		}

		if (form.getValue("rDecisaoAprovadores") == "ajustes" || form.getValue("rDecisaoAprovadores") == "cancelar") {

			var tblObservacaoAprovadores = form.getChildrenIndexes("tblObservacaoAprovadores");

			if (tblObservacaoAprovadores.length <= 0) {

				if (campoVazio(form, "obsAprovadores___1")) {
					msgErro += "<li> Observações " + "</li>";
				}

			} else {
				log.dir("entrou else");
				log.info('<------teste----> >tblObservacaoAprovadores.length ' + tblObservacaoAprovadores.length)

				for (var i = 0; i < tblObservacaoAprovadores.length; i++) {
					log.info('<------teste----> > tblObservacaoAprovadores[i] ' + tblObservacaoAprovadores[i])
					var obsAprovadores = form.getValue("obsAprovadores___" + tblObservacaoAprovadores[i]);
					if (obsAprovadores == null || obsAprovadores == "") {
						msgErro += "<li>Observação " + (i + 1) + "</li>";
					}

				}

			}

		}

	}

	if (atividadeAtual == REALIZAR_AJUSTE_ORCAMENTO) {

		// OPÇÃO ENCONTRADA PARA VALIDAR CHECKBOX, verificar a metodologia do validate pra este campo com o cliente

		if (campoVazio(form, "checkCienteAjuste")) {
			msgErro += "<li>Checkbox 'Ciente da Solicitação de Ajuste'" + "</li>";
		}

		// OPÇÃO ENCONTRADA PARA VALIDAR CHECKBOX, verificar a metodologia do validate pra este campo com o cliente

	}



	if (msgErro != "") {
		msgErro = "<ul>" + msgErro + "</ul>";
		exibirMensagem(form, "Favor informar os campos <b>obrigatórios:</b><br/>" + msgErro);
	}

}


function campoVazio(form, fieldname) {
	if ((form.getValue(fieldname) == null) || (form.getValue(fieldname) == undefined) || (form.getValue(fieldname).trim() == "")) {
		return true;
	} // if
	return false;
} // campoVazio


function exibirMensagem(form, mensagem) {
	var mobile = form.getMobile() != null && form.getMobile();

	if (mobile) {
		throw mensagem;
	} else {
		throw "<div class='alert alert-warning' role='alert'>" +
		"<strong>Atenção:</strong> " + mensagem +
		"</div>" +
		"<i class='fluigicon fluigicon-tag icon-sm'></i> <font style='font-weight: bold'>Dúvidas?</font> Entre em contato com o departamento de TI.";
	} // else if

} // exibirMensagem

