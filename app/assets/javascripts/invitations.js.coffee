# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
	$(document).bind 'cocoon:after-insert', (e, inserted_item) ->
	   	$(inserted_item).find('input[type=text]:first').focus()

	$('form.invitation').on 'ajax:beforeSend', '[data-remote=true]', (event, xhr, settings) ->
		settings.url += "&filter=" + $('.showing').val()
		# //$('.invitations_container').html('<span class="loading"></span>')
	$('form.invitation').on 'ajax:complete', '[data-remote=true]', (event) ->
		setTimeout ->
			$('.loading', '.invitations_container').remove()
		, 100

	$('.showing').change ->
		$.ajax({
			url: '/invitations', 
			data: { filter: $('.showing').val() },
			beforeSend: (jqXHR, settings) ->
		  		# //$('.invitations_container').html('<span class="loading"></span>')
		})

	$(document).on 'click', '.check_all', () ->
		$('#invitations input[name*="invitation_"], .check_all').prop('checked', this.checked)

	$(document).on 'change', '#invitation_email_type', () ->
		if $(this).val() == "custom"
			$('.custom_email').show()
		else
			$('.custom_email').hide()

	$('select.rsvp_status').change ->
		# Check if they are mean

		if $.inArray(parseInt($(this).val()), rsvp_mean_values) >= 0
			alert 'Hey, you big meanie!'

		anyone_coming = false
		$('select.rsvp_status').each ->
			if $.inArray(parseInt($(this).val()), rsvp_attending_values) >= 0
				anyone_coming = true
				return
			
		$('.address').toggle(anyone_coming)