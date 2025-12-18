function iw_Dec2Hex(value){
	var hexVal = Number(value).toString(16); 
	hexVal =  hexVal.length == 1 ? "0" + hexVal : hexVal; 
	if(hexVal.match(/^[0-9A-Fa-f]{2}$/)){
		return hexVal.toUpperCase();
	}else{
		alert("Invalid hex number!!");
		$(this).val(0);
		$(this).focus();
		return 0;
	}
}

function iw_Hex2Dec(value){
	if (!value.match(/^[0-9A-Fa-f]{2}$/)) {
		alert("Invalid hex number!!");
		initialInputStatus(this);
		return 0;
	}
	var intVal = parseInt(value, 16);
	return intVal;
}

function bindRefInputEvent(){
	var jqEl = $(this);
	var refinput_id = jqEl.attr("refinput");
	var renderFnName = jqEl.attr("valueRenderFn");
	if(refinput_id == null){
		return;
	}
	
	var refinputJqEl = $("#"+refinput_id);
	if(refinputJqEl[0] == null){
		return;
	}
	var renderFn = null;
	if(renderFnName != null) {
		renderFn = eval("false||function(val){return " + renderFnName + ".call(this, val);}");
	}
	
	if(jQuery.isFunction(renderFn) == false){
		renderFn = function(value){ return value;};
	}
	
	if(this.type == "checkbox"){
		if(this.checked == true){
			refinputJqEl.val("ENABLE");
		}else{
			refinputJqEl.val("DISABLE")
		}
	}else if(this.tagName.toLowerCase() == 'select'){
		if(jqEl.val() != ""){
			var val = renderFn.call(jqEl[0], jqEl.val());
			refinputJqEl.val(val);
		}
	}else{
		var val = renderFn.call(jqEl[0], jqEl.val());
		refinputJqEl.val(val);
	}
}

function initialInputStatus(el){
	var jqEl = $(el);
	var type = el.type;
	var tag =  el.tagName.toLowerCase();
	var refinput_id = jqEl.attr("refinput");
	if(refinput_id == null){
		return;
	}

	var refinputJqEl = $("#"+refinput_id);
	var refinputDOMobj  = refinputJqEl[0];
	
	if(refinputJqEl[0] == null){
		return;
	}
	var renderFnName = refinputJqEl.attr("valueRenderFn");
	var renderFn = null;
	if(renderFnName != null){
		var renderFn = eval("false||function(val){return " + renderFnName + ".call(this, val);}");
	}
	
	if(jQuery.isFunction(renderFn) == false){
		renderFn = function(value){ return value;}
	}
	
	if (el.type == 'text' || el.type == 'password' || el.tagName.toLowerCase() == 'textarea') {
		jqEl.val(renderFn(refinputJqEl.val()));
		jqEl.bind("change", bindRefInputEvent);
		jqEl.trigger('change');
	}
	
	else if (el.type == "radio") {
			var val = renderFn.call(refinputJqEl[0], refinputJqEl.val());
			if (val == jqEl.attr("value")) {
				jqEl.attr("checked", true);
			}
			else {
				jqEl.attr("checked", false);
			}
			jqEl.bind("click", bindRefInputEvent);
	}else if(el.type == "checkbox"){
		 	var val = renderFn.call(refinputJqEl[0], refinputJqEl.val());
			if(val == "ENABLE"){
				jqEl.attr("checked", true);
			}else{
				jqEl.attr("checked", false);
			}
			jqEl.bind("click", bindRefInputEvent);
	}else if( el.tagName.toLowerCase() == 'select'){
		var val = renderFn.call(refinputJqEl[0], refinputJqEl.val());
		var elId = el.id;
		jqEl.val(val); //Set default selected option
		jqEl.bind("change", bindRefInputEvent);
	}
}

function initialAllInputStatus(){
	$(function(){
        $(":input").each(function(index, el){
            if (el == null) {
                return;
            }
            initialInputStatus(el);
        });
    });
}

function serialDataPackInitial(){
    initialAllInputStatus();
}


function checkRefinputDisableStatus(){
	$(":input").each(function(){
		var el = this;
		var jqEl = $(el);
		var type = el.type;
		var tag =  el.tagName.toLowerCase();
		var refinput_id = jqEl.attr("refinput");
		if(refinput_id == null){
			return;
		}
	
		var refinputJqEl = $("#"+refinput_id);
		var refinputDOMobj  = refinputJqEl[0];
		if(refinputJqEl[0] == null){
			return;
		}
		
		if(jqEl.css('display') == 'none'){
			refinputJqEl[0].disabled = true;
			return;
		}
		if(el.type == "radio"){
			if(refinputJqEl.val() == jqEl.attr("value")){
				refinputJqEl[0].disabled = el.disabled;
				return;
			}
		}else{
			refinputJqEl[0].disabled = el.disabled;
		}
	});
}
