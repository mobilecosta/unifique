window.onload = function () {
    //Seta foto do Solicitante
    $("#imgSolicitante").attr("src", "/social/api/rest/social/image/profile/" + $("#solicitanteMatricula").val() + "/SMALL_PICTURE");

}

$(document).ready(function () {
    console.log("init");
    init();
    top.$('[data-cancel-workflow-request]').hide(); 

});

// window.parent.$("#workflowActions").hide();

function init() {


    try {

        // var numSolicitacao = $("#numeroFluxo").val();
        // $("#numeroSolicitacao").val(numSolicitacao);
        // $("#btnAddNewRowArqContab").hide();


        mostraEscondeCollapse()
        binding();
        showHideCampos()
        // gerarZipAnexos()


       


    } catch (erro) {
        console.log(erro)
    }


}

function mostraEscondeCollapse() {

    var atividade = getWKNumState();


    var respConferencia = $("#respAnalistaProj").val()
    var respAjuste = $("#respAjusteOrcamento").val()


    if (atividade == INICIO || atividade == ABERTURA || atividade == REVISAO_SOLICITACAO_PROJETO) {

        if (respConferencia == "" || respConferencia == undefined) {

            $('#collapseDadosSolicitante, #collapseTipoSolicitacao, #collapseTelaExpansao, #collapseManutencao').collapse('show');

            $(".collapseConferenciaProj, .collapseConfirmacaoProj, .collapseAnaliseEng, .collapseAprovacoes, .collapseAjusteOrcamento, .collapseAlcadaAprovadores").hide()

        } else {

            $('#collapseDadosSolicitante, #collapseTipoSolicitacao, #collapseTelaExpansao, #collapseManutencao, #collapseConferenciaProj').collapse('show');

            $(".collapseConfirmacaoProj, .collapseAnaliseEng, .collapseAprovacoes, .collapseAjusteOrcamento, .collapseAlcadaAprovadores").hide()

        }


    }

    if (atividade == CONFERENCIA_SOLICITACAO_PROJETO) {

        $('#collapseDadosSolicitante, #collapseTipoSolicitacao, #collapseTelaExpansao, #collapseManutencao, #collapseConferenciaProj').collapse('show');

        $(".collapseConfirmacaoProj, .collapseAnaliseEng, .collapseAprovacoes, .collapseAjusteOrcamento, .collapseAlcadaAprovadores").hide()

    }

    if (atividade == CONFIRMACAO_ORCAMENTO_GERADO) {


        $('#collapseDadosSolicitante, #collapseTipoSolicitacao, #collapseTelaExpansao, #collapseManutencao, #collapseConferenciaProj, #collapseConfirmacaoProj').collapse('show');

        $(".collapseAnaliseEng, .collapseAprovacoes, .collapseAjusteOrcamento, .collapseAlcadaAprovadores").hide()

    }

    if (atividade == ANALISE_ENGENHARIA) {

        if (respAjuste == "" || respAjuste == undefined) {

            $('#collapseDadosSolicitante, #collapseTipoSolicitacao, #collapseTelaExpansao, #collapseManutencao, #collapseConferenciaProj, #collapseConfirmacaoProj, #collapseAnaliseEng').collapse('show');

            $(".collapseAprovacoes, .collapseAjusteOrcamento, .collapseAlcadaAprovadores").hide()

        } else {

            $('table[tablename=tblObsAprovadores] tbody tr').not(':first').remove();

            $('#collapseDadosSolicitante, #collapseTipoSolicitacao, #collapseTelaExpansao, #collapseManutencao, #collapseConferenciaProj, #collapseConfirmacaoProj, #collapseAnaliseEng, #collapseAprovacoes, #collapseAjusteOrcamento').collapse('show');

            $(".collapseAlcadaAprovadores").hide()

        }



    }

    if (atividade == ALCADA_APROVADORES) {

        if (respAjuste == "" || respAjuste == undefined) {

            $('#collapseDadosSolicitante, #collapseTipoSolicitacao, #collapseTelaExpansao, #collapseManutencao, #collapseConferenciaProj, #collapseConfirmacaoProj, #collapseAnaliseEng, #collapseAprovacoes, #collapseAlcadaAprovadores').collapse('show');

            $(".collapseAjusteOrcamento").hide()

        } else {

            $('#collapseDadosSolicitante, #collapseTipoSolicitacao, #collapseTelaExpansao, #collapseManutencao, #collapseConferenciaProj, #collapseConfirmacaoProj, #collapseAnaliseEng, #collapseAprovacoes, #collapseAjusteOrcamento, #collapseAlcadaAprovadores').collapse('show');

        }


    }

    if (atividade == REALIZAR_AJUSTE_ORCAMENTO) {


        $('#collapseDadosSolicitante, #collapseTipoSolicitacao, #collapseTelaExpansao, #collapseManutencao, #collapseConferenciaProj, #collapseConfirmacaoProj, #collapseAnaliseEng, #collapseAprovacoes, #collapseAjusteOrcamento, #collapseAlcadaAprovadores').collapse('show');

    }


}

function binding() {

    console.log("entrou binding")
    $('input[type="text"]').change(function () {
        this.value = $.trim(this.value);
    });

    var atividade = getWKNumState();

    if (atividade == INICIO || atividade == ABERTURA) {

        $('input[type=radio][name="rTipoSolicitacao"]').on('click', function () {

            if (this.value == "expansao") {

                $("#campoDescritor").val("Tela de Expansão de Rede");

                $(".collapseTelaExpansao").show();
                $(".collapseManutencao").hide();


            } else if (this.value == "manutencao") {

                $("#campoDescritor").val("Projeto de Manutenção de Rede");

                $(".collapseTelaExpansao").hide();
                $(".collapseManutencao").show();


            }

        });


        // $('input[type=radio][name="rDecisaoEng"]').on('click', function () {

        //     if (this.value == "enviar") {

        //         $("#acimaCinco").val("1")

        //     } else if (this.value == "aprovado") {

        //         $("#acimaCinco").val("")


        //     }

        // });
    }

    if (atividade == CONFIRMACAO_ORCAMENTO_GERADO) {

        // //tirar depois
        // $("#empresaZoom").attr('readonly', false)
        // $("#filialZoom").attr('readonly', false)
        // $("#zUfExpansao").attr('readonly', false)
        // $("#zCidadeExpansao").attr('readonly', false)
        // $("#zUfManutencao").attr('readonly', false)
        // $("#zCidadeManutencao").attr('readonly', false)
        // //tirar depois

        $('input[type=checkbox][name="orcamentoGerado"]').on('click', function () {

            if ($("#checkorcamentoGerado").val() == "") {

                $("#checkorcamentoGerado").val("1");

            } else {
                $("#checkorcamentoGerado").val("");
            }

        });

    }

    if (atividade == ANALISE_ENGENHARIA) {

        $('input[type=radio][name="rDecisaoEng"]').on('click', function () {

            if (this.value == "enviar") {

                $("#mandaAprovadores").val("enviar");

            } else if (this.value == "aprovado") {

                $("#mandaAprovadores").val("aprovado engenharia");

            }

        });

    }

    if (atividade == REALIZAR_AJUSTE_ORCAMENTO) {

        $('input[type=checkbox][name="cienteAjuste"]').on('click', function () {

            if ($("#checkCienteAjuste").val() == "") {

                $("#checkCienteAjuste").val("1");

            } else {
                $("#checkCienteAjuste").val("");
            }

        });

    }
}

function showHideCampos() {

    var atividade = getWKNumState();

    if (atividade != INICIO && atividade != ABERTURA && atividade != REVISAO_SOLICITACAO_PROJETO) {

        $('[name^="rTipoSolicitacao"]').attr('onclick', 'return false');

        $("#empresaZoom").attr('readonly', true)
        $("#filialZoom").attr('readonly', true)
        $("#zUfExpansao").attr('readonly', true)
        $("#zCidadeExpansao").attr('readonly', true)
        $("#zUfManutencao").attr('readonly', true)
        $("#zCidadeManutencao").attr('readonly', true)

        var tipoDoc = $("input:radio[name='rTipoSolicitacao']:checked").val()

        if (tipoDoc == "expansao") {

            $(".collapseTelaExpansao").show();
            $(".collapseManutencao").hide();

        } else if (tipoDoc == "manutencao") {

            $(".collapseTelaExpansao").hide();
            $(".collapseManutencao").show();

        }

        $('.anexoArea .btnUpFile').hide();
        $('.anexoProspect .btnUpFile').hide();
        $('.anexoKMZ .btnUpFile').hide();
        $('.anexoDocumentos .btnUpFile').hide();


    }

    if (atividade != CONFERENCIA_SOLICITACAO_PROJETO) {

        $('[name^="rDecisaoConferencia"]').attr('onclick', 'return false');

        $("#zCentroCusto").attr('readonly', true)

    }

    if (atividade != CONFIRMACAO_ORCAMENTO_GERADO) {



        $('[name^="orcamentoGerado"]').attr('onclick', 'return false');

    }

    if (atividade != ANALISE_ENGENHARIA) {

        $('[name^="rDecisaoEng"]').attr('onclick', 'return false');

    }

    if (atividade != ALCADA_APROVADORES) {

        $('[name^="rDecisaoAprovadores"]').attr('onclick', 'return false');

    }

    if (atividade != REALIZAR_AJUSTE_ORCAMENTO) {

        $('[name^="cienteAjuste"]').attr('onclick', 'return false');

    }







    if (atividade == INICIO || atividade == ABERTURA || atividade == REVISAO_SOLICITACAO_PROJETO) {

        var respConferencia = $("#respAnalistaProj").val()

        if (respConferencia == "" || respConferencia == undefined) {

            $(".collapseTelaExpansao").hide();
            $(".collapseManutencao").hide();

        } else {

            $('[name^="rTipoSolicitacao"]').attr('onclick', 'return false');

            var tipoDoc = $("input:radio[name='rTipoSolicitacao']:checked").val()

            if (tipoDoc == "expansao") {

                $(".collapseTelaExpansao").show();
                $(".collapseManutencao").hide();

            } else if (tipoDoc == "manutencao") {

                $(".collapseTelaExpansao").hide();
                $(".collapseManutencao").show();

            }

        }




        $("#numeroProspect").attr('readonly', false)
        $("#descricaoExpansao").attr('readonly', false)
        $("#descricaoManutencao").attr('readonly', false)
        $("#obsManutencao").attr('readonly', false)

    }

    if (atividade == CONFERENCIA_SOLICITACAO_PROJETO) {

        var indice = $('#tblConferencia tbody tr').length;
        indice--;

        if (indice >= 1) {

            for (var i = 1; i <= indice; i++) {
                if ($('#obsConferencia___' + i).val() != "") {

                    $("#obsConferencia___" + i).attr('readonly', true)

                } else {

                    $("#obsConferencia___" + i).attr('readonly', false)


                }

                var campo = $('#obsConferencia___' + i).val()

                if (i == indice && campo != "" && campo != undefined) {

                    wdkAddChild("tblConferencia")
                    $("#obsConferencia___" + (i + 1)).attr('readonly', false)

                }

            }

        } else {

            wdkAddChild("tblConferencia")
            $("#obsConferencia___1").attr('readonly', false)

        }

    }

    if (atividade == ANALISE_ENGENHARIA) {

        // $("#valorOrcamento").attr('readonly', false)
        $("#obsEngenharia").attr('readonly', false)

        conferirvalor()

       


    }



    if (atividade == ALCADA_APROVADORES) {

        $("#rDecisaoAprovadores_aprovado").prop("checked", false)
        $("#rDecisaoAprovadores_ajustes").prop("checked", false)
        $("#rDecisaoAprovadores_cancelar").prop("checked", false)


        if ($("#contador").val() == "1") {

            $(".necessitaAjuste").show()

        } else {

            $(".necessitaAjuste").hide()

        }


        var indice = $('#tblObservacaoAprovadores tbody tr').length;
        indice--;

        if (indice >= 1) {

            for (var i = 1; i <= indice; i++) {
                if ($('#obsAprovadores___' + i).val() != "") {

                    $("#obsAprovadores___" + i).attr('readonly', true)

                } else {

                    $("#obsAprovadores___" + i).attr('readonly', false)


                }

                var campo = $('#obsAprovadores___' + i).val()

                if (i == indice && campo != "" && campo != undefined) {

                    wdkAddChild("tblObservacaoAprovadores")
                    $("#obsAprovadores___" + (i + 1)).attr('readonly', false)

                }

            }

        } else {

            wdkAddChild("tblObservacaoAprovadores")
            $("#obsAprovadores___1").attr('readonly', false)

        }
    }

    if (atividade == REALIZAR_AJUSTE_ORCAMENTO) {

        $("#obsAjusteOrcamento").attr('readonly', false)

    }




}

function setSelectedZoomItem(selectedItem) {
    var name_item = selectedItem.inputName;

    if (name_item == "empresaZoom") {
        $("#codGrupoEmpresa").val(selectedItem.codEmpresa);
        reloadZoomFilterValues('filialZoom', 'codEmpresa,' + selectedItem.codEmpresa + ',emailSolicitante,' + 'pedro.ramos@xplanning.com.br');
        //reloadZoomFilterValues('filialZoom', 'codEmpresa,' + selectedItem.codEmpresa+ 'emailSolicitante,' + $("#solicitanteEmail").val());
    }

    if (name_item == "zUfExpansao") {
        $("#zUfExpansao").val(selectedItem.ESTADO);
        $("#codUFExpansao").val(selectedItem.ESTADO);
        var tipo = $("#zUfExpansao").val()
        reloadZoomFilterValues("zCidadeExpansao", "ESTADO," + tipo);
    }

    if (name_item == "filialZoom") {
        $("#codFilial").val(selectedItem.codFilial);
    }

    if (name_item == "zUfManutencao") {
        $("#zUfManutencao").val(selectedItem.ESTADO);
        $("#codUFManutencao").val(selectedItem.ESTADO);
        var tipo = $("#zUfManutencao").val()
        reloadZoomFilterValues("zCidadeManutencao", "ESTADO," + tipo);
    }

    if (name_item == "zCidadeExpansao") {
        $("#codCidadeExpansao").val(selectedItem.nome)
        $("#codIBGECidadeExpansao").val(selectedItem.codigo)
        var codCidade = $("#codIBGECidadeExpansao").val()
        codCidade = codCidade.substr(2)
        $("#codIBGECidadeExpansao").val(codCidade)

    }

    if (name_item == "zCidadeManutencao") {
        $("#codCidadeManutencao").val(selectedItem.nome)
        $("#codIBGECidadeManutencao").val(selectedItem.codigo)
        var codCidade = $("#codIBGECidadeManutencao").val()
        codCidade = codCidade.substr(2)
        $("#codIBGECidadeManutencao").val(codCidade)

    }

    if (name_item == "zCentroCusto") {
        codCentroCusto.value = selectedItem.CTT_CUSTO;

        existeAlcada()
    }

}


function removedZoomItem(removedItem) {
    var name_item = removedItem.inputName;


    if (name_item == "empresaZoom") {
        $("#codGrupoEmpresa").val('');
        reloadZoomFilterValues('filialZoom', 'codEmpresa, ');

    }

    if (name_item == "zUfExpansao") {
        window['zCidadeExpansao'].clear()
    }

    if (name_item == "zCentroCusto") {
        $("#codCentroCusto").val('');
    }

    if (name_item == "zUfManutencao") {
        window['zCidadeManutencao'].clear()

    }

}

jQuery(function ($) {
    $(document).on('keypress', 'input.only-number', function (e) {
        var $this = $(this);
        var key = (window.event) ? event.keyCode : e.which;
        var dataAcceptDot = $this.data('accept-dot');
        var dataAcceptComma = $this.data('accept-comma');
        var acceptDot = (typeof dataAcceptDot !== 'undefined' && (dataAcceptDot == true || dataAcceptDot == 1) ? true : false);
        var acceptComma = (typeof dataAcceptComma !== 'undefined' && (dataAcceptComma == true || dataAcceptComma == 1) ? true : false);

        if ((key > 47 && key < 58)
            || (key == 46 && dataAcceptDot)
            || (key == 44 && dataAcceptComma)) {
            return true;
        } else {
            return (key == 8 || key == 0) ? true : false;
        }
    });
});

function conferirvalor() {
   
    var orcamento =parseFloat($("#valorOrcamento").val()) 
    $("#valorOrcamentoFloat").val(orcamento)
    
    $("#valorOrcamento").val(orcamento.toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))

}



function esconde(){
    
    $(".escondeEnviar").hide()
}



function existeAlcada() {

    var rTipoSolicitacao = $("input:radio[name='rTipoSolicitacao']:checked").val()

    if (rTipoSolicitacao == "expansao") {

        var codCentroCusto = $("#codCentroCusto").val();
        var cidade = $("#codCidadeExpansao").val();
    
        var c1 = DatasetFactory.createConstraint("codCentroCusto", codCentroCusto, codCentroCusto, ConstraintType.MUST);
        var c2 = DatasetFactory.createConstraint("codCidadeExpansao", cidade, cidade, ConstraintType.MUST);
        var dataset = DatasetFactory.getDataset("dsMatrizAprovacao", null, new Array(c1, c2), null);
    
        if (dataset.values.length <= 0) {
            exibirMensagem("Este Centro de Custo + Cidade não possue Alçada de Aprovadores Cadastrada, favor cadastrar Alçada!", 'danger');
    
            window['zCentroCusto'].clear();
            $("#codCentroCusto").val("")
        } 

    } 
	
	
}

function exibirMensagem(mensagem, tipo){
	// tipos:
	// danger
	// warning
	// success
	FLUIGC.toast({
		title: '',
		message: mensagem,
		type: tipo,
		timeout: 6000
	});
}