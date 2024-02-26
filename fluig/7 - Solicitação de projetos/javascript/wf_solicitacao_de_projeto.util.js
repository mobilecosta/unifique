function obterNomeUsuarioPelaMatricula(matricula){
	if (matricula == null || matricula == undefined || matricula == "undefined" || matricula.trim() == ""){
		return "";
	} // if
	var c1 = DatasetFactory.createConstraint("colleaguePK.colleagueId", matricula, matricula, ConstraintType.MUST);
	var filtros = new Array(c1);
	var dsUsuario = DatasetFactory.getDataset("colleague", null, filtros, null);
	if (dsUsuario.rowsCount > 0){
		return dsUsuario.getValue(0, "colleagueName");
	} else {
		return "";
	}
} 

function obterLoginUsuarioPelaMatricula(matricula){
	if (matricula == null || matricula == undefined || matricula == "undefined" || matricula.trim() == ""){
		return "";
	} // if
	var c1 = DatasetFactory.createConstraint("colleaguePK.colleagueId", matricula, matricula, ConstraintType.MUST);
	var filtros = new Array(c1);
	var dsUsuario = DatasetFactory.getDataset("colleague", null, filtros, null);
	if (dsUsuario.rowsCount > 0){
		return dsUsuario.getValue(0, "login");
	} else {
		return "";
	}
}

// function obterEmailUsuarioPelaMatricula(matricula){
// 	if (matricula == null || matricula == undefined || matricula == "undefined" || matricula.trim() == ""){
// 		return "";
// 	} // if
// 	var c1 = DatasetFactory.createConstraint("colleaguePK.colleagueId", matricula, matricula, ConstraintType.MUST);
// 	var filtros = new Array(c1);
// 	var dsUsuario = DatasetFactory.getDataset("colleague", null, filtros, null);
// 	if (dsUsuario.rowsCount > 0){
// 		return dsUsuario.getValue(0, "mail");
// 	} else {
// 		return "";
// 	}
// }

function obterDataCorrente() {
	var dateCorrente = new Date();
	var formatoData = new java.text.SimpleDateFormat("dd/MM/yyyy");
	return formatoData.format(dateCorrente);
}

function obterHoraCorrente() {
	return (new java.text.SimpleDateFormat('HH:mm')).format(new Date());
}
