function enableFields(form) {
	var atividadeAtual = getValue("WKNumState");
	var fieldsEnabled = [];
	var fieldsDisabled = [];
	
	disabledFieldList(form, fieldsDisabled);
	
	enabledFieldList(form, fieldsEnabled);
}

function disableAllFields(form) {
	var fields = form.getCardData();
	var keys = fields.keySet().toArray();
	for (var k in keys) {
		var field = keys[k];
		form.setEnabled(field, false);
	}
}

function disabledFieldList(form, fields) {
	for (var i = 0; i < fields.length; i++) {
		form.setEnabled(fields[i], false);
	}
}

function enabledFieldList(form, fields) {
	for (var i = 0; i < fields.length; i++) {
		form.setEnabled(fields[i], true);
	}
}