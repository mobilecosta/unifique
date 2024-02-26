function functions() { }

function geraOrcamento() {

    var dsService = DatasetFactory.getDataset("dsServicoProtheus", null, null, null);
    var service = dsService.getValue(0, "nomeServico")

    if (hAPI.getCardValue('rTipoSolicitacao') == "expansao") {

        var codIBGECidade = hAPI.getCardValue('codIBGECidadeExpansao')
        var codUF = hAPI.getCardValue('codUFExpansao')
        var codUFCidade = codUF + codIBGECidade
        var descricao = hAPI.getCardValue('descricaoExpansao')
        var projeto = "Tela de Expansão de Rede"

    } else {

        var codIBGECidade = hAPI.getCardValue('codIBGECidadeManutencao')
        var codUF = hAPI.getCardValue('codUFManutencao')
        var codUFCidade = codUF + codIBGECidade
        var descricao = hAPI.getCardValue('descricaoManutencao')
        var projeto = "Projeto de Manutenção de Rede"

    }



    var nomeSolicitante = hAPI.getCardValue('nomeSolicitante')
    var numeroSolicitacao = hAPI.getCardValue('numeroSolicitacao')
    var centroCusto = hAPI.getCardValue('codCentroCusto')

    log.info("### UF e cidade recebido  ###" + codUFCidade)

    try {
        log.info("### INICIOU  geraOrcamento  ###")
        var clientService = fluigAPI.getAuthorizeClientService();
        var data = {
            serviceCode: service,
            endpoint: '/WSGERORC',
            method: 'post',
            timeoutService: '100',
            params: {
                "codmun": codUFCidade,
                // "codmun": "00051",
                "descricao": descricao,
                "projeto": projeto,
                "solicitante": nomeSolicitante,
                "idfluig": numeroSolicitacao,
                "centrodecusto": centroCusto
            }
        }

        log.info("### geraOrcamento  Objeto gerado  ###")
        log.dir(data)

        var envelope = JSONUtil.toJSON(data);
        var vo = clientService.invoke(envelope);
        log.dir(vo);
        var json = JSON.parse(vo.getResult());

        log.info("### geraOrcamento  Objeto Retornado  ###")
        log.dir(json)
        log.info("### geraOrcamento  Status retornado  ### - " + vo.getHttpStatusResult())

        if (vo.getHttpStatusResult() != 201) {
            log.info("### retorno está vazio")
            throw "### retorno está vazio"
        } else {

            if (json.retorno = "OK") {
                var json = JSON.parse(vo.getResult());

                if (json.orcamento == null || json.orcamento == undefined || json.orcamento == "") {
                    throw "Não foi possível obter o número do Orçamento gerado no PROTHEUS, favor comunicar a equipe de TI.";
                } else {
                    hAPI.setCardValue("orcamentoGeradoProtheus", json.orcamento);
                }

            }

        }
        return true;
    } catch (e) {
        log.info("### retorno houve um erro inesperado aquiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii " + e)
        log.dir(e)
        throw e;
    }
}

function alteraStatus(status) {
    var orcamento = hAPI.getCardValue("orcamentoGeradoProtheus");
    var dsService = DatasetFactory.getDataset("dsServicoProtheus", null, null, null);
    var service = dsService.getValue(0, "nomeServico")

    try {
        log.info("### INICIOU  alteraStatus  ###")
        var clientService = fluigAPI.getAuthorizeClientService();
        var data = {
            serviceCode: service,
            endpoint: '/WSALTSTATUS',
            method: 'post',
            timeoutService: '100',
            params: {
                "codorc": orcamento,
                "status": status
            }
        }

        log.info("### alteraStatus  Objeto gerado  ###")
        log.dir(data)

        var envelope = JSONUtil.toJSON(data);
        var vo = clientService.invoke(envelope);

        var json = JSON.parse(vo.getResult());

        var retornoJson = json
        log.info("### alteraStatus  Objeto Retornado  ###")
        log.dir(retornoJson.retorno)
        log.info("### alteraStatus  Status retornado  ### - " + vo.getHttpStatusResult())

        if (vo.getHttpStatusResult() != 201) {
            log.info("### retorno está vazio")
            throw "### retorno está vazio"
        }

        return true;
    } catch (e) {
        log.info("### retorno houve um erro inesperado aquiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii " + e)
        log.dir(e)
        throw e;
    }
}



function empenho() {
    log.info("### INICIOU  empenho  ###")
    var dsService = DatasetFactory.getDataset("dsServicoProtheus", null, null, null);
    var service = dsService.getValue(0, "nomeServico")
    var filial = hAPI.getCardValue("codFilial");
    var orcamento = hAPI.getCardValue("orcamentoGeradoProtheus");
    var centroCusto = hAPI.getCardValue('codCentroCusto')
    log.info("###  empenho  CODIGO FILIAL ###" + filial)
    log.info("###  empenho  ORCAMNETO ###" + orcamento)
    try {
        log.info("### INICIOU  empenho  ###")
        var clientService = fluigAPI.getAuthorizeClientService();
        var data = {
            serviceCode: service,
            endpoint: '/WSEMPENHO',
            method: 'post',
            timeoutService: '100',
            params: {
                "codorc": orcamento,              
                "centrodecusto": centroCusto,               
                "delempenho": true
               
              

            }
        }

        log.info("### empenho  Objeto gerado  ###")
        log.dir(data)

        var envelope = JSONUtil.toJSON(data);
        var vo = clientService.invoke(envelope);

        var json = JSON.parse(vo.getResult());

        var retornoJson = json
        log.info("### empenho  Objeto Retornado  ###")
        log.dir(retornoJson)
        log.info("### empenho  Status retornado  ### - " + vo.getHttpStatusResult())

        if (vo.getHttpStatusResult() != 201) {
            log.info("### retorno está vazio")
            throw "### retorno está vazio"
        } else {
            if (retornoJson.retorno != 'OK') {
                hAPI.setCardValue("empenhouValor", "sem saldo")
            } else {
                hAPI.setCardValue("contador", 2)
            }
        }

        return true;
    } catch (e) {
        log.info("### retorno houve um erro inesperado aquiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii " + e)
        log.dir(e)
        throw e;
    }
}

function devolveEmpenho() {
    var dsService = DatasetFactory.getDataset("dsServicoProtheus", null, null, null);
    var service = dsService.getValue(0, "nomeServico")
    var filial = hAPI.getCardValue("codFilial");
    var orcamento = hAPI.getCardValue("orcamentoGeradoProtheus");
    var centroCusto = hAPI.getCardValue('codCentroCusto')
    log.info("###  empenho  CODIGO FILIAL ###" + filial)
    log.info("###  empenho  ORCAMNETO ###" + orcamento)
    try {
        log.info("### INICIOU  devolveEmpenho  ###")
        var clientService = fluigAPI.getAuthorizeClientService();
        var data = {
            serviceCode: service,
            endpoint: '/WSALTORC',
            method: 'post',
            timeoutService: '100',
            params: {
                "codorc": orcamento, 
                "centrodecusto": centroCusto,              
                "delempenho": false

              
            }
        }

        log.info("### devolveEmpenho  Objeto gerado  ###")
        log.dir(data)

        var envelope = JSONUtil.toJSON(data);
        var vo = clientService.invoke(envelope);

        var json = JSON.parse(vo.getResult());

        var retornoJson = json
        log.info("### devolveEmpenho  Objeto Retornado  ###")
        log.dir(retornoJson)
        log.info("### devolveEmpenho  Status retornado  ### - " + vo.getHttpStatusResult())

        if (vo.getHttpStatusResult() != 201) {
            log.info("### Erro no devolver empenho protheus")
            throw "### Erro no devolver empenho protheus"
        }

        return true;
    } catch (e) {
        log.info("### retorno houve um erro inesperado aquiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii " + e)
        log.dir(e)
        throw e;
    }
}


function aprovaFormularioAlcadaFluig() {
    log.info("##[ENTROU aprovaFormularioAlcadaFluig]##");

    var indexes = hAPI.getChildrenIndexes("tblObsAprovadores");
    for (var i = 0; i < indexes.length; i++) {
        var aprovado = hAPI.getCardValue("statusAprovacao___" + indexes[i]);
        var proximoAprovador = hAPI.getCardValue("nomeAprovador___" + indexes[i + 1]); //
        log.info("##[ENTROU aprovaFormularioAlcadaFluig VER STATUS]##" + aprovado);
        log.info("##[ENTROU aprovaFormularioAlcadaFluig VER PROXIMO APROVADOR]##" + proximoAprovador);
        hAPI.setCardValue("aprovadorAtual", "");

        if (aprovado != "Aprovado") {
            log.info("##[ENTROU aprovaFormularioAlcadaFluig ENTROU NO IF APROVADO]##");
            hAPI.setCardValue("statusAprovacao___" + indexes[i], "Aprovado");
            hAPI.setCardValue("nomeAprovador___" + indexes[i], hAPI.getCardValue('respAprovador'));
            hAPI.setCardValue("dataAprovacao___" + indexes[i], obterDataHoraFormatada());
            if (proximoAprovador != "" && proximoAprovador != null) {///////alterei aqui
                log.info("##[ENTROU aprovaFormularioAlcadaFluig ENTROU NO PROXIMO APROVADOR]##");
                hAPI.setCardValue("aprovadorAtual", proximoAprovador);
                return true;
            }
        } else {
            hAPI.setCardValue("aprovadorAtual", "");
        }
    }
}

function convertStringFloat(valor) {
    log.info("##[ENTROU convertStringFloat VALOR ]## " + valor);
    valor = String(valor);

    if (valor.indexOf(',') == -1) {
    } else {
        valor = valor.split(".").join("").replace(",", ".");
    }
    valor = parseFloat(valor);
    valor = valor.toFixed(2);

    log.info("##[ENTROU convertStringFloat VALOR CONVERTIDO ]## " + valor);
    return valor;
}

function preencheAlcadaFluig() {
    log.info("##[ENTROU preencheAlcadaFluig 19]##");
    var processo = getValue("WKNumProces");
    var campos = hAPI.getCardData(processo);
    var codCentroCusto = campos.get("codCentroCusto");
    var cidade = campos.get("zCidadeExpansao");
    // var valorOrcamento = convertStringFloat(campos.get("valorOrcamento"));
    var valorOrcamento = campos.get("valorOrcamentoFloat");

    log.info("##[ENTROU preencheAlcadaFluig RETORNOS DO FORMULARIO]##");
    log.info("CIDADE: " + cidade);
    log.info("CC: " + codCentroCusto);
    log.info("VALOR: " + valorOrcamento);

    var constraints = [];
    var sortingFields = [];
    var fields = [];

    constraints.push(DatasetFactory.createConstraint("zCidadeExpansao", cidade, cidade, ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("codCentroCusto", codCentroCusto, codCentroCusto, ConstraintType.MUST));
    try {
        var dataset = DatasetFactory.getDataset("dsMatrizAprovacao", fields, constraints, sortingFields);
    } catch (erro) {
        log.info(erro);
    }

    log.info("##[ENTROU preencheAlcadaFluig RETORNO DO DATASET]##");
    log.dir(dataset)
    log.dir(dataset.rowsCount)
    if (dataset.rowsCount == 0) {
        throw "SEM FLUXO DE APROVAÇÃO |" + codCentroCusto + '|' + cidade;
    } else {
        var valorNivelUm = parseFloat(dataset.getValue(0, "valorMaximoUmFloat"));
        var valorNivelUmDois = parseFloat(dataset.getValue(0, "valorMaximoUmDoisFloat"));
        var valorNivelUmTres = parseFloat(dataset.getValue(0, "valorMaximoUmTresFloat"));

        var valorNivelDois = parseFloat(dataset.getValue(0, "valorMaximoDoisFloat"));
        var valorNivelTres = parseFloat(dataset.getValue(0, "valorMaximoTresFloat"));
        var valorNivelQuatro = parseFloat(dataset.getValue(0, "valorMaximoQuatroFloat"));

        log.info("##[preencheAlcadaFluig aprovadorAtual]## - " + valorNivelUm);

        log.info("##[preencheAlcadaFluig aprovadorAtual valorNivelUm]## - " + valorNivelUm);
        log.info("##[preencheAlcadaFluig aprovadorAtual valorNivelDois]## - " + valorNivelDois);
        log.info("##[preencheAlcadaFluig aprovadorAtual valorNivelTres]## - " + valorNivelTres);
        log.info("##[preencheAlcadaFluig aprovadorAtual valorNivelQuatro]## - " + valorNivelQuatro);
        log.info("##[preencheAlcadaFluig aprovadorAtual valorOrcamento]## - " + valorOrcamento);


        log.info("##[preencheAlcadaFluig ENTROU NO IF]##");
        var childData1 = new java.util.HashMap();
        hAPI.setCardValue("aprovadorAtual", dataset.getValue(0, "codAprovadorUm"));

        childData1.put("nomeAprovador", dataset.getValue(0, "codAprovadorUm"));
        childData1.put("valorAlcada", dataset.getValue(0, "valorMaximoUm"));
        hAPI.addCardChild("tblObsAprovadores", childData1);

        if (valorNivelUmDois <= valorOrcamento) {

            var childData1 = new java.util.HashMap();
            childData1.put("nomeAprovador", dataset.getValue(0, "codAprovadorUmDois"));
            childData1.put("valorAlcada", dataset.getValue(0, "valorMaximoUmDois"));
            hAPI.addCardChild("tblObsAprovadores", childData1);
    
        }

        if (valorNivelUmTres <= valorOrcamento) {

            var childData1 = new java.util.HashMap();
            childData1.put("nomeAprovador", dataset.getValue(0, "codAprovadorUmTres"));
            childData1.put("valorAlcada", dataset.getValue(0, "valorMaximoUmTres"));
            hAPI.addCardChild("tblObsAprovadores", childData1);

        }      

        if (valorNivelDois <= valorOrcamento) {

            var childData1 = new java.util.HashMap();
            childData1.put("nomeAprovador", dataset.getValue(0, "codAprovadorDois"));
            childData1.put("valorAlcada", dataset.getValue(0, "valorMaximoDois"));
            hAPI.addCardChild("tblObsAprovadores", childData1);

        }
        if (valorNivelTres <= valorOrcamento) {

            var childData1 = new java.util.HashMap();
            childData1.put("nomeAprovador", dataset.getValue(0, "codAprovadorTres"));
            childData1.put("valorAlcada", dataset.getValue(0, "valorMaximoTres"));
            hAPI.addCardChild("tblObsAprovadores", childData1);

        }
        if (valorNivelQuatro <= valorOrcamento) {

            var childData1 = new java.util.HashMap();
            childData1.put("nomeAprovador", dataset.getValue(0, "codAprovadorQuatro"));
            childData1.put("valorAlcada", dataset.getValue(0, "valorMaximoQuatro"));
            hAPI.addCardChild("tblObsAprovadores", childData1);

        }
    }

    //throw "TESTE DE ENTRADA|" + centroCusto + '|' + cidade + '|' + valo;
}

function preencheAlcadaProtheus() {
    //var centroDecusto = campos.get("codCentroCusto");
    //var valor = parseFloat(campos.get("valorOrcamento"));
    // var dsService = DatasetFactory.getDataset("dsServicoProtheus", null, null, null);
    // var service = dsService.getValue(0, "nomeServico")

    //testes
    var centroDecusto = "401003";
    //testes
    var valorOrcamento = convertStringFloat(hAPI.getCardValue("valorOrcamento"));

    try {
        log.info("### INICIOU  alcada  ###")
        var clientService = fluigAPI.getAuthorizeClientService();
        var data = {
            serviceCode: "Protheus 8401",
            endpoint: '/WSRALCADA?FIL=01&TIPO=PRJ&CCUSTO=' + centroDecusto,
            method: 'get',
            timeoutService: '100',
        }

        log.info("### alcada  Objeto gerado  ###")
        log.dir(data)

        var envelope = JSONUtil.toJSON(data);
        var vo = clientService.invoke(envelope);

        var json = JSON.parse(vo.getResult());

        var retornoJson = json.ALCADA

        log.info("### alcada  Objeto Retornado  ###")
        log.dir(retornoJson)
        log.info("### alcada  Status retornado  ### - " + vo.getHttpStatusResult())

        if (vo.getHttpStatusResult() != 200) {
            log.info("### retorno está vazio")
            throw "### retorno está vazio"
        }
        else {
            hAPI.setCardValue("aprovadorAtual", retornoJson[0].LOGIN);
            for (i = 0; i < retornoJson.length; i++) {
                var childData = new java.util.HashMap();
                childData.put("aprovadorAtual", retornoJson[i].LOGIN);
                log.info("### retorno LOGIN" + retornoJson[i].LOGIN)
                log.info("### retorno LIMITE_MAXIMO" + retornoJson[i].LIMITE_MAXIMO)
                if (retornoJson[i].LIMITE_MINIMO <= valorOrcamento) {
                    var childData1 = new java.util.HashMap();
                    childData1.put("nomeAprovador", retornoJson[i].LOGIN);
                    childData1.put("valorAlcada", "0");
                    hAPI.addCardChild("tblObsAprovadores", childData1);
                }
            }

        }
        return true;
    } catch (e) {
        log.info("### retorno houve um erro inesperado aquiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii " + e)
        log.dir(e)
        throw e;
    }
}

function obterDataHoraFormatada() {
    var data = new Date();
    var dia = ("0" + data.getDate()).slice(-2);
    var mes = ("0" + (data.getMonth() + 1)).slice(-2);
    var ano = data.getFullYear();
    //var hora = ("0" + data.getHours()).slice(-2);
    //var minuto = ("0" + data.getMinutes()).slice(-2);
    //var segundo = ("0" + data.getSeconds()).slice(-2);
    //var dataHora = ""+dia+"/"+mes+"/"+ano+" "+hora+":"+minuto+":"+segundo;
    var dataHora = "" + dia + "/" + mes + "/" + ano;
    return dataHora;
}

function Reprovar() {

    if ((hAPI.getCardValue("contador") == "1" && hAPI.getCardValue("rDecisaoAprovadores") == "cancelar") || (hAPI.getCardValue("contador") != "1" && hAPI.getCardValue("rDecisaoAprovadores") == "cancelar")) {
        log.info("##[ENTROU cancelamento do processo]##");

        var indexes = hAPI.getChildrenIndexes("tblObsAprovadores");
        for (var i = 0; i < indexes.length; i++) {
            if (hAPI.getCardValue("statusAprovacao___" + indexes[i]) != "Aprovado") {
                log.info("##[ENTROU cancelamento do processo ENTROU NO IF REPROVADO]##");
                hAPI.setCardValue("statusAprovacao___" + indexes[i], "Reprovado");
                hAPI.setCardValue("nomeAprovador___" + indexes[i], hAPI.getCardValue('respAprovador'));
                hAPI.setCardValue("dataAprovacao___" + indexes[i], obterDataHoraFormatada());
                return true
            }
        }
    }

}

