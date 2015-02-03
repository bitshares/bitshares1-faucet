$(function () {
  var $newsletter_input = $('input[name="users[newsletter_subscribed]"]');

  $newsletter_input.on('change', function() {
    $.ajax({
      url: $(this).parents('ul').data('url'),
      data: { value: $(this).val() },
      success: function (data) {
        // todo
      },
      error: function () {
        // todo
      }
    })
  })
})
