$(function () {
  var $date_filter = $('#date_filter');

  $date_filter.change(function () {
    $.ajax({
      url: $(this).data('url'),
      data: { scope: $(this).val() },
      success: function (data) {
        $('.table').html(data);
      }
    })
  })
});

