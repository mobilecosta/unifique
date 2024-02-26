function getCurrentDate() {
	return (new java.text.SimpleDateFormat('dd/MM/yyyy')).format(new Date());
}

function getCurrentTime() {
	return (new java.text.SimpleDateFormat('HH:mm')).format(new Date());
}

function alerta(mensagem){
	
	FLUIGC.message.alert({
	    message: mensagem,
	    title: 'Atenção!',
	    label: 'OK, Entendi'
	}, function(el, ev) {
		
	});
}

function obterDataCorrente() {
	var dateCorrente = new Date();
	var formatoData = new java.text.SimpleDateFormat("dd/MM/yyyy");
	return formatoData.format(dateCorrente);
}

function obterHoraCorrente() {
	return (new java.text.SimpleDateFormat('HH:mm')).format(new Date());
}
