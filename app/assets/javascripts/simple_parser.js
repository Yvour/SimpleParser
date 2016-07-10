// Written by I. Urvanov in the name of Sir Walter Scott
function show_model_info(data) {

	if (data.model_params) {
		var txt = '';
		var cnt = 0;
		txt = '<tr class = "info_name"><th class>Name</th><td colspan = 2>' + data.model + ' ' + data.brand + '</td></tr>'
		for (var key in data.model_params) {
			txt += '<tr class= "info_string' + (cnt % 2) + '"><th class = "info_group" rowspan = ' + data.model_params[key].length + '>' + key + '</th>';
			txt += '<td>' + data.model_params[key][0].name + '</td><td>' + data.model_params[key][0].value + '</td>';
			txt += '</tr>';
			cnt++;
			for (var i = 1; i < data.model_params[key].length; i++) {
				var class_name = 'info_string' + (cnt % 2);
				txt += '<tr class  = "' + class_name + '">';
				txt += '<td>' + data.model_params[key][i].name + '</td><td>' + data.model_params[key][i].value + '</td>';
				txt += '</tr>';
				cnt++;
			}
		}//of key in
		txt = '<table border><tbody>' + txt + '</tbody></table>';
		$('.model_info').html(txt);
		$('.model_info').scrollTop(0);

	}
}


$(document).ready(function() {
	var ajax_prefix = location.origin + '/simple_parser/search?params=';
	$('.search_start').on('click', function() {
		var query_text = $('.query_text')[0].value;
		if (true) {
			//$('.model_info').html('');
			$('.search_results').html("Searching....");
			var req_obj = {
				mode : 'search_by_query',
				query : query_text
			};
			$.ajax({
				url : ajax_prefix + JSON.stringify(req_obj),
				success : function(data) {

					var txt = '';
					var classes = ['odd_result', 'even_result'];
					for (var i = 0; i < data.length; i++) {

						txt += '<tr class = "tr_result ' + classes[i % 2] + '"';
						txt += ' data-model = "' + data[i].name + '" ';
						txt += ' data-brand = "' + data[i].brand + '" ';
						txt += '>';
						txt += '<td>' + data[i].name + '</td><td>' + data[i].brand + '</td></tr>';
					}
					txt = '<table class = "tbl_result"><tbody>' + txt + '</tbody></table>';

					$('.search_results').html(txt);
					$('.tr_result').on('click', function(event) {
						var brand = $(event.currentTarget).data('brand');
						var model = $(event.currentTarget).data('model');
						//$('.model_info').html("Getting information..");

						req_obj = {
							mode : 'get_model_info',
							model : model,
							brand : brand
						}
						$.ajax({
							url : ajax_prefix + JSON.stringify(req_obj),
							success : show_model_info

						})
					});
				}//of success
			});
		}
	});
	$('.select_model').on('change', function() {
		var model = $('.select_model')[0].value;
		var brand = $('.select_brand')[0].value;
		if ((model.length > 0) && (brand.length > 0)) {
			$('.model_info').html('');
			//$('.search_results').html('');
			req_obj = {
				mode : 'get_model_info',
				model : model,
				brand : brand
			}
			$.ajax({
				url : ajax_prefix + JSON.stringify(req_obj),
				success : show_model_info
			})
		}
	});

	$('.select_brand').on('change', function() {
		var brand = $('.select_brand')[0].value;
		$('.select_model').html('');
		$('.model_info').html('');

		if (brand.length > 0) {

			var req_obj = {
				mode : 'get_models_by_brand',
				brand : brand
			};

			$.ajax({
				url : ajax_prefix + JSON.stringify(req_obj),
				success : function(data) {
					data.unshift({
						name : ''
					});
					$('.select_phone').html('');
					for (var i = 0; i < data.length; i++) {
						$('.select_model').append('<option value = "' + data[i].name + '">' + data[i].name + '</option>');
					}
				}
			});
		}
	});
	$.ajax({
		url : ajax_prefix + '{"mode":"get_brands"}',
		success : function(data) {
			data.unshift({
				name : ''
			});
			for (var i = 0; i < data.length; i++) {
				$('.select_brand').append('<option value = "' + data[i].name + '">' + data[i].name + '</option>');
			}
		}
	})
})